module OSM

  # OpenStreetMap Relation.
  #
  # To create a new OSM::Relation object:
  #   relation = OSM::Relation.new(331, 'user', '2007-10-31T23:51:53Z')
  #
  # To get a relation from the API:
  #   relation = OSM::Relation.from_api(17)
  #
  class Relation < OSMObject

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
    # * If the argument is a Hash or an OSM::Tags object, those tags are added.
    # * If the argument is an OSM::Member object, it is added to the relation
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
      when OSM::Member
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
      raise NoGeometryError.new("Relations don't have a geometry")
    end

    # Returns a polygon made up of all the ways in this relation. This
    # works only if it is tagged with 'polygon' or 'multipolygon'.
    def polygon
      raise OSM::NoDatabaseError.new("can't create Polygon from relation if it is not in a OSM::Database") if @db.nil?
      raise OSM::NoDatabaseError.new("can't create Polygon from relation if it does not represent a polygon") if self['type'] != 'multipolygon' and self['type'] != 'polygon'

      c = []
      member_objects.each do |way|
        raise TypeError.new("member is not a way so it can't be represented as Polygon") unless way.kind_of? OSM::Way
        raise OSM::NotClosedError.new("way is not closed so it can't be represented as Polygon") unless way.is_closed?
        raise OSM::GeometryError.new("way with less then three nodes can't be turned into a polygon") if way.nodes.size < 3
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
        raise OSM::NotFoundError.new("not in database: #{member.type} #{member.ref}") unless obj
        obj
      end
    end

    # Return string version of this Relation object.
    # 
    # call-seq: to_s -> String
    #
    def to_s
      if @visible == nil
        "#<OSM::Relation id=\"#{@id}\" user=\"#{@user}\" timestamp=\"#{@timestamp}\">"
      else
        "#<OSM::Relation id=\"#{@id}\" user=\"#{@user}\" timestamp=\"#{@timestamp}\" visible=\"#{@visible}\">"
      end
    end

    # Return the member with a specified type and id. Returns nil
    # if not found.
    #
    # call-seq: member(type, id) -> OSM::Member
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