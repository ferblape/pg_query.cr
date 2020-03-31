require "./pg_query/lib_pg_query"

module PgQuery
  extend self

  VERSION = "0.1.0"

  class Error < Exception
    def initialize(result)
      super(String.new(result.error.value.message))
    end
  end

  def parse(query : String)
  end

  def normalize(query : String)
    result = LibPgQuery.pg_query_normalize(query)
    raise Error.new(result) if result.normalized_query.null?

    String.new(result.normalized_query)
  ensure
    LibPgQuery.pg_query_free_normalize_result(result) unless result.nil?
  end

  def fingerprint(query : String) : String
    result = LibPgQuery.pg_query_fingerprint(query)
    raise Error.new(result) if result.hexdigest.null?

    String.new(result.hexdigest)
  ensure
    LibPgQuery.pg_query_free_fingerprint_result(result) unless result.nil?
  end
end
