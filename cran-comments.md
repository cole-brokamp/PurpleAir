## R CMD check results

0 errors | 0 warnings | 2 notes

- This is a bug fix and new feature update.
- R CMD checks passed with above results on:
  - R v4.4.3 (macOS 26.4.1)
- The future timestamp NOTE says "unable to verify current time"; this is a local environment issue, not a package timestamp issue.
- The HTML manual NOTE comes from the local validator rejecting R-generated HTML5 tags such as `<main>` across all Rd pages.

The latest GitHub Actions R-CMD-check run on `main` passed on 2026-05-08 for macOS release, Windows release, Ubuntu release, Ubuntu oldrel-1, and Ubuntu devel.

## Reverse dependencies

There are no reverse dependencies.
