# -----------------------------------------------------------------------------
#
# Error classes for OSM Lib
#
# -----------------------------------------------------------------------------

module OSMLib
  
  module Error

    # Unspecified OSM API error.
    class APIError < StandardError; end

    # The API returned more than one OSM object where it should only
    # have returned one.
    class APITooManyObjects < APIError; end

    # The API returned HTTP 400 (Bad Request).
    class APIBadRequest < APIError; end # 400

    # The API operation wasn't authorized. This happens if you didn't
    # set the user and password for a write operation.
    class APIUnauthorized < APIError; end # 401

    # The object was not found (HTTP 404). Generally means that the
    # object doesn't exist and never has.
    class APINotFound < APIError; end # 404

    # The object was not found (HTTP 410), but it used to exist. This
    # generally means that the object existed at some point, but was
    # deleted.
    class APIGone < APIError; end # 410

    # Unspecified API server error.
    class APIServerError < APIError; end # 500

    # This error is raised when an object is not associated with a
    # OSMLib::Database but database access is needed.
    class NoDatabaseError < StandardError
    end

    # This error is raised when a way that should be closed (i.e.
    # first node equals last node) but isn't.
    class NotClosedError < StandardError
    end

    # This error is raised when an OSM object is not associated with a
    # geometry.
    class NoGeometryError < StandardError
    end

    # This error is raised when an OSM object can't be turned into
    # a proper geometry. Happens if way has not enough nodes.
    class GeometryError < StandardError
    end

    # An object was not found in the database.
    class NotFoundError < StandardError
    end


  end
end