# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'OSM/version'

Gem::Specification.new do |s|
  s.name        = "osmlib-base"
  s.version     = OSM::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jochen Topf", "Serge Wroclawski", "Vitor George"]
  s.email       = ["jochen@topf.org", "serge+osmlib@wroclawski.org", "vitor.george@gmail.com"]
  s.homepage    = "http://github.emacsen.net/emacsen/osmlib-base"
  s.summary     = "Library for basic OpenStreetMap data handling"
  s.description = "Basic support for OpenStreetMap data model (Nodes, Ways, Relations and Tags). Parsing of OSM XML files. Access to OpenStreetMap API."

  s.rubyforge_project = 'osmlib'

  s.add_development_dependency "rake"   
  s.add_development_dependency "rdoc"  
  s.add_development_dependency "simplecov" 

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end