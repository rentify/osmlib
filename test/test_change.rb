$: << 'lib'
require 'test/unit'
require 'osmlib'

class TestChange < Test::Unit::TestCase
  def test_init
    assert_nothing_raised do
      change = OSMLib::OSMChange::Change.new
    end
  end
  def test_actions
    node =  OSMLib::Element::Node.new(17, 'somebody', '2007-02-20T10:29:49+00:00', 8.5, 47.5, 5, 3)
    way = way = OSMLib::Element::Way.new(123, 'somebody', '2007-02-20T10:29:49+00:00', [], 3, 5)
    action1 = OSMLib::OSMChange::Action.new(:modify)
    action1.objects = [node]
    action2 = OSMLib::OSMChange::Action.new(:create)
    action2.objects = [way]                         
    change = OSMLib::OSMChange::Change.new
    change.push action1
    change.push action2
    assert_equal change.actions, [action1, action2]
  end
  def test_objects
    node =  OSMLib::Element::Node.new(17, 'somebody', '2007-02-20T10:29:49+00:00', 8.5, 47.5, 5, 3)
    way = way = OSMLib::Element::Way.new(123, 'somebody', '2007-02-20T10:29:49+00:00', [], 3, 5)
    action1 = OSMLib::OSMChange::Action.new(:modify)
    action1.objects = [node]
    action2 = OSMLib::OSMChange::Action.new(:create)
    action2.objects = [way]                         
    change = OSMLib::OSMChange::Change.new
    change.push action1
    change.push action2
    assert_equal change.objects, [node, way]
  end
end
    
