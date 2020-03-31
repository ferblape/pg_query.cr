require "./pg_query/lib_pg_query"

module PgQuery
  extend self

  VERSION = "0.1.0"

  class Error < Exception
  end

  def parse(query : String)
  end

  def normalize(query : String)
  end

  def fingerprint(query : String) : String
    result = LibPgQuery.pg_query_fingerprint(query)
    raise Error.new(String.new(result.error.value.message)) if result.hexdigest.null?

    String.new(result.hexdigest)
  ensure
    LibPgQuery.pg_query_free_fingerprint_result(result) unless result.nil?
  end
end
