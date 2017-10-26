Stupid SQL Tricks
=================

Subset
------

Is resultset A a subset of resultset B?

```sql
select not exists (
  select * from A
  except
  select * from B
)
```

Equivalent sets
---------------

Is resultset A equivalent to resultset B?

```sql
select not exists (select * from A except select * from B) and
       not exists (select * from B except select * from A)
```
