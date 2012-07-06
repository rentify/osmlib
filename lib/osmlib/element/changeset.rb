require 'xmlsimple'

module OSMLib
  module Element

    class Changeset

      # Get OSMLib::Element::Changeset from API
      def self.from_api(id, api = OSMLib::API::Client.new) 
        api.get_changeset(id)
      end

      # Instanciate a OSMLib::Element::Changetset from a Hash
      def self.from_osm_xml( osm_xml ) 
        osm_hash = XmlSimple.xml_in( osm_xml )["changeset"][0]
        OSMLib::Element::Changeset.new( osm_hash["id"].to_i, 
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

      # Generate xml for changeset creation
      def self.osm_xml_for_new_changeset (tags = {})
        result =  "<?xml version='1.0' encoding='UTF-8'?>"
        result += "<osm><changeset>"
        tags.each { |key, value|
          result += "<tag k='#{key}' v='#{value}'/>"
        }
        result += "</changeset></osm>"
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
        @tags = OSMLib::Element::Tags.new      
      end

    end
  end
end