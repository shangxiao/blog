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
 - temp move migrations elsewhere (ie just deleting then reinstate with your vcs)
 - create an empty 0001_initial
 - replace any references temporarily to 0001_initial
 - run makemigrations into name something like 0001_manual_squash_initial
 - if your apps have circular dependencies then makemigrations will create 2 separate migrations for an app to break the cycle
 - copy any non-elidable migrations / manual migrations etc into newly created squashed initial
 - undo reference temp change
 - remove temp empty 0001_initial
 - remove 0001_manual_squash_initial's dependency on 0001_initial
 - put back migrations
 - add a replaces list with the names of all the moved back migrations. if there were 2 migrations created, they need to go in both

A note about circular references: I ended up having to remove all cross-app dependencies in the replaced migrations in order to get any migration command to behave

Finally if you have any custom/weird migrations going on from custom constraints or whatever you may need to manually curate the order of operations.


Cleanup
-------

For each squashed app on any deployments you need to run:
```
./manage.py migration --prune <app>
```
