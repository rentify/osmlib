$: << 'lib'
require 'test/unit'
require 'osmlib'

require 'rubygems'
require 'geo_ruby'

class TestGeometry < Test::Unit::TestCase

    def setup
        @db = OSMLib::Database.new
    end

    def test_node_geometry
        node = OSMLib::Element::Node.new(1, nil, nil, 10.4, 40.3)
        assert_kind_of GeoRuby::SimpleFeatures::Point, node.geometry
        assert_equal 10.4, node.geometry.lon
        assert_equal 40.3, node.geometry.lat
        assert_equal 10.4, node.point.lon
        assert_equal 40.3, node.point.lat
    end

    def test_node_geometry_nil
        node = OSMLib::Element::Node.new(1)
        assert_raise OSMLib::Error::GeometryError do
            node.geometry
        end
    end

    def test_node_shape
        node = OSMLib::Element::Node.new(1, nil, nil, 10.4, 40.3)
        attrs = {'a' => 'b', 'c' => 'd'}
        shape = node.shape(node.point, attrs)
        assert_kind_of GeoRuby::Shp4r::ShpRecord, shape
        assert_equal attrs, shape.data
        assert_kind_of GeoRuby::SimpleFeatures::Point, shape.geometry
        assert_equal node.geometry, shape.geometry
    end

    def test_way_geometry_nil
        way = OSMLib::Element::Way.new(1)
        assert_raise OSMLib::Error::GeometryError do
            way.linestring
        end
        assert_raise OSMLib::Error::GeometryError do
            way.polygon
        end
        assert_raise OSMLib::Error::GeometryError do
            way.geometry
        end

    end

    def test_way_geometry_fail
        way = OSMLib::Element::Way.new(1)
        way.nodes << OSMLib::Element::Node.new.id << OSMLib::Element::Node.new.id << OSMLib::Element::Node.new.id
        assert_raise OSMLib::Error::NoDatabaseError do
            way.linestring
        end
        assert_raise OSMLib::Error::NoDatabaseError do
            way.polygon
        end
        assert_raise OSMLib::Error::NoDatabaseError do
            way.geometry
        end
    end

    def test_way_geometry
        @db << (way = OSMLib::Element::Way.new(1))
        @db << (node1 = OSMLib::Element::Node.new(nil, nil, nil, 0, 0))
        @db << (node2 = OSMLib::Element::Node.new(nil, nil, nil, 0, 10))
        @db << (node3 = OSMLib::Element::Node.new(nil, nil, nil, 10, 10))

        assert_raise OSMLib::Error::GeometryError do
            way.linestring
        end
        assert_raise OSMLib::Error::GeometryError do
            way.polygon
        end
        assert_raise OSMLib::Error::GeometryError do
            way.geometry
        end

        way.nodes << node1.id

        assert_raise OSMLib::Error::GeometryError do
            way.linestring
        end
        assert_raise OSMLib::Error::GeometryError do
            way.polygon
        end
        assert_raise OSMLib::Error::GeometryError do
            way.geometry
        end

        way.nodes << node2.id

        assert_kind_of GeoRuby::SimpleFeatures::LineString, way.linestring
        assert_raise OSMLib::Error::GeometryError do
            way.polygon
        end
        assert_kind_of GeoRuby::SimpleFeatures::LineString, way.geometry

        way.nodes << node3.id

        assert_kind_of GeoRuby::SimpleFeatures::LineString, way.linestring
        assert_raise OSMLib::Error::NotClosedError do
            way.polygon
        end
        assert_kind_of GeoRuby::SimpleFeatures::LineString, way.geometry

        way.nodes << node1.id
        assert_kind_of GeoRuby::SimpleFeatures::Polygon, way.polygon

    end

    def test_relation_geometry
        rel = OSMLib::Element::Relation.new
        assert_raise OSMLib::Error::NoGeometryError do
            rel.geometry
        end
    end

end
