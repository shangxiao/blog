Django Wishlist:
================

July 2024

Check constraints defined on the field
--------------------------------------

Note: In postgres at least there is no difference between defining check constraints at the table-level vs column-level.

I like code colocality. I like seeing the validation next to the field definition. Additionally validation that
constraints provide can be inferred similarly to validators - or even have validators define checks.


Old Wishlist
============

Unique Indexes
--------------

Unique indexes are distinct from unique constraints: The former is the mechanism enforcing the latter (at least in pg).
However, indexes support expressions whereas constraints do not. This may be useful in a few ways, for me at least I
found myself needing to setup a unique constraint on a json field's attribute.

Ticket created: https://code.djangoproject.com/ticket/32932#ticket


Generated Columns
-----------------

Now supported in Django 5.0+

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
 - https://code.djangoproject.com/ticket/28822
 
 
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

One possible work-around suggested by Simon Charette is to use the pre-migrate signal to inject operations into the
migration plan: https://groups.google.com/d/msg/django-developers/qRNkReCZiCk/Ah90crNFAAAJ

Related discussion:
 - https://groups.google.com/d/msg/django-developers/kqWJ2WsMW6w/BBrd3T5MBQAJ


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

Custom Joins
------------

 * More flexibility in defining queries
 * Better performance than an equivalent as a correlated subquery
 * https://code.djangoproject.com/ticket/29262
 * https://code.djangoproject.com/ticket/25590

Removing the Requirement for max_length
---------------------------------------

Postgres' own recommendation is to not bother using a limit with varchar types: https://wiki.postgresql.org/wiki/Don%27t_Do_This#Don.27t_use_varchar.28n.29_by_default

I'm not interested in using other databases, but one of Django's core principles is that it supports a wide range
of RDBMSs.  This means that the idea of removing the `max_length` requirement for PG was extensively discussed and
failed to reach a consensus:

 * https://code.djangoproject.com/ticket/14094
 * https://groups.google.com/forum/#!topic/django-developers/h1vMu_k0JcA/discussion

Improved Django Migrations
--------------------------

There are 2 areas I'd like to see Django migrations be improved in:

1. "Zero" Downtime Migrations

Migrations for high usage/volume sites & databases aren't just a straight forward push-migrate-update-code.  There are
a list of things that need addressing in this article, albeit from 2015 and the optional removal of transactions for some
data migrations is possible now: https://pankrat.github.io/2015/django-migrations-without-downtimes/

2. Non-Destructive Reversible Migrations

This may be more of a general ORM thing and I'm not sure what the end result would look like but the ability to switch
between features to support feature switching in continuos delivery. It's also possible that multiple leaf nodes of a
migration state graph be a thing here.

This place has been creating tools to help in this area: https://medium.com/3yourmind/keeping-django-database-migrations-backward-compatible-727820260dbb

Explicitly Named Primary Keys
-----------------------------

If the automatically generated primary key's name is explicitly named using the model's name then you could take advantage
of natural joins using the USING join condition to make joins more succinct.  You could also rely on Django's pk alias as a
shortcut to lengthy pk names.

Annotating with Q Objects
-------------------------

One useful case for annotating on filter-like expressions is to use them in a group by:

```
Foo.objects.annotate(bar_is_null=Q(bar__isnull=True)).values('bar_is_null').annotate(count=Count('*'))
```

However this is not supported: https://code.djangoproject.com/ticket/27021  The workaround listed is to use 
`ExpressionWrapper` although even that doesn't seem to work with Django 1.11?
