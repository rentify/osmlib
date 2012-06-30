# -----------------------------------------------------------------------------
#
# OSMLib main file
#
# -----------------------------------------------------------------------------


# OSMLib is a library for handling OpenStreetMap and interacting with its API
# 
# === Standard Modules
# 
# These are the standard module provide by the "osmlib" gem.
# 
# * OSMLib::Element contains base elements of OpenStreetMap: Nodes, Ways, Relations,
#   Changesets and Tags.
# 
# * OSMLib::API contains classes for interacting with OpenStreetMap API. 

module OSMLib
end


require 'OSM/version'
require 'OSM/element/object'
require 'OSM/element/tags'
require 'OSM/element/node'
require 'OSM/element/way'
require 'OSM/element/relation'
require 'OSM/element/changeset'
require "OSM/stream_parser/stream_parser"
