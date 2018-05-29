module ActsAsBookable
  module Bookable

    def bookable?
      false
    end

    ##
    # Make a model bookable
    #
    # Example:
    #   class Room < ActiveRecord::Base
    #     acts_as_bookable
    #   end
    def acts_as_bookable(options={})
      bookable(options)
    end

    private

    # Make a model bookable
    def bookable(options)

      if bookable?
        self.booking_opts = options
      else
        class_attribute :booking_opts
        self.booking_opts = options
        capacity_as = if booking_opts && !booking_opts[:capacity_as].nil?
                        booking_opts[:capacity_as]
                      else
                        :capacity
                      end

        class_eval do
          serialize :schedule, IceCube::Schedule

          has_many :bookings, as: :bookable, dependent: :destroy, class_name: '::ActsAsBookable::Booking'

          validates_presence_of :schedule, if: :schedule_required?
          validates_presence_of capacity_as, if: :capacity_required?
          validates_numericality_of capacity_as, if: :capacity_required?, only_integer: true, greater_than_or_equal_to: 0

          def self.bookable?
            true
          end

          def schedule_required?
            booking_opts && booking_opts && booking_opts[:time_type] != :none
          end

          def capacity_required?
            booking_opts && booking_opts[:capacity_type] != :none
          end
        end
      end

      include Core
    end
  end
end
