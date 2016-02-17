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

        #
        # Convert options (Date to Time)
        #
        options[:time_start] = options[:time_start].to_time if options[:time_start].present?
        options[:time_end] = options[:time_end].to_time if options[:time_end].present?
        options[:time] = options[:time].to_time if options[:time].present?

        # Return true if everything's ok
        true
      end

      private
        ##
        # Set the options
        #
        def set_options
          # The default preset is 'room'
          self.booking_opts[:preset]

          defaults = nil

          # Validates options
          permitted_options = {
            time_type: [:range, :fixed, :none],
            capacity_type: [:open, :closed, :none],
            preset: [:room,:event,:show],
            bookable_across_occurrences: [true, false]
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
          when :room
            defaults = {
              time_type: :range,      # time_start is check-in, time_end is check-out
              capacity_type: :closed,  # capacity is closed: after the first booking the room is not bookable anymore, even though the capacity has not been reached
              bookable_across_occurrences: true # a room is bookable across recurrences: if a recurrence is daily, a booker must be able to book from a date to another date, even though time_start and time_end falls in different occurrences of the schedule
            }
          # Event preset (e.g. a birthday party)
          when :event
            defaults = {
              time_type: :none,       # time is ininfluent for booking an event.
              capacity_type: :open,    # capacity is open: after a booking the event is still bookable until capacity is reached.
              bookable_across_occurrences: false # an event is not bookable across recurrences
            }
          # Show preset (e.g. a movie)
          when :show
            defaults = {
              time_type: :fixed,      # time is fixed: a user chooses the time of the show (the show may have a number of occurrences)
              capacity_type: :open,    # capacity is open: after a booking the show is still bookable until capacity is reached
              bookable_across_occurrences: false # a show is not bookable across recurrences
            }
          else
            defaults = {
              time_type: :none,
              capacity_type: :none,
              bookable_across_occurrences: false
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
        # validates options
        self.validate_booking_options!(opts)

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
          time_check_ok = true
          # If it's bookable across recurrences, just check start time and end time
          if self.booking_opts[:bookable_across_occurrences]
            # Check start time
            if !(ActsAsBookable::TimeUtils.time_in_schedule?(self.schedule, opts[:time_start]))
              time_check_ok = false
            end
            # Check end time
            if !(ActsAsBookable::TimeUtils.time_in_schedule?(self.schedule, opts[:time_end]))
              time_check_ok = false
            end
          # If it's not bookable across recurrences, check if the whole interval is included in an occurrence
          else
            # Check the whole interval
            if !(ActsAsBookable::TimeUtils.interval_in_schedule?(self.schedule, opts[:time_start], opts[:time_end]))
              time_check_ok = false
            end
          end
          # If something went wrong
          unless time_check_ok
            raise ActsAsBookable::AvailabilityError.new ActsAsBookable::T.er('.availability.unavailable_interval', model: self.class.to_s, time_start: opts[:time_start], time_end: opts[:time_end])
          end
        end
        if self.booking_opts[:time_type] == :fixed
          if !(ActsAsBookable::TimeUtils.time_in_schedule?(self.schedule, opts[:time]))
            raise ActsAsBookable::AvailabilityError.new ActsAsBookable::T.er('.availability.unavailable_time', model: self.class.to_s, time: opts[:time])
          end
        end

        ##
        # Real capacity check (calculated with overlapped bookings)
        #
        overlapped = ActsAsBookable::Booking.overlapped(self, opts)
        # If capacity_type is :closed cannot book if already booked (no matter if amount < capacity)
        if (self.booking_opts[:capacity_type] == :closed && !overlapped.empty?)
          raise ActsAsBookable::AvailabilityError.new ActsAsBookable::T.er('.availability.already_booked', model: self.class.to_s)
        end
        # if capacity_type is :open, check if amount <= maximum amount of overlapped booking
        if (self.booking_opts[:capacity_type] == :open && !overlapped.empty?)
          # if time_type is :range, split in sub-intervals and check the maximum sum of amounts against capacity for each sub-interval
          if (self.booking_opts[:time_type] == :range)
            # Map overlapped bookings to a set of intervals with amount
            intervals = overlapped.map { |e| {time_start: e.time_start, time_end: e.time_end, amount: e.amount} }
            # Make subintervals from overlapped bookings and check capacity for each of them
            ActsAsBookable::TimeUtils.subintervals(intervals) do |a,b,op|
              case op
              when :open
                res = {amount: a[:amount] + b[:amount]}
              when :close
                res = {amount: a[:amount] - b[:amount]}
              end
              raise ActsAsBookable::AvailabilityError.new ActsAsBookable::T.er('.availability.already_booked', model: self.class.to_s) if (res[:amount] > self.capacity)
              res
            end
          # else, just sum the amounts (fixed times are not intervals and they overlap if are the same)
          else
            if(overlapped.sum(:amount) + opts[:amount] > self.capacity)
              raise ActsAsBookable::AvailabilityError.new ActsAsBookable::T.er('.availability.already_booked', model: self.class.to_s)
            end
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
      # Accept a booking by a booker. This is an alias method,
      # equivalent to @booker.book!(@bookable, opts)
      #
      # @param booker The booker model
      # @param opts The booking options
      #
      # Example:
      #   @room.be_booked!(@user, from: Date.today, to: Date.tomorrow, amount: 2)
      def be_booked!(booker, opts={})
        booker.book!(self, opts)
      end

      ##
      # Check if options passed for booking this Bookable are valid
      #
      # @raise ActsAsBookable::OptionsInvalid if options are not valid
      # @param opts The booking options
      #
      def validate_booking_options!(opts)
        self.class.validate_booking_options!(opts)
      end

      def booker?
        self.class.booker?
      end
    end
  end
end
