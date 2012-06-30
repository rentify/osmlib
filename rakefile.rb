#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rdoc'
require 'rake/testtask'
require 'rdoc/task'

$: << 'lib'

require 'OSM'

task :default => :test

desc "Run the tests"
Rake::TestTask::new do |t|
  t.test_files = FileList['test/test_*.rb']
  t.verbose = true
end

desc 'generate API documentation to doc/rdocs/index.html'
RDoc::Task.new do |rd|
  rd.rdoc_dir = 'doc'
  rd.main = 'README.rdoc'
  rd.rdoc_files.include 'README.rdoc', 'ChangeLog', "lib/**/*\.rb"
 
  rd.options << '--line-numbers'
  rd.options << '--all'
end