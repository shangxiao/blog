Arbitrary Queries in Django
===========================

Django doesn't do these things:

1. Virtual tables
2. Arbitrary joins
3. Subqueries


Examples:
 - Output from `generate_series()`
 - Cross product of series generation with a set of data from a concrete table/model (eg `generate_series() × (select * from some_category)` which is then left joined onto some sparse data)
 - Subqueries to make use of calculations. Eg: output from window expressions can only be used in outer queries.

There may be cases when you want to statically define a model backed by SQL eg with `generate_series()` but there'd also be cases
where a temporary dynamic model may be required, eg to be used as the backing for an arbitrary queryset.
