The Anatomy of a Recursive CTE
==============================

30th August 2017

Recursion is a useful feature of a programming language to delve deep into repetitive data structures of unknown depth.  It's particularly
useful for traversing graph based data structures such as trees.  Recursion involves the use of a function to tackle the analysis
in a divide-and-conquer approach - the function will analyse a particular segment of something and delegate the rest (usually another
layer) to another call of itself.


The basics
----------

Recursion must involve 3 things:

1. A seed for the calculations;
2. A method for progressing onto the next segment of processing;
3. The recusive call itself; and
4. A way to stop the recursion


A simple example in Python
--------------------------

Using the simplest possible example, counting 1 to 5, a recursive solution in Python would look like:

```python
>>> def count_to_5(counter=1):          # Initialisation: set the counter to 1
...      print(counter)
...      if counter < 5:                # The stop: when counter gets to 5 we no longer recurse and start returning
...          counter += 1               # Progression: increment the counter
...          count_to_5(counter)        # The recursion
...
>>> count_to_5()
1
2
3
4
5
```


Recursive SQL
-------------

It's possible to use recursion in a relational database with the use of a similar feature in SQL: The Common Table Expression (CTE).
CTEs are reusable pieces of a query that help you break up complex queries into more human readable chunks; they can sort of be thought
of as the equivalent to functions.  A useful feature of CTEs is that you can recurse into them much like a function.

A recursive CTE works by producing a set of rows from the query structure:

```sql
non-recursive query component
union [all]
recursive query component
```

Reusing our count from 1 to 5 example as SQL, it would look like this:

```sql
=# with recursive test as (
  select 1 as counter            --< This is our seed value
  union
  select counter + 1 from test   --< Here is both the progression (counter + 1) and the progression (select … from test)
  where counter < 5              --< Here is our stop
)
select * from test;
 counter
---------
       1
       2
       3
       4
       5
(5 rows)
```

A more practical example for working with graph like data would be your classic parent/child 1-many relationship that forms a tree-like
structure.
