
                             CCI Revisited


                                   ┏━━━━━━━━━━━━┓
                                   ┃Organisation┃
                                   ┣━━━━━━━━━━━━┫
               unique index ━┳━━━━━┃id:int      ┃
                             ┗━━━━━┃name:str    ┃
                                   ┗━━━━━━━━━━━━┛
                                          ▲
                                          ┃
                                      (id, name)
                                          ┃
                                   ┏━━━━━━━━━━━━┓
                                   ┃Report      ┃
                                   ┣━━━━━━━━━━━━┫
           check constraint ━┳━━━━━┃org_name:str┃
                             ┗━━━━━┃data:json   ┃
                                   ┗━━━━━━━━━━━━┛


