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
  gem.summary     = "A reservation plugin for Rails applications that allows resources to be bookable"
  gem.description = "A reservation plugin for Rails applications that allows resources to be bookable"
  gem.licenses    = ["MIT"]
  gem.platform    = Gem::Platform::RUBY

  gem.files         = `git ls-files`.split($/)
  gem.test_files    =  gem.files.grep(%r{^spec/})

  gem.require_paths = ['lib']
  gem.required_ruby_version = '>= 1.9.3'

  if File.exist?('UPGRADING.md')
    gem.post_install_message = File.read('UPGRADING.md')
  end

  gem.add_dependency 'ice_cube', '~> 0.13'

  gem.add_runtime_dependency 'activerecord', ['>= 3.2', '< 5']

  gem.add_development_dependency 'sqlite3'
  gem.add_development_dependency 'mysql2', '~> 0.3.7'
  gem.add_development_dependency 'pg'
  gem.add_development_dependency 'rspec-rails'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'factory_girl_rails'
  gem.add_development_dependency 'barrier'
  gem.add_development_dependency 'database_cleaner'
end
