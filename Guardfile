# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :rspec, cmd: "bundle exec rspec" do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  # Rails files
  rails = dsl.rails(view_extensions: %w(erb haml slim))
  dsl.watch_spec_files_for(rails.app_files)
  dsl.watch_spec_files_for(rails.views)
  watch(rails.controllers) do |m|
    [
      rspec.spec.("routing/#{m[1]}_routing"),
      rspec.spec.("controllers/#{m[1]}_controller"),
      rspec.spec.("requests/#{m[1]}"),
      rspec.spec.("acceptance/#{m[1]}")
    ]
  end

  # Rails config changes
  watch(rails.spec_helper)     { rspec.spec_dir }
  watch(rails.routes)          { "#{rspec.spec_dir}/routing" }
  watch(rails.app_controller) do
    [
      "#{rspec.spec_dir}/controllers",
      "#{rspec.spec_dir}/requests",
    ]
  end
  watch("app/controllers/v1/api_controller.rb") do
    [
      "#{rspec.spec_dir}/controllers",
      "#{rspec.spec_dir}/requests",
    ]
  end

  # Capybara features specs
  watch(rails.view_dirs)     { |m| rspec.spec.("features/#{m[1]}") }
  watch(rails.layouts)       { |m| rspec.spec.("features/#{m[1]}") }

  # Turnip features and steps
  watch(%r{^spec/acceptance/(.+)\.feature$})
  watch(%r{^spec/acceptance/steps/(.+)_steps\.rb$}) do |m|
    Dir[File.join("**/#{m[1]}.feature")][0] || "spec/acceptance"
  end

  callback(:run_all_begin) { CombustionHelper.stop_combustion }
  callback(:run_on_modifications_begin) { CombustionHelper.stop_combustion }
  callback(:run_all_end) { CombustionHelper.start_combustion }
  callback(:run_on_modifications_end) { CombustionHelper.start_combustion }
end

# Add files to watch, like the example:
#   watch(%r{file/path})
#
# Per modificare la porta di combustion, modificare il file .guard_combustion_port
#
guard :combustion do
  watch(%r{^(app|config|lib|spec)/(.*)})
end
