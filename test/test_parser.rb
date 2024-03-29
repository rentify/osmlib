$: << 'lib'
require 'test/unit'
require 'osmlib'

require 'rubygems'
require 'builder'

class CallbacksForTests < OSMLib::Stream::Callbacks

    include Test::Unit::Assertions

    def node(node)
        @node = node
    end

    def way(way)
    end

    def relation(relation)
    end

    def result
        @node
    end

end

class TestParser < Test::Unit::TestCase

    def test_create_fail
        assert_raise ArgumentError do
            OSMLib::Stream::Parser.new
        end
        assert_raise ArgumentError do
            OSMLib::Stream::Parser.new(:filename => 'foo', :string => 'bar')
        end
    end

    def test_create_with_file
        parser = OSMLib::Stream::Parser.new(:filename => 'test/test.osm', :callbacks => CallbacksForTests.new)
        node = parser.parse
        assert_kind_of OSMLib::Element::Node, node
        assert_equal "48.9629821", node.lat
    end

    def test_create_with_string1
        parser = OSMLib::Stream::Parser.new(:callbacks => CallbacksForTests.new, :string => %q{<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.5" generator="OpenStreetMap server">
  <node id="17905203" lat="48.9614113" lon="8.3046066" user="test" visible="true" timestamp="2007-04-09T22:16:39+01:00">
    <tag k="created_by" v="JOSM"/>
  </node>
</osm>
        })
        node = parser.parse
        assert_kind_of OSMLib::Element::Node, node
        assert_equal "48.9614113", node.lat
    end

    def test_create_with_string2
        parser = OSMLib::Stream::Parser.new(:callbacks => CallbacksForTests.new, :string => %q{<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.5" generator="OpenStreetMap server">
  <node id="-2" lat="48.9614113" lon="8.3046066" user="test" visible="true" timestamp="2007-04-09T22:16:39+01:00">
    <tag k="created_by" v="JOSM"/>
  </node>
</osm>
        })
        node = parser.parse
        assert_kind_of OSMLib::Element::Node, node
        assert_equal -2, node.id
    end

end
