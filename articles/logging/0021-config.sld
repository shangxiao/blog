
                     Typical Logging Configuration


        The recommended way to config is to use dictConfig()

LOGGING = {
    'version': 1,  # always 1
    'disable_existing_loggers': False,  # always False
    'formatters': {
        'simple': '%(asctime)s %(name)s %(levelname)s: %(message)s',
    },
    'handlers': {
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',  # must be str
            'formatter': 'simple',
        },
    },
    'loggers': {
        'foo': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'DEBUG',
    },
}
