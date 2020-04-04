# pg_query.cr

Crystal bindings for [libpg_query](https://github.com/lfittl/libpg_query).


## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     pg_query:
       github: hugopl/pg_query.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "pg_query"

puts PgQuery.normalize("SELECT foo FROM bar WHERE x > 4 AND Y LIKE 'something'")
# "SELECT foo FROM bar WHERE x > $1 AND Y LIKE $2"

puts PgQuery.fingerprint("SELECT 'hello world'")
# "02a281c251c3a43d2fe7457dff01f76c5cc523f8c8"

query = PgQuery.parse("SELECT foo FROM bar WHERE x > 4 AND Y LIKE 'something'")
puts query.parse_tree # Returns a Json::Any object.
# [{"RawStmt" => {"stmt" => {"SelectStmt" => {"targetList" => [{"ResTarget" => {"val" => {"ColumnRef" => {"fields" => [{"String" => {"str" => "foo"}}], "location" => 7}}, "location" => 7}}], "fromClause" => [{"RangeVar" => {"relname" => "bar", "inh" => true, "relpersistence" => "p", "location" => 16}}], "whereClause" => {"BoolExpr" => {"boolop" => 0, "args" => [{"A_Expr" => {"kind" => 0, "name" => [{"String" => {"str" => ">"}}], "lexpr" => {"ColumnRef" => {"fields" => [{"String" => {"str" => "x"}}], "location" => 26}}, "rexpr" => {"A_Const" => {"val" => {"Integer" => {"ival" => 4}}, "location" => 30}}, "location" => 28}}, {"A_Expr" => {"kind" => 8, "name" => [{"String" => {"str" => "~~"}}], "lexpr" => {"ColumnRef" => {"fields" => [{"String" => {"str" => "y"}}], "location" => 36}}, "rexpr" => {"A_Const" => {"val" => {"String" => {"str" => "something"}}, "location" => 43}}, "location" => 38}}], "location" => 32}}, "op" => 0}}}}]

query = PgQuery.parse("EXPLAIN SELECT foo FROM bar")
puts query.explain?
# true
```

## TODO

Helper methods on PgQuery::Query object to fetch information like what tables were used in the query, what columns were selected, etc... aren't implemented.

## Contributing

1. Fork it (<https://github.com/hugopl/pg_query.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Hugo Parente Lima](https://github.com/hugopl) - creator and maintainer
