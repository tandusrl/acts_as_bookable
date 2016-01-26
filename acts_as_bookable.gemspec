$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "acts_as_bookable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "acts_as_bookable"
  s.version     = ActsAsBookable::VERSION
  s.authors     = ["Chosko"]
  s.email       = ["ruben.caliandro@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of ActsAsBookable."
  s.description = "TODO: Description of ActsAsBookable."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2.5.1"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'factory_girl_rails'
end
