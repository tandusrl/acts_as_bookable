# === boot ===

begin
  require "bundler/setup"
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

# === application ===

require "rails"
require "combustion"
require "active_record/railtie"

Bundler.require :default, Rails.env

Combustion::Application.configure_for_combustion

# === Rakefile ===

task :environment do
  Combustion::Application.initialize!

  # Reset migrations paths so we can keep the migrations in the project root,
  # not the Rails root
  migrations_paths = ["db/migrate"]
  ActiveRecord::Tasks::DatabaseTasks.migrations_paths = migrations_paths
  ActiveRecord::Migrator.migrations_paths = migrations_paths
end

require "rspec/core/rake_task"

Combustion::Application.load_tasks

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'ActsAsBookable'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Bundler::GemHelper.install_tasks
