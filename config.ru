require 'rubygems'
require 'bundler/setup'
require 'rails'

Bundler.require :default, :development

# See: https://github.com/pat/combustion/issues/50#issuecomment-27470591
require 'action_controller/railtie'

Combustion.initialize! :all

run Combustion::Application
