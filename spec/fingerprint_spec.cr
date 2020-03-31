require "./spec_helper"

describe PgQuery do
  it "works for basic cases" do
    PgQuery.fingerprint("SELECT 1").should eq(PgQuery.fingerprint("SELECT 2"))
    PgQuery.fingerprint("SELECT  1").should eq(PgQuery.fingerprint("SELECT 2"))
    PgQuery.fingerprint("SELECT A").should eq(PgQuery.fingerprint("SELECT a"))
    PgQuery.fingerprint("SELECT \"a\"").should eq(PgQuery.fingerprint("SELECT a"))
    PgQuery.fingerprint("  SELECT 1;").should eq(PgQuery.fingerprint("SELECT 2"))
    PgQuery.fingerprint("  ").should eq(PgQuery.fingerprint(""))
    PgQuery.fingerprint("--comment").should eq(PgQuery.fingerprint(""))

    # Test uniqueness
    PgQuery.fingerprint("SELECT a").should_not eq(PgQuery.fingerprint("SELECT b"))
    PgQuery.fingerprint("SELECT \"A\"").should_not eq(PgQuery.fingerprint("SELECT a"))
    PgQuery.fingerprint("SELECT * FROM a").should_not eq(PgQuery.fingerprint("SELECT * FROM b"))
  end

  it "works for multi-statement queries" do
    PgQuery.fingerprint("SET x=?; SELECT A").should eq(PgQuery.fingerprint("SET x=?; SELECT a"))
    PgQuery.fingerprint("SET x=?; SELECT A").should_not eq(PgQuery.fingerprint("SELECT a"))
  end

  it "ignores aliases" do
    PgQuery.fingerprint("SELECT a AS b").should eq(PgQuery.fingerprint("SELECT a AS c"))
    PgQuery.fingerprint("SELECT a").should eq(PgQuery.fingerprint("SELECT a AS c"))
    PgQuery.fingerprint("SELECT * FROM a AS b").should eq(PgQuery.fingerprint("SELECT * FROM a AS c"))
    PgQuery.fingerprint("SELECT * FROM a").should eq(PgQuery.fingerprint("SELECT * FROM a AS c"))
    PgQuery.fingerprint("SELECT * FROM (SELECT * FROM x AS y) AS a").should eq(PgQuery.fingerprint("SELECT * FROM (SELECT * FROM x AS z) AS b"))
    PgQuery.fingerprint("SELECT a AS b UNION SELECT x AS y").should eq(PgQuery.fingerprint("SELECT a AS c UNION SELECT x AS z"))
  end

  pending "ignores aliases referenced in query" do
    PgQuery.fingerprint("SELECT s1.id FROM snapshots s1").should eq(PgQuery.fingerprint("SELECT s2.id FROM snapshots s2"))
    PgQuery.fingerprint("SELECT a AS b ORDER BY b").should eq(PgQuery.fingerprint("SELECT a AS c ORDER BY c"))
  end

  it "ignores param references" do
    PgQuery.fingerprint("SELECT $1").should eq(PgQuery.fingerprint("SELECT $2"))
  end

  it "ignores SELECT target list ordering" do
    PgQuery.fingerprint("SELECT a, b FROM x").should eq(PgQuery.fingerprint("SELECT b, a FROM x"))
    PgQuery.fingerprint("SELECT ?, b FROM x").should eq(PgQuery.fingerprint("SELECT b, ? FROM x"))
    PgQuery.fingerprint("SELECT ?, ?, b FROM x").should eq(PgQuery.fingerprint("SELECT ?, b, ? FROM x"))

    # Test uniqueness
    PgQuery.fingerprint("SELECT a, c FROM x").should_not eq(PgQuery.fingerprint("SELECT b, a FROM x"))
    PgQuery.fingerprint("SELECT b FROM x").should_not eq(PgQuery.fingerprint("SELECT b, a FROM x"))
  end

  it "ignores INSERT cols ordering" do
    PgQuery.fingerprint("INSERT INTO test (a, b) VALUES (?, ?)").should eq(PgQuery.fingerprint("INSERT INTO test (b, a) VALUES (?, ?)"))

    # Test uniqueness
    PgQuery.fingerprint("INSERT INTO test (a, c) VALUES (?, ?)").should_not eq(PgQuery.fingerprint("INSERT INTO test (b, a) VALUES (?, ?)"))
    PgQuery.fingerprint("INSERT INTO test (b) VALUES (?, ?)").should_not eq(PgQuery.fingerprint("INSERT INTO test (b, a) VALUES (?, ?)"))
  end

  it "ignores IN list size (simple)" do
    q1 = "SELECT * FROM x WHERE y IN (?, ?, ?)"
    q2 = "SELECT * FROM x WHERE y IN (?)"
    PgQuery.fingerprint(q1).should eq(PgQuery.fingerprint(q2))
  end

  it "ignores IN list size (complex)" do
    q1 = "SELECT * FROM x WHERE y IN ( ?::uuid, ?::uuid, ?::uuid )"
    q2 = "SELECT * FROM x WHERE y IN ( ?::uuid )"
    PgQuery.fingerprint(q1).should eq(PgQuery.fingerprint(q2))
  end
end
