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

CI runs `nix build` and the self-check on every push and pull request
(`.github/workflows/ci.yml`).

`bin/rloop` is plain Bash and also runs directly, given `git`, GNU or uutils coreutils and
`uuidgen` on `PATH`.

## Use

- **A lone Run:** `rloop` picks the next task from the repository's tracker; `rloop "fix the
  flaky retry test"` steers the pick. Exit 0 is done, 1 is blocked, 3 is idle (nothing to pick),
  2 is a failure; the Finished File — the Manager's report — is on standard output.
- **Blocked (exit 1) is a question for you.** The Manager blocks when the task turns on a point
  the repository's specifications leave ambiguous — it never picks a reading — and the report
  names the passage and recommends a clarification. Clarify the specification, then run again.
  Implementation choices the specifications leave open it settles after consulting two advisers
  — four when the two disagree, and blocked for you when the four do not settle it — and the brief
  records the question and the answers.
- **A Sequence:** check out the branch the work should land on, then `rloop --auto`. It runs
  until the Manager finds nothing left (exit 0), a task blocks (1), or something fails (2). The
  Manager commits each accepted task before the next starts; rloop never commits, branches or
  pushes, and opening the pull request is yours.
- **After a Run that ended blocked or capped:** the work is in the tree, uncommitted, on top of
  clean history — unless the Implementer committed during the Round, in which case unaccepted
  commits sit behind a clean tree and the next invocation's base would take them in unreviewed.
  Read the Finished File: it says what is committed and what is in the tree. Reconcile before
  starting again.
- **A Run is long.** A Round takes 15–30 minutes and a Run may take an hour. Run rloop in the
  foreground, in a terminal or a tmux window, and read the exit status from the shell as with any
  command. A caller that cannot wait that long — an agent whose command tool has a timeout —
  should use that tool's own background facility, which keeps the process tracked and returns the
  exit status, rather than detaching with `setsid nohup … &`: a detached process reports its exit
  status to nobody, and under `nix run` the PID the shell hands back is the wrapper's, which exits
  once rloop starts. If you must detach, the Run's own PID is on the `rloop: run <n>: pid <pid>`
  line on standard error and, by default, the suffix of the Run Directory name, and the exit
  status survives only if you wrap the command: `sh -c 'nix run …; echo $? > rloop.exit'`.
- **The Run Directory** — `.rloop/runs/<timestamp>-<pid>/` by default — holds every brief, every
  Reviewer's feedback, every agent's output and the Manager's report. It is never deleted.

`rloop --help` lists the options.
