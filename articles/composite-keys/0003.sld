

                             Example: CCI

      * Customer wants to control everything through report data
      * Report data defines the organisation name
      * We need an Organisation model to group Reports
      * Organisations need a name

                            ┏━━━━━━━━━━━━┓
                            ┃Organisation┃
                            ┣━━━━━━━━━━━━┫
                            ┃name:str    ┃
                            ┗━━━━━━━━━━━━┛
                                   ▲
                                   ┃
                            ┏━━━━━━━━━━━━┓
                            ┃Report      ┃
        org name stored in  ┣━━━━━━━━━━━━┫
            report data ->  ┃data:json   ┃
                            ┗━━━━━━━━━━━━┛
