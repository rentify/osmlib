require 'net/http'

module OSMLib

  module API

    # 
    # Handles all calls to OpenStreetMap API.
    #
    # Usage:
    #   require 'osmlib'
    #
    #   @api = OSMLib::API::Client.new
    #   node = @api.get_node(3437)
    #
    # For response results other than 200, this class will raise the following errors:
    # 
    # * OSMLib::Error::APINotFound for status code 404 (not found);
    # * OSMLib::Error::APIGone for status code 410 (page gone);
    # * OSMLib::Error::APIServerError for status code 500 (server error);
    # * OSMLib::Error::APIError for others codes.
    # 
    # In most cases you can use the more convenient methods on the
    # OSMLib::Element::Node, OSMLib::Element::Way, or OSMLib::Element::Relation objects.
    #
    class Client

      attr_reader :username
      attr_reader :password
      attr_reader :current_changeset
      
      # Creates a new API object. Without any arguments it uses the
      # default API at DEFAULT_BASE_URI. If you want to use a different
      # API, give the base URI as parameter to this method.
      def initialize( uri = OSMLib::API::DEFAULT_BASE_URI, username = nil, password = nil )

        @base_uri = uri
        @username = username 
        @password = password 
      end

      # Get an object ('node', 'way', or 'relation') with specified ID
      # from API.
      #
      # call-seq: get_object(type, id) -> OSMLib::Element::Object
      #
      def get_object(type, id)
        raise ArgumentError.new("type needs to be one of 'node', 'way', and 'relation'") unless type =~ /^(node|way|relation)$/
        raise TypeError.new('id needs to be a positive integer') unless(id.kind_of?(Fixnum) && id > 0)
        response = get("#{type}/#{id}")
        check_response_codes(response)
        parser = OSMLib::Stream::Parser.new(:string => response.body, :callbacks => OSMLib::Stream::ObjectListCallbacks.new)
        list = parser.parse
        raise OSMLib::Error::APITooManyObjects if list.size > 1
        list[0]
      end

      # Get a node with specified ID from API.
      #
      # call-seq: get_node(id) -> OSMLib::Element::Node
      #
      def get_node(id)
        get_object('node', id)
      end


      # Get a way with specified ID from API.
      #
      # call-seq: get_node(id) -> OSMLib::Element::Way
      #
      def get_way(id)
        get_object('way', id)
      end

      # Get a relation with specified ID from API.
      #
      # call-seq: get_node(id) -> OSMLib::Element::Relation
      #
      def get_relation(id)
        get_object('relation', id)
      end

      # Get all ways using the node with specified ID from API.
      #
      # call-seq: get_ways_using_node(id) -> Array of OSMLib::Element::Way
      #
      def get_ways_using_node(id)
        api_call(id, "node/#{id}/ways")
      end

      # Get all relations which refer to the object of specified type and with specified ID from API.
      #
      # call-seq: get_relations_referring_to_object(type, id) -> Array
      # of OSMLib::Element::Relation
      #
      def get_relations_referring_to_object(type, id)
        api_call_with_type(type, id, "#{type}/#{id}/relations")
      end

      # Get all historic versions of an object of specified type and
      # with specified ID from API.
      #
      # call-seq: get_history(type, id) -> Array of OSMLib::Element::Object
      #
      def get_history(type, id)
        api_call_with_type(type, id, "#{type}/#{id}/history")
      end

      # Get all objects in the bounding box (bbox) given by the left, bottom, right, and top
      # parameters. They will be put into a OSMLib::Database object which is returned.
      #
      # call-seq: get_bbox(left, bottom, right, top) -> OSMLib::Database
      #
      def get_bbox(left, bottom, right, top)
        raise TypeError.new('"left" value needs to be a number between -180 and 180') unless(left.kind_of?(Float) && left >= -180 && left <= 180)
        raise TypeError.new('"bottom" value needs to be a number between -90 and 90') unless(bottom.kind_of?(Float) && bottom >= -90 && bottom <= 90)
        raise TypeError.new('"right" value needs to be a number between -180 and 180') unless(right.kind_of?(Float) && right >= -180 && right <= 180)
        raise TypeError.new('"top" value needs to be a number between -90 and 90') unless(top.kind_of?(Float) && top >= -90 && top <= 90)
        response = get("map?bbox=#{left},#{bottom},#{right},#{top}")
        check_response_codes(response)
        db = OSMLib::Database.new
        parser = OSMLib::Stream::Parser.new(:string => response.body, :db => db)
        parser.parse
        db
      end

      # Get a changeset with specified ID from OpenstreetMap API
      #
      # call-seq: get_changeset(id) -> OSMLib::Element::Changeset
      #
      def get_changeset(id)
        raise TypeError.new('id needs to be a positive integer') unless(id.kind_of?(Integer) && id > 0)
        response = get("changeset/#{id}")
        check_response_codes(response)
        OSMLib::Element::Changeset.from_osm_xml(response.body)
      end

      # Opens a changeset and returns its id. Tags for changeset is not implemented yet.
      #
      # call-seq: create_changeset( tags={} ) -> int
      #
      def create_changeset(tags = {})
        osm_xml = OSMLib::Element::Changeset.osm_xml_for_new_changeset(tags)
        response = put('changeset/create', osm_xml)
        check_response_codes(response)
        response
      end
      
      # Creates a new node in OpenStreetMap databse. If no changeset id provided, osmlib will
      # create a new changeset.
      # 
      # call-seq: create_node(lat, lon, tags = {}, changeset_id = nil) -> new_node_id
      # 
      def create_node( lon, lat, tags = {}, changeset_id = nil)
        raise ArgumentError.new("Latitude should be between [-90,90]") unless lat.to_f.between?( -90.0, 90.0 )
        raise ArgumentError.new("Longitude should be between [-180,180]") unless lon.to_f.between?( -180.0, 180.0)

        # If no changeset is provided, use current or create a new one.
        if not changeset_id then
          response = create_changeset()
          changeset_id = response.body.to_i
        end

        # Generate request payload
        xml = OSMLib::API::XMLPayload.to_create_new_node( lon, lat, tags, changeset_id )

        response = put('node/create', xml)
        check_response_codes(response)

        response.body.to_i
      end

      private

      def api_call_with_type(type, id, path)
        raise ArgumentError.new("type needs to be one of 'node', 'way', and 'relation'") unless type =~ /^(node|way|relation)$/
        api_call(id, path)
      end

      def api_call(id, path)
        raise TypeError.new('id needs to be a positive integer') unless(id.kind_of?(Fixnum) && id > 0)
        response = get(path)
        check_response_codes(response)
        parser = OSMLib::Stream::Parser.new(:string => response.body, :callbacks => OSMLib::Element::ObjectListCallbacks.new)
        parser.parse
      end

      def get(suffix)
        uri = URI.parse(@base_uri + suffix)
        request = Net::HTTP.new(uri.host, uri.port)
        request.get(uri.request_uri)
      end

      def check_response_codes(response)
        case response.code.to_i
        when 200 then return
        when 404 then raise OSMLib::Error::APINotFound
        when 410 then raise OSMLib::Error::APIGone
        when 500 then raise OSMLib::Error::APIServerError
        else raise OSMLib::Error::APIError
        end
      end

    end

  end
end
