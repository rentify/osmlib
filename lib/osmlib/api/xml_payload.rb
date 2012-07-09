module OSMLib

  module API

    # 
    # XMLPayload is an utility class to help create XML used in OpenStreetMap API calls
    #
    class XMLPayload

      # 
      # Return the XML to be used as payload in a create node call
      #
      # call-seq: to_create_node(changeset, lat, lon, tags = {}) -> String
      #
      def self.to_create_new_node( lon, lat, tags = {}, changeset )
        xml = "<?xml version='1.0' encoding='UTF-8'?><osm><node changeset='#{changeset}' lat='#{lat}' lon='#{lon}'>"
        tags.each{ |key,value|
          xml += "<tag k='#{key}' v='#{value}'>"
        }
        xml += "</node></osm>" 
      end

    end
  end
end      
