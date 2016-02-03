module ActsAsBookable
  module Booker
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      ##
      # Make a model a booker. This allows an instance of a model to claim ownership
      # of bookings.
      #
      # Example:
      #   class User < ActiveRecord::Base
      #     acts_as_booker
      #   end
      def acts_as_booker(opts={})
        class_eval do
          has_many :bookings, as: :booker, dependent: :destroy, class_name: '::ActsAsBookable::Booking'
        end

        include ActsAsBookable::Booker::InstanceMethods
        extend ActsAsBookable::Booker::SingletonMethods
      end

      def booker?
        false
      end
    end

    module InstanceMethods
      ##
      # Book a bookable model
      #
      # @param bookable The resource that will be booked
      # @return The booking created
      # @raise ActiveRecord::RecordInvalid if trying to create an invalid booking
      # @raise ActsAsBookable::OptionsInvalid if opts are not valid for given bookable
      #
      # Example:
      #   @user.book!(@room)
      def book!(bookable, opts={})
        # validates options
        bookable.class.validate_booking_options!(opts) if bookable.class.bookable?

        # create the new booking
        booking = ActsAsBookable::Booking.create!(booker: self, bookable: bookable)

        # reload the bookable to make changes available
        bookable.reload
        booking
      end

      def booker?
        self.class.booker?
      end
    end

    module SingletonMethods
      def booker?
        true
      end
    end
  end
end