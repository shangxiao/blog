Django Composite FK Examples
============================

June 2025


Implicit columns

```python
class Parent(Model):
    pk = CompositePrimaryKey('field_1', 'field_2')
    field_1 = IntegerField()
    field_2 = CharField()

class Child(Model):
    parent = ForeignKey(Parent, on_delete=...)
    ... child implicitly gets the fields field_1 & field_2 with same types ...
```

Explicit columns

```python
class Child(Model):
    # names can be anything, types must match
    field_a = IntegerField()
    field_b = CharField()
    # follows same API as ForeignObject
    parent = ForeignKey(Parent, from_fields=['field_a', 'field_b'], to_fields=['field_1', 'field_2'], on_delete=...)
```

Inclusion

The best of both worlds: this sets up a `parent_id` as per regular FK behaviour but allows you to specify the additional non-ID columns that need to be "shared"

```python
class Child(Model):
    field_b = CharField()
    parent = ForeignKey(Parent, include=['field_b'])
```

Multitenancy

```python
# customer is the tenant
class Customer(Model):
    pass

# "Tenanted" models will need to include the tenant FK and additionally have it part of the PK
# whether useful or not so as to propagate the tenancy equality
class Contact(Model):
    pk = CompositePrimaryKey('id', 'customer')
    id = AutoField()  # as per usual
    customer = ForeignKey(Customer)  # top-level models will have a direct relationship to the tenant and use a normal fk

# another top-level model but with a fk to another top-level model
class Order(Model):
    pk = CompositePrimaryKey('id', 'customer')
    id = AutoField()
    customer = ForeignKey(Customer)
    contact = ForeignKey(Contact, null=True, include=['customer'])  # to enforce tenancy the tenant ID must be included in the FK
```

Temporal

Every model has both an auto generated ID as per normal but also gains a `valid_time` attribute which must be part of the PK and
has a special validation when used in the FK.

```python
class Company(Model):
    pk = CompositePrimaryKey('id', 'valid_time')
    id = AutoField()
    valid_time = DateTimeRangeField(db_default=RawSQL("tstzrange(now(), 'infinity')"))
    name = CharField()

class Employee(Model):
    pk = CompositePrimaryKey('id', 'valid_time')
    id = AutoField()
    valid_time = DateTimeRangeField(db_default=RawSQL("tstzrange(now(), 'infinity')"))
    company = ForeignKey(Company, include=['valid_time'])
    name = CharField()
    address = CharField()
```
