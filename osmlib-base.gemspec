# -*- encoding: utf-8 -*-
require File.expand_path('../lib/osmlib/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "osmlib"
  s.summary     = "Library for basic OpenStreetMap data and API handling"
  s.description = "Basic support for OpenStreetMap data model (Nodes, Ways, Relations and Tags). Parsing of OSM XML files. Access to OpenStreetMap API."
  s.version     = OSMLib::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jochen Topf", "Serge Wroclawski", "Vitor George"]
  s.email       = ["jochen@topf.org", "serge+osmlib@wroclawski.org", "vitor.george@gmail.com"]
  s.homepage    = "http://vgeorge.github.com/osmlib/rdoc"

  s.rubyforge_project = 'osmlib'

  s.add_development_dependency "rdoc"  
  s.add_development_dependency "simplecov" 

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end