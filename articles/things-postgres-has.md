Things Django developers (may not) know PostgreSQL has
======================================================


Generated Columns
------------------

https://www.postgresql.org/docs/14/ddl-generated-columns.html

 - Computed column
 - Stored as a physical table column and written on insert/update or
   - computed on-the-fly is not yet implemented
 - Read-only
 - Can be used as a foreign key reference

Restrictions:
 - Cannot reference anything other than the current row
 - Cannot reference another generated column
 - Only use immutable functions


Updatable Views
---------------

https://www.postgresql.org/docs/current/sql-createview.html#SQL-CREATEVIEW-UPDATABLE-VIEWS

 - Simple views only referencing a single table and no complex SQL (set operations, CTEs, aggregation, distinct etc)
 - Columns are updatable if simply referencing an underlying column otherwise read-only
 - By default INSERT and UPDATE can create/move rows "outside" the view with a WHERE clause. CHECK OPTION can prevent this.


Series Generation
-----------------

Sparsely populated data can be aggregated by regular intervals thanks to a handy postgres function: generate_series()


Foreign Tables
--------------


Table Inheritance
-----------------

Table Partitioning
------------------

