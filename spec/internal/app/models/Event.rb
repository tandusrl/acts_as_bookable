class Event < ActiveRecord::Base
  acts_as_bookable preset: :event
end
