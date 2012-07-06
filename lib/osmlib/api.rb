module OSMLib
  
  # === Accessing the OSM API
  # 
  # You can access the OSM RESTful web API through the OSMLib::API::Client class
  # and through some methods in the OSMLib::Element::Node, OSMLib::Element::Way, and OSMLib::Element::Relation
  # classes.
  # 
  # There are methods for getting Nodes, Ways, and Relations by ID,
  # getting the history of an object etc.
  # 
  # Currently only read access is implemented, write access will follow
  # in a later version.
  module API
  end

end

# Implementation file
require 'osmlib/api/client'