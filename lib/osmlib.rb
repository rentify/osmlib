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


# Modules for this gem

require 'osmlib/version'
require 'osmlib/api'
require 'osmlib/database'
require 'osmlib/element'
require 'osmlib/error'
require 'osmlib/osmchange'
require 'osmlib/stream'
