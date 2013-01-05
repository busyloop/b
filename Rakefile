require "bundler/gem_tasks"

require 'rspec/core/rake_task'

task :default => :test

RSpec::Core::RakeTask.new("test:spec") do |t|
    t.pattern = 'spec/**/*_spec.rb'
    t.rspec_opts = '--fail-fast -b -c -f documentation --tag ~benchmark'
end

desc 'Run full test suite'
task :test => [ 'test:spec' ]
