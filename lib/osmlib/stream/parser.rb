
# Namespace for modules and classes related to the OpenStreetMap project.
module OSMLib
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

require "osmlib/stream/parser/#{OSMLib::Stream.XMLParser}"