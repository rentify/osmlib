$: << 'lib'
require 'test/unit'
require 'osmlib'


class TestMembers < Test::Unit::TestCase

    def test_node
        member = OSMLib::Element::Member.new('node', 17, 'foo')
        assert_equal 'node', member.type
        assert_equal 17, member.ref
        assert_equal 'foo', member.role
    end

    def test_way
        member = OSMLib::Element::Member.new('way', 17)
        assert_equal 'way', member.type
        assert_equal 17, member.ref
        assert_equal '', member.role
    end

    def test_relation
        member = OSMLib::Element::Member.new('relation', 17, 'foo')
        assert_equal 'relation', member.type
        assert_equal 17, member.ref
        assert_equal 'foo', member.role
    end

    def test_fail
        assert_raise ArgumentError do
            OSMLib::Element::Member.new('unknown', 17, 'foo')
        end
    end

end
