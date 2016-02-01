module ActsAsBookable
  #
  # Booking model. Store in database bookings made by bookers on bookables
  #
  class Booking < ::ActiveRecord::Base
    # #TODO, remove from 4.0.0
    # attr_accessible :tag,
    #                 :tag_id,
    #                 :context,
    #                 :taggable,
    #                 :taggable_type,
    #                 :taggable_id,
    #                 :tagger,
    #                 :tagger_type,
    #                 :tagger_id if defined?(ActiveModel::MassAssignmentSecurity)
    #
    # belongs_to :tag, class_name: '::ActsAsTaggableOn::Tag', counter_cache: ActsAsTaggableOn.tags_counter
    belongs_to :bookable, polymorphic: true
    belongs_to :booker,   polymorphic: true
    #
    # scope :owned_by, ->(owner) { where(tagger: owner) }
    # scope :not_owned, -> { where(tagger_id: nil, tagger_type: nil) }
    #
    # scope :by_contexts, ->(contexts = ['tags']) { where(context: contexts) }
    # scope :by_context, ->(context= 'tags') { by_contexts(context.to_s) }
    #
    validates_presence_of :bookable
    validates_presence_of :booker
    validate :bookable_must_be_bookable, :booker_must_be_booker

    #
    # validates_presence_of :context
    # validates_presence_of :tag_id
    #
    # validates_uniqueness_of :tag_id, scope: [:taggable_type, :taggable_id, :context, :tagger_id, :tagger_type]
    #
    # after_destroy :remove_unused_tags
    #
    private

      def bookable_must_be_bookable
        if bookable.present? && !bookable.class.bookable?
          errors.add(:bookable, T.er('booking.bookable_must_be_bookable', model: bookable.class.to_s))
        end
      end

      def booker_must_be_booker
        if booker.present? && !booker.class.booker?
          errors.add(:booker, T.er('booking.booker_must_be_booker', model: booker.class.to_s))
        end
      end

    # def remove_unused_tags
    #   if ActsAsTaggableOn.remove_unused_tags
    #     if ActsAsTaggableOn.tags_counter
    #       tag.destroy if tag.reload.taggings_count.zero?
    #     else
    #       tag.destroy if tag.reload.taggings.count.zero?
    #     end
    #   end
    # end
  end
end
