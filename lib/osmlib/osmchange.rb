module OSMLib
  
  # 
  # OSMLib::OSMChange::Change objects consist of OSMLib::OSMChange::Action objects, which contain a
  # single action as well as one or more Node, Way or Relation. An action
  # must be created with an action keyword :create, :modify, or :delete)
  # 
  #   change = OSMLib::OSMChange::Change.new
  # 
  #   node = OSMLib::Element::Node.new(17, 'user', '2007-10-31T23:48:54Z', 7.4, 53.2)
  #   action = OSMLib::OSMChange::Action.new(:create)
  #   action.push(node)
  # 
  # OSMLib::OSMChange::Change objects have two relevant methods, .actions, which returns
  # an Array of OSMLib::OSMChange::Actions, and objects, which returns all the objects
  # in all the actions.
  # 
  #    actions = change.actions
  #    objects = change.objects
  # 
  
  module OSMChange
  end
end

# Implementation files
require 'osmlib/osmchange/action'
require 'osmlib/osmchange/change'
