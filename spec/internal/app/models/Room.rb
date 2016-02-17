class Room < ActiveRecord::Base
  acts_as_bookable preset: :room
end
