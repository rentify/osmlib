module OSMLib
  
  # The Element module implements models for OpenStreetMap base elements: 
  # Nodes, Ways, Relations, Changesets
  module Element
  end

end

# Implementation files
require 'osmlib/element/object'
require 'osmlib/element/tags'
require 'osmlib/element/node'
require 'osmlib/element/way'
require 'osmlib/element/relation'
require 'osmlib/element/changeset'
require 'osmlib/element/tags'