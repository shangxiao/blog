
                                Loggers



          Since logger names are hierarchical dot separated,
          The recommended way to name loggers is to simply
          use the Python module's name, from which you can
          use __name__:


                # logger = getLogger("my_logger") ❌

                logger = getLogger(__name__) ✅







