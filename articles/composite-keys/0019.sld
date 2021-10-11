
                             CCI Revisited


                                   ┏━━━━━━━━━━━━┓
                                   ┃Organisation┃
                                   ┣━━━━━━━━━━━━┫
               unique index ━┳━━━━━┃id:int      ┃
                             ┗━━━━━┃name:str    ┃
                                   ┗━━━━━━━━━━━━┛
                                          ▲
                                          ┃
                                          ┃
                                   ┏━━━━━━━━━━━━┓
                                   ┃Report      ┃
                                   ┣━━━━━━━━━━━━┫
           check constraint ━┳━━━━━┃org_name:str┃
                             ┗━━━━━┃data:json   ┃
                                   ┗━━━━━━━━━━━━┛


