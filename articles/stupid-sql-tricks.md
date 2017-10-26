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

Django equivalent:

```python
# assuming A & B are querysets
not A.difference(B).exists()
```

Equivalent sets
---------------

Is resultset A equivalent to resultset B?

```sql
select not exists (select * from A except select * from B) and
       not exists (select * from B except select * from A)
```

or

```sql
select not exists(
  select * from A except select * from B
  union
  select * from B except select * from A
)
```

Django equivalent:

```python
not A.difference(B).union(B.difference(A)).exists()
```
