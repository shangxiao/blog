Django ORM Notes
================

Clarification on what join promotion is from Anssi: https://gist.github.com/akaariai/a4c1acbfedac0f2cbf3e


 - `Query.alias_prefix` -> the T, U, V... etc prefix used when bumping
 - `Query.table_map` -> map table name to list of aliases (why is it a list?)
 - `Query.alias_map` -> map of alias -> join-like objects
 - `Query.base_table` -> property getting first alias in `alias_map`
 - `Query.default_cols` is True by default, set to False for a few reasons, eg setting values("field")
