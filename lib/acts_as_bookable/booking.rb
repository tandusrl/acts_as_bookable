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

      # Date options
      if(opts[:date].present?)
        query = query.where(date: opts[:date])
      end
      if(opts[:from_date].present?)
        query = query.where('from_date >= ?', opts[:from_date])
      end
      if(opts[:to_date].present?)
        query = query.where('to_date <= ?', opts[:to_date])
      end

      # Time options
      if(opts[:time].present?)
        query = query.where(time: opts[:time])
      end
      if(opts[:from_time].present?)
        query = query.where('from_time >= ?', opts[:from_time])
      end
      if(opts[:to_time].present?)
        query = query.where('to_time <= ?', opts[:to_time])
      end

      # Location options
      if(opts[:location].present?)
        query = query.where(location: opts[:location])
      end
      if(opts[:from_location].present?)
        query = query.where(from_location: opts[:from_location])
      end
      if(opts[:to_location].present?)
        query = query.where(to_location: opts[:to_location])
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
