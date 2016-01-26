# Start your engines
# ==================

# Starting point
require 'rubygems'

# Requiring gems
require 'bundler/setup'

# See: https://github.com/pat/combustion/issues/50#issuecomment-27470591
require 'action_controller/railtie'
require 'action_view/railtie'

# Require Combustion, for not-so-dummy app testing
require 'combustion'

# Capybara rspec
require 'capybara/rspec'

# 5. Activate Combustion! Now!
Combustion.initialize! :all

# 6. Finally requiring Rails...
require 'rspec/rails'

# 7. ...Capybara Rails extension...
require 'capybara/rails'

# 8. ...Factory Girl...
require 'factory_girl_rails'

# 10. ...and Faker...
require 'faker'

# RSpec Configuration
# ===================

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
