

                                                Why?

        • Semantic commits
            • meaningfully grouped commits into bug fixes/features/refactor/etc

        • Atomic commits
            • No single commit should (ideally) break parseability/features/
              tests/type or lint checks. Also try to group documentation.

        • Progressive enhancement
            • Try to progress the feature, building on earlier commits, not later.
            • Storytelling.

        • Tests may/may not be included with the feature. A potential benefit
          for writing tests first then a feature is to show TDD red/green to
          show the feature fixes the test.

        • Avoid superfluous style commits by automating some of that with Black & Prettier
            • Once this is done we may be able to do away with pure style commits
              altogether and instead have commits dedicated to fixing non-style
              related lint issues such as errors (actual or potential).

