require 'active_record'
require 'active_record/version'
require 'active_support/core_ext/module'

require_relative 'acts_as_bookable/engine'  if defined?(Rails)

module ActsAsBookable
  extend ActiveSupport::Autoload

  autoload :Bookable
  autoload :Booker
  autoload :Booking
  autoload :T
  autoload :VERSION

  # autoload_under 'bookable' do
  #
  # end
end

ActiveSupport.on_load(:active_record) do
  extend ActsAsBookable::Bookable
  include ActsAsBookable::Booker
end
