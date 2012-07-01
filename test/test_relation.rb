$: << 'lib'
require 'test/unit'
require 'osmlib'

class TestRelation < Test::Unit::TestCase

    def test_create
        relation = OSMLib::Element::Relation.new(123, 'somebody', '2007-02-20T10:29:49+00:00', [], 3, 5)
        assert_kind_of OSMLib::Element::Relation, relation
        assert_equal 123, relation.id
        assert_equal 'somebody', relation.user
        assert_equal '2007-02-20T10:29:49+00:00', relation.timestamp
        assert_equal '#<OSMLib::Element::Relation id="123" user="somebody" timestamp="2007-02-20T10:29:49+00:00">', relation.to_s

        assert_kind_of Hash, relation.tags
        assert relation.tags.empty?
        assert_nil relation.tags['foo']

        hash = {:id => 123, :version => 5, :uid => 3, :user => 'somebody', :timestamp => '2007-02-20T10:29:49+00:00'}
        assert_equal hash, relation.attributes
    end

    def test_init_id
        relation1 = OSMLib::Element::Relation.new
        relation2 = OSMLib::Element::Relation.new
        relation3 = OSMLib::Element::Relation.new(4)
        relation4 = OSMLib::Element::Relation.new(-3)
        assert relation1.id < 0
        assert relation2.id < 0
        assert_not_equal relation1.id, relation2.id
        assert_equal 4, relation3.id
        assert_equal -3, relation4.id
    end

    def test_set_id
        relation = OSMLib::Element::Relation.new
        assert_raise NotImplementedError do
            relation.id = 1
        end
    end

    def test_set_user
        relation = OSMLib::Element::Relation.new
        assert_nil relation.user
        relation.user = 'me'
        assert_equal 'me', relation.user
    end

    def test_set_timestamp
        relation = OSMLib::Element::Relation.new
        assert_nil relation.timestamp
        assert_raise ArgumentError do
            relation.timestamp = 'xxx'
        end
        relation.timestamp = '2007-06-17T16:02:34+01:00'
        assert_equal '2007-06-17T16:02:34+01:00', relation.timestamp
    end

    def test_tags1
        relation = OSMLib::Element::Relation.new
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
        relation = OSMLib::Element::Relation.new
        relation.add_tags('amenity' => 'fuel', 'name' => 'ESSO')

        assert_equal 'fuel', relation.tags['amenity']
        assert_equal 'ESSO', relation.tags['name']
        assert_equal 'ESSO', relation.name

        assert_equal 2, relation.tags.size
    end

    def test_id_type
        assert_kind_of OSMLib::Element::Relation, OSMLib::Element::Relation.new('123')
        assert_kind_of OSMLib::Element::Relation, OSMLib::Element::Relation.new(123)
        assert_raise ArgumentError do
            OSMLib::Element::Relation.new('foo')
        end
        assert_raise ArgumentError do
            OSMLib::Element::Relation.new('123x')
        end
        assert_raise ArgumentError do
            OSMLib::Element::Relation.new(123.3)
        end
        assert_raise ArgumentError do
            OSMLib::Element::Relation.new(Hash.new)
        end
    end

    def test_magic_add_hash
        relation = OSMLib::Element::Relation.new
        relation << { 'a' => 'b' } << { 'c' => 'd' }
        assert_equal 'b', relation.tags['a']
        assert_equal 'd', relation.tags['c']
    end

    def test_magic_add_tags
        relation = OSMLib::Element::Relation.new
        tags = OSMLib::Element::Tags.new
        tags['a'] = 'b'
        relation << tags
        assert_equal 'b', relation.tags['a']
    end

    def test_magic_add_array
        relation = OSMLib::Element::Relation.new
        relation << [{'a' => 'b'}, {'c' => 'd'}]
        assert_equal 'b', relation.tags['a']
        assert_equal 'd', relation.tags['c']
    end

    def test_magic_add_node
        relation = OSMLib::Element::Relation.new
        relation << node = OSMLib::Element::Member.new('node', 21, 'foo')
        assert ! relation.is_tagged?
        assert_equal 1, relation.members.size
        assert_equal node, relation.members[0]
        assert_equal 'node', relation.members[0].type
        assert_equal node, relation.member('node', 21)
        assert_nil relation.member('node', 22)
    end

end
