#!/usr/bin/env rake
require "bundler/gem_tasks"

desc 'Measures test coverage'
task :rcov do
  rm_f "coverage"
  system("rcov test/test_*rb")
end
