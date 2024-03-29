module OSMLib
  module Element

    # OpenStreetMap Node.
    #
    # To create a new OSMLib::Element::Node object:
    #   node = OSMLib::Element::Node.new(17, 'someuser', '2007-10-31T23:48:54Z', 7.4, 53.2)
    #
    # To get a node from the API:
    #   node = OSMLib::Element::Node.from_api(17)
    # 
    # To add tags to a node:
    #   node << {'amenity' => 'parking', 'fee' => 'no' }
    #
    class Node < OSMLib::Element::Object

      # Longitude in decimal degrees
      attr_reader :lon

      # Latitude in decimal degrees
      attr_reader :lat

      # Create new Node object.
      #
      # If +id+ is +nil+ a new unique negative ID will be allocated.
      def initialize(id=nil, user=nil, timestamp=nil, lon=nil, lat=nil, uid=-1, version=1, visible=nil)
        @lon = _check_lon(lon) unless lon.nil?
        @lat = _check_lat(lat) unless lat.nil?
        super(id, user, timestamp, uid, version, visible)
      end

      def type
        'node'
      end

      # Set longitude.
      def lon=(lon)
        @lon = _check_lon(lon)
      end

      # Set latitude.
      def lat=(lat)
        @lat = _check_lat(lat)
      end
      
      # True if lon in in [-180.0,180.0] and lat is in [-90.0,90.0]
      def in_world?
        ( @lon.to_f.between?( -180.0 , 180.0 ) and  @lat.to_f.between?( -180.0 ,180.0 ) ) ? true : false
      end
      

      # List of attributes for a Node
      def attribute_list
        if @visible == nil
          return [:id, :version, :uid, :user, :timestamp, :lon, :lat]
        else
          return [:id, :version, :visible, :user, :timestamp, :lon, :lat]
        end
      end

      # Add one or more tags to this node.
      #
      # The argument can be one of the following:
      #
      # * If the argument is a Hash or an OSMLib::Element::Tags object, those tags are added.
      # * If the argument is an Array the function is called recursively, i.e. all items in the Array are added.
      #
      # Returns the node to allow chaining.
      #
      # call-seq: node << something -> Node
      #
      def <<(stuff)
        case stuff
        when Array  # call this method recursively
          stuff.each do |item|
            self << item
          end
        else
          tags.merge!(stuff)
        end
        self    # return self to allow chaining
      end

      # Create object of class GeoRuby::SimpleFeatures::Point with the
      # coordinates of this node.  Raises an OSMLib::Error::GeometryError
      # exception if the coordinates are not set.
      #
      # Only works if the GeoRuby library is loaded.
      #
      #   require 'rubygems'
      #   require 'geo_ruby'
      #   geometry = OSMLib::Element::Node.new(nil, nil, nil, 10.1, 20.2).point
      #
      # call-seq: geometry ->  GeoRuby::SimpleFeatures::Point
      #
      def point
        raise OSMLib::Error::GeometryError.new("coordinates missing") if lon.nil? || lat.nil? || lon == '' || lat == ''
        GeoRuby::SimpleFeatures::Point.from_lon_lat(lon.to_f, lat.to_f)
      end

      alias :geometry :point

      # Return string version of this node.
      # 
      # call-seq: to_s -> String
      #
      def to_s
        if @visible != nil
          "#<OSMLib::Element::Node id=\"#{@id}\" user=\"#{@user}\" timestamp=\"#{@timestamp}\" lon=\"#{@lon}\" lat=\"#{@lat}\" visible=\"#{@visible}\">"
        else
          "#<OSMLib::Element::Node id=\"#{@id}\" user=\"#{@user}\" timestamp=\"#{@timestamp}\" lon=\"#{@lon}\" lat=\"#{@lat}\">"
        end
      end

      # Return XML for this node. This method uses the XML Builder
      # library. The only parameter is the builder object.
      def to_xml(xml)
        xml.node(attributes) do
          tags.to_xml(xml)
        end
      end

      # Get all ways using this node from the API.
      #
      # The optional parameter is an OSMLib::API::Client object. If none is specified
      # the default OSM API is used.
      #
      # Returns an array of OSMLib::Element::Way objects.
      def get_ways_using_node_from_api(api=OSMLib::API::Client.new)
        api.get_ways_using_node(self.id.to_i)
      end

    end
  end
end