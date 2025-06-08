Temporal Postgres
=================

June 2025

[Postgres 18 is receiving 2 new features](https://www.postgresql.org/about/news/postgresql-18-beta-1-released-3070/) that takes us 1 step closer to the spec defining full temporal support for a relational database:

 - Temporal primary keys: https://www.depesz.com/2024/09/30/waiting-for-postgresql-18-add-temporal-primary-key-and-unique-constraints/
 - Temporal foreign keys: https://www.depesz.com/2024/10/03/waiting-for-postgresql-18-add-temporal-foreign-key-contraints/

Let's explore these new features using the "valid time" aspect.

How will these temporal relationships work?
-------------------------------------------

 - Primary keys get the new `WITHOUT OVERLAPS` modifier which:
   - must be the last column of the key
   - the key must have at least one additional column
   - will cause the constraint to check for overlaps instead of equality (ie `EXCLUDE`)
   - will allow duplicates in the other columns as long as the range does not overlap
   - will use a GiST index
 - Foreign keys get the new `PERIOD` modifier which:
   - is required for a range type to refer to a range defined with `WITHOUT OVERLAPS`
   - is specified on both sides when declaring the key
   - will cause the constraint to check that range is contained within the referenced tables **combined range** over the records where the non-period parts of the key match.
 - `create extension btree_gist;` is required to define primary keys with `WITHOUT OVERLAPS`
 - Ref: https://www.postgresql.org/docs/18/sql-createtable.html#SQL-CREATETABLE-PARMS-UNIQUE
 - Ref: https://www.postgresql.org/docs/18/sql-createtable.html#SQL-CREATETABLE-PARMS-REFERENCES


Ideal setup for a Temporal Table
--------------------------------

Ideally temporal tables have the following attributes:

 - Have an attribute defining the time range (period) in which the fact is true in the real world, often called `valid_time`
 - Have an attribute defining the time range the fact was stored in the system, often called `transaction_time`
 - These 2 attributes allow you to "rewind" along 2 axes:
   - Rewind to a point in history to retrieve facts at a specific point in time using `valid_time`
   - Rewind to a specific point in time _as the system understood it_ using `transaction_time`; this allows errors/mistakes to be corrected and kept in the system so that you can understand
     data at a point of time from both the real world and how the system saw the world
 - Data is inserted to temporal tables with a `valid_time` range of now until ∞
 - All updates & deletes to data produce _new rows_:
   - The new data is inserted as per above
   - The previous record is "closed out" with the upper bound at the timestamp of the transaction
     - Alternatively with a bitemporal setup allow the application to specify the upper bound of `valid_time` however set the `transaction_time` as timestamp of the transaction
 - Hence all data becomes read-only with the exception of the upper bound of the current record which is allowed to be closed out.


Defining Triggers - First Attempt
---------------------------------

As there are multiple steps in maintaining a temporal table, triggers may be the best way to abstract these details from users.

Using this temporal table:

```sql
create table account (
  -- primary key consists of the ID + time
  name varchar not null,
  valid_time tstzrange not null default tstzrange(now(), 'infinity', '[)'),
  primary key (name, valid_time without overlaps) deferrable initially deferred,

  address varchar
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

CREATE OR REPLACE FUNCTION account_delete_function()
 RETURNS trigger
AS $$
BEGIN
    -- Simply close out the last entry
    UPDATE account
    SET valid_time = tstzrange(lower(valid_time), now())
    WHERE name = OLD.name AND upper(valid_time) = 'infinity';

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER account_delete_trigger
BEFORE DELETE ON account
FOR EACH ROW
EXECUTE FUNCTION account_delete_function();
```

Defining Triggers - Second Attempt
----------------------------------

As elegant as the update trigger is, it won't work in the real world because it relies on the primary key being deferrable.  Primary & unique keys are
only deferrable if there are no foreign keys referring to them:

```
ERROR:  cannot use a deferrable unique constraint for referenced table "account"
```

(Note if you recompile postgres with this check disabled then the whole issue of recursive triggers below goes away)

Removing the ability to defer the primary key means the elegant update trigger will need to be replace with something that updates the account pk before inserting the new entry:

```sql
alter table account drop constraint account_pkey;

alter table account add constraint account_pkey primary key (name, valid_time without overlaps);

CREATE OR REPLACE FUNCTION account_update_function()
 RETURNS trigger
 LANGUAGE plpgsql
AS $$
BEGIN
    -- Close out the row being updated. Historic records are readonly and we only update valid_time.
    UPDATE account
    SET valid_time = tstzrange(lower(valid_time), now())
    WHERE name = OLD.name AND upper(valid_time) = 'infinity';

    -- Insert new entry with updated values
    INSERT INTO account (name, address) VALUES (NEW.name, NEW.address);

    RETURN NULL;
END;
$$;
```

now we can add our referencing table:

```sql
create table shift (
  -- primary key
  account varchar not null,
  valid_time tstzrange not null default tstzrange(now(), 'infinity', '[)'),
  primary key (account, valid_time without overlaps),

  -- foreign key
  constraint shift_account foreign key (account, period valid_time) references account (name, period valid_time),

  start_at timestamptz not null,
  end_at timestamptz not null check (end_at > start_at)
);
```

and if we try to assign a shift to alice it won't be a valid relationship.:

```
temporal=# table account;
 name  |                            valid_time                             | address
-------+-------------------------------------------------------------------+---------
 alice | ["2025-06-07 00:19:36.41239+10","2025-06-07 00:19:51.728734+10")  | paris
 alice | ["2025-06-07 00:19:51.728734+10","2025-06-07 00:20:53.443553+10") | rome
(2 rows)

temporal=# insert into shift (account, start_at, end_at) values ('alice', now(), now() + interval '1 hour');
ERROR:  insert or update on table "shift" violates foreign key constraint "shift_account"
DETAIL:  Key (account, valid_time)=(alice, ["2025-06-07 02:12:59.127703+10",infinity)) is not present in table "account".
```

we'll need a new account:

```
temporal=# insert into account (name, address) values ('bob', 'new york');
INSERT 0 1
temporal=# table account;
 name  |                            valid_time                             | address
-------+-------------------------------------------------------------------+----------
 alice | ["2025-06-07 00:19:36.41239+10","2025-06-07 00:19:51.728734+10")  | paris
 alice | ["2025-06-07 00:19:51.728734+10","2025-06-07 00:20:53.443553+10") | rome
 bob   | ["2025-06-07 02:14:25.951625+10",infinity)                        | new york
(3 rows)

temporal=# insert into shift (account, start_at, end_at) values ('bob', now(), now() + interval '1 hour');
INSERT 0 1
temporal=# table shift;
 account |                 valid_time                 |           start_at            |            end_at
---------+--------------------------------------------+-------------------------------+-------------------------------
 bob     | ["2025-06-07 02:15:12.389635+10",infinity) | 2025-06-07 02:15:12.389635+10 | 2025-06-07 03:15:12.389635+10
(1 row)
```

let's try and delete bob:

```
temporal=# delete from account where name = 'bob';
ERROR:  update or delete on table "account" violates foreign key constraint "shift_account" on table "shift"
DETAIL:  Key (name, valid_time)=(bob, ["2025-06-07 02:14:25.951625+10",infinity)) is still referenced from table "shift".
CONTEXT:  SQL statement "UPDATE account
    SET valid_time = tstzrange(lower(valid_time), now())
    WHERE name = OLD.name AND upper(valid_time) = 'infinity'"
PL/pgSQL function account_delete_function() line 4 at SQL statement
```

but we can update bob's address and the shift will "link to both records" for bob's address:

```
temporal=# update account set address = 'hong kong' where name = 'bob';
ERROR:  update or delete on table "account" violates foreign key constraint "shift_account" on table "shift"
DETAIL:  Key (name, valid_time)=(bob, ["2025-06-07 02:14:25.951625+10",infinity)) is still referenced from table "shift".
CONTEXT:  SQL statement "UPDATE account
    SET valid_time = tstzrange(lower(valid_time), now())
    WHERE name = OLD.name AND upper(valid_time) = 'infinity'"
PL/pgSQL function account_update_function() line 4 at SQL statement
```

oops! that won't work... because we need to make our foreign key deferrable

```
temporal=# alter table shift drop constraint shift_account;
ALTER TABLE
temporal=# alter table shift add constraint shift_account foreign key (account, period valid_time) references account (name, period valid_time) deferrable initially deferred;
ALTER TABLE
```

and try again:

```
temporal=# update account set address = 'hong kong' where name = 'bob';
UPDATE 0
temporal=# table account;
 name  |                            valid_time                             |  address
-------+-------------------------------------------------------------------+-----------
 alice | ["2025-06-07 00:19:36.41239+10","2025-06-07 00:19:51.728734+10")  | paris
 alice | ["2025-06-07 00:19:51.728734+10","2025-06-07 00:20:53.443553+10") | rome
 bob   | ["2025-06-07 02:14:25.951625+10","2025-06-07 02:19:19.808921+10") | new york
 bob   | ["2025-06-07 02:19:19.808921+10",infinity)                        | hong kong
(4 rows)

temporal=# table shift;
 account |                 valid_time                 |           start_at            |            end_at
---------+--------------------------------------------+-------------------------------+-------------------------------
 bob     | ["2025-06-07 02:15:12.389635+10",infinity) | 2025-06-07 02:15:12.389635+10 | 2025-06-07 03:15:12.389635+10
(1 row)
```

Defining Views
--------------

Defining views for the latest snapshot of a temporal table will give us a single dimensional table which mimicks a non-temporal table.

Remember - views in Postgres are automatically updatable as long as they're simple single-table view with simple filtering.

In our account view we have bob living in hong kong but no alice:

```
temporal=# create view account_view as select name, address from account where upper(valid_time) = 'infinity';
CREATE VIEW
temporal=# table account_view;
 name |  address
------+-----------
 bob  | hong kong
(1 row)
```

Let's update bob to see how elegant this is:

```
temporal=# update account_view set address = 'tokyo' where name = 'bob';
UPDATE 0
temporal=# table account_view;
 name | address
------+---------
 bob  | tokyo
(1 row)

temporal=# table account;
 name  |                            valid_time                             |  address
-------+-------------------------------------------------------------------+-----------
 alice | ["2025-06-07 00:19:36.41239+10","2025-06-07 00:19:51.728734+10")  | paris
 alice | ["2025-06-07 00:19:51.728734+10","2025-06-07 00:20:53.443553+10") | rome
 bob   | ["2025-06-07 02:14:25.951625+10","2025-06-07 02:19:19.808921+10") | new york
 bob   | ["2025-06-07 02:19:19.808921+10","2025-06-07 02:25:53.883379+10") | hong kong
 bob   | ["2025-06-07 02:25:53.883379+10",infinity)                        | tokyo
(5 rows)
```

Now let's delete bob:

```
temporal=# delete from shift;
DELETE 1
temporal=# delete from account_view where name = 'bob';
DELETE 0
temporal=# table account_view;
 name | address
------+---------
(0 rows)

temporal=# table account;
 name  |                            valid_time                             |  address
-------+-------------------------------------------------------------------+-----------
 alice | ["2025-06-07 00:19:36.41239+10","2025-06-07 00:19:51.728734+10")  | paris
 alice | ["2025-06-07 00:19:51.728734+10","2025-06-07 00:20:53.443553+10") | rome
 bob   | ["2025-06-07 02:14:25.951625+10","2025-06-07 02:19:19.808921+10") | new york
 bob   | ["2025-06-07 02:19:19.808921+10","2025-06-07 02:25:53.883379+10") | hong kong
 bob   | ["2025-06-07 02:25:53.883379+10","2025-06-07 02:26:57.610252+10") | tokyo
(5 rows)
```

Created & last modified
-----------------------

Adding a last modified timestamp is easy to replicate

```
temporal=# insert into account (name, address) values ('jane', 'sydney');
INSERT 0 1
temporal=# create or replace view account_view as select name, address, lower(valid_time) as modified_at from account where upper(valid_time) = 'infinity';
CREATE VIEW
temporal=# table account_view;
 name | address |          modified_at
------+---------+-------------------------------
 jane | sydney  | 2025-06-07 02:29:17.785293+10
(1 row)
```

We need to be a little more creative with the created timestamp

```
temporal=# drop view account_view;
DROP VIEW
temporal=# SELECT name,
       address,
       created_at,
       modified_at
FROM
  (SELECT name,
          address,
          valid_time,
          min(lower(valid_time)) OVER (PARTITION BY name
                                       ORDER BY valid_time) AS created_at,
          lower(valid_time) AS modified_at
   FROM ACCOUNT)
WHERE upper(valid_time) = 'infinity';
CREATE VIEW
temporal=# table account_view;
 name | address |          created_at           |          modified_at
------+---------+-------------------------------+-------------------------------
 jane | sydney  | 2025-06-07 02:29:17.785293+10 | 2025-06-07 02:29:17.785293+10
(1 row)
```

however when adding a window function or selecting from multiple tables we forfeit our automatic update feature...

```
-- simple rule should suffice
create rule account_view_insert as on insert to account_view do instead insert into account (name, address) values (new.name, new.address);
```

```
temporal=# insert into account_view (name, address) values ('alice', 'paris');
INSERT 0 1
temporal=# table account_view;
 name  | address |          created_at           |          modified_at
-------+---------+-------------------------------+-------------------------------
 alice | paris   | 2025-06-09 01:40:43.679346+10 | 2025-06-09 01:40:43.679346+10
(1 row)
```

```
create trigger account_view_update_trigger
instead of update on account_view
for each row
execute FUNCTION account_update_function();
```

```
temporal=# update account_view set address = 'rome';
UPDATE 0
temporal=# table account_view;
 name  | address |          created_at           |          modified_at
-------+---------+-------------------------------+-------------------------------
 alice | rome    | 2025-06-09 01:52:22.197427+10 | 2025-06-09 01:52:22.197427+10
(1 row)
```

