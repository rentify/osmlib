module OSMLib
  module Elements

    # OpenStreetMap Way.
    #
    # To create a new OSM::Way object:
    #   way = OSM::Way.new(1743, 'user', '2007-10-31T23:51:17Z')
    #
    # To get a way from the API:
    #   way = OSM::Way.from_api(17)
    #
    class Way < OSMObject

      # Array of node IDs in this way.
      attr_reader :nodes

      # Create new Way object.
      #
      # id:: ID of this way. If +nil+ a new unique negative ID will be
      # allocated.
      # user:: Username
      # timestamp:: Timestamp of last change
      # nodes:: Array of Node objects and/or node IDs
      def initialize(id=nil, user=nil, timestamp=nil, nodes=[], uid=-1, version=1, visible=nil)
        @nodes = nodes.collect{ |node| node.kind_of?(OSM::Node) ? node.id : node }
        super(id, user, timestamp, uid, version, visible)
      end

      def type
        'way'
      end

      # Add one or more tags or nodes to this way.
      #
      # The argument can be one of the following:
      #
      # * If the argument is a Hash or an OSM::Tags object, those tags
      # * are added.  If the argument is an OSM::Node object, its ID
      # * is added to the list of node IDs.  If the argument is an
      # * Integer or String containing an Integer, this ID is added
      # * to the list of node IDs.  If the argument is an Array the
      # * function is called recursively, i.e. all items in the
      # * Array are added.
      #
      # Returns the way to allow chaining.
      #
      # call-seq: way << something -> Way
      #
      def <<(stuff)
        case stuff
        when Array  # call this method recursively
          stuff.each do |item|
            self << item
          end
        when OSM::Node
          nodes << stuff.id
        when String
          nodes << stuff.to_i
        when Integer
          nodes << stuff
        else
          tags.merge!(stuff)
        end
        self    # return self to allow chaining
      end

      # Is this way closed, i.e. are the first and last nodes the same?
      #
      # Returns false if the way doesn't contain any nodes or only one node.
      #
      # call-seq: is_closed? -> true or false
      #
      def is_closed?
        return false if nodes.size < 2
        nodes[0] == nodes[-1]
      end

      # Return an Array with all the node objects that are part of this way.
      #
      # Only works if the way and nodes are part of an OSM::Database.
      #
      # call-seq: node_objects -> Array of OSM::Node objects
      #
      def node_objects
        raise OSM::NoDatabaseError.new("can't get node objects if the way is not in a OSM::Database") if @db.nil?
        nodes.collect do |id|
          @db.get_node(id)
        end
      end

      # Create object of class GeoRuby::SimpleFeatures::LineString with the
      # coordinates of the node in this way.
      # Raises a OSM::GeometryError exception if the way contain less than
      # two nodes. Raises an OSM::NoDatabaseError exception if this way
      # is not associated with an OSM::Database.
      #
      # Only works if the GeoRuby library is loaded.
      #
      # call-seq: linestring ->  GeoRuby::SimpleFeatures::LineString or nil
      #
      def linestring
        raise OSM::GeometryError.new("way with less then two nodes can't be turned into a linestring") if nodes.size < 2
        raise OSM::NoDatabaseError.new("can't create LineString from way if the way is not in a OSM::Database") if @db.nil?
        GeoRuby::SimpleFeatures::LineString.from_coordinates(node_objects.collect{ |node| [node.lon.to_f, node.lat.to_f] })
      end

      # Create object of class GeoRuby::SimpleFeatures::Polygon with
      # the coordinates of the node in this way.
      # Raises a OSM::GeometryError exception if the way contain less
      # than three nodes.
      # Raises an OSM::NoDatabaseError exception if this way is not
      # associated with an OSM::Database.
      # Raises an OSM::NotClosedError exception if this way is not closed.
      #
      # Only works if the GeoRuby library is loaded.
      #
      # call-seq: polygon ->  GeoRuby::SimpleFeatures::Polygon or nil
      #
      def polygon
        raise OSM::GeometryError.new("way with less then three nodes can't be turned into a polygon") if nodes.size < 3
        raise OSM::NoDatabaseError.new("can't create Polygon from way if the way is not in a OSM::Database") if @db.nil?
        raise OSM::NotClosedError.new("way is not closed so it can't be represented as Polygon") unless is_closed?
        GeoRuby::SimpleFeatures::Polygon.from_coordinates([node_objects.collect{ |node| [node.lon.to_f, node.lat.to_f] }])
      end

      # Currently the same as the linestring method. This might change in
      # the future to return a Polygon in some cases.
      #
      # Only works if the GeoRuby library is loaded.
      #
      # call-seq: geometry ->  GeoRuby::SimpleFeatures::LineString or nil
      #
      def geometry
        linestring
      end

      # Return string version of this Way object.
      # 
      # call-seq: to_s -> String
      #
      def to_s
        if @visible == nil
          "#<OSM::Way id=\"#{@id}\" user=\"#{@user}\" timestamp=\"#{@timestamp}\">"
        else
          "#<OSM::Way id=\"#{@id}\" user=\"#{@user}\" timestamp=\"#{@timestamp}\" visible=\"#{@visible}\">"
        end
      end

      # Return XML for this way. This method uses the Builder library.
      # The only parameter ist the builder object.
      def to_xml(xml)
        xml.way(attributes) do
          nodes.each do |node|
            xml.nd(:ref => node)
          end
          tags.to_xml(xml)
        end
      end

    end

  end
end