# Django Virtual Table Models

19th May 2019

Below is a demonstration how to use virtual tables as a sub-select with Django models. This is useful in setting up
pseudo models that are backed by complex queries formed from other sources with the advantage of having a Django model api.

## Why is this useful?

Often times we have a need to denormalise our schema design at certain points in our application to work with something more
suited to the context. In order to keep our database design normalised we can create specific projections of the database
design at different layers.  Often these are achievable with the Django ORM but sometimes we hit the limits of what we can
achieve with the ORM and custom SQL may be required.  These custom queries may be made at the api or model level or even
within the database as a view.

Executing a custom SQL query will result in a RawQuerySet which is a less powerful version of QuerySet.  We may find ourselves
requiring the features of QuerySet on top of the base raw query, such as annotations, filtering or aggregation.  We can do
this by creating a model specifically for this result schema and changing it's source so that it refers to our raw query
as a "virtual table".

## Virtual Tables in the Database

Modern relational databases allow users to construct complex queries through the use of virtual tables in sub queries.  These
sub queries may be declared in the FROM clause.  This is often done to work around the limitations of a single query - for eg
filtering by a calculated column declared in the SELECT clause. 

## Virtual Tables with Django Models

We can use this same approach with Django models with a little intervention on how Django constructs its query:

 * Django uses a class BaseTable to define the source table during its query compliation.  We can use a similaryly defined
   class to return our own virtual table.
 * The BaseTable class is added to a map of aliases on a QuerySet's Query class.  We can replace BaseTable with our version.
 * We can replace the table class during our queryset construction in our Model Manager's get_queryset() method.
 
Here is an example (demo at https://github.com/shangxiao/django-virtual-table-model-demo):


```python
class FooVirtualTable:
    """
    Replaces Django's BaseTable
    """
    table_name = 't'
    table_alias = 't'
    join_type = None
    parent_alias = None
    filtered_relation = None

    def as_sql(self, compiler, connection):
        # this is where BaseTable would normally just return the table's name
        return "(select 1 as id, 'bar' as foo) t", []


class FooManager(models.Manager):
    def get_queryset(self):
        qs = super().get_queryset()
        # The goal here is to replace the base physical table in qs.query.alias_map with our virtual table.
        # (alias_map is used to construct the from clause)
        # This is the line that the SQL compiler uses to initialise alias_map, as at this point it's an empty ordered dict.
        qs.query.join(FooVirtualTable())
        return qs


class Foo(models.Model):
    objects = FooManager()

    foo = models.CharField(max_length=255)

    class Meta:
        managed = False
```

We can see that Django will happily replace the table name with our virtual table and can proceed to use it as if it were
a regular model queryset!

```
>>> print(Foo.objects.all().query)
SELECT "t"."id", "t"."foo" FROM (select 1 as id, 'bar' as foo) t
>>> Foo.objects.annotate(bar=F('foo')).first().bar
'bar'
>>> print(Foo.objects.filter(foo='not bar').first())
None
```

## Limitations

Django models require a convention of a single-field primary key, named whatever you like but defaulting to an integer named "id" if one is not specified.  Due to this custom queries used as the model source must define an id… this may be as simple as selecting an existing id that would be unique across the resultset, using `ROW_NUMBER()` or even concatenating your unique fields together as a string field.

## Advantages & Disadvantages over a Postgres View

Models backed by a Postgres views are the alternative to creating pseudo-models.  All that's required is a migration to create (& drop) the view and to modify `Meta.db_table` to point to the new view.

The advantages are:
 * Simple views are potentially updatable, but these types of views are also easily achieved by modifying a model's default queryset.  Use this when you want the view to be exposed at a lower level.
 * Views can be materialised.
 * The logic is exposed & reusable at a lower level.

The disadvantages:
 * Any change to the base query requires a migration.  (Setting up a virtual table like above still requires a migration for the model to keep track of model state for the migration engine.)
 * The logic for the view code may be obscured in a migration.
