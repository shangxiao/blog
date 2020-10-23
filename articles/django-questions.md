## Questions from #django

### How do I force a left join?

Normally a filter will produce an inner join, however to force a left join simply check the relationship is null.  This works both forwards and backwards:

```python
class Bar(models.Model):
    name = models.CharField(...)

class Foo(models.Model):
    name = models.CharField(...)
    bar = models.ForeignKey(Bar, null=True, on_delete=models.CASCADE)

# forwards - get foos that either have no bar or bar.name is 'asdf'
Foo.objects.filter(Q(bar__isnull=True) | Q(bar__name="asdf"))

# backwards - get bars that have no foos pointing at them or those with foo.name is 'asdf'
Bar.objects.filter(Q(foo__isnull=True) | Q(foo__name="asdf"))
```

### How do I enforce that at least 1 from 2 foreign keys is set but not both at the same time?

Use a [check constraint](https://docs.djangoproject.com/en/3.1/ref/models/constraints/#checkconstraint). Neither Q objects nor PostgreSQL support XOR so you'd have to do this manually with these equivalent expressions:

```
(p | q) & !(p & q)
!p & q | p & !q
```

or for 2 operands, simply:

```
p != q
```

```python 
class Bar(models.Model):
    bar = models.CharField(max_length=255)

class Baz(models.Model):
    baz = models.CharField(max_length=255)

class Foo(models.Model):
    bar = models.ForeignKey(Bar, null=True, on_delete=models.CASCADE)
    baz = models.ForeignKey(Baz, null=True, on_delete=models.CASCADE)

    class Meta:
        constraints = (
            models.CheckConstraint(
                check=models.Q(bar__isnull=True) & models.Q(baz__isnull=False)
                | models.Q(bar__isnull=False) & models.Q(baz__isnull=True),
                # Alternatively use RawSQL from Django 3.1
                # check=models.expressions.RawSQL(
                #     "(bar_id is null) != (baz_id is null)",
                #     params=[],
                #     output_field=models.BooleanField(),
                # ),
                name="only_one_fk",
            ),
        )
```

### How to enforce only a single row in a table to have a flag set?

#### Using NULL
If you consider `NULL` as your unset state and then choose a specific value as your set state (it doesn't matter what type it is) then you can do the following:
* Set a unique constraint on the field to enforce only one row in the "set" state; and
* Set a check constraint to prevent any other values than the "set" value.

The unique constraint will allow multiple `NULL` values as `NULL != NULL`.

For eg, simply using a boolean type, prevent false values and setting a unique constraint will allow a developer to implement a "single primary record":
```python
class OnlyOneRowNotNull(models.Model):
    primary_entry = models.BooleanField(null=True, unique=True)

    class Meta:
        constraints = (
            models.CheckConstraint(
                check=models.Q(primary_entry=True),
                name="only_one_row_not_null",
            ),
        )
```

#### Without using NULL
If it's more convenient to use true/false (or perhaps you want to enforce a specific value from a set of values using `choices`) then you can use a [partial unique index](https://docs.djangoproject.com/en/dev/ref/models/constraints/#condition):

```python
class OnlyOneRowTrue(models.Model):
    primary_entry = models.BooleanField(default=False)

    class Meta:
        constraints = (
            models.UniqueConstraint(
                fields=("primary_entry",),
                name="only_one_row_true",
                condition=models.Q(primary_entry=True),
            ),
        )
```

### How do I make sure that 2 sibling models can only relate to each other if they belong to the same parent?

This requires an additional _composite_ foreign key relationship to be specified _alongside_ that which Django creates normally. The purpose of this additional relationship is to include the parent's primary key in order to prevent extraneous relationships with different parents to be formed.

There are 2 parts to this:

1. First create a composite key that includes the parent pk with which the foreign key can refer to.  Typically this would be the primary key, but that's already taken by the Django model, so we need to create a second key - and this can be done with a regular unique key.
2. Create the composite foreign key referencing the newly creating unique key.

The second step is not supported out of the box by Django but we can still create it with a manual migration.

For eg, if we have an Organisation, Office and Employee models, we may want to restrict the relationship between Office-Employee to only those employees that work in the organisation that runs the office:

```python
# models

class Organisation(models.Model):
    ...

class Office(models.Model):
    organisation = models.ForeignKey(Organisation, on_delete=models.CASCADE)

    class Meta:
        constraints = (
            models.UniqueConstraint(fields=("id", "organisation"), name="composite_pk"),
        )

class Employee(models.Model):
    organisation = models.ForeignKey(Organisation, on_delete=models.CASCADE)
    office = models.ForeignKey(Office, on_delete=models.CASCADE)


# migration

make_fk = """\
ALTER TABLE app_name_here_employee
ADD CONSTRAINT composite_fk
FOREIGN KEY (office_id, organisation_id) REFERENCES app_name_here_office (id, organisation_id)
ON DELETE CASCADE
"""

class Migration(migrations.Migration):
    ...
    operations = (
        migrations.RunSQL(make_fk, migrations.RunSQL.noop),
    )
```
