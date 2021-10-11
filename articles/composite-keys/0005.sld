
                       How to Manage Redundancy?

                      We could try the following:

           Application layer?
            - override save()?
            - other sources?

           Check Constraint?
            - Only works within the rows

           Triggers?
            - You need to define checks at both ends
              of the redundancy
            - Triggers can be disabled
            - You need to be aware of the gotchas[1]

[1]
https://www.cybertec-postgresql.com/en/triggers-to-enforce-constraints/

