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
          # has_many_with_taggable_compatibility :owned_taggings,
          #                                      opts.merge(
          #                                          as: :booker,
          #                                          dependent: :destroy,
          #                                          class_name: '::ActsAsBookable::Tagging'
          #                                      )
          #
          # has_many_with_taggable_compatibility :owned_bookings,
          #                                      through: :owned_taggings,
          #                                      source: :tag,
          #                                      class_name: '::ActsAsBookable::Tag',
          #                                      uniq: true
        end

        include ActsAsBookable::Booker::InstanceMethods
        extend ActsAsBookable::Booker::SingletonMethods
      end

      def booker?
        false
      end
    end

    module InstanceMethods
      # ##
      # # Tag a taggable model with bookings that are owned by the booker.
      # #
      # # @param taggable The object that will be tagged
      # # @param [Hash] options An hash with options. Available options are:
      # #               * <tt>:with</tt> - The bookings that you want to
      # #               * <tt>:on</tt>   - The context on which you want to tag
      # #
      # # Example:
      # #   @user.tag(@photo, :with => "paris, normandy", :on => :locations)
      # def tag(taggable, opts={})
      #   opts.reverse_merge!(force: true)
      #   skip_save = opts.delete(:skip_save)
      #   return false unless taggable.respond_to?(:is_taggable?) && taggable.is_taggable?
      #
      #   fail 'You need to specify a tag context using :on' unless opts.key?(:on)
      #   fail 'You need to specify some bookings using :with' unless opts.key?(:with)
      #   fail "No context :#{opts[:on]} defined in #{taggable.class}" unless opts[:force] || taggable.tag_types.include?(opts[:on])
      #
      #   taggable.set_owner_tag_list_on(self, opts[:on].to_s, opts[:with])
      #   taggable.save unless skip_save
      # end
      def book(bookable, opts={})
        
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
