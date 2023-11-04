Row-Level Timezone Conversion in Django
=======================================

November 2023


Django, PostgreSQL & psycopg all have timezone support, though this support is limited to session-based timezone
management.

If your data model captures timestamps that relate to entities in different timezones then you may need to view or
report on that data in its local timezone.


A trivial example may look like the following with a model capturing some data at a given timestamp relevant to a
specific timezone:


```python
class Data(Model):
    timezone = CharField()
    timestamp = DateTimeField()
```


Viewing Data in Templates
-------------------------

Viewing data is straight forward as we can convert the timestamp in our template then use the tzinfo for display
purposes using the [timezone template tag](https://docs.djangoproject.com/en/5.0/topics/i18n/timezones/#timezone) along
with the [date filter](https://docs.djangoproject.com/en/5.0/ref/templates/builtins/#date) to display the timezone
("e"):


```htmldjango
{% load tz %}

{% for record in records %}
    {% timezone record.timezone %}
        {{ record.timestamp | date:"j M Y H:i:s e" }}: {{ record.data }}
    {% endtimezone %}
{% endfor %}
```

Database-level timezone conversion can be done but we end up with `datetime`s without `tzinfo` set and we'd need to set
it manually if we'd like to display the timezone:

```python
record.timestamp = record.timestamp.replace(tzinfo=ZoneInfo(record.timezone))  # or use Django's make_aware()
```


Reporting with Aggregation
--------------------------

Reporting is a little more involved if we need to convert timestamps before any aggegation - this may be the case if
your data needs to be considered within the context of local time - for eg if you're analysing customer arrival time of
day and comparing this across timezones.

You can use one of the following options to do this, which will be explained below:

 1. Set `USE_TZ = True` & `TIME_ZONE = 'UTC'` & use timezone-aware filtering
 2. Set `USE_TZ = True` & if `TIME_ZONE` is something other than UTC, make sure that `TIME_ZONE` and
    `DATABASES.TIME_ZONE` are the same timezone & use timezone-aware filtering
 3. Set `USE_TZ = True` & with another default timezone - you'll then need to override the supplied `DateTimeField` to
    avoid the timezone conversion when encountered with a naive timestamp during filtering of localised timestamps.
 4. Set `USE_TZ = False`


NOTE: If you're manually querying with raw SQL then you have the option of passing naive datetimes and thereby have
consistent types when comparing localised timestamps, though it still is a good idea to be sure that `TIME_ZONE` and
`DATABASES.TIME_ZONE` are consistent.


Tech Notes
----------

Here are some important notes about Django, psycopg & PostgreSQL which explain the approaches above:

PostgreSQL:

 - PostgreSQL has 2 timestamp types:
   - `timestamp without time zone` aka `timestamp`
   - `timestamp with time zone` aka `timestamptz`
 - PostgreSQL does not store timestamp information with `timestamptz`. Both timestamp types are stored as UTC. The
   `timestamptz` type merely informs PostgreSQL that it should do timezone conversion on read & write.
 - When reading timestamptz values in PostgreSQL, the timezone conversion is done according to the `TIME ZONE` session
   setting.
 - Converting timezones at row-level is done with the `<timestamp> AT TIME ZONE <timezone>` expression or the
   `timezone(<timezone>, <timestamp>)` function which is equivalent. Ref:
   https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-ZONECONVERT
 - When manually converting timezones, a `timestamptz` is converted to `timestamp` and vice versa.
 - When comparing a `timestamp` with a `timestamptz`, the `timestamp` is converted to the `TIME ZONE` first, eg: the
   expression `'2000-01-01 12:00'::timestamp = '2000-01-01 12:00+11'::timestamptz` _will_ evaluate to false if the `TIME
   ZONE` is anything other than +11.
 - Whilst date/time processing functions like `date_trunc()` have the option to pass a timezone parameter,
   `generate_series()` unfortunately does not and may produce unexpected results when transitioning daylight savings if
   the incorrect `TIME ZONE` setting is used.


psycopg:

 - psycopg allows you to set the `TIME ZONE` session setting
 - When reading values from the database, `datetime` types will have their `tzinfo` set according to the session time
   zone if the type is `timestamptz` & `None` if the type is `timestamp`. There is no row-level support for setting the
   `tzinfo`.


Django:

 - Django has 3 settings for managing timezones: `USE_TZ`, `TIME_ZONE` & `DATABASES.TIME_ZONE`
 - When `USE_TZ` is `False` then:
   - the database session is set to `TIME_ZONE`
   - naive datetimes are left as-is when used with `DateTimeField`s
 - When `USE_TZ` is `True` then:
   - the database session is set to `UTC` by default _or_ the `DATABASES.TIME_ZONE` setting if set.
   - any naive timestamps it encounters when input into `DateTimeField`, including filtering, will have the `tzinfo`
     (made aware) set to `TIME_ZONE` (the default timezone _not_ the current timezone) **and raise an undesirable
     warning**.

We can see now that when `USE_TZ = True`, using naive timestamps is not an option because Django will attempt to
intervene (and raise warnings which is not ideal).  Simply making sure that `TIME_ZONE` and `DATABASE.TIME_ZONE` are
consistent appears to be the best option – since parameters passed to PostgreSQL will be in the `TIME_ZONE` format we
need to make sure that `timestamp without time zone` from any local conversions will also be evaluated in the same time
zone.
