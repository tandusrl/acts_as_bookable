require 'active_record'
require 'active_record/version'
require 'active_support/core_ext/module'
require_relative 'acts_as_bookable/engine'  if defined?(Rails)
require 'ice_cube'
IceCube.compatibility = 12 # Drop compatibility for :start_date, avoiding a bunch of warnings caused by serialization

module ActsAsBookable
  extend ActiveSupport::Autoload

  autoload :Bookable
  autoload :Booker
  autoload :Booking
  autoload :T
  autoload :VERSION
  autoload :TimeHelpers

  autoload_under 'bookable' do
    autoload :Core
  end

  class InitializationError < StandardError
    def initialize model, message
      super "Error initializing acts_as_bookable on #{model.to_s} - " + message
    end
  end

  class OptionsInvalid < StandardError
    def initialize model, message
      super "Error validating options for #{model.to_s} - " + message
    end
  end

  class AvailabilityError < StandardError
  end
end

ActiveSupport.on_load(:active_record) do
  extend ActsAsBookable::Bookable
  include ActsAsBookable::Booker
end
