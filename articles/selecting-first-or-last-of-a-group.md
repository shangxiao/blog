Selecting First or Last of a Group
==================================

A common question on the #django irc channel is something similar to [this question](https://botbot.me/freenode/django/2018-05-02/?msg=99602183&page=1):

> If I had a bunch of users with some activity each day,
> how can I construct a query to get their last activity object on that day for each of the days?

This is a common class of query which seems to get asked a lot: How do you find
the first (or last) of a group?

Consider the following table of data which simplifies the problem:

    +—————————————————————————————————————————————————————————————————————————————+
    |                                 Activity                                    |
    +-----------------------------------------------------------------------------|
    |  Who?       |   When?   |    What?                                          |
    +-------------+-----------+---------------------------------------------------|
    |  g1eb       |   9am     |    Go to work                                     |
    |  g1eb       |   5pm     |    Knock-off time!                                |
    |  shangxiao  |   9am     |    Go to work                                     |
    |  shangxiao  |   5pm     |    Knock-off time!                                |
    |  shangxiao  |   6pm     |    Attend MelbDjango                              |
    +-----------------------------------------------------------------------------+

We want to know what each person's final activity is:

    +-----------------------------------------------------------------------------+
    |  g1eb       |   5pm     |    Knock-off time!                                |
    |  shangxiao  |   6pm     |    Attend MelbDjango                              |
    +-----------------------------------------------------------------------------+

There are several ways to solve this:


In the application layer
------------------------

A first attempt may be to resolve this in your application layer.  For example
in Django it may look like:

    final_activities = []
	prev_activity = None

	for activity in Activity.objects.order_by('who', 'when'):
        # as we iterate over the list of activities keep the previous activity when we 
		if prev_activity and activity.who != prev_activity.who:
			final_activities.append(prev_activity)
		prev_activity = activity

	final_activities.append(prev_activity)

        
Using Subqueries
----------------

It may be more efficient and readable to run this with a single query and this
is do-able with the use of a [correlated subquery](https://en.wikipedia.org/wiki/Correlated_subquery)

I usually prefer to think in terms of SQL first then write my Django ORM
queries so here's how the SQL would look for that:

    SELECT *
    FROM activity a1
    WHERE a1.when = (
        SELECT MAX(a2.when)
        FROM activity a2
        WHERE a2.who = a1.who
    )

With Django:

    max_when = Activity.objects \
        .values('who') \   # required, see below
        .filter(who=OuterRef('who')) \
        .annotate(max_when=Max('when'))
    final_activities = Activity.objects \
        .filter(when=Subquery(max_when.values('max_when')))

Although a GROUP BY is unnecessary Django will create a default GROUP BY
comprised of all the table columns, therefore values('who') is required
here to restrict the group to the 'who' column.

However, correlated subqueries may be relatively ineffecient compared with
other types of queries.  (I also personally find the syntax for aggregation
& sub-querying to be more difficult to compose & read so I tend to avoid them.)


Using Joins
-----------

This problem may be solved by obtaining the maximum times per person then
joining the resultset back onto the original table to retrieve the required
columns:

    SELECT *
    FROM (
        SELECT who, MAX("when") as max_when
        FROM activity a
        GROUP BY who
    ) as max_times
    INNER JOIN activity a2 ON a2."when" = max_times.max_when AND a2.who = max_times.who

Reference: http://sqlfiddle.com/#!17/5bc43/7

Custom joins like this are hard to achieve in Django although do-able each has
its own drawbacks:

 - Use a raw query feeding into the Activity model
 - Use database views & create unmanaged models to read from these views from
   where you can define 1-1 relationships
 - ~Using extra() to use the join shown above but with implicit join notation~
 - Using a CTE with [django-cte](https://github.com/dimagi/django-cte)

Let's take a look at how this would be solved with django-cte. Converting the
previous join query to a CTE would look like so:

    WITH max_times AS (
        SELECT who, MAX(when) AS max_when
        FROM activity
        GROUP BY who
    )

    SELECT *
    FROM activity a
    INNER JOIN max_times m ON m.who = a.who AND m.max_when = a.when

And then to compose in Python with django-cte:

    # assume that Activity's manager is an instance of CTEManager
    max_when = Activity.objects \
        .values('who') \
        .annotate(max_when=Max('when')) \
        .values('who', 'max_when')
    cte = With(max_when)
    cte.join(Activity, who=cte.col, when=cte.col.max_when).with_cte(cte)


MySQL GROUP BY abuse
--------------------

Before MySQL 5.7.5<sup>1</sup>, developers could abuse the relaxed query interpretation with
queries involving GROUP BY as it would happily return columns outside those
declared in the group and are not functionally dependent on the declared group.

Below is an example of such a query:

```sql
SELECT *, MAX(when_)
FROM activity
GROUP BY who, DATE(when_)
```

Ref: http://sqlfiddle.com/#!9/472c1/10

Although it appears that MySQL simply chooses the first row, it is documented
that the row selection is *non-deterministic* and is not affected in any way by
declaring an ORDER BY<sup>2</sup>.


Using PostgreSQL's DISTINCT ON extension
----------------------------------------

PostgreSQL has a handy extension to the DISTINCT clause called
[DISTINCT ON](https://www.postgresql.org/docs/current/static/sql-select.html#SQL-DISTINCT)
which allows developers to select columns outside the distinct:

```sql
SELECT DISTINCT ON (name, when_::DATE) name, when_, label
FROM activity
ORDER BY name, when_::date, when_ DESC;
```

Ref: http://sqlfiddle.com/#!17/5a86b/4

[Django will happily use DISTINCT ON](https://docs.djangoproject.com/en/2.0/ref/models/querysets/#distinct)
if you are using PostgreSQL.

Given the original question regarding people's final activities per day, one
might code the solution like so:

```python
Person.objects \
    .annotate(when_date=TruncDate('activities__when')) \
    .distinct('name', 'when_date') \
    .order_by('name', 'when_date', 'activities__when')
```

Ref: https://repl.it/repls/ProperMarriedPixels


### Footnotes

1. The release of MySQL 5.7.5 [saw changes to the way MySQL would handle these
types of queries by
default](https://dev.mysql.com/doc/relnotes/mysql/5.7/en/news-5-7-5.html#mysqld-5-7-5-sql-mode): 
2. https://dev.mysql.com/doc/refman/5.7/en/group-by-handling.html
