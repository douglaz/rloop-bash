# rloop-bash

The Bash Implementation of [rloop](https://github.com/douglaz/rloop-spec): one long-lived Manager
agent picks a task, briefs disposable Implementers and a four-model review Panel, and judges the
result, Round after Round, until it writes the Finished File. The specification is the `spec/`
submodule and is authoritative; this repository holds only `bin/rloop` and the build.

## Build and check

```sh
git submodule update --init
nix build                                   # result/bin/rloop
spec/conformance/run ./result/bin/rloop     # the definition of done
spec/conformance/run ./result/bin/rloop --self-check
spec/conformance/test-panel-trace ./result/bin/rloop
```

CI runs `nix build`, the self-check and the Panel trace check on every push and pull request
(`.github/workflows/ci.yml`).

`bin/rloop` is plain Bash and also runs directly, given `git`, GNU or uutils coreutils and
`uuidgen` on `PATH`. With no clone at all: `nix run github:douglaz/rloop-bash`.

## Use

`rloop --help` lists the options.

Everything else an operator needs — what a lone Run and a Sequence do, what each exit status
means, what a Run that blocked or failed leaves behind, and how to run one that takes an hour —
belongs to the Specification and is written for exactly that reader:
[**Using rloop**](https://github.com/douglaz/rloop-spec#using-rloop). It is the same for every
Implementation, so it is not repeated here.
