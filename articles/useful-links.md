## Coding Philosophy & Design

* https://mcfunley.com/choose-boring-technology
* https://news.ycombinator.com/item?id=11093733
* https://www.sandimetz.com/blog/2016/1/20/the-wrong-abstraction
* https://dev.to/wuz/stop-trying-to-be-so-dry-instead-write-everything-twice-wet-5g33
* https://kentcdodds.com/blog/write-tests/
* https://dave.cheney.net/2019/07/09/clear-is-better-than-clever
* https://en.wikipedia.org/wiki/SOLID

## Python

* https://nedbatchelder.com/blog/201608/lists_vs_tuples.html

## Computer Science

* https://0.30000000000000004.com/
* https://en.wikipedia.org/wiki/Vacuous_truth
* https://en.wikipedia.org/wiki/Parametric_polymorphism
* Null References: The Billion Dollar Mistake
  * https://news.ycombinator.com/item?id=11798518
  * https://medium.com/@hinchman_amanda/null-pointer-references-the-billion-dollar-mistake-1e616534d485

## Functional Programming

* [Putting the Fun back into Functional with Lambda Calculus](https://youtu.be/YTKqBuq1XWI)
* A Flock of Functions: Combinators, Lambda Calculus, & Church Encodings in JavaScript (with Gabriel Lebec): [Part 1](https://youtu.be/3VQ382QG-y4) and [Part 2](https://youtu.be/pAnLQ9jwN-E)
* https://en.wikipedia.org/wiki/SKI_combinator_calculus
* https://en.wikipedia.org/wiki/Church_encoding

## Testing

* https://jamescooke.info/arrange-act-assert-pattern-for-python-developers.html

## Architectural Design

* https://blog.bradfieldcs.com/you-are-not-google-84912cf44afb
* https://chriskiehl.com/article/event-sourcing-is-hard
  * https://news.ycombinator.com/item?id=19072850
* https://m.signalvnoise.com/the-majestic-monolith/
  * https://news.ycombinator.com/item?id=11195798
* https://changelog.com/posts/monoliths-are-the-future
  * https://news.ycombinator.com/item?id=22193383

## CI/CD

* https://news.ycombinator.com/item?id=21677819
* https://martinfowler.com/bliki/BlueGreenDeployment.html

## VCS

* https://georgestocker.com/2020/03/04/please-stop-recommending-git-flow/

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
* [Advisory Locks](http://shiroyasha.io/advisory-locks-and-how-to-use-them.html)
* https://www.cybertec-postgresql.com/en/discovering-less-known-postgresql-12-features/
* [Handy text search parsing queries](https://www.postgresql.org/docs/11/textsearch-controls.html#TEXTSEARCH-PARSING-QUERIES)
* https://wiki.postgresql.org/wiki/Don%27t_Do_This
* [Scalable PostgreSQL connection pooler](https://github.com/yandex/odyssey)
* https://github.com/okbob/pspg
  * http://okbob.blogspot.com/2017/07/i-hope-so-every-who-uses-psql-uses-less.html
* https://www.pgcli.com/

## Databases

* https://nickcraver.com/blog/2016/05/03/stack-overflow-how-we-do-deployment-2016-edition/#database-migrations
* https://jvns.ca/blog/2019/10/03/sql-queries-don-t-start-with-select/
* https://samsaffron.com/archive/2011/03/30/How+I+learned+to+stop+worrying+and+write+my+own+ORM

## Database Theory

* https://en.wikipedia.org/wiki/ACID
* https://en.wikipedia.org/wiki/CAP_theorem
* https://en.wikipedia.org/wiki/Database_normalization

## SQL

* https://www.dcs.warwick.ac.uk/~hugh/TTM/HAVING-A-Blunderful-Time.html

## Command Line Tools

* https://github.com/junegunn/fzf
* https://weechat.org
* https://github.com/BurntSushi/ripgrep
* https://jonas.github.io/tig/
* https://www.pgcli.com
* [Where GREP Came From (with Brian Kernighan)](https://youtu.be/NTfOnGZUZDk)

## Business

* https://www.vanityfair.com/news/2019/11/inside-the-fall-of-wework

## Teaching Resources

* https://catonmat.net/cookbooks/curl
* https://jvns.ca/blog/2019/10/03/sql-queries-don-t-start-with-select/

## Misc

* [“Considered Harmful” Essays Considered Harmful](https://meyerweb.com/eric/comment/chech.html)
