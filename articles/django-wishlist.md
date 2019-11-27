Django Wishlist:
================

Generated Columns
-----------------

Generated columns exist in PostgreSQL 12+ (stored only), MySQL 5.x+ & SQLite. Generating the syntax for
the DDL here is the easy part as the expression API can compile the expression used.  The obstacle is Django:

 - Django has no way of arbitrarily skipping fields during insert.  Field defaults are managed by Django
   rather than at the db layer (so one cannot affect skipping a field this way).  The field list to add
   to the insert statement is determined by 2 things:
    - Is it an auto field?  Only 1 can be set per model and is it's used for the pk.
    - Is it a concrete field?  Concrete fields are fields not backed by a database column, turning this off
      means that the field is never selected during database queries.

 - The insert & update statements need to make use of RETURNING to return the updated value.  ATM only
   the auto generated pk is returned.

 - Users of the model will just have to ignore these attributes for unsaved model instances otherwise
   come up with something akin to hybrid attributes on something like SQLAlchemy
 
Some relevant discussion:
 - ... 


Database Level Defaults
-----------------------

Some relevant discussion:
 - ... 


Database Level Delete Cascades
------------------------------


Custom migration operations, custom meta
----------------------------------------

Without having to monkey-patch Django


Enforcing same-parent type database relationships
-------------------------------------------------

Convincing clients to add composite keys to enforce additional attributes across a relationship is hard enough,
trying to convince them to "pollute" many-to-many relationships with those same attributes to enable the 
integrity constraint to span the m2m is even harder and has many steps involved.  Having a simple declarative
way of doing this would be easier to sell.
