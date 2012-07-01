$: << 'lib'
require 'test/unit'
require 'osmlib'

require 'rexml/document'
require 'rubygems'
require 'builder'

# In this file we test all the
# functionality related to the
# visable flag on OSM objects.

class TestVisible < Test::Unit::TestCase

  def setup
    @out = ''
    @doc = Builder::XmlMarkup.new(:target => @out)
  end
  
  def test_node_nil
    node = OSMLib::Element::Node.new(17, 'somebody', '2007-02-20T10:29:49+00:00', 8.5, 47.5, 5, 3)
    assert_equal nil, node.visible
    assert_equal '#<OSMLib::Element::Node id="17" user="somebody" timestamp="2007-02-20T10:29:49+00:00" lon="8.5" lat="47.5">', node.to_s
  end

  def test_node_visible
    node = OSMLib::Element::Node.new(17, 'somebody', '2007-02-20T10:29:49+00:00', 8.5, 47.5, 5, 3, true)
    assert_equal true, node.visible
    assert_equal '#<OSMLib::Element::Node id="17" user="somebody" timestamp="2007-02-20T10:29:49+00:00" lon="8.5" lat="47.5" visible="true">', node.to_s
  end

  def test_node_invisible
    node = OSMLib::Element::Node.new(17, 'somebody', '2007-02-20T10:29:49+00:00', 8.5, 47.5, 5, 3, false)
    assert_equal false, node.visible
    assert_equal '#<OSMLib::Element::Node id="17" user="somebody" timestamp="2007-02-20T10:29:49+00:00" lon="8.5" lat="47.5" visible="false">', node.to_s
  end

  def test_way_nil
    way = OSMLib::Element::Way.new(123, 'somebody', '2007-02-20T10:29:49+00:00', [], 3, 5)
    assert_equal nil, way.visible
    assert_equal '#<OSMLib::Element::Way id="123" user="somebody" timestamp="2007-02-20T10:29:49+00:00">', way.to_s
  end

  def test_way_true
    way = OSMLib::Element::Way.new(123, 'somebody', '2007-02-20T10:29:49+00:00', [], 3, 5, true)
    assert_equal true, way.visible
    assert_equal '#<OSMLib::Element::Way id="123" user="somebody" timestamp="2007-02-20T10:29:49+00:00" visible="true">', way.to_s
  end

  def test_way_false
    way = OSMLib::Element::Way.new(123, 'somebody', '2007-02-20T10:29:49+00:00', [], 3, 5, false)
    assert_equal false, way.visible
    assert_equal '#<OSMLib::Element::Way id="123" user="somebody" timestamp="2007-02-20T10:29:49+00:00" visible="false">', way.to_s
  end

  def test_relation_nil
    relation = OSMLib::Element::Relation.new(123, 'somebody', '2007-02-20T10:29:49+00:00', [], 3, 5)
    assert_equal nil, relation.visible
    assert_equal '#<OSMLib::Element::Relation id="123" user="somebody" timestamp="2007-02-20T10:29:49+00:00">', relation.to_s
  end

  def test_relation_true
    relation = OSMLib::Element::Relation.new(123, 'somebody', '2007-02-20T10:29:49+00:00', [], 3, 5, true)
    assert_equal true, relation.visible
    assert_equal '#<OSMLib::Element::Relation id="123" user="somebody" timestamp="2007-02-20T10:29:49+00:00" visible="true">', relation.to_s
  end

  def test_relation_false
    relation = OSMLib::Element::Relation.new(123, 'somebody', '2007-02-20T10:29:49+00:00', [], 3, 5, false)
    assert_equal false, relation.visible
    assert_equal '#<OSMLib::Element::Relation id="123" user="somebody" timestamp="2007-02-20T10:29:49+00:00" visible="false">', relation.to_s
  end

  def test_node_xml_true
    node = OSMLib::Element::Node.new(45, 'user', '2007-12-12T01:01:01Z', 10.0, 20.0)
    node.visible = true
    node.to_xml(@doc)    
    rexml = REXML::Document.new(@out)
    element = REXML::XPath.first(rexml, '/node')
    assert_equal 'true', REXML::XPath.first(rexml, '/node/@visible').value
  end
  
  def test_node_xml_false
    node = OSMLib::Element::Node.new(45, 'user', '2007-12-12T01:01:01Z', 10.0, 20.0)
    node.visible = false
    node.to_xml(@doc)    
    rexml = REXML::Document.new(@out)
    element = REXML::XPath.first(rexml, '/node')
    assert_equal 'false', REXML::XPath.first(rexml, '/node/@visible').value
  end

  def test_node_xml_nil
    node = OSMLib::Element::Node.new(45, 'user', '2007-12-12T01:01:01Z', 10.0, 20.0)
    node.to_xml(@doc)    
    rexml = REXML::Document.new(@out)
    element = REXML::XPath.first(rexml, '/node')
    assert_equal nil, REXML::XPath.first(rexml, '/node/@visible')
  end
end
