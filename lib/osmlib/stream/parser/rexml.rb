# Contains the OSMLib::Stream::REXML class.

require 'rexml/parsers/sax2parser'
require 'rexml/sax2listener'

# Namespace for modules and classes related to the OpenStreetMap project.
module OSMLib
  module Stream

    # Stream parser for OpenStreetMap XML files.
    class Parser::REXML < OSMLib::Stream::ParserBase

      # Create new StreamParser object. Only argument is a hash.
      #
      # call-seq: OSMLib::Stream::Parser.new(:filename => 'filename.osm')
      #           OSMLib::Stream::Parser.new(:string => '...')
      #
      # The hash keys:
      #   :filename  => name of XML file
      #   :string    => XML string
      #   :db        => an OSMLib::Database object
      #   :callbacks => an OSMLib::Stream::Callbacks object (or more likely from a
      #   derived class)
      #                 if none was given a new OSM:Callbacks object is
      #                 created
      #
      # You can only use :filename or :string, not both.
      def initialize(options)
        super(options)

        source = if @filename
          File.new(@filename)
        else
          @string
        end
        @parser = REXML::Parsers::SAX2Parser.new(source)
        @parser.listen(@callbacks)
      end

      # Run the parser. Return value is the return value of the
      # OSMLib::Stream::Callbacks#result method.
      def parse
        @callbacks.on_start_document
        @parser.parse
        @callbacks.on_end_document
        @callbacks.result
      end

    end

  end
end