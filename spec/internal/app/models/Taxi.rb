class Taxi < ActiveRecord::Base
  acts_as_bookable preset: 'taxi'
end
