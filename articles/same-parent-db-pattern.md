Database Pattern: Enforcing Same Parent
=======================================

Given your typical parent/child database structure like so:

If we wanted to model where passengers sit we may choose to add a 3rd "sibling" relationship like so:

A first attempt to model this might be to do the usual thing here and add foreign keys to single primary keys
and this is certainly what you'd end up with when using an ORM such as Django's.

The problem here is that multiple pathways to Car exist from either Seat or Passenger introducing the risk that one
pathway might conflict with the other; a classic problem with redundancy.  For years I've often wondered what the
best way to enforce that siblings have the same parent is - often just relegating this task to the application
layer or looking into triggers if required in the database.

After speaking with the nice folks on #postgresql on freenode, they advised me that the solution is much simpler:
Use composite foreign keys!  If you include the parent entity's primary key in the foreign key then you end up
constraining equal parent ids between the siblings.  You may either include the parent's id in the primary key or,
if you are working with PostgreSQL and your ORM does not support composite keys (eg Django), then you may simply
refer to a unique key:

Many-to-many relationships work similarly.  In the through table you add an extra column for your parent's id
and add the necessary composite foreign keys to both sides:
