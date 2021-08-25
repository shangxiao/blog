Django Model Checklist
======================

A few things to consider when creating a Django model.  I don't necessarily follow all of them, but 

 - [ ] Define a `__str__()` method for human readability
 - [ ] Define a `__repr__()` method for debugging
 - [ ] Which fields, or combination of fields, may require an index _or_ unique constraint
 - [ ] What check constraints you may need
 - [ ] What database triggers may help enforce rules to be governed by the database (take a look at [django-pgtrigger](https://github.com/Opus10/django-pgtrigger))
 - [ ] Define `related_name` for any foreign keys (default is `<model_name>_set` – some folks prefer this, some prefer something a little more obvious like the plural model name)
 - [ ] Declare `Meta.db_table` to avoid db operations if renaming the model's app
 - [ ] Write some simple tests to check correct setup of any keys & constraints, especially if setup manually with custom migrations
 - [ ] For idempotent many-to-many relationship, make sure to add a unique constraint across the related fields
