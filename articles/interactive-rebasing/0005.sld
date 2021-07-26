

                                           Some benefits

        • Easier to review
            • Smaller, digestable chunks
            • Related patches in commit

        • Separation of risk
            • Style changes (least risky)
            • Behaviour changes (most risky)

        • History archeology
            • Part of your toolset to determine the "original author's intent"
              by looking through the history

        • Non-pollution from WIP / meaningless / fixed-something commits
            • Git blame will generally show the last meaningful commit to help
              determine intent

        • Easier to git-bisect
            • auto-bisecting is made possible with "Atomic commits"


