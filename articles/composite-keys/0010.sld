

                       Composite Foreign Keys



                 ✔ Database-level guarantee
                 ✔ Simple to setup: a constraint instead of
                   multiple checks.


     ┏━━━━━━━━━━━━━━━┓                         ┏━━━━━━━━━━━━━━━┓
     ┃Foo            ┃                         ┃Bar            ┃
     ┣━━━━━━━━━━━━━━━┫  (id, redundant_field)  ┣━━━━━━━━━━━━━━━┫
     ┃id             ┃━━┳━━━━━━━━━━━━━━━━━━━┳━━┃foo_id         ┃
     ┃redundant_field┃━━┛                   ┗━━┃redundant_field┃
     ┗━━━━━━━━━━━━━━━┛                         ┗━━━━━━━━━━━━━━━┛




