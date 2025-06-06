Temporal Postgres
=================

June 2025

[Postgres 18 is receiving 2 new features](https://www.postgresql.org/about/news/postgresql-18-beta-1-released-3070/) that takes us 1 step closer to the spec defining temporal support for a relational database:

 - Temporal primary keys: https://www.depesz.com/2024/09/30/waiting-for-postgresql-18-add-temporal-primary-key-and-unique-constraints/
 - Temporal foreign keys: https://www.depesz.com/2024/10/03/waiting-for-postgresql-18-add-temporal-foreign-key-contraints/

Let's explore these new features using the "valid time" aspect.

How will these temporal relationships work?
-------------------------------------------

 - `create extension btree_gist;` is required to define primary keys with `WITHOUT OVERLAPS`
 - tbd...

Defining Triggers - First Attempt
---------------------------------

As there are multiple steps in maintaining a temporal table, triggers may be the best way to abstract these details from users.

Using this temporal table:

```sql
create table account (
  name varchar not null,
  valid_time tstzrange not null default tstzrange(now(), 'infinity', '[)'),
  address varchar,
  primary key (name, valid_time without overlaps) deferrable initially deferred
);
```

we can use a very neat trigger function that takes advantage of the deferrable primary key:

```sql
CREATE OR REPLACE FUNCTION account_update_function()
RETURNS trigger AS $$
BEGIN
    -- Insert new entry with updated values
    INSERT INTO account (name, address) VALUES (NEW.name, NEW.address);

    -- Close out the row being updated. Historic records are readonly and we only update valid_time.
    OLD.valid_time := tstzrange(lower(OLD.valid_time), now());
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER account_update_trigger
BEFORE UPDATE ON account
FOR EACH ROW
EXECUTE FUNCTION account_update_function();
```

It works very nicely:

```
temporal=# insert into account (name, address) values ('alice', 'paris');
INSERT 0 1
temporal=# table account;
 name  |                 valid_time                 | address
-------+--------------------------------------------+---------
 alice | ["2025-06-06 20:13:48.097884+10",infinity) | paris
(1 row)

temporal=# update account set address = 'rome' where name = 'alice';
UPDATE 1
temporal=# table account;
 name  |                            valid_time                             | address
-------+-------------------------------------------------------------------+---------
 alice | ["2025-06-06 20:14:08.409362+10",infinity)                        | rome
 alice | ["2025-06-06 20:13:48.097884+10","2025-06-06 20:14:08.409362+10") | paris
(2 rows)
```

Defining a delete trigger is just as easy, however it involves running an `UPDATE` so we first need to prevent our update trigger from being fired if it's in response to another trigger:

```sql
DROP TRIGGER account_update_trigger ON account;

CREATE TRIGGER account_update_trigger
BEFORE UPDATE ON account
FOR EACH ROW
WHEN (pg_trigger_depth() < 1)
EXECUTE FUNCTION account_update_function();

CREATE OR REPLACE FUNCTION public.account_delete_function()
 RETURNS trigger
 LANGUAGE plpgsql
AS $$
BEGIN
    -- Simply close out the last entry
    UPDATE account
    SET valid_time = tstzrange(lower(valid_time), now())
    WHERE name = OLD.name AND upper(valid_time) = 'infinity';

    RETURN NULL;
END;
$$
```

Defining Triggers - Second Attempt
----------------------------------

As elegant as the update trigger is, it won't work in the real world because it relies on the primary key being deferrable.  Primary keys are
only deferrable if there are no foreign keys referring to them.

Defining Views
--------------
