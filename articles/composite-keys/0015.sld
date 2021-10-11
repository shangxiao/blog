

             We need 2 things to accomplish this in Django:


        1. A way to define a composite key on the target table

                Thankfully databases let you reference
               any unique constraint for a foreign key…

           So all we need to do is define a unique_together


           2. A way to define a composite foreign key on the
                           referencing table





