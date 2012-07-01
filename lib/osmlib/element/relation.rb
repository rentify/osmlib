module OSMLib
  module Element

    # OpenStreetMap Relation.
    #
    # To create a new OSMLib::Element::Relation object:
    #   relation = OSMLib::Element::Relation.new(331, 'user', '2007-10-31T23:51:53Z')
    #
    # To get a relation from the API:
    #   relation = OSMLib::Element::Relation.from_api(17)
    #
    class Relation < OSMLib::Element::Object

      # Array of Member objects
      attr_reader :members

      # Create new Relation object.
      #
      # If +id+ is +nil+ a new unique negative ID will be allocated.
      def initialize(id=nil, user=nil, timestamp=nil, members=[], uid=-1, version=1, visible=nil)
        @members = members
        super(id, user, timestamp, uid, version, visible)
      end

      def type
        'relation'
      end

      # Add one or more tags or members to this relation.
      #
      # The argument can be one of the following:
      #
      # * If the argument is a Hash or an OSMLib::Element::Tags object, those tags are added.
      # * If the argument is an OSMLib::Element::Member object, it is added to the relation
      # * If the argument is an Array the function is called recursively, i.e. all items in the Array are added.
      #
      # Returns the relation to allow chaining.
      #
      # call-seq: relation << something -> Relation
      #
      def <<(stuff)
        case stuff
        when Array  # call this method recursively
          stuff.each do |item|
            self << item
          end
        when OSMLib::Element::Member
          members << stuff
        else
          tags.merge!(stuff)
        end
        self    # return self to allow chaining
      end

      # Raises a NoGeometryError.
      #
      # Future versions of this library may recognize certain relations
      # that do have a geometry (such as Multipolygon relations) and do
      # the right thing.
      def geometry
        raise OSMLib::Error::NoGeometryError.new("Relations don't have a geometry")
      end

      # Returns a polygon made up of all the ways in this relation. This
      # works only if it is tagged with 'polygon' or 'multipolygon'.
      def polygon
        raise OSMLib::Error::NoDatabaseError.new("can't create Polygon from relation if it is not in a OSMLib::Database") if @db.nil?
        raise OSMLib::Error::NoDatabaseError.new("can't create Polygon from relation if it does not represent a polygon") if self['type'] != 'multipolygon' and self['type'] != 'polygon'

        c = []
        member_objects.each do |way|
          raise TypeError.new("member is not a way so it can't be represented as Polygon") unless way.kind_of? OSMLib::Element::Way
          raise OSMLib::Error::NotClosedError.new("way is not closed so it can't be represented as Polygon") unless way.is_closed?
          raise OSMLib::Error::GeometryError.new("way with less then three nodes can't be turned into a polygon") if way.nodes.size < 3
          c << way.node_objects.collect{ |node| [node.lon.to_f, node.lat.to_f] }
        end
        GeoRuby::SimpleFeatures::Polygon.from_coordinates(c)
      end

      # Return all the member objects of this relation.
      def member_objects
        members.collect do |member|
          obj = case member.type
          when :node,     'node'     then @db.get_node(member.ref)
          when :way,      'way'      then @db.get_way(member.ref)
          when :relation, 'relation' then @db.get_relation(member.ref)
          end
          raise OSMLib::Error::NotFoundError.new("not in database: #{member.type} #{member.ref}") unless obj
          obj
        end
      end

      # Return string version of this Relation object.
      # 
      # call-seq: to_s -> String
      #
      def to_s
        if @visible == nil
          "#<OSMLib::Element::Relation id=\"#{@id}\" user=\"#{@user}\" timestamp=\"#{@timestamp}\">"
        else
          "#<OSMLib::Element::Relation id=\"#{@id}\" user=\"#{@user}\" timestamp=\"#{@timestamp}\" visible=\"#{@visible}\">"
        end
      end

      # Return the member with a specified type and id. Returns nil
      # if not found.
      #
      # call-seq: member(type, id) -> OSMLib::Element::Member
      #
      def member(type, id)
        members.select{ |member| member.type == type && member.ref == id }[0]
      end

      # Return XML for this relation. This method uses the Builder library.
      # The only parameter ist the builder object.
      def to_xml(xml)
        xml.relation(attributes) do
          members.each do |member|
            member.to_xml(xml)
          end
          tags.to_xml(xml)
        end
      end

    end

    # A member of an OpenStreetMap Relation.
    class Member

      # Role this member has in the relationship
      attr_accessor :role

      # Type of referenced object (can be 'node', 'way', or 'relation')
      attr_reader :type

      # ID of referenced object
      attr_reader :ref

      # Create a new Member object. Type can be one of 'node', 'way' or
      # 'relation'. Ref is the ID of the corresponding Node, Way, or
      # Relation. Role is a freeform string and can be empty.
      def initialize(type, ref, role='')
        if type !~ /^(node|way|relation)$/
          raise ArgumentError.new("type must be 'node', 'way', or 'relation'")
        end
        if ref.to_s !~ /^[0-9]+$/
          raise ArgumentError
        end
        @type = type
        @ref  = ref.to_i
        @role = role
      end

      # Return XML for this way. This method uses the Builder library.
      # The only parameter ist the builder object.
      def to_xml(xml)
        xml.member(:type => type, :ref => ref, :role => role)
      end

    end
  end
end