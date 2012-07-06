module OSMLib
  
  # The Element module implements models for OpenStreetMap base elements.
  # 
  # Basic usage for Node, Way and Relation :
  # 
  #  # create a node
  #  node = OSMLib::Element::Node.new(17, 'user', '2007-10-31T23:48:54Z', 7.4, 53.2)
  # 
  #  # create a way and add a node
  #  way = OSMLib::Element::Way.new(1743, 'user', '2007-10-31T23:51:17Z')
  #  way.nodes << node
  # 
  #  # create a relation
  #  relation = OSMLib::Element::Relation.new(331, 'user', '2007-10-31T23:51:53Z')
  # 
  # There is also an Member class for members of a relation:
  # 
  #    # create a member and add it to a relation
  #    member = OSMLib::Element::Member.new('way', 1743, 'role')
  #    relation << [member]
  # 
  # Tags can be added to Nodes, Ways, and Relations:
  # 
  #    way.add_tags('highway' => 'residential', 'name' => 'Main Street')
  # 
  # You can get the hash of tags like this:
  # 
  #    way.tags
  #    way.tags['highway']
  #    way.tags['name'] = 'Bay Street'
  # 
  # As a convenience tags can also be accessed with their name only:
  #    way.highway
  # 
  # This is implemented with the method_missing() function. Of course it
  # only works for tag keys which are allowed as ruby method names.

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