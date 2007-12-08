$: << 'lib'
require File.join(File.dirname(__FILE__), '..', 'lib', 'OSM', 'objects.rb')
require 'test/unit'

class RelationTest < Test::Unit::TestCase

    def test_create
        relation = OSM::Relation.new(123, 'somebody', '2007-02-20T10:29:49+00:00')
        assert_kind_of OSM::Relation, relation
        assert_equal 123, relation.id
        assert_equal 'somebody', relation.user
        assert_equal '2007-02-20T10:29:49+00:00', relation.timestamp
        assert_equal '#<OSM::Relation id="123" user="somebody" timestamp="2007-02-20T10:29:49+00:00">', relation.to_s

        assert_kind_of Hash, relation.tags
        assert relation.tags.empty?
        assert_nil relation.tags['foo']

        hash = {:id => 123, :user => 'somebody', :timestamp => '2007-02-20T10:29:49+00:00'}
        assert_equal hash, relation.attributes
    end

    def test_init_id
        relation1 = OSM::Relation.new
        relation2 = OSM::Relation.new
        relation3 = OSM::Relation.new(4)
        assert relation1.id < 0
        assert relation2.id < 0
        assert_not_equal relation1.id, relation2.id
        assert_equal 4, relation3.id
    end

    def test_set_id
        relation = OSM::Relation.new
        assert_raise NotImplementedError do
            relation.id = 1
        end
    end

    def test_set_user
        relation = OSM::Relation.new
        assert_nil relation.user
        relation.user = 'me'
        assert_equal 'me', relation.user
    end

    def test_set_timestamp
        relation = OSM::Relation.new
        assert_nil relation.timestamp
        assert_raise ArgumentError do
            relation.timestamp = 'xxx'
        end
        relation.timestamp = '2007-06-17T16:02:34+01:00'
        assert_equal '2007-06-17T16:02:34+01:00', relation.timestamp
    end

    def test_tags1
        relation = OSM::Relation.new
        assert relation.tags.empty?
        assert ! relation.is_tagged?

        relation.tags['highway'] = 'residential'
        assert ! relation.tags.empty?
        assert relation.is_tagged?

        assert_equal 'residential', relation.tags['highway']
        assert_equal 'residential', relation['highway']
        assert_equal 'residential', relation.highway
        assert_nil relation.tags['doesnt_exist']

        relation['name'] = 'Main Street'
        assert_equal 'Main Street', relation['name']

        assert_equal 2, relation.tags.size
    end

    def test_tags2
        relation = OSM::Relation.new
        relation.add_tags('amenity' => 'fuel', 'name' => 'ESSO')

        assert_equal 'fuel', relation.tags['amenity']
        assert_equal 'ESSO', relation.tags['name']
        assert_equal 'ESSO', relation.name

        assert_equal 2, relation.tags.size
    end

    def test_id_type
        assert_kind_of OSM::Relation, OSM::Relation.new('123')
        assert_kind_of OSM::Relation, OSM::Relation.new(123)
        assert_raise ArgumentError do
            OSM::Relation.new('foo')
        end
        assert_raise ArgumentError do
            OSM::Relation.new('123x')
        end
        assert_raise ArgumentError do
            OSM::Relation.new(123.3)
        end
        assert_raise ArgumentError do
            OSM::Relation.new(Hash.new)
        end
    end

end