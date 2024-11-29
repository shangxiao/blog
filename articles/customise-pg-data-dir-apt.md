```
|17:03:46       shangxiao | Hey folks! I know that I can set PGDATA and have `pg_ctl initdb` and `pg_ctl start` refer to that for the data dir… Is there a way to get `apt install postgresql` to use this though?       │ andehhh_
│17:04:49       shangxiao | For context this is Debian bullseye                                                                                                                                                          │ andreas303
│18:00:05          depesz | shangxiao: apt will install binaries in predefined location                                                                                                                                  │ andres
│18:00:15          depesz | *BUT* you can still have your data wherver you like.                                                                                                                                         │ Ankhers
│18:02:12       shangxiao | Yup I was wondering whether one could do `PGDATA=/data apt install postgresql` to avoid it doing an initdb in the default location … I guess it we can't then it's not a huge issue 🤔       │ ano
│18:03:28       shangxiao | (from my testing it doesn't appear to be the case that it will respect PGDATA but couldn't confirm that from code as I'm not sure where the apt install scripts are located)                 │ ansa
│18:15:15          depesz | shangxiao: install postgresql-common, then edit /etc/postgresql-common/createcluster.conf accordingly                                                                                        │ apirkle
│18:15:21          depesz | then install appropriate postgresql-VERSION                                                                                                                                                  │ apollo13
│18:15:32          depesz | details in `man pg_createcluster`                                                                                                                                                            │ arcade_droid
│18:23:11       shangxiao | 👀 👍                                                                                                                                                                                        │ arcanez
```
