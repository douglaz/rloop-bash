# AGENTS.md

This repository is `rloop-bash`: the Bash Implementation of rloop. The Specification it
implements is the git submodule `spec/` (rloop-spec), pinned at one revision; read
`spec/README.md` first, then `spec/00-overview.md`, `spec/01-run-lifecycle.md` and the rest in
order. The Specification is authoritative; nothing here restates it.

## What must be true

- The executable is `bin/rloop`, plain Bash, and `nix build` yields `result/bin/rloop` (a
  `flake.nix` with `writeShellApplication` wrapping `git` and coreutils is enough).
- `spec/conformance/run ./result/bin/rloop --self-check` passes. That suite is the definition of
  done; there is no other test suite to write.
- Prompts and agent command lines are hardcoded in `bin/rloop`, byte for byte as
  `spec/02-agents.md` and `spec/03-prompts.md` state them. The Implementation reads nothing from
  `spec/` at build or run time (`spec/docs/adr/0001-*.md`).
- Keep it small: the loop is about two hundred lines. No rollback, no resume, no daemon, no
  configuration file, no environment-variable flags (`spec/00-overview.md`, non-goals).

## Working here

- Run `spec/conformance/run ./result/bin/rloop` unpiped and quote its output when reporting.
- Commit with conventional messages (`feat:`, `fix:`, …). Never any AI or assistant reference in
  a commit, a comment or a document.
- Do not modify anything under `spec/`. A problem with the Specification is reported, not
  patched around.
