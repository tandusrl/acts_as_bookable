lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# Maintain your gem's version:
require "acts_as_bookable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |gem|
  gem.name        = "acts_as_bookable"
  gem.version     = ActsAsBookable::VERSION
  gem.authors     = ["Chosko"]
  gem.email       = ["ruben.caliandro@gmail.com"]
  gem.homepage    = "https://github.com/tandusrl/acts_as_bookable"
  gem.summary     = "The reservation engine for Rails applications that allows resources to be booked"
  gem.description = "ActsAsBookable is a reservation engine for Rails applications that allows resources to be booked. You can define availability rules for bookable models and set costraints to implement different types of booking (hotels, theaters, meeting rooms...)"
  gem.licenses    = ["MIT"]
  gem.platform    = Gem::Platform::RUBY

  gem.files         = `git ls-files`.split($/)
  gem.test_files    =  gem.files.grep(%r{^spec/})

  gem.require_paths = ['lib']
  gem.required_ruby_version = '>= 2.0.0'

  if File.exist?('UPGRADING.md')
    gem.post_install_message = File.read('UPGRADING.md')
  end

  gem.add_dependency 'ice_cube_chosko', '~> 0.1.0'
  gem.add_runtime_dependency 'activerecord', ['>= 3.2']

  gem.add_development_dependency 'sqlite3', '~> 1.3'
  gem.add_development_dependency 'mysql2', '~> 0.3.7'
  gem.add_development_dependency 'pg', '~> 0.18'
  gem.add_development_dependency 'rspec-rails', '~> 3'
  gem.add_development_dependency 'rspec', '~> 3'
  gem.add_development_dependency 'coveralls', '~> 0.8'
  gem.add_development_dependency 'factory_girl_rails', '~> 4.6'
  gem.add_development_dependency 'barrier', '~> 1.0'
  gem.add_development_dependency 'database_cleaner', '~>1.5'
  gem.add_development_dependency 'awesome_print', '~>1.6'
end
