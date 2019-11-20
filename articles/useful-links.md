## Coding Philosophy

* https://mcfunley.com/choose-boring-technology
* https://news.ycombinator.com/item?id=11093733
* https://www.sandimetz.com/blog/2016/1/20/the-wrong-abstraction
* https://kentcdodds.com/blog/write-tests/
* https://dave.cheney.net/2019/07/09/clear-is-better-than-clever


## Testing

* https://jamescooke.info/arrange-act-assert-pattern-for-python-developers.html

## Architectural Design

* https://blog.bradfieldcs.com/you-are-not-google-84912cf44afb

## PostgreSQL

* http://www.craigkerstiens.com/2017/09/10/better-postgres-migrations/
* http://postgresguide.com
* https://djrobstep.com/docs/migra
* https://www.braintreepayments.com/blog/safe-operations-for-high-volume-postgresql/
* https://gocardless.com/blog/zero-downtime-postgres-migrations-the-hard-parts/
* https://pankrat.github.io/2015/django-migrations-without-downtimes/
  * Not null columns with no default being removed require the not null being dropped along with model update, then moving onto post-migration column removal
  * Consider signals or triggers when moving data to prevent inconsistencies between v1 & v2
* [A Missing Link in Postgres 11: Fast Column Creation with Defaults](https://brandur.org/postgres-default)
  * Only for non-volatile defaults

## Databases

* https://nickcraver.com/blog/2016/05/03/stack-overflow-how-we-do-deployment-2016-edition/#database-migrations
* https://jvns.ca/blog/2019/10/03/sql-queries-don-t-start-with-select/
* https://samsaffron.com/archive/2011/03/30/How+I+learned+to+stop+worrying+and+write+my+own+ORM

## SQL

* https://www.dcs.warwick.ac.uk/~hugh/TTM/HAVING-A-Blunderful-Time.html

## Command Line Tools

* https://github.com/junegunn/fzf
* https://weechat.org
* https://github.com/BurntSushi/ripgrep
* https://jonas.github.io/tig/
* https://www.pgcli.com
