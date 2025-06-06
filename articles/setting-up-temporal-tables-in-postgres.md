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

CREATE TRIGGER account_delete_trigger
BEFORE DELETE ON account
FOR EACH ROW
EXECUTE FUNCTION account_delete_function();
$$
```

Defining Triggers - Second Attempt
----------------------------------

As elegant as the update trigger is, it won't work in the real world because it relies on the primary key being deferrable.  Primary & unique keys are
only deferrable if there are no foreign keys referring to them:

```
ERROR:  cannot use a deferrable unique constraint for referenced table "account"
```

Removing the ability to defer the primary key means the elegant update trigger will need to be replace with something that updates the account pk before inserting the new entry:

```
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

```
create table shift (
  account varchar not null,
  valid_time tstzrange not null default tstzrange(now(), 'infinity', '[)'),
  start_at timestamptz not null,
  end_at timestamptz not null check (end_at > start_at),
  primary key (account, valid_time without overlaps)
  constraint shift_account foreign key (account, period valid_time) references account (name, period valid_time),
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
