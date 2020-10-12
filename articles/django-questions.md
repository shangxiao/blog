## Questions from #django

### How do I force a left join?

Normally a filter will produce an inner join, however to force a left join simply check the relationship is null.  This works both forwards and backwards:

```
class Bar(models.Model):
    name = models.CharField(...)

class Foo(models.Model):
    name = models.CharField(...)
    bar = models.ForeignKey(Bar, null=True, on_delete=models.CASCADE)

# forwards - get foos that either have no bar or bar.name is 'asdf'
Foo.objects.filter(Q(bar__isnull=True) | Q(bar__name="asdf"))

# backwards - get bars that have no foos pointing at them or those with foo.name is 'asdf'
Bar.objects.filter(Q(foo__isnull=True) | Q(foo__name="asdf"))
