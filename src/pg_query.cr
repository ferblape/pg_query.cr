require "./pg_query/lib_pg_query"
require "./pg_query/query"

module PgQuery
  extend self

  VERSION         = "0.1.0"
  PG_VERSION      = "10.0"
  PG_MAJORVERSION = "10"
  PG_VERSION_NUM  = 100000

  class Error < Exception
    def initialize(message : String)
      super
    end

    def initialize(result)
      super(String.new(result.error.value.message))
    end
  end

  class ParserError < Error
    getter location : Int32 = 0

    def initialize(result)
      super
      @location = result.error.value.cursorpos
    end
  end

  def parse(query : String)
    Query.new(query)
  end

  def valid?(query : String)
    Query.new(query).valid?
  rescue Error
    false
  end

  def normalize(query : String)
    result = LibPgQuery.pg_query_normalize(query)
    raise Error.new(result) if result.normalized_query.null?

    String.new(result.normalized_query)
  ensure
    LibPgQuery.pg_query_free_normalize_result(result) unless result.nil?
  end

  def fingerprint(query : String)
    result = LibPgQuery.pg_query_fingerprint(query)
    raise Error.new(result) if result.hexdigest.null?

    String.new(result.hexdigest)
  ensure
    LibPgQuery.pg_query_free_fingerprint_result(result) unless result.nil?
  end
end
