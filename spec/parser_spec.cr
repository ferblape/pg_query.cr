require "./spec_helper"

describe PgQuery do
  it "parses a simple query" do
    query = PgQuery.parse("SELECT 1")
    query.parse_tree.to_s.should eq "[{\"RawStmt\" => {\"stmt\" => {\"SelectStmt\" => {\"targetList\" => [{\"ResTarget\" => {\"val\" => {\"A_Const\" => {\"val\" => {\"Integer\" => {\"ival\" => 1}}, \"location\" => 7}}, \"location\" => 7}}], \"op\" => 0}}}}]"
  end

  it "can give us the query fingerprint" do
    query = PgQuery.parse("SELECT 1")
    query.fingerprint.should eq("02a281c251c3a43d2fe7457dff01f76c5cc523f8c8")
  end

  it "handles errors" do
    expect_raises(PgQuery::Error, "unterminated quoted string at or near \"'ERR\"") do
      PgQuery.parse("SELECT 'ERR")
    end

    begin
      PgQuery.parse("SELECT 'ERR")
    rescue e : PgQuery::ParserError
      e.location.should eq(8)
    end
  end

  it "returns JSON error due to too much nesting" do
    query_text = "SELECT a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(a(b))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))"
    expect_raises(PgQuery::Error, "Failed to parse JSON") do
      PgQuery.parse(query_text)
    end
  end

  pending "parses real queries" do
    query = PgQuery.parse("SELECT memory_total_bytes, memory_free_bytes, memory_pagecache_bytes, memory_buffers_bytes, memory_applications_bytes, (memory_swap_total_bytes - memory_swap_free_bytes) AS swap, date_part($0, s.collected_at) AS collected_at FROM snapshots s JOIN system_snapshots ON (snapshot_id = s.id) WHERE s.database_id = $0 AND s.collected_at BETWEEN $0 AND $0 ORDER BY collected_at")
    query.tables.should eq %w(snapshots system_snapshots)
    query.select_tables.should eq %w(snapshots system_snapshots)
  end

  #   it "parses empty queries" do
  #     query = PgQuery.parse("-- nothing")
  #     expect(query.tables).to eq []
  #     expect(query.warnings).to be_empty
  #   end

  #   it "parses ALTER TABLE" do
  #     query = PgQuery.parse("ALTER TABLE test ADD PRIMARY KEY (gid)")
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['test']
  #     expect(query.ddl_tables).to eq ['test']
  #   end

  #   it "parses SET" do
  #     query = PgQuery.parse("SET statement_timeout=0")
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq []
  #   end

  #   it "parses SHOW" do
  #     query = PgQuery.parse("SHOW work_mem")
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq []
  #   end

  #   it "parses COPY" do
  #     query = PgQuery.parse("COPY test (id) TO stdout")
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['test']
  #   end

  #   it "parses DROP TABLE" do
  #     query = PgQuery.parse("drop table abc.test123 cascade")
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['abc.test123']
  #     expect(query.ddl_tables).to eq ['abc.test123']
  #   end

  #   it "parses VACUUM" do
  #     query = PgQuery.parse("VACUUM my_table")
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['my_table']
  #     expect(query.ddl_tables).to eq ['my_table']
  #   end

  #   it "parses EXPLAIN" do
  #     query = PgQuery.parse("EXPLAIN DELETE FROM test")
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['test']
  #   end

  #   it "parses SELECT INTO" do
  #     query = PgQuery.parse("CREATE TEMP TABLE test AS SELECT 1")
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['test']
  #     expect(query.ddl_tables).to eq ['test']
  #   end

  #   it "parses LOCK" do
  #     query = PgQuery.parse("LOCK TABLE public.schema_migrations IN ACCESS SHARE MODE")
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['public.schema_migrations']
  #   end

  #   it 'parses CREATE TABLE' do
  #     query = PgQuery.parse('CREATE TABLE test (a int4)')
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['test']
  #     expect(query.ddl_tables).to eq ['test']
  #   end

  #   it 'parses CREATE TABLE WITH OIDS' do
  #     query = PgQuery.parse('CREATE TABLE test (a int4) WITH OIDS')
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['test']
  #     expect(query.ddl_tables).to eq ['test']
  #   end

  #   it 'parses CREATE INDEX' do
  #     query = PgQuery.parse('CREATE INDEX testidx ON test USING gist (a)')
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['test']
  #     expect(query.ddl_tables).to eq ['test']
  #   end

  #   it 'parses CREATE SCHEMA' do
  #     query = PgQuery.parse('CREATE SCHEMA IF NOT EXISTS test AUTHORIZATION joe')
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq []
  #   end

  #   it 'parses CREATE VIEW' do
  #     query = PgQuery.parse('CREATE VIEW myview AS SELECT * FROM mytab')
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['myview', 'mytab']
  #     expect(query.ddl_tables).to eq ['myview']
  #     expect(query.select_tables).to eq ['mytab']
  #   end

  #   it 'parses REFRESH MATERIALIZED VIEW' do
  #     query = PgQuery.parse('REFRESH MATERIALIZED VIEW myview')
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['myview']
  #     expect(query.ddl_tables).to eq ['myview']
  #   end

  #   it 'parses CREATE RULE' do
  #     query = PgQuery.parse('CREATE RULE shoe_ins_protect AS ON INSERT TO shoe
  #                            DO INSTEAD NOTHING')
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['shoe']
  #   end

  #   it 'parses CREATE TRIGGER' do
  #     query = PgQuery.parse('CREATE TRIGGER check_update
  #                            BEFORE UPDATE ON accounts
  #                            FOR EACH ROW
  #                            EXECUTE PROCEDURE check_account_update()')
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['accounts']
  #   end

  #   it 'parses DROP SCHEMA' do
  #     query = PgQuery.parse('DROP SCHEMA myschema')
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq []
  #   end

  #   it 'parses DROP VIEW' do
  #     query = PgQuery.parse('DROP VIEW myview, myview2')
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq []
  #   end

  #   it 'parses DROP INDEX' do
  #     query = PgQuery.parse('DROP INDEX CONCURRENTLY myindex')
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq []
  #   end

  #   it 'parses DROP RULE' do
  #     query = PgQuery.parse('DROP RULE myrule ON mytable CASCADE')
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['mytable']
  #   end

  #   it 'parses DROP TRIGGER' do
  #     query = PgQuery.parse('DROP TRIGGER IF EXISTS mytrigger ON mytable RESTRICT')
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['mytable']
  #   end

  #   it 'parses GRANT' do
  #     query = PgQuery.parse('GRANT INSERT, UPDATE ON mytable TO myuser')
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['mytable']
  #     expect(query.ddl_tables).to eq ['mytable']
  #   end

  #   it 'parses REVOKE' do
  #     query = PgQuery.parse('REVOKE admins FROM joe')
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq []
  #   end

  #   it 'parses TRUNCATE' do
  #     query = PgQuery.parse('TRUNCATE bigtable, fattable RESTART IDENTITY')
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['bigtable', 'fattable']
  #     expect(query.ddl_tables).to eq ['bigtable', 'fattable']
  #   end

  #   it 'parses WITH' do
  #     query = PgQuery.parse('WITH a AS (SELECT * FROM x WHERE x.y = ? AND x.z = 1) SELECT * FROM a')
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['x']
  #     expect(query.cte_names).to eq ['a']
  #   end

  #   it 'parses table functions' do
  #     query = PgQuery.parse("CREATE FUNCTION getfoo(int) RETURNS TABLE (f1 int) AS '
  #     SELECT * FROM foo WHERE fooid = $1;
  # ' LANGUAGE SQL")
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq []
  #   end

  #   # https://github.com/lfittl/pg_query/issues/38
  #   it 'correctly finds nested tables in select clause' do
  #     query = PgQuery.parse("select u.email, (select count(*) from enrollments e where e.user_id = u.id) as num_enrollments from users u")
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['users', 'enrollments']
  #     expect(query.select_tables).to eq ['users', 'enrollments']
  #   end

  #   # https://github.com/lfittl/pg_query/issues/52
  #   it 'correctly separates CTE names from table names' do
  #     query = PgQuery.parse("WITH cte_name AS (SELECT 1) SELECT * FROM table_name, cte_name")
  #     expect(query.cte_names).to eq ['cte_name']
  #     expect(query.tables).to eq ['table_name']
  #     expect(query.select_tables).to eq ['table_name']
  #   end

  #   it 'correctly finds nested tables in from clause' do
  #     query = PgQuery.parse("select u.* from (select * from users) u")
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['users']
  #     expect(query.select_tables).to eq ['users']
  #   end

  #   it 'correctly finds nested tables in where clause' do
  #     query = PgQuery.parse("select users.id from users where 1 = (select count(*) from user_roles)")
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['users', 'user_roles']
  #     expect(query.select_tables).to eq ['users', 'user_roles']
  #   end

  #   it 'correctly finds tables in a select that has sub-selects without from clause' do
  #     query = PgQuery.parse('SELECT * FROM pg_catalog.pg_class c JOIN (SELECT 17650 AS oid UNION ALL SELECT 17663 AS oid) vals ON c.oid = vals.oid')
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ["pg_catalog.pg_class"]
  #     expect(query.select_tables).to eq ["pg_catalog.pg_class"]
  #     expect(query.filter_columns).to eq [["pg_catalog.pg_class", "oid"], ["vals", "oid"]]
  #   end

  #   it 'traverse boolean expressions in where clause' do
  #     query = PgQuery.parse(<<-SQL)
  #       select users.*
  #       from users
  #       where users.id IN (
  #         select user_roles.user_id
  #         from user_roles
  #       ) and (users.created_at between '2016-06-01' and '2016-06-30')
  #     SQL
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['users', 'user_roles']
  #   end

  #   it 'correctly finds nested tables in the order by clause' do
  #     query = PgQuery.parse(<<-SQL)
  #       select users.*
  #       from users
  #       order by (
  #         select max(user_roles.role_id)
  #         from user_roles
  #         where user_roles.user_id = users.id
  #       )
  #     SQL
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['users', 'user_roles']
  #   end

  #   it 'correctly finds nested tables in the order by clause with multiple entries' do
  #     query = PgQuery.parse(<<-SQL)
  #       select users.*
  #       from users
  #       order by (
  #         select max(user_roles.role_id)
  #         from user_roles
  #         where user_roles.user_id = users.id
  #       ) asc, (
  #         select max(user_logins.role_id)
  #         from user_logins
  #         where user_logins.user_id = users.id
  #       ) desc
  #     SQL
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['users', 'user_roles', 'user_logins']
  #   end

  #   it 'correctly finds nested tables in the group by clause' do
  #     query = PgQuery.parse(<<-SQL)
  #       select users.*
  #       from users
  #       group by (
  #         select max(user_roles.role_id)
  #         from user_roles
  #         where user_roles.user_id = users.id
  #       )
  #     SQL
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['users', 'user_roles']
  #   end

  #   it 'correctly finds nested tables in the group by clause with multiple entries' do
  #     query = PgQuery.parse(<<-SQL)
  #       select users.*
  #       from users
  #       group by (
  #         select max(user_roles.role_id)
  #         from user_roles
  #         where user_roles.user_id = users.id
  #       ), (
  #         select max(user_logins.role_id)
  #         from user_logins
  #         where user_logins.user_id = users.id
  #       )
  #     SQL
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['users', 'user_roles', 'user_logins']
  #   end

  #   it 'correctly finds nested tables in the having clause' do
  #     query = PgQuery.parse(<<-SQL)
  #       select users.*
  #       from users
  #       group by users.id
  #       having 1 > (
  #         select count(user_roles.role_id)
  #         from user_roles
  #         where user_roles.user_id = users.id
  #       )
  #     SQL
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['users', 'user_roles']
  #   end

  #   it 'correctly finds nested tables in the having clause with a boolean expression' do
  #     query = PgQuery.parse(<<-SQL)
  #       select users.*
  #       from users
  #       group by users.id
  #       having true and 1 > (
  #         select count(user_roles.role_id)
  #         from user_roles
  #         where user_roles.user_id = users.id
  #       )
  #     SQL
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['users', 'user_roles']
  #   end

  #   it 'correctly finds nested tables in a subselect on a join' do
  #     query = PgQuery.parse(<<-SQL)
  #       select foo.*
  #       from foo
  #       join ( select * from bar ) b
  #       on b.baz = foo.quux
  #     SQL
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['foo', 'bar']
  #   end

  #   it 'does not list CTEs as tables after a union select' do
  #     query = PgQuery.parse(<<-SQL)
  #       with cte_a as (
  #         select * from table_a
  #       ), cte_b as (
  #         select * from table_b
  #       )
  #       select id from table_c
  #       left join cte_b on
  #         table_c.id = cte_b.c_id
  #       union
  #       select * from cte_a
  #     SQL
  #     expect(query.tables).to match_array(['table_a', 'table_b', 'table_c'])
  #     expect(query.cte_names).to match_array(['cte_a', 'cte_b'])
  #   end

  #   describe 'parsing INSERT' do
  #     it 'finds the table inserted into' do
  #       query = PgQuery.parse(<<-SQL)
  #         insert into users(pk, name) values (1, 'bob');
  #       SQL
  #       expect(query.warnings).to be_empty
  #       expect(query.tables).to eq(['users'])
  #     end

  #     it 'finds tables in being selected from for insert' do
  #       query = PgQuery.parse(<<-SQL)
  #         insert into users(pk, name) select pk, name from other_users;
  #       SQL
  #       expect(query.warnings).to be_empty
  #       expect(query.tables).to match_array(['users', 'other_users'])
  #     end

  #     it 'finds tables in a CTE' do
  #       query = PgQuery.parse(<<-SQL)
  #         with cte as (
  #           select pk, name from other_users
  #         )
  #         insert into users(pk, name) select * from cte;
  #       SQL
  #       expect(query.warnings).to be_empty
  #       expect(query.tables).to match_array(['users', 'other_users'])
  #     end
  #   end

  #   describe 'parsing UPDATE' do
  #     it 'finds the table updateed into' do
  #       query = PgQuery.parse(<<-SQL)
  #         update users set name = 'bob';
  #       SQL
  #       expect(query.warnings).to be_empty
  #       expect(query.tables).to eq(['users'])
  #     end

  #     it 'finds tables in a sub-select' do
  #       query = PgQuery.parse(<<-SQL)
  #         update users set name = (select name from other_users limit 1);
  #       SQL
  #       expect(query.warnings).to be_empty
  #       expect(query.tables).to match_array(['users', 'other_users'])
  #     end

  #     it 'finds tables in a CTE' do
  #       query = PgQuery.parse(<<-SQL)
  #         with cte as (
  #           select name from other_users limit 1
  #         )
  #         update users set name = (select name from cte);
  #       SQL
  #       expect(query.warnings).to be_empty
  #       expect(query.tables).to match_array(['users', 'other_users'])
  #     end
  #   end

  #   it 'handles DROP TYPE' do
  #     query = PgQuery.parse("DROP TYPE IF EXISTS repack.pk_something")
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq []
  #   end

  #   it 'handles COPY' do
  #     query = PgQuery.parse("COPY (SELECT test FROM abc) TO STDOUT WITH (FORMAT 'csv')")
  #     expect(query.warnings).to eq []
  #     expect(query.tables).to eq ['abc']
  #   end
end
