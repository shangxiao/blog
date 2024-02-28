django-seal review
==================

Feb 2024

https://github.com/charettes/django-seal


Background
----------

I work at a Django agency and spawn many projects around a
template using Django in addition to maintaining legacy or rescue Django
codebases. We often hire a lot of people new to Django or programming in general
so we try to include a lot of tools & checks that help guide newer developers.

N+1 issues tend to be the most common performance complaint from customers,
especially so for newer devs who often don't realise they're introducing the
pattern. Initially our past CTO setup a middleware to count the number of
queries and log a warning if the count gets past a certain threshold. This has
been quite useful in identifying issues but has its limitations with false
negatives if you don't test with enough test data (& false positives for that
matter). Additionally it also only logs that it occurred and is only traceable
to a certain request.

Trial
-----

I trialled django-seal on sample project and it has so far been a very welcome
addition!

 - ✓ Identifies the root cause of the issue
 - ✓ Catches potential n+1 issues without requiring a lot of test data
 - ✓ Warning will show source, additionally if escalated as exception you get the
   traceback
 - ✓ Helps new devs avoid the issue, reduces time spent in reviews identifying &
   fixing potential issues
 - ✓ Catches issues that even experienced devs miss, eg when queryset usage is
   dispersed or even defined/used deep within magic (eg a ModelForm)

Upon initial setup seal identified a tonne of areas that needed addressing -
some valid but a lot that didn't warrant addressing involving single object
retrieval.

After some discussion with another trusted senior dev we came to the conclusion
that we only really wanted to highlight n+1; and we don't really care that
single object retrieval fetched a handful of related objects and we were happy
to let Django do its thing here. We don't want to burden developers to
select/prefetch in these situations.

A couple of other points from my review:

 - Oftentimes projects will refer to related objects in a model's `__str__()`.
   Whilst it's important to identify this, especially when it's used in a form
   field as select options, it can be problematic concealing errors when
   rendering models in tracebacks as Django refers to `__str__()` via
   `__repr__()`.
 - Sometimes UnsealedAttributeAccess exceptions were quite difficult trace
   through to identify the offending source/queryset. This was especially the
   case within complex DRF serialisation and you had to go back & peruse the
   code.

Along with a couple of remaining goals/nice-to-haves which are possibly outside
the scope of seal:

 - Identifying explicit n+1 aside from related attribute/manager access?  Unsure
   whether warning is helpful yet because in many cases these are deliberate
   indicating the dev is aware of the context.
 - Unnecessary select/prefetching; it'd be handy to be able to identify when
   this is occurring. These situations come about for a few reasons:
    - Code changes over time and related attributes may no longer get used but
      because the qs definition & usage are dispersed devs may forget to remove
      the select/prefetch.
    - Lazy devs copy & paste select/prefetch definitions without updating
      accordingly - this does happen and has passed code review - again because
      code dispersal makes this hard to identify.

Ideas for Improvement
---------------------

Here's what we'd ideally like to have moving forward:

 - Avoid raising warnings during repr
 - Have an option to only warn during looping to solve n+1
 - So far we're not sure how we'd tackle difficulties in tracing offending
   querysets but if there were solutions here they'd make life a lot easier!

There were a few ways we thought customise the solution:

### 1. Add an unseal()

 - Add an `unseal()` on our base model
 - Override `get()`, `first()`, `last()` & `__getitem__()` on our base queryset
   to unseal the returned instance
 - Additionally override `__repr__()` on our base model to unseal. This is safe
   to do because whilst Python will refer to `__repr__()` if a `__str__()` is
   not defined, Django implements both and refer to `__str__()` from
   `__repr()__` (opposite direction).
 - so far this is what we used to finalise adding seal to the sample project;
   however:

### 2. Customise SealableQuerySet to only seal from `__getitem__()`

This is potentially the cleaner solution - a trusted senior dev highlighted that
design that requires "escape hatches" (ie unseal) may indicate a less-than-ideal
solution that needs further thought.

 - Isolates sealing to looping/iteration
 - Single object access via `get()` and `__getitem()__` are unsealed
 - `first()` and `last()` unfortunately remain sealed as they make use of slices
   to retrieve the object (slicing calling `__getitem__()`)
   - These methods can be overridden though because a simple change can avoid
     slicing.

### 3. Investigate possibly counting queries per instance?

A dev had wondered whether some of our goals could be achieved if we could
somehow combine seal & query counting together.

Candidate for Inclusion into Django?
------------------------------------

I think a modified django-seal would be a nice inclusion as this the n+1 from
magic issue is raised often. Suggestions to auto-select/prefetch are often
rejected so perhaps the solution is to warn instead, but only for n+1 and not
single object retrieval?
