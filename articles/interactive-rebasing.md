Interactive Rebasing
====================

Interactive rebasing is the process of editing Git commits to produce a **clean history**.

Contentious issue, some folks arguing that this amounts to "hiding your mistakes" but hopefully some points below will
convince folks of the value of a clean history.


Why do we want clean histories?
-------------------------------
Some aspects of a clean history:
 - Semantic commits: meaningfully grouped commits into bug fixes/features/refactor/etc
 - Atomic commits: No single commit should (ideally) break parseability/features/tests/type or lint checks. Also try to group documentation.
 - Progressive enhancement: Try to progress the feature, building on earlier commits, not later. Storytelling.
   - Tests may/may not be included with the feature. A potential benefit for writing tests first then a feature is to show TDD red/green
     to show the feature fixes the test.
 - Avoid superfluous style commits by automating some of that with Black & Prettier
   - Once this is done we may be able to do away with pure style commits altogether and instead have commits dedicated
     to fixing non-style related lint issues such as errors (actual or potential).

Some benefits:
 - Easier to review
   - Smaller, digestable chunks
   - Related patches in commit
 - Separation of risk
 - History archeology: Part of your toolset to determine the "original author's intent" by looking through the history
 - Non-pollution from WIP / meaningless / fixed-something commits
   - Git blame will generally show the last meaningful commit to help determine intent
 - Easier to bisect (auto-bisecting is made possible with "Atomic commits")


When should you rebase?
-----------------------
Generally you are free to edit **your own** commits that have not yet been published or shared with other developers.

**Do not**:
 - Edit commits that have been (or may have been) used by other developers
 - Edit other people's commits

The following may be considered acceptable:
 - Non-shared branches that have not been merged
 - Shared branches that have not been pushed
 - Git repos not yet published


A note on force-pushing
-----------------------
Editing the git history requires force pushing for commits that have already been pushed. **This is dangerous
for shared branches** and requires that you check that you're not about to overwrite other people's changes.
You can mitigate this by using the somewhat-better `--force-with-lease` option.  Force-with-lease will fail
if your refs are out-of-date, meaning that you mush fetch first. If you have to fetch first, this is an indication
that another developer has pushed to the branch. However it is not a fail-safe solution as you may still ignore
the updated ref and continue with the forced push.


Automating
----------

Fixup commits

```
git commit --fixup <commit-hash>
```

Auto-Squash

```
git rebase -i --autosquash <commit-hash>
```

Auto-Stash

```
git rebase -i --autostash <commit-hash>
```

Configuration

 - `rebase.autoSquash=true`
 - `rebase.autoStash=true`


Tig
---

Installed simply with:
```
brew install tig
```

Some of the useful features:
 - Viewing branch history; multiple branches; even stashes!
 - Customise views, some I have:
   - Main view, fixup commit
   - Main view, interactive rebase from commit
 - Status view
   - Scroll view with up/down, files with j/k
   - Easily stage/unstage hunks `u` or single lines `1`
   - Increase/decrease the size of hunks with `[`/`]`


References
----------
 - [Linus on Clean Histories](https://www.mail-archive.com/dri-devel@lists.sourceforge.net/msg39091.html)
