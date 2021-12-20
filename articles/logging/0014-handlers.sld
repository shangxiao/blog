
                               Handlers

    • Are the "backend" to loggers, ie where it puts the log
    • Also have a log level for simple filtering
    • Useful stdlib handlers:
     - FileHandler
     - StreamHandler
     - RotatingFileHandler
     - SMTPHandler


    • Multiple handlers per logger with differing levels mean
      possible to write low severity logs to a file but high
      severity to an email
