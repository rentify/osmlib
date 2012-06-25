$: << 'lib'
require File.join(File.dirname(__FILE__), '..', 'lib', 'OSM', 'Changeset')
require 'test/unit'
require 'net/http'


class TestChangeset < Test::Unit::TestCase

  def setup
    @api = OSM::API.new

    @mapi = OSM::API.new('http://mock/')
    def @mapi.get(suffix)
      MockHTTPResponse.new(suffix)
    end
  end

  def test_get_changeset_bad_id
    assert_raise TypeError do
      @mapi.get_changeset(-11)
    end    
  end

  def test_get_changeset_id_1
    changeset = OSM::Changeset.from_api( 1,  @mapi )

    assert_kind_of OSM::Changeset, changeset
    assert_equal 1, changeset.id
    assert_equal 'u', changeset.user
    assert_equal 1, changeset.uid 
    assert_equal "2011-05-18T12:38:17Z", changeset.created_at 
    assert_equal "2011-05-18T12:38:19Z", changeset.closed_at
    assert_equal false,  changeset.open
    assert_equal 46.7733159, changeset.min_lat
    assert_equal 23.5928252, changeset.min_lon
    assert_equal 46.7733159, changeset.max_lat
    assert_equal 23.5928252, changeset.max_lon
    
  end

end