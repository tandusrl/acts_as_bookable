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
      #
      # Example:
      #   @user.book!(@room)
      def book!(bookable)
        booking = ActsAsBookable::Booking.create!(booker: self, bookable: bookable)
        bookable.reload
        booking
      end

      ##
      # Book a bookable Model
      #
      # @param bookable The resource that will be booked
      # @return The booking created, or false in case of errors
      #
      # Example:
      #   @user.book(@room)
      def book(bookable)
        begin
          book!(bookable)
        rescue ActiveRecord::RecordInvalid => er
          false
        end
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
