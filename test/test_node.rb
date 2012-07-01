$: << 'lib'
require 'test/unit'
require 'osmlib'

class TestNode < Test::Unit::TestCase

    def test_create
        node = OSMLib::Element::Node.new(17, 'somebody', '2007-02-20T10:29:49+00:00', 8.5, 47.5, 5, 3)
        assert_kind_of OSMLib::Element::Node, node
        assert_equal 17, node.id
        assert_equal 'somebody', node.user
        assert_equal '2007-02-20T10:29:49+00:00', node.timestamp
        assert_equal '#<OSMLib::Element::Node id="17" user="somebody" timestamp="2007-02-20T10:29:49+00:00" lon="8.5" lat="47.5">', node.to_s

        assert_kind_of Hash, node.tags
        assert node.tags.empty?
        assert_nil node.tags['foo']

        hash = {:id => 17, :version => 3, :uid => 5, :user => 'somebody', :timestamp => '2007-02-20T10:29:49+00:00', :lon => '8.5', :lat => '47.5'}
        assert_equal hash, node.attributes
    end

    def test_init_id
        node1 = OSMLib::Element::Node.new
        node2 = OSMLib::Element::Node.new
        node3 = OSMLib::Element::Node.new(4)
        node4 = OSMLib::Element::Node.new(-3)
        assert node1.id < 0
        assert node2.id < 0
        assert_not_equal node1.id, node2.id
        assert_equal 4, node3.id
        assert_equal -3, node4.id
    end

    def test_set_id
        node = OSMLib::Element::Node.new
        assert_raise NotImplementedError do
            node.id = 1
        end
    end

    def test_set_user
        node = OSMLib::Element::Node.new
        assert_nil node.user
        node.user = 'me'
        assert_equal 'me', node.user
    end

    def test_set_timestamp
        node = OSMLib::Element::Node.new
        assert_nil node.timestamp
        assert_raise ArgumentError do
            node.timestamp = 'xxx'
        end
        node.timestamp = '2007-06-17T16:02:34+01:00'
        assert_equal '2007-06-17T16:02:34+01:00', node.timestamp
    end

    def test_tags1
        node = OSMLib::Element::Node.new
        assert node.tags.empty?
        assert ! node.is_tagged?

        node.tags['tourism'] = 'hotel'
        assert ! node.tags.empty?
        assert node.is_tagged?

        assert_equal 'hotel', node.tags['tourism']
        assert_equal 'hotel', node['tourism']
        assert_equal 'hotel', node.tourism
        assert_nil node.tags['doesnt_exist']

        node['name'] = 'Hotel Alfredo'
        assert_equal 'Hotel Alfredo', node['name']

        assert_equal 2, node.tags.size
    end

    def test_tag2
        node = OSMLib::Element::Node.new
        node.add_tags('amenity' => 'fuel', 'name' => 'ESSO')

        assert_equal 'fuel', node.tags['amenity']
        assert_equal 'ESSO', node.tags['name']
        assert_equal 'ESSO', node.name

        assert_equal 2, node.tags.size
    end

    def test_method_missing
        node = OSMLib::Element::Node.new
        assert_equal 'foo', node.bar = 'foo'
        assert_equal 'foo', node.bar
        assert ! node.bar?
        assert_raise ArgumentError do
            node.call(:bar=, 'x', 'y')
        end
        assert_raise ArgumentError do
            node.call(:bar?, 'x')
        end
        assert_raise ArgumentError do
            node.call(:bar, 'x')
        end
    end

    def test_tag_boolean
        node = OSMLib::Element::Node.new
        node.add_tags('true1' => 'true', 'true2' => 'yes', 'true3' => '1', 'false1' => 'x', 'false2' => '0')

        assert node.true1?
        assert node.true2?
        assert node.true3?
        assert ! node.false1?
        assert ! node.false2?
    end

    def test_id_type
        assert_kind_of OSMLib::Element::Node, OSMLib::Element::Node.new('123')
        assert_kind_of OSMLib::Element::Node, OSMLib::Element::Node.new(123)
        assert_raise ArgumentError do
            OSMLib::Element::Node.new('foo')
        end
        assert_raise ArgumentError do
            OSMLib::Element::Node.new('123x')
        end
        assert_raise ArgumentError do
            OSMLib::Element::Node.new(123.3)
        end
        assert_raise ArgumentError do
            OSMLib::Element::Node.new(Hash.new)
        end
    end

    def test_lat
        node = OSMLib::Element::Node.new(123)
        assert_raise ArgumentError do
            node.lat = Hash.new
        end
        assert_nil node.lat
        node.lat = '123.45'
        assert_equal '123.45', node.lat
        node.lat = 123.45
        assert_equal '123.45', node.lat
    end

    def test_lon
        node = OSMLib::Element::Node.new(123)
        assert_raise ArgumentError do
            node.lon = Hash.new
        end
        assert_nil node.lon
        node.lon = '123.45'
        assert_equal '123.45', node.lon
        node.lon = 123.45
        assert_equal '123.45', node.lon
    end

    def test_magic_add_hash
        node = OSMLib::Element::Node.new
        node << { 'a' => 'b' } << { 'c' => 'd' }
        assert_equal 'b', node.tags['a']
        assert_equal 'd', node.tags['c']
    end

    def test_magic_add_tags
        node = OSMLib::Element::Node.new
        tags = OSMLib::Element::Tags.new
        tags['a'] = 'b'
        node << tags
        assert_equal 'b', node.tags['a']
    end

    def test_magic_add_array
        node = OSMLib::Element::Node.new
        node << [{'a' => 'b'}, {'c' => 'd'}]
        assert_equal 'b', node.tags['a']
        assert_equal 'd', node.tags['c']
    end

end
