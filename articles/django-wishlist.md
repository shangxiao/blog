Django Wishlist:
================

Generated Columns
-----------------

Generated columns exist in PostgreSQL 12+ (stored only), MySQL 5.x+ & SQLite. Generating the syntax for
the DDL here is the easy part as the expression API can compile the expression used.  The obstacle is Django's
DML statements:

 - Django has no way of arbitrarily skipping fields during insert.  (Field defaults are managed by Django
   rather than at the db layer (so one cannot affect skipping a field this way.)  The field list to add
   to the insert statement is determined by 2 things:
    - Is it an auto field?  Only 1 can be set per model and is it's used for the pk.
    - Is it a concrete field?  Concrete fields are fields backed by a database column, turning this off
      means that the field is never selected during database queries.

 - The insert & update statements need to make use of RETURNING to return the updated value.  ATM only
   the auto generated pk is returned during an insert (for pg).  Note that RETURNING isn't supported by
   MySQL so additional fetching is required (basically do the same as is done for AUTO_INCREMENT).

 - Users of the model will just have to ignore these attributes for unsaved model instances otherwise
   come up with something akin to hybrid attributes on something like SQLAlchemy
 
Some relevant discussion:
 - https://code.djangoproject.com/ticket/21454
 - https://github.com/django/django/pull/7515
 - https://groups.google.com/forum/#!topic/django-developers/BDAlTyJwQeY
 
 
Composite Keys
--------------

 - https://groups.google.com/d/msg/django-developers/wakEPFMPiyQ/DcXNfL4sCQAJ


View-Backed Models
------------------

Currently to back a model with a view one needs to manually create this with a migration and set the `db_table` and
`managed=False` Meta options.  Preventing inserts & updates may be optional depending on whether the view is updatable.

It'd be more visible & convenient if you could define a view from the model Meta via a queryset however I believe there
may be issues with keeping the view up to date if the model updates.  This may be a good or bad thing.


Database Level Defaults
-----------------------

This would also need to rely on RETURNING similarly to generated columns.

Some relevant discussion:
 - https://code.djangoproject.com/ticket/470
 - https://groups.google.com/forum/#!topic/django-developers/3mcro17Gb40/discussion
 - SQLAlchemy support: https://docs.sqlalchemy.org/en/13/core/defaults.html#server-side-defaults


Database Level Delete Cascades
------------------------------

 - https://code.djangoproject.com/ticket/21961
 - https://github.com/django/django/pull/8661


Extendable Migration Auto-Detector & Model Meta
-----------------------------------------------

Without having to monkey-patch Django.  Having an extendable migration autodetector that allows us to create custom fields
that would require specific custom migrations.  In addition, allowing extensions to the model meta to allow
other custom migrations to take place would be helpful.


Enforcing same-parent type database relationships
-------------------------------------------------

Convincing clients to add composite keys to enforce additional attributes across a relationship is hard enough,
trying to convince them to "pollute" many-to-many relationships with those same attributes to enable the 
integrity constraint to span the m2m is even harder and has many steps involved.  Having a simple declarative
way of doing this would be easier to sell.  An additional benefit would be the automatic management of migrations
including dependencies of the fk to the newly created unique key (eg if in different apps).


Read-only Models & Fields
-------------------------

Aside from `editable=False` which only affects model forms & validation, a way to prevent inserts and/or updates,
depending on the use case, on either columns or rows would be helpful.  Eg: for an audit trail table you want to
allow inserts but not updates.  A trigger may be setup to raise exceptions for a row level blocking.
