
module OSMLib

  # === The Stream Parser
  #
  # To parse an OSM XML file create a subclass of OSMLib::Stream::Callbacks and
  # define the methods node(), way(), and relation() in it:
  #
  #   class MyCallbacks < OSMLib::Stream::Callbacks
  #
  #     def node(node)
  #        ...
  #     end
  #
  #     def way(way)
  #        ...
  #     end
  #
  #     def relation(relation)
  #        ...
  #     end
  #
  #   end
  #
  # Instantiate an object of this class and give it to a OSMLib::Stream::Parser:
  #
  #   require 'osmlib'
  #
  #   cb = MyCallbacks.new
  #   parser = OSMLib::Stream::Parser.new(:filename => 'filename.osm', :callbacks => cb)
  #   parser.parse
  #
  # The methods node(), way(), or relation() will be called whenever
  # the parser has parsed a complete node, way, or relation (i.e. after
  # all tags, nodes in a way, or members of a relation are available).
  #
  # There are several parser options available:
  #
  # * REXML (Default, slow, works on all machines, because it is part
  #   of the Ruby standard distribution)
  # * Libxml (Based on the C libxml2 library, faster than REXML, new
  #   version needed, sometimes hard to install)
  # * Expat (Based on C Expat library, faster than REXML)
  #
  # Since version 0.1.3 REXML is the default parser because many people
  # had problems with the C-based parser. Change the parser by setting
  # the environment variable OSMLIB_XML_PARSER to the parser you want
  # to use (before you require 'OSM/StreamParser'):
  #
  # From the shell:
  #     export OSMLIB_XML_PARSER=Libxml
  #
  # From ruby:
  #     ENV['OSMLIB_XML_PARSER']='Libxml'
  #     require 'osmlib'
  #

  module Stream

    @@XMLPARSER = ENV['OSMLIB_XML_PARSER'] || 'REXML'

    def self.XMLParser
      @@XMLPARSER
    end

    if OSMLib::Stream.XMLParser == 'REXML'
      require 'rexml/parsers/sax2parser'
      require 'rexml/sax2listener'
    elsif OSMLib::Stream.XMLParser == 'Libxml'
      require 'rubygems'
      begin
        require 'xml/libxml'
      rescue LoadError
        require 'libxml'
      end
    elsif OSMLib::Stream.XMLParser == 'Expat'
      require 'rubygems'
      require 'xmlparser'
    end

    # This is the base class for the OSMLib::Stream::REXML,
    # OSMLib::Stream::Libxml, and OSMLib::Stream::Expat
    # classes. Do not instantiate this class!
    class ParserBase

      # Byte position within the input stream. This is only updated by
      # the Expat parser.
      attr_reader :position

      def initialize(options) # :nodoc:
        @filename = options[:filename]
        @string = options[:string]
        @db = options[:db]
        @context = nil
        @position = 0

        if (@filename.nil? && @string.nil?) || ((!@filename.nil?) && (!@string.nil?))
          raise ArgumentError.new('need either :filename or :string argument')
        end

        @callbacks = options[:callbacks].nil? ? OSMLib::Stream::Callbacks.new : options[:callbacks]
        @callbacks.db = @db
      end

    end

    # Class to parse XML files. This is a factory class. When calling
    # OSMLib::Stream::Parser.new() an object of one of the following
    # classes is created and returned: OSMLib::Stream::REXML,
    # OSMLib::Stream::Libxml, OSMLib::Stream::Expat.
    #
    # Usage:
    #   ENV['OSMLIB_XML_PARSER'] = 'Libxml'
    #   require 'osmlib'
    #   parser = OSMLib::Stream::Parser.new(:filename => 'file.osm')
    #   result = parser.parse
    #
    class Parser

      # Create new StreamParser object. Only argument is a hash.
      #
      # call-seq: OSMLib::Stream::Parser.new(:filename => 'filename.osm')
      #           OSMLib::Stream::Parser.new(:string => '...')
      #
      # The hash keys:
      #   :filename  => name of XML file
      #   :string    => XML string
      #   :db        => an OSMLib::Database object
      #   :callbacks => an OSMLib::Stream::Callbacks object (or more likely from a derived class)
      #                 if none was given a new OSM:Callbacks object is created
      #
      # You can only use :filename or :string, not both.
      def self.new(options)
        eval "OSMLib::Stream::Parser::#{OSMLib::Stream.XMLParser}.new(options)"
      end

    end

  end
end

require "osmlib/stream/parser/#{OSMLib::Stream.XMLParser.downcase}"
