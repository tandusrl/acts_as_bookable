require 'coveralls'
Coveralls.wear!

begin
  require 'pry-nav'
rescue LoadError
end
$LOAD_PATH << '.' unless $LOAD_PATH.include?('.')
$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'logger'

require File.expand_path('../../lib/acts_as_bookable', __FILE__)
I18n.enforce_available_locales = true
require 'rails'
require 'barrier'
require 'database_cleaner'
require 'factory_bot_rails'
require 'awesome_print'

ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')
Dir[File.join(ENGINE_RAILS_ROOT, "spec/factories/**/*.rb")].each {|f| require f }

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

I18n.load_path << File.expand_path("../../config/locales/en.yml", __FILE__)

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
end
