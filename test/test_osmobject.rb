$: << 'lib'
require 'test/unit'
require 'osmlib'

class TestOSMLib < Test::Unit::TestCase

    def test_init
        assert_raise ArgumentError do
            OSMLib::Element::Object.new()
        end
        assert_raise ArgumentError do
            OSMLib::Element::Object.new(17)
        end
        assert_raise NotImplementedError do
            OSMLib::Element::Object.new(17, 'user', '2000-01-01T00:00:00Z')
        end
    end

end
