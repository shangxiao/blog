Django ORM Notes
================

Clarification on what join promotion is from Anssi: https://gist.github.com/akaariai/a4c1acbfedac0f2cbf3e


Query
-----

 - `Query.alias_prefix` -> the T, U, V... etc prefix used when bumping
 - `Query.table_map` -> map table name to list of aliases (why is it a list?)
 - `Query.alias_map` -> map of alias -> join-like objects
 - `Query.base_table` -> property getting first alias in `alias_map`
 - `Query.default_cols` is True by default, set to False for a few reasons, eg setting values("field")

Selecting
 - `QuerySet._fields`
 - `Query.select` comment: "Select and related select clauses are expressions to use in the SELECT clause of the query. The select is used for cases where we want to set up the select clause to contain other than default fields (values(), subqueries...). Note that annotations go to annotations dictionary."
 - `Query.annotations` comment: "Maps alias -> Annotation Expression"
 - `Query.annotation_select` / `Query.annotation_select_mask` / `Query._annotation_select_cache`
   - property
   - dict of aggregate columns not masked, cached for performance
   - extracted from `annotations` masked by (using only keys from) the mask
 - `Query.extra_select`
 - `Query.values_select` - from the comments: "Holds the selects defined by a call to values() or values_list() excluding annotation_select and extra_select."

During compilation, in `SQLCompiler.get_select()`, a mapping of annotations are prepared from `extra_select` + `annotation_select`. Stored in `SQLCompiler.annotation_col_map`. During queryset iteration, `annotation_col_map` is used to set additional attributes on the object.


QuerySet
--------
 - `_known_related_objects` - Only set by `RelatedManager` when setting up the related queryset. Used by queryset iteration to


RelatedPopulator
----------------
 - comment: "RelatedPopulator is used for select_related() object instantiation."
 - During queryset iteration, information from `SQLCompiler.klass_info["related_klass_infos"]`
 - That information is gathered in `SQLCompiler.get_select()` from `SQLCompiler.get_related_selections()` which uses a model's Meta to and the select-related defs.  Additionally the select list is extended.


Misc
----
 - Value with an output_field causes get_db_prep_value() to be used for that field
 - ForeignKeyDeferredAttribute
 - ForwardManyToOneDescriptor
 - PathInfo
 - relabeled_clone()
 - change_aliases()

```python
class Query(BaseExpression):
    …
    def relabeled_clone(self, change_map):
        clone = self.clone()
        clone.change_aliases(change_map)
        return clone
```
