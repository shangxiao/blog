
                           Additional Notes


                               Benefits

        • Processing logs downstream with log analysis tools
          such as logstash or NewRelic
        • Sentry captures logs for the associated request


                          Possible Downsides

        • Logging (& error handling) can pollute otherwise
          easily readable declarative code with imperative commands
        • Too much logging? Performance impact? I've seen
          recommendations that enabling DEBUG in logging is a
          bad idea.
        • Too much data in log?


