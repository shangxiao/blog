Squashing Migrations
====================

Skipping Migrations
-------------------

For any Django apps that don't have:
 1. Custom migrations
 2. Dependencies to other Django apps with migrations
 3. or aren't themselves dependencies

you're free to tell Django to skip migrations altogether by using `MIGRATION_MODULES`:

```python
MIGRATION_MODULES = {
    "app_name": None,
}
```

Note though if you do this in CI then you're no longer testing migrations, which may or may not be valuable to you,
but you're also skipping some basic smoke testing of data migrations.

Squashing 3rd Party Migrations
------------------------------

Using `MIGRATION_MODULES` you can declare a local module for migrations, then run `makemigrations` to genearate a freshly minted initial migration.
Note before doing this any dependencies to the 3rd party migrations will need to be temporarily commented out then replaced with the `0001_initial`.


Squashing Location Migrations
-----------------------------
TODO


a.) wipe out, replace, then fake any remaining on deployments

b.) side-by-side


Cleanup
-------

```
./manage.py migration --prune
```
