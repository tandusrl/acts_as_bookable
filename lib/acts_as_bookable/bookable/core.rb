module ActsAsBookable::Bookable
  module Core
    def self.included(base)
      base.extend ActsAsBookable::Bookable::Core::ClassMethods
      base.send :include, ActsAsBookable::Bookable::Core::InstanceMethods

      base.initialize_acts_as_bookable_core
    end

    module ClassMethods
      ##
      # Initialize the core of Bookable
      #
      def initialize_acts_as_bookable_core
        # Manage the options
        set_options
      end

      ##
      # Check if options passed for booking this Bookable are valid
      #
      # @raise ActsAsBookable::OptionsInvalid if options are not valid
      #
      def validate_booking_options!(options)
        unpermitted_params = []
        required_params = {}

        #
        # Set unpermitted parameters and required parameters depending on Bookable options
        #

        # Switch :time_type
        case self.booking_opts[:time_type]
        # when :range, we need :time_start and :time_end
        when :range
          required_params[:time_start] = [Time,Date]
          required_params[:time_end] = [Time,Date]
          unpermitted_params << :time
        when :fixed
          required_params[:time] = [Time,Date]
          unpermitted_params << :time_start
          unpermitted_params << :time_end
        when :none
          unpermitted_params << :time_start
          unpermitted_params << :time_end
          unpermitted_params << :time
        end

        # Switch :capacity_type
        case self.booking_opts[:capacity_type]
        when :closed
          required_params[:amount] = [Integer]
        when :open
          required_params[:amount] = [Integer]
        when :none
          unpermitted_params << :amount
        end

        #
        # Actual validation
        #
        unpermitted_params = unpermitted_params
          .select{ |p| options.has_key?(p) }
          .map{ |p| "'#{p}'"}
        wrong_types = required_params
          .select{ |k,v| options.has_key?(k) && (v.select{|type| options[k].is_a?(type)}.length == 0) }
          .map{ |k,v| "'#{k}' must be a '#{v.join(' or ')}' but '#{options[k].class.to_s}' found" }
        required_params = required_params
          .select{ |k,v| !options.has_key?(k) }
          .map{ |k,v| "'#{k}'" }

        #
        # Raise OptionsInvalid if some invalid parameters were found
        #
        if unpermitted_params.length + required_params.length + wrong_types.length > 0
          message = ""
          message << " unpermitted parameters: #{unpermitted_params.join(',')}." if (unpermitted_params.length > 0)
          message << " missing parameters: #{required_params.join(',')}." if (required_params.length > 0)
          message << " parameters type mismatch: #{wrong_types.join(',')}" if (wrong_types.length > 0)
          raise ActsAsBookable::OptionsInvalid.new(self, message)
        end

        # Return true if everything's ok
        true
      end

      private
        ##
        # Set the options
        #
        def set_options
          # The default preset is 'room'
          self.booking_opts[:preset] ||= 'room'

          defaults = nil

          # Validates options
          permitted_options = {
            time_type: [:range, :fixed, :none],
            capacity_type: [:open, :closed, :none],
            preset: ['room','event','show']
          }
          self.booking_opts.each_pair do |key, val|
            if !permitted_options.has_key? key
              raise ActsAsBookable::InitializationError.new(self, "#{key} is not a valid option")
            elsif !permitted_options[key].include? val
              raise ActsAsBookable::InitializationError.new(self, "#{val} is not a valid value for #{key}. Allowed values are: #{permitted_options[key]}")
            end
          end

          case self.booking_opts[:preset]
          # Room preset
          when 'room'
            defaults = {
              time_type: :range,      # time_start is check-in, time_end is check-out
              capacity_type: :closed  # capacity is closed: after the first booking the room is not bookable anymore, even though the capacity has not been reached
            }
          # Event preset (e.g. a birthday party)
          when 'event'
            defaults = {
              time_type: :none,       # time is ininfluent for booking an event.
              capacity_type: :open    # capacity is open: after a booking the event is still bookable until capacity is reached.
            }
          # Show preset (e.g. a movie)
          when 'show'
            defaults = {
              time_type: :fixed,      # time is fixed: a user chooses the time of the show (the show may have a number of occurrences)
              capacity_type: :open    # capacity is open: after a booking the show is still bookable until capacity is reached
            }
          else
            defaults = {
              time_type: :none,
              capacity_type: :open
            }
          end

          # Merge options with defaults
          self.booking_opts.reverse_merge!(defaults)
        end
    end

    module InstanceMethods
      ##
      # Check availability of current bookable, raising an error if the bookable is not available
      #
      # @param opts The booking options
      # @return true if the bookable is available for given options
      # @raise ActsAsBookable::AvailabilityError if the bookable is not available for given options
      #
      # Example:
      #   @room.check_availability!(from: Date.today, to: Date.tomorrow, amount: 2)
      def check_availability!(opts)
        # Capacity check (done first because it doesn't require additional queries)
        if self.booking_opts[:capacity_type] != :none
          # Amount > capacity
          if opts[:amount] > self.capacity
            raise ActsAsBookable::AvailabilityError.new ActsAsBookable::T.er('.availability.amount_gt_capacity', model: self.class.to_s)
          end
        end

        ##
        # Time check
        #
        if self.booking_opts[:time_type] == :range
          available = false
          query_start = opts[:time_start].to_time
          query_end = opts[:time_end].to_time
          query_duration = (query_end - query_start).seconds
          if self.schedule.occurring_between?(query_start, query_end) && self.schedule.occurring_at?(query_start) && self.schedule.occurring_at?(query_end)
            query_duration = (query_end - query_start).seconds
            first_occurrence_remaining_duration = self.schedule.next_occurrence(query_start) + self.schedule.duration - query_start
            binding.pry
            if(query_duration < first_occurrence_remaining_duration)
              available = true
            end
          end
          if !available
            raise ActsAsBookable::AvailabilityError.new ActsAsBookable::T.er('.availability.unavailable_time', model: self.class.to_s, time_start: query_start, time_end: query_end)
          end
        end

        ##
        # Real capacity check (calculated with overlapped bookings)
        # TODO: improve this
        #
        overlapped = ActsAsBookable::Booking.overlapped(self, opts)
        # If capacity_type is :closed cannot book if already booked (no matter if amount < capacity)
        if (self.booking_opts[:capacity_type] == :closed && !overlapped.empty?)
          raise ActsAsBookable::AvailabilityError.new ActsAsBookable::T.er('.availability.already_booked', model: self.class.to_s)
        end
        # if capacity_type is :open, check if amount <= maximum amount of overlapped booking
        if (self.booking_opts[:capacity_type] == :open && !overlapped.empty?)
          if(overlapped.sum(:amount) + opts[:amount] > self.capacity)
            raise ActsAsBookable::AvailabilityError.new ActsAsBookable::T.er('.availability.already_booked', model: self.class.to_s)
          end
        end
        true
      end

      ##
      # Check availability of current bookable
      #
      # @param opts The booking options
      # @return true if the bookable is available for given options, otherwise return false
      #
      # Example:
      #   @room.check_availability!(from: Date.today, to: Date.tomorrow, amount: 2)
      def check_availability(opts)
        begin
          check_availability!(opts)
        rescue ActsAsBookable::AvailabilityError
          false
        end
      end

      ##
      # Book a bookable. This is an alias method,
      # equivalent to @booker.book!(@bookable, opts)
      #
      # @param booker The booker model
      # @param opts The booking options
      #
      # Example:
      #   @room.book!(@user, from: Date.today, to: Date.tomorrow, amount: 2)
      def book!(booker, opts)
        booker.book!(self, opts)
      end

      ##
      # Check if options passed for booking this Bookable are valid
      #
      # @raise ActsAsBookable::OptionsInvalid if options are not valid
      # @param opts The booking options
      #
      def validate_booking_options!(opts)
        self.validate_booking_options!(opts)
      end

      def booker?
        self.class.booker?
      end
    end
  end
end
