Django Composite FK Examples
============================

June 2025


### Implicit columns

```python
class Parent(Model):
    field_1 = IntegerField()
    field_2 = CharField()

    pk = CompositePrimaryKey('field_1', 'field_2')


class Child(Model):
    parent = ForeignKey(Parent, on_delete=...)

    # implicitly gained attributes
    # field_1 = IntegerField()
    # field_2 = CharField()
```

### Explicit columns

```python
class Child(Model):
    # follows same API as ForeignObject
    parent = ForeignKey(Parent, from_fields=['field_a', 'field_b'], to_fields=['field_1', 'field_2'], on_delete=...)

    # Explicitly declared attributes: names can be anything, types must match
    field_a = IntegerField()
    field_b = CharField()
```

### Inclusion

The best of both worlds: this sets up a `parent_id` as per regular FK behaviour but allows you to specify the additional non-ID columns that need to be "shared"

```python
class Child(Model):
    # only declare the fields that need to be shared/included in the relationship
    parent = ForeignKey(Parent, include=['field_b'])

    field_b = CharField()
```

### Real world example: Multitenancy

```python
# Customer is the tenant
class Customer(Model):
    pass


# "Tenanted" models need to:
#  - declare the tenant as a FK
#  - include it in the PK
#  - this is done in all models in the tenancy domain, whether used or not, in order to propagate the tenancy equality
class Contact(Model):
    # define a standard surrogate ID as per usual
    id = AutoField()
    # top-level models declare a direct relationship to the tenant as a normal FK
    customer = ForeignKey(Customer)  

    pk = CompositePrimaryKey('id', 'customer')


# A top-level model but with a FK to another top-level model
class Order(Model):
    id = AutoField()
    customer = ForeignKey(Customer)

    pk = CompositePrimaryKey('id', 'customer')

    # to enforce tenancy the tenant ID must be included in the FK
    contact = ForeignKey(Contact, null=True, include=['customer'])


# Not a top-level model but still requires the tenant ID
class OrderItem(Model):
    id = AutoField()
    customer = ForeignKey(Customer)

    pk = CompositePrimaryKey('id', 'customer')

    order = ForeignKey(Order, include=['customer'])    
```

### Real world example: Temporal

Every model has both an auto generated ID as per normal but also gains a `valid_time` attribute which must be part of the PK and
has a special validation when used in the FK.

```python
class Company(Model):
    id = AutoField()
    valid_time = DateTimeRangeField(db_default=RawSQL("tstzrange(now(), 'infinity')"))

    pk = CompositePrimaryKey('id', 'valid_time')

    name = CharField()


class Employee(Model):
    id = AutoField()
    valid_time = DateTimeRangeField(db_default=RawSQL("tstzrange(now(), 'infinity')"))

    pk = CompositePrimaryKey('id', 'valid_time')

    company = ForeignKey(Company, include=['valid_time'])
    name = CharField()
    address = CharField()
```
