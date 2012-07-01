$: << 'lib'
require 'test/unit'
require 'osmlib'

require 'net/http'

# This is a mock class that pretends to be a Net::HTTPResponse. It is called from some of the
# tests to fake the network interaction with the server.
class MockHTTPGetResponse

  attr_reader :code, :body

  def initialize(suffix)
    case suffix
    when 'node/1'
      @code = 200
      @body = %q{<?xml version="1.0" encoding="UTF-8"?>
        <osm version="0.6" generator="OpenStreetMap server">
        <node id="1" version="1" lat="48.1" lon="8.1" uid="1" user="u" visible="true" timestamp="2007-07-03T00:04:12+01:00">
        <tag k="created_by" v="JOSM"/>
        </node>
        </osm>
      }
    when 'node/2'
      @code = 200
      @body = %q{<?xml version="1.0" encoding="UTF-8"?>
        <osm version="0.6" generator="OpenStreetMap server">
        <node id="1" version="1" lat="48.1" lon="8.1" uid="1" user="u" visible="true" timestamp="2007-07-03T00:04:12+01:00">
        <tag k="created_by" v="JOSM"/>
        </node>
        <node id="2" version="1" lat="48.2" lon="8.2" uid="1" user="u" visible="true" timestamp="2007-07-03T00:04:12+01:00">
        <tag k="created_by" v="JOSM"/>
        </node>
        </osm>
      }
    when 'way/1'
      @code = 200
      @body = %q{<?xml version="1.0" encoding="UTF-8"?>
        <osm version="0.6" generator="OpenStreetMap server">
        <way id="1" version="1" visible="true" timestamp="2007-06-03T20:02:39+01:00" uid="1" user="u">
        <nd ref="1"/>
        <nd ref="2"/>
        <nd ref="3"/>
        <tag k="created_by" v="osmeditor2"/>
        <tag k="highway" v="residential"/>
        </way>
        </osm>
      }
    when 'way/2'
      @code = 200
      @body = %q{<?xml version="1.0" encoding="UTF-8"?>
        <osm version="0.6" generator="OpenStreetMap server">
        <way id="1" version="1" visible="true" timestamp="2007-06-03T20:02:39+01:00" uid="1" user="u">
        <nd ref="1"/>
        <nd ref="2"/>
        <nd ref="3"/>
        <tag k="created_by" v="osmeditor2"/>
        <tag k="highway" v="residential"/>
        </way>
        <way id="2" version="1" visible="true" timestamp="2007-06-03T20:02:39+01:00" uid="1" user="u">
        <nd ref="4"/>
        <nd ref="5"/>
        <nd ref="6"/>
        <tag k="created_by" v="osmeditor2"/>
        <tag k="highway" v="residential"/>
        </way>
        </osm>
      }
    when 'relation/1'
      @code = 200
      @body = %q{<?xml version="1.0" encoding="UTF-8"?>
        <osm version="0.6" generator="OpenStreetMap server">
        <relation id="1" version="1" visible="true" timestamp="2007-07-24T16:18:51+01:00" uid="1" user="u">
        <member type="way" ref="1" role=""/>
        <member type="way" ref="2" role=""/>
        <tag k="type" v="something"/>
        </relation>
        </osm>
      }
    when 'relation/2'
      @code = 200
      @body = %q{<?xml version="1.0" encoding="UTF-8"?>
        <osm version="0.6" generator="OpenStreetMap server">
        <relation id="1" version="1" visible="true" timestamp="2007-07-24T16:18:51+01:00" uid="1" user="u">
        <member type="way" ref="1" role=""/>
        <member type="way" ref="2" role=""/>
        <tag k="type" v="something"/>
        </relation>
        <relation id="2" version="1" visible="true" timestamp="2007-07-24T16:18:51+01:00" uid="1" user="u">
        <member type="way" ref="3" role=""/>
        <member type="way" ref="4" role=""/>
        <tag k="type" v="something"/>
        </relation>
        </osm>
      }
    when /^(node|way|relation)\/404$/
      @code = 404
      @body = ''
    when /^(node|way|relation)\/410$/
      @code = 410
      @body = ''
    when /^(node|way|relation)\/500$/
      @code = 500
      @body = ''
    when /^map\?bbox/
      @code = 200
      @body = %q{<?xml version="1.0" encoding="UTF-8"?>
        <osm version="0.6" generator="OpenStreetMap server">
        <node id="1" version="1" lat="48.1" lon="8.1" uid="1" user="u" visible="true" timestamp="2007-07-03T00:04:12+01:00">
        <tag k="created_by" v="JOSM"/>
        </node>
        <node id="2" version="1" lat="48.2" lon="8.2" uid="1" user="u" visible="true" timestamp="2007-07-03T00:04:12+01:00">
        <tag k="created_by" v="JOSM"/>
        </node>
        </osm>
      }

    when 'changeset/1'
      @code = 200
      @body = %q{<?xml version="1.0" encoding="UTF-8"?>
        <osm version="0.6" generator="OpenStreetMap server">
        <changeset id="1" user="u" uid="1" created_at="2011-05-18T12:38:17Z" closed_at="2011-05-18T12:38:19Z" open="false" min_lat="46.7733159" min_lon="23.5928252" max_lat="46.7733159" max_lon="23.5928252">
        <tag k="comment" v="Added street names"/>
        <tag k="created_by" v="Addressdust 0.1"/>
        </changeset>
        </osm>
      }

    else
      raise ArgumentError.new("unknown parameter: '#{suffix}'")
    end
  end

