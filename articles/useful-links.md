## Coding Philosophy & Design

* https://mcfunley.com/choose-boring-technology
* [Write code that is easy to delete, not easy to extend](https://news.ycombinator.com/item?id=11093733)
* https://www.sandimetz.com/blog/2016/1/20/the-wrong-abstraction
* https://dev.to/wuz/stop-trying-to-be-so-dry-instead-write-everything-twice-wet-5g33
* https://kentcdodds.com/blog/write-tests/
* https://dave.cheney.net/2019/07/09/clear-is-better-than-clever
* https://en.wikipedia.org/wiki/SOLID
* https://en.wikipedia.org/wiki/Leaky_abstraction
* https://korban.net/posts/postgres/2017-11-02-the-case-against-orms/
* https://en.wikipedia.org/wiki/Robustness_principle
* [Static vs Dynamic Type Checking](https://thecodeboss.dev/2015/11/programming-concepts-static-vs-dynamic-type-checking/)
* [Clear is better than clever](https://news.ycombinator.com/item?id=20386073)
* [Write code. Not too much. Mostly functions.](https://news.ycombinator.com/item?id=25500671)

## Types
* [Nominal vs Structural Typing](https://medium.com/@thejameskyle/type-systems-structural-vs-nominal-typing-explained-56511dd969f4)

## Python

* https://github.com/cassiobotaro/awesome-python-modules-as-script
* https://nedbatchelder.com/blog/201608/lists_vs_tuples.html
* Article on pyproject.toml, discussion on the state of package management: https://news.ycombinator.com/item?id=22746762
* [How you implemented your Python decorator is wrong](http://blog.dscpl.com.au/2014/01/how-you-implemented-your-python.html)
* [Raymond Hettinger - Beyond PEP 8 -- Best practices for beautiful intelligible code](https://youtu.be/wf-BqAjZb8M)
* [Raymond Hettinger - Dataclasses: The code generator to end all code generators](https://youtu.be/T-TwcmT6Rcw)
* [Raymond Hettinger - Transforming Code into Beautiful, Idiomatic Python](https://youtu.be/OSGv2VnC0go)
* [Facebook's type checker, Pyre](https://pyre-check.org/)
  * [Pysa](https://pyre-check.org/docs/pysa-basics.html)
* [Brett Slatkin - How to Be More Effective with Functions](https://youtu.be/WjJUPxKB164)
* [Ned Batchelder - Loop like a native: while, for, iterators, generators](https://youtu.be/EnSu9hHGq5o)
* [Descriptors](https://youtu.be/ZdvpNaWwx24)
* [It's Pythons all the way down: Python Types & Metaclasses Made Simple](https://youtu.be/ZpV3tel0xtQ)
* [Christopher Neugebauer - On the Use and Misuse of Decorators](https://youtu.be/Z1FLIj1kZLg)
  * Has some interesting uses for decorators 
* [Jack Diederich - Stop Writing Class](https://youtu.be/o9pEzgHorH0)
  * Great Quote: "I hate code and I want little of it as possible in our product"
  * Good talk but I disagree with some of the assumptions, particularly:
    * Nobody talks about design principles
    * Just use stdlib exceptions (An audience member actually challenged this during Q&A with the same reason I like to use dedicated exceptions
* [Someone's guide to debugging in Python](https://martinheinz.dev/blog/24)
* [Default Parameter Values in Python](https://web.archive.org/web/20200221224620id_/http://effbot.org/zone/default-values.htm)
* https://github.com/gforcada/flake8-builtins
* https://github.com/adamchainz/flake8-comprehensions
* [Zero Downtime Deployments with Gunicorn](https://wingu.github.io/zero-downtime-gunicorn.html)

## Django

* https://hakibenita.com/django-rest-framework-slow
* https://hakibenita.com/django-nested-transaction
* [Django Views – the Right Way](https://spookylukey.github.io/django-views-the-right-way)
* [Do people actually squash migrations?](https://groups.google.com/g/django-developers/c/xpeFRpMTBZw/m/M3aTAOFgAwAJ)
* https://adamj.eu/tech/2024/01/03/postgresql-full-text-search-websearch/
* [Django migrations without downtimes (2015)](https://pankrat.github.io/2015/django-migrations-without-downtimes/#django-wishlist)
  * Postgres support fast non-null-with-default-column adds since 11
  * Django now supports `db_default`

## Django Gotchas

* [Django can't handle closed DB connections](https://code.djangoproject.com/ticket/24810)
  * Earlier ticket https://code.djangoproject.com/ticket/15802

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
* [Programming with Categories - MIT course by Brendan Fong, Bartosz Milewski & David Spivak](http://brendanfong.com/programmingcats.html)

## Testing

* [Write tests. Not too many. Mostly integration](https://kentcdodds.com/blog/write-tests)
* [Arrange, Act, Assert](https://jamescooke.info/arrange-act-assert-pattern-for-python-developers.html)
* [Coverage should be a guide, not a goal](https://martinfowler.com/bliki/TestCoverage.html)
* [Gold Master/Characterisation Testing](https://en.wikipedia.org/wiki/Characterization_test)

## Architectural Design

* https://blog.bradfieldcs.com/you-are-not-google-84912cf44afb
* https://chriskiehl.com/article/event-sourcing-is-hard
  * https://news.ycombinator.com/item?id=19072850
* https://m.signalvnoise.com/the-majestic-monolith/
  * https://news.ycombinator.com/item?id=11195798
* https://changelog.com/posts/monoliths-are-the-future
  * https://news.ycombinator.com/item?id=22193383
* [Mistakes we made adopting event sourcing and how we recovered](https://news.ycombinator.com/item?id=20324021)
* [Conway's Law](https://en.wikipedia.org/wiki/Conway%27s_law)

## CI/CD

* https://news.ycombinator.com/item?id=21677819
* https://martinfowler.com/bliki/BlueGreenDeployment.html

## VCS

* https://georgestocker.com/2020/03/04/please-stop-recommending-git-flow/
* Linus on keeping clean history:
 * https://news.ycombinator.com/item?id=4612331
 * https://news.ycombinator.com/item?id=20874240

## HTTP APIs

* https://wiki.postgresql.org/wiki/HTTP_API
* http://postgrest.org/en/v6.0/
* PostgREST alternative in Go: https://postgres.rest/
* Java implementation: https://github.com/bjornharrtell/jdbc-http-server
* Node implementation: https://github.com/bjornharrtell/postgresql-http-server

## Databases

* Erwin Brandstetter
  * https://dba.stackexchange.com/users/3684/erwin-brandstetter
  * https://stackoverflow.com/users/939860/erwin-brandstetter
* https://nickcraver.com/blog/2016/05/03/stack-overflow-how-we-do-deployment-2016-edition/#database-migrations
* https://jvns.ca/blog/2019/10/03/sql-queries-don-t-start-with-select/
* https://samsaffron.com/archive/2011/03/30/How+I+learned+to+stop+worrying+and+write+my+own+ORM
* [MariaDB support for temporal tables (see limitations on mysqldump though)](https://news.ycombinator.com/item?id=23808444)
* "SQL queries run in this order" diagram/zine by Julia Evans: https://x.com/b0rk/status/1179449535938076673
* Free book: Developing Time-Oriented Database Applications in SQL: https://www2.cs.arizona.edu/~rts/tdbbook.pdf
* SQL Standard is not free to read, so there are some summaries from vendors at the time:
  * IBM: Temporal features in SQL:2011 https://cs.ulb.ac.be/public/_media/teaching/infoh415/tempfeaturessql2011.pdf
  * Oracle: What's new in SQL:2011 https://sigmodrecord.org/publications/sigmodRecord/1203/pdfs/10.industry.zemke.pdf
* Maria support for temporal tables (system-versioned tables, application time periods, bitemporal) https://mariadb.com/docs/server/reference/sql-structure/temporal-tables

## Database Theory

* https://en.wikipedia.org/wiki/ACID
* https://en.wikipedia.org/wiki/CAP_theorem
* https://en.wikipedia.org/wiki/Database_normalization

## SQL

* https://www.dcs.warwick.ac.uk/~hugh/TTM/HAVING-A-Blunderful-Time.html
* https://github.com/krisajenkins/yesql/
* [Codd's 12 Rules](https://en.wikipedia.org/wiki/Codd%27s_12_rules)
* [SQLite can be used as a graph database](https://news.ycombinator.com/item?id=24843643)

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
* https://news.ycombinator.com/item?id=22775330
* [Migrating Large Heroku Postgres Instances to AWS Aurora Without Downtime](https://news.ycombinator.com/item?id=25071502)
* [Christophe Pettus: PG index types, when to use, why, how (& when not)](https://youtu.be/Xv0NFozBIbM)
* https://til.cybertec-postgresql.com/post/2019-09-02-Postgres-Constraint-Naming-Convention/
* https://www.2ndquadrant.com/en/blog/postgresql-10-identity-columns/
* [Postgres 14 Internals, the book](https://postgrespro.com/community/books/internals)
* https://hakibenita.com/postgresql-unknown-features
* [SQL MERGE vs upsert clarification by Peter Geoghegan (2014)](https://www.postgresql.org/message-id/CAM3SWZRP0c3g6+aJ=YYDGYAcTZg0xA8-1_FCVo5Xm7hrEL34kw@mail.gmail.com)
* [Unlogged tables](https://www.crunchydata.com/blog/postgresl-unlogged-tables)
* [YouTube: Bruce Momjian: Explaining the Postgres Query Optimizer](https://youtu.be/wLpcVM9qxV0)
* [YouTube: Christophe Pettus: Breaking PostgreSQL at Scale](https://youtu.be/XUkTUMZRBE8)
* https://github.com/citusdata/pg_cron
  * https://www.citusdata.com/blog/2023/10/26/making-postgres-tick-new-features-in-pg-cron/
* m2m anti-pattern? https://thebuild.com/blog/2023/01/18/a-foreign-key-pathology-to-avoid/
* [pg_cron now supports seconds granularity](https://www.citusdata.com/blog/2023/10/26/making-postgres-tick-new-features-in-pg-cron/)
* [Thread on whether or not to support errors in transactions](https://www.postgresql.org/message-id/3.0.5.32.20001114163035.02bac100%40mail.rhyme.com.au)
* https://www.crunchydata.com/blog/magic-tricks-for-postgres-psql-settings-presets-cho-and-saved-queries
* https://www.cybertec-postgresql.com/en/abusing-security-definer-functions/
* Thread on why ON CONFLICT does not support deferrable unique constraints: https://www.postgresql.org/message-id/CAH2-Wzmp6fg2XT1TC30QOLjNZyYWDpUBDc0ntCwhsp_SP5GBmQ%40mail.gmail.com
* [YouTube: Intro to Postgres Hacking via Temporal Tables](https://youtu.be/k5ROpCdL5G8)
* https://medium.com/@janeethreddyalle2/aws-rds-postgresql-zero-downtime-major-version-upgrade-81275d0757d4
* security_barrier views: https://www.enterprisedb.com/blog/how-do-postgresql-securitybarrier-views-work
* Nice summary of multitenancy in PG: https://stackoverflow.com/a/44530588
* Laurenz Albe on constraint triggers: https://www.cybertec-postgresql.com/en/triggers-to-enforce-constraints/
* https://www.bytebase.com/blog/postgres-row-level-security-footguns/
* Normalising pg_stat_statements (outdated but still useful) https://blog.ioguix.net/postgresql/2012/08/06/Normalizing-queries-for-pg_stat_statements.html
* [Boosting Postgres INSERT Performance by 2x With UNNEST](https://www.tigerdata.com/blog/boosting-postgres-insert-performance)

## Oracle
* [23c Free Developer Release](https://www.oracle.com/news/announcement/oracle-database-23c-free-developer-release-2023-04-03/)
* [23c New Features](https://docs.oracle.com/en/database/oracle/oracle-database/23/nfcoa/toc.htm#Table-of-Contents)
* https://github.com/oracle/docker-images/blob/main/OracleDatabase/SingleInstance/README.md

## Security
* [Crypographers apparently don't like JWT](https://news.ycombinator.com/item?id=14727252)
* [Tokens ain't Tokens](https://blog.tinbrain.net/blog/tokens-aint-tokens.html)
* [OWASP cheatsheets](https://cheatsheetseries.owasp.org/)
* What's inside this QR code? https://news.ycombinator.com/item?id=41622632

## Web
* [web.dev: Useful site from Google with guides on web development](https://web.dev/)
* https://thedailywtf.com/articles/The_Spider_of_Doom

## HTML
* [HTML Tips (2020)](https://news.ycombinator.com/item?id=27054348)
* [Modern 2021 HTML boilerplate + HN discussion with updates, recommendations, etc](https://news.ycombinator.com/item?id=26952557)
* [The Button Cheatsheet - The dos and donts of creating buttons in HTML](https://www.buttoncheatsheet.com/)
* [The Dialog Element](https://webkit.org/blog/12209/introducing-the-dialog-element/)

## CSS
* [a { outline: none; } DON'T DO IT!](http://www.outlinenone.com/)
* [Checkboxes styled with CSS](https://news.ycombinator.com/item?id=33418445)
* [Lightening and darkening colors with CSS (sass-style using color-mix())](https://publishing-project.rivendellweb.net/lightening-and-darkening-colors-with-css/)

## UX
* [Scrollbar Blindness and discussion on mac-centric UI design](https://news.ycombinator.com/item?id=24293421)
* [GitHub's reasons for switching from icon fonts to SVG](https://github.blog/2016-02-22-delivering-octicons-with-svg/)
* https://speakerdeck.com/ninjanails/death-to-icon-fonts
* https://technology.blog.gov.uk/2020/02/24/why-the-gov-uk-design-system-team-changed-the-input-type-for-numbers/
* [Visual design rules you can safely follow (anthonyhobday.com)](https://news.ycombinator.com/item?id=34684761)
* https://inclusive-components.design/tooltips-toggletips/
* https://www.bbc.co.uk/gel/features/inputs

## a11y
* https://accessibility.blog.gov.uk/2016/09/02/dos-and-donts-on-designing-for-accessibility/

## Command Line Tools

* https://github.com/junegunn/fzf
* https://weechat.org
* https://github.com/BurntSushi/ripgrep
* https://jonas.github.io/tig/
* https://www.pgcli.com
* [Where GREP Came From (with Brian Kernighan)](https://youtu.be/NTfOnGZUZDk)
* https://github.com/orf/gping
* http://wttr.in/Melbourne  `curl http://wttr.in/Melbourne`

## AWS
* [Delete large number of objects in S3 quickly (not using the console)](https://serverfault.com/questions/679989/most-efficient-way-to-batch-delete-s3-files)

## Vim

* https://www.hillelwayne.com/post/intermediate-vim/

## Vim Plugins

* https://github.com/preservim/nerdtree
* https://github.com/tpope/vim-fugitive
* https://github.com/psf/black/blob/master/plugin/black.vim
* https://github.com/google/yapf/tree/master/plugins/vim
* https://github.com/junegunn/fzf/blob/master/plugin/fzf.vim / https://github.com/junegunn/fzf.vim
* https://github.com/vim-test/vim-test
* https://github.com/mgedmin/coverage-highlight.vim
* https://github.com/tpope/vim-abolish
* https://github.com/tpope/vim-repeat
* https://github.com/tpope/vim-unimpaired
* https://github.com/tpope/vim-surround
* https://github.com/editorconfig/editorconfig-vim
* https://github.com/SirVer/ultisnips
* https://github.com/mgedmin/python-imports.vim
* https://github.com/dhruvasagar/vim-table-mode
* https://github.com/bogado/file-line
* https://github.com/arouene/vim-ansible-vault

## Business

* https://www.vanityfair.com/news/2019/11/inside-the-fall-of-wework

## Teaching Resources

* https://catonmat.net/cookbooks/curl
* https://jvns.ca/blog/2019/10/03/sql-queries-don-t-start-with-select/

## Misc

* [“Considered Harmful” Essays Considered Harmful](https://meyerweb.com/eric/comment/chech.html)
* https://www.punctuationmatters.com/en-dash-em-dash-hyphen/
* ["We ran out of columns"](https://news.ycombinator.com/item?id=41146239)
* [Goodbye integers, hello UUIDv7](https://news.ycombinator.com/item?id=37733036)
