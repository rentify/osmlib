require 'xmlsimple'

# Namespace for modules and classes related to the OpenStreetMap project.
module OSM

  class Changeset
    
    # Get OSM::Changeset from API
    def self.from_api(id, api = OSM::API.new) 
      api.get_changeset(id)
    end
    
    # Instanciate a OSM::Changetset from a Hash
    def self.from_osm_xml( osm_xml ) 
      osm_hash = XmlSimple.xml_in( osm_xml )["changeset"][0]
      # p osm_hash
      OSM::Changeset.new( osm_hash["id"].to_i, 
                          osm_hash["user"], 
                          osm_hash["uid"].to_i, 
                          osm_hash["created_at"], 
                          osm_hash["closed_at"], 
                          osm_hash["open"], 
                          osm_hash["min_lat"], 
                          osm_hash["min_lon"], 
                          osm_hash["max_lat"], 
                          osm_hash["max_lon"])
    end
    
    # Attributes
    
    attr_reader :id
    attr_reader :user
    attr_reader :uid
    attr_reader :created_at
    attr_reader :closed_at
    attr_reader :open
    attr_reader :min_lat
    attr_reader :min_lon
    attr_reader :max_lat
    attr_reader :max_lon
        
    def initialize(id, user, uid, created_at, closed_at, open, min_lat, min_lon, max_lat, max_lon)
      @id = id
      @user = user
      @uid = uid
      @created_at = created_at
      @closed_at = closed_at
      @open = (open == "true") ? true : false
      @min_lat = min_lat.to_f
      @min_lon = min_lon.to_f
      @max_lat = max_lat.to_f
      @max_lon = max_lon.to_f
      @tags = Tags.new      
    end
    
  end

end