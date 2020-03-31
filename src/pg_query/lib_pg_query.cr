@[Link(ldflags: "#{__DIR__}/../../build/lib_pgquery/libpg_query.a")]
lib LibPgQuery
  struct PgQueryError
    message : LibC::Char*  # exception message
    funcname : LibC::Char* # source function of exception (e.g. SearchSysCache)
    filename : LibC::Char* # source of exception (e.g. parse.l)
    lineno : Int32         # source of exception (e.g. 104)
    cursorpos : Int32      # char in query at which exception occurred
    context : LibC::Char*  # additional context (optional, can be NULL)
  end

  struct PgQueryFingerprintResult
    hexdigest : LibC::Char*
    stderr_buffer : LibC::Char*
    error : PgQueryError*
  end

  # PgQueryNormalizeResult pg_query_normalize(const char* input);
  # PgQueryParseResult pg_query_parse(const char* input);
  # PgQueryPlpgsqlParseResult pg_query_parse_plpgsql(const char* input);

  fun pg_query_fingerprint(input : LibC::Char*) : PgQueryFingerprintResult

  # void pg_query_free_normalize_result(PgQueryNormalizeResult result);
  # void pg_query_free_parse_result(PgQueryParseResult result);
  # void pg_query_free_plpgsql_parse_result(PgQueryPlpgsqlParseResult result);
  fun pg_query_free_fingerprint_result(result : PgQueryFingerprintResult) : Void
end
