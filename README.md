# rloop-bash

The Bash Implementation of [rloop](spec/README.md): one long-lived Manager agent picks a task,
briefs disposable Implementers and a four-model review Panel, and judges the result, Round after
Round, until it writes the Finished File. The specification is the `spec/` submodule and is
authoritative; this repository holds only `bin/rloop` and the build.

## Build and check

```sh
git submodule update --init
nix build                                   # result/bin/rloop
spec/conformance/run ./result/bin/rloop     # the definition of done
spec/conformance/run ./result/bin/rloop --self-check
```

`bin/rloop` is plain Bash and also runs directly, given `git`, GNU or uutils coreutils and
`uuidgen` on `PATH`.

## Use

- **A lone Run:** `rloop` picks the next task from the repository's tracker; `rloop "fix the
  flaky retry test"` steers the pick. Exit 0 is done, 1 is blocked, 3 is idle (nothing to pick),
  2 is a failure; the Finished File — the Manager's report — is on standard output.
- **A Sequence:** check out the branch the work should land on, then `rloop --auto`. It runs
  until the Manager finds nothing left (exit 0), a task blocks (1), or something fails (2). The
  Manager commits each accepted task before the next starts; rloop never commits, branches or
  pushes, and opening the pull request is yours.
- **After a Run that ended blocked or capped:** the work is in the tree, uncommitted, on top of
  clean history — unless the Implementer committed during the Round, in which case unaccepted
  commits sit behind a clean tree and the next invocation's base would take them in unreviewed.
  Read the Finished File: it says what is committed and what is in the tree. Reconcile before
  starting again.
- **The Run Directory** — `.rloop/runs/<timestamp>-<pid>/` by default — holds every brief, every
  Reviewer's feedback, every agent's output and the Manager's report. It is never deleted.

`rloop --help` lists the options.
