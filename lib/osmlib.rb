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


require 'osmlib/version'
require 'osmlib/element/object'
require 'osmlib/element/tags'
require 'osmlib/element/node'
require 'osmlib/element/way'
require 'osmlib/element/relation'
require 'osmlib/element/changeset'
require "osmlib/stream_parser/stream_parser"
