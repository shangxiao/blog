
                         Security Implications


          • Log4Shell 😕

          • Don't log sensitive information!
            - includes information within a stack trace!
            - passwords, secrets incl from settings
            - credit cards
            - other PII (Personally Identifiable Information)

          • Django by default will filter out sensitive settings
            containing API, KEY, PASS, SECRET, SIGNATURE or TOKEN

          • Django has a @sensitive_variables decorator

          • Django's AdminEmailHandler may contain all sorts
            of information similar to the debug page

