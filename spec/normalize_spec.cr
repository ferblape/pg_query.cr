require "./spec_helper"

describe PgQuery do
  it "normalizes a simple query" do
    q = PgQuery.normalize("SELECT 1")
    q.should eq("SELECT $1")
  end

  it "normalizes IN(...)" do
    q = PgQuery.normalize("SELECT 1 FROM x WHERE y = 12561 AND z = '124' AND b IN (1, 2, 3)")
    q.should eq("SELECT $1 FROM x WHERE y = $2 AND z = $3 AND b IN ($4, $5, $6)")
  end

  it "normalizes subselects" do
    q = PgQuery.normalize("SELECT 1 FROM x WHERE y = (SELECT 123 FROM a WHERE z = 'bla')")
    q.should eq("SELECT $1 FROM x WHERE y = (SELECT $2 FROM a WHERE z = $3)")
  end

  it "normalizes ANY(array[...])" do
    q = PgQuery.normalize("SELECT * FROM x WHERE y = ANY(array[1, 2])")
    q.should eq("SELECT * FROM x WHERE y = ANY(array[$1, $2])")
  end

  it "normalizes ANY(query)" do
    q = PgQuery.normalize("SELECT * FROM x WHERE y = ANY(SELECT 1)")
    q.should eq("SELECT * FROM x WHERE y = ANY(SELECT $1)")
  end

  it "works with complicated strings" do
    q = PgQuery.normalize("SELECT U&'d\\0061t\\+000061' FROM x")
    q.should eq("SELECT $1 FROM x")

    q = PgQuery.normalize("SELECT u&'d\\0061t\\+000061'    FROM x")
    q.should eq("SELECT $1    FROM x")

    q = PgQuery.normalize("SELECT * FROM x WHERE z NOT LIKE E'abc'AND TRUE")
    q.should eq("SELECT * FROM x WHERE z NOT LIKE $1AND $2")

    # We can't avoid this easily, so treat it as known behaviour that we remove comments in this case
    q = PgQuery.normalize("SELECT U&'d\\0061t\\+000061'-- comment\nFROM x")
    q.should eq("SELECT $1\nFROM x")
  end

  it "normalizes COPY" do
    q = PgQuery.normalize("COPY (SELECT * FROM t WHERE id IN ('1', '2')) TO STDOUT")
    q.should eq("COPY (SELECT * FROM t WHERE id IN ($1, $2)) TO STDOUT")
  end

  it "normalizes SETs" do
    q = PgQuery.normalize("SET test=123")
    q.should eq("SET test=$1")
  end

  it "normalizes weird SETs" do
    q = PgQuery.normalize("SET CLIENT_ENCODING = UTF8")
    q.should eq("SET CLIENT_ENCODING = $1")
  end

  it "does not fail if it does not understand parts of the statement" do
    q = PgQuery.normalize("DEALLOCATE bla; SELECT 1")
    q.should eq("DEALLOCATE bla; SELECT $1")
  end

  it "normalizes EPXLAIN" do
    q = PgQuery.normalize("EXPLAIN SELECT x FROM y WHERE z = 1")
    q.should eq("EXPLAIN SELECT x FROM y WHERE z = $1")
  end

  it "normalizes DECLARE CURSOR" do
    q = PgQuery.normalize("DECLARE cursor_b CURSOR FOR SELECT * FROM databases WHERE id = 23")
    q.should eq("DECLARE cursor_b CURSOR FOR SELECT * FROM databases WHERE id = $1")
  end
end
