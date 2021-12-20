
                     Typical Logging Configuration


      • version: is *always* set to 1 and will allow for future
        backwards-compatibility.

      • disable_existing_loggers: Disables any existing non-root
        loggers. It's default is True to be consistent with the
        older fileConfig() setup but is recommended that is set
        and turned off.

      • incremental: Incremental logging configuration
        (usually doesn't apply with Django)
