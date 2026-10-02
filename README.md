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

`bin/rloop` is plain Bash and also runs directly, given `git`, GNU or uutils coreutils, `cmp`
(diffutils) and `uuidgen` on `PATH`. With no clone at all: `nix run github:douglaz/rloop-bash`.

## Use

`rloop --help` lists the options.

### Hosting a long Run

A Run often takes hours: one Implementer call alone may run for `--implementer-timeout`, four hours
by default. In a terminal, run rloop in the foreground or in tmux. From an agent, or anywhere the
caller may go away, launch it as a transient systemd user unit. That has no runtime cap, outlives
the caller and keeps the exit status:

```sh
R=$(nix build --refresh --no-link --print-out-paths github:douglaz/rloop-bash)/bin/rloop
D=/var/tmp/rloop-units/myrepo-$(date -u +%m%dT%H%M); mkdir -p "$D"
systemd-run --user --unit=rloop-myrepo --collect --expand-environment=no \
  --working-directory="$PWD" -E PATH -p KillMode=mixed -p TimeoutStopSec=120 \
  -p "StandardOutput=file:$D/out" -p "StandardError=file:$D/err" \
  -p "ExecStopPost=/bin/sh -c 'echo \$\$SERVICE_RESULT \$\$EXIT_CODE \$\$EXIT_STATUS > $D/exit'" \
  "$R" --auto
```

- `$D/err` is the progress, `$D/out` the Finished File, and `$D/exit` the outcome, for example
  `exit-code exited 1`.
- `-E PATH` passes your `PATH`, so `claude` and `codex` resolve as they do in your shell.
  `--expand-environment=no` keeps a `$` in the instruction literal; avoid `%`, which systemd reads
  as a specifier.
- rloop is the unit's main process, so `systemctl --user stop rloop-myrepo` sends SIGTERM to rloop
  alone: it reaps its agents and exits 2 with `interrupted`. A task the Manager claimed stays
  claimed. The fixed unit name refuses a second Run in the same repository.
- The unit outlives your login only with `loginctl enable-linger $USER`, and no transient unit
  survives a reboot: a missing `exit` file means unknown, not success.
- Do not host a Run in an agent tool's background facility, which stops it at the tool's own
  timeout (two hours at most) and with the agent's session. Do not detach it with
  `setsid nohup … &` either: nobody receives the exit status, and under `nix run` the PID you get
  back is the wrapper's.

Everything else an operator needs — what a lone Run and a Sequence do, what each exit status
means, and what a Run that blocked or failed leaves behind — belongs to the Specification and is
written for exactly that reader:
[**Using rloop**](https://github.com/douglaz/rloop-spec#using-rloop). It is the same for every
Implementation, so it is not repeated here.
