module OSMLib
  module Stream
    
    # This exception is raised by OSMLib::Stream::Parser when the OSM file
    # has an unknown version.
    class VersionError < StandardError; end

    # This exception is raised when you try to use an unknown XML parser
    # by setting the environment variable OSMLIB_XML_PARSER to an unknown
    # value.
    class UnknownParserError < StandardError; end
    

    # Implements the callbacks called by OSMLib::Stream::Parser while parsing
    # the OSM XML file.
    #
    # To create your own behaviour, create a subclass of this class and
    # (re)define the following methods:
    #
    #   node(node) - see below
    #   way(way) - see below
    #   relation(relation) - see below
    #
    #   start_document() - called once at start of document
    #   end_document() - called once at end of document
    #
    #   result() - see below
    #
    class Callbacks

      case OSMLib::Stream.XMLParser
      when 'REXML' then include REXML::SAX2Listener
      when 'Libxml' then include XML::SaxParser::Callbacks
      when 'Expat' then
      else
        raise UnknownParserError
      end

      # the OSMLib::Database used to store objects in
      attr_accessor :db

      # Overwrite this in a derived class. The default behaviour is to
      # do nothing but to store all node objects in a OSMLib::Database if
      # one was supplied when creating the OSMLib::Stream::Parser object.
      def node(node)
        true
      end

      # Overwrite this in a derived class. The default behaviour is to
      # do nothing but to store all way objects in a OSMLib::Database
      # if one was supplied when creating the OSMLib::Stream::Parser
      # object.
      def way(way)
        true
      end

      # Overwrite this in a derived class. The default behaviour is to
      # do nothing but to store all relation objects in a OSMLib::Database
      # if one was supplied when creating the OSMLib::Stream::Parser object.
      def relation(relation)
        true
      end

      # Overwrite this in a derived class. Whatever this method returns
      # will be returned from the OSMLib::Stream::Parser#parse method.
      def result
      end

      def on_start_document   # :nodoc:
        start_document if respond_to?(:start_document)
      end

      def on_end_document     # :nodoc:
        end_document if respond_to?(:end_document)
      end

      def on_start_element(name, attr_hash)   # :nodoc:
        case name
        when 'osm'      then _start_osm(attr_hash)
        when 'node'     then _start_node(attr_hash)
        when 'way'      then _start_way(attr_hash)
        when 'relation' then _start_relation(attr_hash)
        when 'tag'      then _tag(attr_hash)
        when 'nd'       then _nd(attr_hash)
        when 'member'   then _member(attr_hash)
        end
      end

      def on_end_element(name)    # :nodoc:
        case name
        when 'node'     then _end_node()
        when 'way'      then _end_way()
        when 'relation' then _end_relation()
        end
      end

      # used by REXML
      def start_element(uri, name, qname, attr_hash)   # :nodoc:
        on_start_element(name, attr_hash)
      end

      # used by REXML
      def end_element(uri, name, qname)    # :nodoc:
        on_end_element(name)
      end

      private

      def _start_osm(attr_hash)
        @context = nil
        if attr_hash['version'] != '0.5' && attr_hash['version'] != '0.6'
          raise OSMLib::Error::VersionError, 'OSMLib::Stream::Parser only understands OSM file version 0.5 and 0.6'
        end
      end

      def _start_node(attr_hash)
        @context = OSMLib::Element::Node.new(attr_hash['id'], attr_hash['user'], attr_hash['timestamp'], attr_hash['lon'], attr_hash['lat'])
      end

      def _end_node()
        @db << @context if node(@context) && ! @db.nil?
        @context = nil
      end

      def _start_way(attr_hash)
        @context = OSMLib::Element::Way.new(attr_hash['id'], attr_hash['user'], attr_hash['timestamp'])
      end

      def _end_way()
        @db << @context if way(@context) && ! @db.nil?
        @context = nil
      end

      def _start_relation(attr_hash)
        @context = OSMLib::Element::Relation.new(attr_hash['id'], attr_hash['user'], attr_hash['timestamp'])
      end

      def _end_relation()
        @db << @context if relation(@context) && ! @db.nil?
        @context = nil
      end

      def _nd(attr_hash)
        @context.nodes << attr_hash['ref']
      end

      def _tag(attr_hash)
        return if @context == nil
        if respond_to?(:tag)
          return unless tag(@context, attr_hash['k'], attr_value['v'])
        end
        @context.add_tags( attr_hash['k'] => attr_hash['v'] )
      end

      def _member(attr_hash)
        new_member = OSMLib::Element::Member.new(attr_hash['type'], attr_hash['ref'], attr_hash['role'])
        if respond_to?(:member)
          return unless member(@context, new_member)
        end
        @context.members << new_member
      end

    end    

    # This callback class for OSMLib::Stream::Parser collects all objects
    # found in the XML in an array and the OSMLib::Stream::Parser#parse
    # method returns this array.
    #
    #   cb = OSMLib::Element::ObjectListCallbacks.new
    #   parser = OSMLib::Stream::Parser.new(:filename => 'filename.osm', :callbacks => cb)
    #   objects = parser.parse
    #
    class ObjectListCallbacks < Callbacks

      def start_document
        @list = []
      end

      def node(node)
        @list << node
      end

      def way(way)
        @list << way
      end

      def relation(relation)
        @list << relation
      end

      def result
        @list
      end

    end

    class ChangeCallbacks < ObjectListCallbacks

      def on_start_element(name, attr_hash)   # :nodoc:
        case name
        when 'node'      then _start_node(attr_hash)
        when 'way'       then _start_way(attr_hash)
        when 'relation'  then _start_relation(attr_hash)
        when 'tag'       then _tag(attr_hash)
        when 'nd'        then _nd(attr_hash)
        when 'member'    then _member(attr_hash)
        when 'create'    then _start_create()
        when 'modify'    then _start_modify()
        when 'delete'    then _start_delete()
        end
      end

      def on_end_element(name)    # :nodoc:
        case name
        when 'node'     then _end_node()
        when 'way'      then _end_way()
        when 'relation' then _end_relation()
        when 'create' then _end_action()
        when 'modify' then _end_action()
        when 'delete' then end_action()
        end
      end

      def start_document
        @change = OSMLib::OSMChange::Change.new
      end

      def _start_create
        @action = OSMLib::OSMChange::Action.new(:create)
        @list = []
      end

      def _start_modify
        @action = OSMLib::OSMChange::Action.new(:modify)
        @list = []
      end

      def _start_delete
        @action = OSMLib::OSMChange::Action.new(:delete)
        @list = []
      end

      def _end_action
        @action.objects = @list
        @change.push(@action)
        @action = nil
        @list = []
      end

      def result
        return @change
      end
    end


  end
end
