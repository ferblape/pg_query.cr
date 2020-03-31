PG_QUERY_VERSION = "10-1.0.2"

.PHONY: all configure

all: build/lib_pgquery/libpg_query.a

configure:
	mkdir -p build
	cd build/lib_pgquery || git clone https://github.com/lfittl/libpg_query.git build/lib_pgquery
	cd build/lib_pgquery && git checkout $(PG_QUERY_VERSION)

build/lib_pgquery/libpg_query.a: build/lib_pgquery/src/pg_query.c
	cd build/lib_pgquery && make -j4
	