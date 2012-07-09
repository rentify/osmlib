module OSMLib
  
  # === Accessing the OSM API
  # 
  # Please check OSMLib::API::Client documentation.
  # 
  module API
    
    # The default base URI for the API
    DEFAULT_BASE_URI = 'http://www.openstreetmap.org/api/0.6/'

    # The development base URI for the API
    DEV_BASE_URI = 'http://api06.dev.openstreetmap.org/api/0.6/'
    
  end

end

# Implementation file
require 'osmlib/api/client'
require 'osmlib/api/xml_payload'