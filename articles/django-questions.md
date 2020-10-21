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

Use a check constraint. Neither Q objects nor PostgreSQL support XOR so you'd have to do this manually with these equivalent expressions for 2 operands:

```
(p | q) & ^(p & q)
^p & q | p & ^q
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
                #     "bar_id is null and baz_id is not null or bar_id is not null and baz_id is null",
                #     params=[],
                #     output_field=models.BooleanField(),
                # ),
                name="only_one_fk",
            ),
        )
