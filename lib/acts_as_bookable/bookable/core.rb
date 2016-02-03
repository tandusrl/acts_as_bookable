module ActsAsBookable::Bookable
  module Core
    def self.included(base)
      base.extend ActsAsBookable::Bookable::Core::ClassMethods

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

        # Switch :date_type
        case self.booking_opts[:date_type]
        # when :range, we need :from_date and :to_date
        when :range
          required_params[:from_date] = Date
          required_params[:to_date] = Date
          unpermitted_params << :date
        when :fixed
          required_params[:date] = Date
          unpermitted_params << :from_date
          unpermitted_params << :to_date
        when :none
          unpermitted_params << :from_date
          unpermitted_params << :to_date
          unpermitted_params << :date
        end

        # Switch :time_type
        case self.booking_opts[:time_type]
        # when :range, we need :from_time and :to_time
        when :range
          required_params[:from_time] = Time
          required_params[:to_time] = Time
          unpermitted_params << :time
        when :fixed
          required_params[:time] = Time
          unpermitted_params << :from_time
          unpermitted_params << :to_time
        when :none
          unpermitted_params << :from_time
          unpermitted_params << :to_time
          unpermitted_params << :time
        end

        # Switch :location_type
        case self.booking_opts[:location_type]
        # when :range, we need :from_location and :to_location
        when :range
          required_params[:from_location] = String
          required_params[:to_location] = String
          unpermitted_params << :location
        when :fixed
          required_params[:location] = String
          unpermitted_params << :from_location
          unpermitted_params << :to_location
        when :none
          unpermitted_params << :from_location
          unpermitted_params << :to_location
          unpermitted_params << :location
        end

        # Switch :capacity_type
        case self.booking_opts[:capacity_type]
        when :closed
          required_params[:amount] = Integer
        when :open
          required_params[:amount] = Integer
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
          .select{ |k,v| options.has_key?(k) && !options[k].is_a?(v) }
          .map{ |k,v| "'#{k}' must be a '#{v.to_s}' but '#{options[k].class.to_s}' found" }
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

      def bookable(options={})
        super(options)
        initialize_acts_as_bookable_core
      end

      private
        ##
        # Set the options
        #
        def set_options
          # The default preset is 'room'
          self.booking_opts[:preset] ||= 'room'

          defaults = nil

          case self.booking_opts[:preset]
          # Room preset
          when 'room'
            defaults = {
              date_type: :range,      # from_date is check-in, to_date is check-out
              time_type: :none,       # time is ininfluent for booking: users book for the whole day
              location_type: :none,   # location is ininfluent for booking: users book a room which already is located somewhere
              capacity_type: :closed  # capacity is closed: after the first booking the room is not bookable anymore, even though the capacity has not been reached
            }
          # Event preset (e.g. a birthday party)
          when 'event'
            defaults = {
              date_type: :none,       # date is ininfluent for booking. An event has already a date set and users have no choice.
              time_type: :none,       # time is ininfluent for booking. An event has a range of times, but users have no choice.
              location_type: :none,   # location is ininfluent
              capacity_type: :open    # capacity is open: after a booking the event is still bookable until capacity is reached.
            }
          # Show preset (e.g. a movie)
          when 'show'
            defaults = {
              date_type: :fixed,      # date is fixed: a user chooses the exact date of a show
              time_type: :fixed,      # time is fixed: a user chooses the time of the show
              location_type: :none,   # location is ininfluent
              capacity_type: :open    # capacity is open: after a booking the show is still bookable until capacity is reached
            }
          # # TODO: implement this.
          # # Table preset (e.g. restaurant)
          # when 'table'
          #   defaults = {
          #     date_type: :fixed,      # date is fixed: a user chooses the exact date
          #     time_type: :range,      #
          #     location_type: :none,
          #     capacity_type: :closed
          #   }
          # Car preset (e.g. car sharing)
          when 'taxi'
            defaults = {
              date_type: :fixed,      # Date is fixed. For car sharing the user chooses the exact date
              time_type: :fixed,      # Time is fixed. User chooses starting time of car sharing
              location_type: :range,  # Location is range. User chooses the starting location and the ending location
              capacity_type: :closed  # capacity is closed: after the first booking the car is not bookable anymore, even though the capacity has not been reached
            }
          else
            raise ActsAsBookable::InitializationError.new(self, "#{self.booking_opts[:preset]} is not a valid preset")
          end

          self.booking_opts.reverse_merge!(defaults)
        end
    end
  end
end
