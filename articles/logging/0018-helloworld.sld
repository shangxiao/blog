
                                Loggers


            import logging

            logger = getLogger("hello_world_logger")


            logger.info("Hello World")

            logger.warning("Warning! Warning! Danger Will Robinson!")

            logger.error("Computer says no")

            logger.critical("I'm melting!")

            # pro tip: log a stack trace along with the message:
            # (within an exception handler)
            logger.exception("Exceptional!")

