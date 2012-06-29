#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rake/testtask'

$: << 'lib'

require 'OSM'

task :default => :test

desc "Run the tests"
Rake::TestTask::new do |t|
  t.test_files = FileList['test/test_*.rb']
  t.verbose = true
end
