$: << 'lib'
require 'test/unit'
require 'osmlib'

class TestWay < Test::Unit::TestCase

    def test_create
        way = OSMLib::Element::Way.new(123, 'somebody', '2007-02-20T10:29:49+00:00', [], 3, 5)
        assert_kind_of OSMLib::Element::Way, way
        assert_equal 123, way.id
        assert_equal 'somebody', way.user
        assert_equal '2007-02-20T10:29:49+00:00', way.timestamp
        assert_equal '#<OSMLib::Element::Way id="123" user="somebody" timestamp="2007-02-20T10:29:49+00:00">', way.to_s

        assert_kind_of Hash, way.tags
        assert way.tags.empty?
        assert_nil way.tags['foo']

        hash = {:id => 123, :version => 5, :uid => 3, :user => 'somebody', :timestamp => '2007-02-20T10:29:49+00:00'}
        assert_equal hash, way.attributes
    end

    def test_init_id
        way1 = OSMLib::Element::Way.new
        way2 = OSMLib::Element::Way.new
        way3 = OSMLib::Element::Way.new(4)
        way4 = OSMLib::Element::Way.new(-3)
        assert way1.id < 0
        assert way2.id < 0
        assert_not_equal way1.id, way2.id
        assert_equal 4, way3.id
        assert_equal -3, way4.id
    end

    def test_set_id
        way = OSMLib::Element::Way.new
        assert_raise NotImplementedError do
            way.id = 1
        end
    end

    def test_set_user
        way = OSMLib::Element::Way.new
        assert_nil way.user
        way.user = 'me'
        assert_equal 'me', way.user
    end

    def test_set_timestamp
        way = OSMLib::Element::Way.new
        assert_nil way.timestamp
        assert_raise ArgumentError do
            way.timestamp = 'xxx'
        end
        way.timestamp = '2007-06-17T16:02:34+01:00'
        assert_equal '2007-06-17T16:02:34+01:00', way.timestamp
    end

    def test_tags1
        way = OSMLib::Element::Way.new
        assert way.tags.empty?
        assert ! way.is_tagged?

        way.tags['highway'] = 'residential'
        assert ! way.tags.empty?
        assert way.is_tagged?

        assert_equal 'residential', way.tags['highway']
        assert_equal 'residential', way['highway']
        assert_equal 'residential', way.highway
        assert_nil way.tags['doesnt_exist']

        way['name'] = 'Main Street'
        assert_equal 'Main Street', way['name']

        assert_equal 2, way.tags.size
    end

    def test_tags2
        way = OSMLib::Element::Way.new
        way.add_tags('amenity' => 'fuel', 'name' => 'ESSO')

        assert_equal 'fuel', way.tags['amenity']
        assert_equal 'ESSO', way.tags['name']
        assert_equal 'ESSO', way.name

        assert_equal 2, way.tags.size
    end

    def test_id_type
        assert_kind_of OSMLib::Element::Way, OSMLib::Element::Way.new('123')
        assert_kind_of OSMLib::Element::Way, OSMLib::Element::Way.new(123)
        assert_raise ArgumentError do
            OSMLib::Element::Way.new('foo')
        end
        assert_raise ArgumentError do
            OSMLib::Element::Way.new('123x')
        end
        assert_raise ArgumentError do
            OSMLib::Element::Way.new(123.3)
        end
        assert_raise ArgumentError do
            OSMLib::Element::Way.new(Hash.new)
        end
    end

    def test_closed
        way = OSMLib::Element::Way.new
        assert ! way.is_closed?
        way.nodes << (node = OSMLib::Element::Node.new(1)).id
        assert ! way.is_closed?
        way.nodes << OSMLib::Element::Node.new(2).id
        assert ! way.is_closed?
        way.nodes << OSMLib::Element::Node.new(3).id
        assert ! way.is_closed?
        way.nodes << node.id
        assert way.is_closed?
    end

    def test_init_with_node_ids
        node1 = OSMLib::Element::Node.new
        node2 = OSMLib::Element::Node.new
        way = OSMLib::Element::Way.new(nil, nil, nil, [node1.id, node2.id])
        assert_equal node1.id, way.nodes[0]
        assert_equal node2.id, way.nodes[1]
    end

    def test_init_with_nodes
        node1 = OSMLib::Element::Node.new
        node2 = OSMLib::Element::Node.new
        way = OSMLib::Element::Way.new(nil, nil, nil, [node1, node2])
        assert_equal node1.id, way.nodes[0]
        assert_equal node2.id, way.nodes[1]
    end

    def test_magic_add_hash
        way = OSMLib::Element::Way.new
        way << { 'a' => 'b' } << { 'c' => 'd' }
        assert_equal 'b', way.tags['a']
        assert_equal 'd', way.tags['c']
    end

    def test_magic_add_tags
        way = OSMLib::Element::Way.new
        tags = OSMLib::Element::Tags.new
        tags['a'] = 'b'
        way << tags
        assert_equal 'b', way.tags['a']
    end

    def test_magic_add_array
        way = OSMLib::Element::Way.new
        way << [{'a' => 'b'}, {'c' => 'd'}]
        assert_equal 'b', way.tags['a']
        assert_equal 'd', way.tags['c']
    end

    def test_magic_add_node
        way = OSMLib::Element::Way.new
        way << 17 << 21 << "22" << OSMLib::Element::Node.new(23)
        assert ! way.is_tagged?
        assert_equal [17, 21, 22, 23], way.nodes
    end

end
