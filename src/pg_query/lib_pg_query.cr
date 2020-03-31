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

  struct PgQueryParseResult
    parse_tree : LibC::Char*
    stderr_buffer : LibC::Char*
    error : PgQueryError*
  end

  struct PgQueryPlpgsqlParseResult
    plpgsql_funcs : LibC::Char*
    error : PgQueryError*
  end

  struct PgQueryFingerprintResult
    hexdigest : LibC::Char*
    stderr_buffer : LibC::Char*
    error : PgQueryError*
  end

  struct PgQueryNormalizeResult
    normalized_query : LibC::Char*
    error : PgQueryError*
  end

  fun pg_query_normalize(input : LibC::Char*) : PgQueryNormalizeResult
  fun pg_query_parse(input : LibC::Char*) : PgQueryParseResult
  fun pg_query_parse_plpgsql(input : LibC::Char*) : PgQueryPlpgsqlParseResult

  fun pg_query_fingerprint(input : LibC::Char*) : PgQueryFingerprintResult

  fun pg_query_free_normalize_result(result : PgQueryNormalizeResult) : Void
  fun pg_query_free_parse_result(result : PgQueryParseResult) : Void
  fun pg_query_free_plpgsql_parse_result(result : PgQueryPlpgsqlParseResult) : Void
  fun pg_query_free_fingerprint_result(result : PgQueryFingerprintResult) : Void
end
