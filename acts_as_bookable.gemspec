$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "acts_as_bookable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "acts_as_bookable"
  s.version     = ActsAsBookable::VERSION
  s.authors     = ["Chosko"]
  s.email       = ["ruben.caliandro@gmail.com"]
  s.homepage    = "https://github.com/tandusrl/acts_as_bookable"
  s.summary     = "A reservation plugin for Rails applications that allows resources to be bookable"
  s.description = "A reservation plugin for Rails applications that allows resources to be bookable"
  s.licenses    = ["MIT"]
  s.platform    = Gem::Platform::RUBY

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2.5"

  s.add_development_dependency "pg"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'combustion', '~> 0.5.4'
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "guard-combustion", '~> 1.0.0'

  s.test_files = Dir["spec/**/*"]
end
