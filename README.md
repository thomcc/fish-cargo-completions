# Better cargo completion for fish

Note: These require `jq` to be installed and on the path, in order to parse `cargo metadata` output. Patches welcome to modify this to not require JQ.

I wanted to upstream this but I gather it would suffer the same fate as https://github.com/fish-shell/fish-shell/pull/6868. E.g. packaging rules make this kind of hard to get into a usable place.

## Features:

This adds completion for stuff like:

- `--target <tab>` to complete your currently installed target triples.

- `--package <local package>`/`-p <local package>` to autocomplete to the packages in the workspace.

- Much better completion of specific build targets:
    - `--example example` can complete examples that
    - `cargo {run,build,...} --bin <tab>` completes binaries
    - `cargo {bench,build,...} --bench <tab>` completes `[[bench]]`marks
    - `cargo {test,build,...} --test <tab>` completes integration tests
        - Caveat: this isnt the same as `cargo test -- <tab>` to complete based on the names of tests, which might be more useful, but we can't know until we build, which seems bad to do behind your back

- Completion for testrunner flags, (flags like `--nocapture` in `cargo test -- --nocapture`)

- Completion for `--features` listed in Cargo.toml (handles subdirs, `--manifest-path`, etc...)

- Completion for `--manifest-path`s in the current workspace, including when not at workspace root.

- A much more comprehensive set of flags and such than fish's builtin completions, although probably not fully complete because there's no way to do this other than manually going through `cargo help <subcmd>`, which I've done a few times now, for some reason.

- ...

All of this should be --manifest-path and --package/-p aware, and aware of your current directory, and only offer completions of feature/binaries/examples/tests/whatever for the manifest path or package you specify.

That is, even convoluted stuff like: `cargo run --manifest-path=../somewhere/Cargo.toml -p foobar --example <tab>` will (should) be able to let you choose from the list of examples (the normal cases work too, of course).

## Install with fisher (not tested but should work)

You should be able to install with [fisherman](https://github.com/fisherman/fisherman) by running

```
fisher thomcc/fish-cargo-completions
```

Again, note that you must install jq in addition.

Ask me if you want to install manually and don't know how (copying or symlinking files into the right spot).

# License

I based `completions/cargo.fish` off of https://github.com/fish-shell/fish-shell/blob/master/share/completions/cargo.fish, although almost none of the original remains now.

Everything else is CC0/public domain, I don't care about the license of the code.
