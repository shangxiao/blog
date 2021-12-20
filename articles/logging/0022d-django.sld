
                           Logging in Django

        Example: Print database queries

        from django.utils.log import DEFAULT_LOGGING

        LOGGING = DEFAULT_LOGGING

        LOGGING["handlers"]["console"]["level"] = "DEBUG"
        LOGGING["loggers"]["django.db.backends"] = {
            "handlers": ["console"],
            "filters": ["require_debug_false"],
            "level": "DEBUG",
            "propagate": False,
        }

