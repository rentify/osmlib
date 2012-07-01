$: << 'lib'
require 'test/unit'
require 'osmlib'

class TestTags < Test::Unit::TestCase

    def setup
        @tags = OSMLib::Element::Tags.new
        @tags['foo'] = 'bar'
    end

    def test_set
        assert_equal 1, @tags.size
        assert_equal 'bar', @tags['foo']
    end

    def test_merge
        @tags.merge!('x' => 'y', 'a' => 'b')

        assert_equal 3, @tags.size
        assert_equal 'bar', @tags['foo']
        assert_equal 'y', @tags['x']
    end

end
