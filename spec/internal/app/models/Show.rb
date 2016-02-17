class Show < ActiveRecord::Base
  acts_as_bookable preset: :show
end
