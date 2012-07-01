$: << 'lib'
require 'test/unit'
require 'osmlib'

class TestAction < Test::Unit::TestCase
  
  def test_init
    assert_raise ArgumentError do
      OSMLib::OSMChange::Action.new()
    end
    assert_raise TypeError do
      OSMLib::OSMChange::Action.new(17)
    end
    assert_nothing_raised do
      OSMLib::OSMChange::Action.new(:create)
    end
  end
  
  def test_create
    action = OSMLib::OSMChange::Action.new(:create)
    assert_equal action.type, :create
  end
  
  def test_node
    node = OSMLib::Element::Node.new(17, 'somebody', '2007-02-20T10:29:49+00:00', 8.5, 47.5, 5, 3)
    create = OSMLib::OSMChange::Action.new(:create)
    create.push node
    assert_equal create.objects, [node]
  end

  def test_list
    node =  OSMLib::Element::Node.new(17, 'somebody', '2007-02-20T10:29:49+00:00', 8.5, 47.5, 5, 3)
    way = way = OSMLib::Element::Way.new(123, 'somebody', '2007-02-20T10:29:49+00:00', [], 3, 5)
    relation = OSMLib::Element::Relation.new(123, 'somebody', '2007-02-20T10:29:49+00:00', [], 3, 5)
    action = OSMLib::OSMChange::Action.new(:modify)
    action.objects = [node, way, relation]
    assert_equal  action.objects, [node, way, relation]
  end
end
