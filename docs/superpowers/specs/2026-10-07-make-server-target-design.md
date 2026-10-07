# Make server target

## Goal

Provide one Make target to clean compiled Rails assets, precompile them, and
start the Rails server in sequence.

## Design

Add a `.PHONY` target named `server` to the repository-root `Makefile`. Running
`make server` executes this as one recipe, so a failed step prevents later
steps from running:

```sh
rails assets:clobber && rails assets:precompile && rails server
```

## Validation

Confirm the Makefile target and command match the requested sequence. Do not
run the Rails command during validation because it starts a server.
