Read-Only Tables using Triggers
===============================

13th September 2017

Creating a read-only table in Postgres is surprisingly simple:

```sql
CREATE OR REPLACE FUNCTION raise_exception() RETURNS TRIGGER AS $$
  BEGIN
    RAISE EXCEPTION '"%"', TG_ARGV[0];
    RETURN NULL;
  END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER some_table_read_only
  BEFORE INSERT OR UPDATE OR DELETE OR TRUNCATE  -- customise this part to make insertable but no updates
  ON some_table
  FOR EACH STATEMENT
  EXECUTE PROCEDURE raise_exception('some_table is read-only');
```
