module ActsAsBookable
  ##
  # Booking model. Store in database bookings made by bookers on bookables
  #
  class Booking < ::ActiveRecord::Base
    self.table_name = 'acts_as_bookable_bookings'

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
        query = DBUtils.time_comparison(query,'time','=',opts[:time])
      end
      if(opts[:time_start].present?)
        query = DBUtils.time_comparison(query,'time_end', '>=', opts[:time_start])
      end
      if(opts[:time_end].present?)
        query = DBUtils.time_comparison(query,'time_start', '<', opts[:time_end])
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
