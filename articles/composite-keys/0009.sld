

                       Composite Foreign Keys



        * Normally these are used to point to composite primary
          keys such as many-to-many tables.


        * Including redundant fields in the foreign key has the
          useful effect of enforcing equality.

     ┏━━━━━━━━━━━━━━━┓                         ┏━━━━━━━━━━━━━━━┓
     ┃Foo            ┃                         ┃Bar            ┃
     ┣━━━━━━━━━━━━━━━┫  (id, redundant_field)  ┣━━━━━━━━━━━━━━━┫
     ┃id             ┃━━┳━━━━━━━━━━━━━━━━━━━┳━━┃foo_id         ┃
     ┃redundant_field┃━━┛                   ┗━━┃redundant_field┃
     ┗━━━━━━━━━━━━━━━┛                         ┗━━━━━━━━━━━━━━━┛


