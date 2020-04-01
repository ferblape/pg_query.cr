require "json"

module PgQuery
  class Query
    getter! parse_tree : JSON::Any?

    # Use `PgQuery.parse` to create Query objects.
    protected def initialize(@query : String)
      result = LibPgQuery.pg_query_parse(@query)
      raise ParserError.new(result) unless result.error.null?

      parse_tree = String.new(result.parse_tree)
      begin
        @parse_tree = JSON.parse(parse_tree)
      rescue JSON::ParseException
        raise Error.new("Failed to parse JSON")
      end
    ensure
      LibPgQuery.pg_query_free_parse_result(result) unless result.nil?
    end

    # Return query fingerprint, same as PgQuery.fingerprint
    def fingerprint
      PgQuery.fingerprint(@query)
    end
  end
end
