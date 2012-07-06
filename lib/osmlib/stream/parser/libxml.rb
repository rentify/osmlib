
require 'rubygems'
begin
  require 'xml/libxml'
rescue LoadError
  require 'libxml'
end

module OSMLib
  module Stream

    # Stream parser for OpenStreetMap XML files using Libxml.
    class Parser::Libxml < OSMLib::Stream::ParserBase

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

        @parser = XML::SaxParser.new
        if @filename.nil?
          @parser = XML::SaxParser.string(@string)
        else
          @parser = XML::SaxParser.file(@filename)
        end
        @parser.callbacks = @callbacks
      end

      # Run the parser. Return value is the return value of the
      # OSMLib::Stream::Callbacks#result method.
      def parse
        @parser.parse
        @callbacks.result
      end

    end

  end
end