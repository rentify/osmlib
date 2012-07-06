
# OSMLib is a library for handling OpenStreetMap data and interacting with its API
# 
# === Standard Modules
# 
# These are the standard module provide by the "osmlib" gem.
# 
# * OSMLib::Element is the base module for Node, Way, Relation, Changeset and Tag.
# * OSMLib::API contains classes for interacting with OpenStreetMap API. 
# * OSMLib::Database contains classes for interacting with OpenStreetMap API. 
# * OSMLib::Error contains classes for interacting with OpenStreetMap API. 
# * OSMLib::OSMChange contains classes for interacting with OpenStreetMap API. 
# * OSMLib::Stream contains classes for interacting with OpenStreetMap API. 

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
