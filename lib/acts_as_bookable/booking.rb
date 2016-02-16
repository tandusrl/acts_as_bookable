module ActsAsBookable
  ##
  # Booking model. Store in database bookings made by bookers on bookables
  #
  class Booking < ::ActiveRecord::Base
    belongs_to :bookable, polymorphic: true
    belongs_to :booker,   polymorphic: true

    validates_presence_of :bookable
    validates_presence_of :booker
    validate  :bookable_must_be_bookable,
              :booker_must_be_booker

    ##
    # Retrieves overlapped bookings, given a bookable and some booking options
    #
    scope :overlapped, ->(bookable,opts) {
      query = where(bookable_id: bookable.id)

      # Time options
      if(opts[:time].present?)
        query = query.where(time: opts[:time].to_time)
      end
      if(opts[:time_start].present?)
        query = query.where('time_end >= ?', opts[:time_start].to_time)
      end
      if(opts[:time_end].present?)
        query = query.where('time_start < ?', opts[:time_end].to_time)
      end
      query
    }

    private
      ##
      # Validation method. Check if the bookable resource is actually bookable
      #
      def bookable_must_be_bookable
        if bookable.present? && !bookable.class.bookable?
          errors.add(:bookable, T.er('booking.bookable_must_be_bookable', model: bookable.class.to_s))
        end
      end

      ##
      # Validation method. Check if the booker model is actually a booker
      #
      def booker_must_be_booker
        if booker.present? && !booker.class.booker?
          errors.add(:booker, T.er('booking.booker_must_be_booker', model: booker.class.to_s))
        end
      end
  end
end
