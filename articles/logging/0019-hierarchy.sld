
                       Logger Names & Hierarchy

        • Names are hierarchical; descending left to right
        • At the base there exists a root logger named ""
        • Logs propagate upwards unless turned off
        • Useful for only having to define broad-reaching
          handlers at the top level and then fine tune handler
          for more specific loggers on a need-be basis.


               Eg:   "" - aka root logger
                      |
                      +---- foo
                      |      |
                      |      +---- foo.bar
                      |
                      +---- django
                             |
                             +---- django.db

