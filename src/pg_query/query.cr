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

    # Returns query fingerprint, same as PgQuery.fingerprint
    def fingerprint
      PgQuery.fingerprint(@query)
    end

    # Returns true/false if the query is a EXPLAIN query.
    def explain?
      tree = parse_tree.as_a?
      return false if tree.nil? || tree.empty?

      raw_stmt = tree[0]["RawStmt"]?
      return false if raw_stmt.nil?

      return raw_stmt["stmt"].as_h.has_key?("ExplainStmt")
    end
  end
end
