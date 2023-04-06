Generated Columns
=================


Database support:

PostgreSQL
----------

 - https://www.postgresql.org/docs/current/ddl-generated-columns.html

```
GENERATED ALWAYS AS ( generation_expr ) STORED
```

 - Only stored columns
 - Cannot refer to other generated columns


SQLite
------
 - https://www.sqlite.org/gencol.html

```
GENERATED ALWAYS AS ( expression ) [ STORED | VIRTUAL ]
```

 - Cannot add stored columns to existing tables, only virtual columns
 - Can refer to other generated columns, but not to itself


MySQL
-----

 - https://dev.mysql.com/doc/refman/8.0/en/create-table-generated-columns.html

```
[GENERATED ALWAYS] AS (expr) [VIRTUAL | STORED]
```

 - Can refer to "earlier" generated columns


Oracle
------

 - https://oracle-base.com/articles/11g/virtual-columns-11gr1

```
[generated always] as (expression) [virtual]
```

- Only virtual columns
- Cannot refer to other generated columns