end

class MockHTTPPutResponse

  attr_reader :code, :body

  def initialize( suffix, put_data )
    case suffix
    when 'changeset/create'

      # Using a fixed osm xml for changeset creation to easier testing
      expected_put_data = %q{<?xml version='1.0' encoding='UTF-8'?><osm><changeset><tag k='created_by' v='my app'/><tag k='comments' v='added some points'/></changeset></osm>}
      if (put_data == expected_put_data )
        @code = 200
        @body = '1' # return changeset number
      else
        @code = 400 # bad request
        @body = ''
      end
    else
      raise ArgumentError.new("unknown parameter: '#{suffix}'")
    end
  end
end

class TestAPI < Test::Unit::TestCase

  def setup
    @api = OSMLib::API::Client.new

    @mapi = OSMLib::API::Client.new('http://mock/')
    def @mapi.get(suffix)
      MockHTTPGetResponse.new(suffix)
    end
    def @mapi.put(suffix, put_data)
      MockHTTPPutResponse.new(suffix, put_data)
    end
  end

  def test_create_std
    assert_kind_of OSMLib::API::Client, @api
    assert_equal 'http://www.openstreetmap.org/api/0.6/', @api.instance_variable_get(:@base_uri)
  end

  def test_create_uri
    api = OSMLib::API::Client.new('http://localhost/')
    assert_kind_of OSMLib::API::Client, api
    assert_equal 'http://localhost/', api.instance_variable_get(:@base_uri)
  end

  def test_get_object
    assert_raise ArgumentError do
      @mapi.get_object('foo', 1)
    end
  end

  # node

  def test_get_node_type_error
    assert_raise TypeError do
      @api.get_node('foo')
    end
    assert_raise TypeError do
      @api.get_node(-17)
    end
  end

  def test_get_node_200
    node = @mapi.get_node(1)
    assert_kind_of OSMLib::Element::Node, node
    assert_equal 1, node.id
    assert_equal '48.1', node.lat
    assert_equal '8.1', node.lon
    assert_equal 'u', node.user
  end

  def test_get_node_too_many_objects
    assert_raise OSMLib::Error::APITooManyObjects do
      @mapi.get_node(2)
    end
  end

  def test_get_node_404
    assert_raise OSMLib::Error::APINotFound do
      @mapi.get_node(404)
    end
  end

  def test_get_node_410
    assert_raise OSMLib::Error::APIGone do
      @mapi.get_node(410)
    end
  end

  def test_get_node_500
    assert_raise OSMLib::Error::APIServerError do
      @mapi.get_node(500)
    end
  end

  # way

  def test_get_way_type_error
    assert_raise TypeError do
      @api.get_way('foo')
    end
    assert_raise TypeError do
      @api.get_way(-17)
    end
  end

  def test_get_way_200
    way = @mapi.get_way(1)
    assert_kind_of OSMLib::Element::Way, way
    assert_equal 1, way.id
    assert_equal 'u', way.user
  end

  def test_get_way_404
    assert_raise OSMLib::Error::APINotFound do
      @mapi.get_way(404)
    end
  end

  def test_get_way_410
    assert_raise OSMLib::Error::APIGone do
      @mapi.get_way(410)
    end
  end

  def test_get_way_500
    assert_raise OSMLib::Error::APIServerError do
      @mapi.get_way(500)
    end
  end

  # relation

  def test_get_relation_type_error
    assert_raise TypeError do
      @api.get_relation('foo')
    end
    assert_raise TypeError do
      @api.get_relation(-17)
    end
  end

  def test_get_relation_200
    relation = @mapi.get_relation(1)
    assert_kind_of OSMLib::Element::Relation, relation
    assert_equal 1, relation.id
    assert_equal 'u', relation.user
  end

  def test_get_relation_404
    assert_raise OSMLib::Error::APINotFound do
      @mapi.get_relation(404)
    end
  end

  def test_get_relation_410
    assert_raise OSMLib::Error::APIGone do
      @mapi.get_relation(410)
    end
  end

  def test_get_relation_500
    assert_raise OSMLib::Error::APIServerError do
      @mapi.get_relation(500)
    end
  end

  def test_get_bbox_fail
    assert_raise TypeError do
      @api.get_bbox('a', 'b', 'c', 'd')
    end
    assert_raise TypeError do
      @api.get_bbox(1, 2, 3, -200)
    end
    assert_raise TypeError do
      @api.get_bbox(1, 2, -200, 3)
    end
    assert_raise TypeError do
      @api.get_bbox(1, -200, 2, 3)
    end
    assert_raise TypeError do
      @api.get_bbox(-200, 1, 2, 3)
    end
  end

  def test_get_bbox
    db = @mapi.get_bbox(8.1, 48.1, 8.2, 48.2)
    assert_kind_of OSMLib::Database, db
    assert_equal "48.1", db.get_node(1).lat
    assert_equal "8.2", db.get_node(2).lon
  end

  def test_create_changeset
    response = @mapi.create_changeset({ "created_by" => "my app", "comments" => "added some points"})
    changeset_id = response.body.to_i
    assert changeset_id > 0
  end

  def test_get_changeset_fail
    assert_raise TypeError do
      @mapi.get_changeset(-11)
    end    

    assert_raise TypeError do
      @mapi.get_changeset(0)
    end    

    assert_raise TypeError do
      @mapi.get_changeset("as")
    end    

  end

  def test_get_changeset_id_1
    changeset = @mapi.get_changeset(1)

    assert_kind_of OSMLib::Element::Changeset, changeset
    assert_equal 1, changeset.id
    assert_equal 'u', changeset.user
    assert_equal 1, changeset.uid 
    assert_equal "2011-05-18T12:38:17Z", changeset.created_at 
    assert_equal "2011-05-18T12:38:19Z", changeset.closed_at
    assert_equal false,  changeset.open
    assert_equal 46.7733159, changeset.min_lat
    assert_equal 23.5928252, changeset.min_lon
    assert_equal 46.7733159, changeset.max_lat
    assert_equal 23.5928252, changeset.max_lon    
  end


end

