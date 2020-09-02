# Better cargo completion for fish

Note: These require `jq` to be installed and on the path, in order to parse `cargo metadata` output. Patches welcome to modify this to not require JQ.

I wanted to upstream this but I gather it would suffer the same fate as https://github.com/fish-shell/fish-shell/pull/6868. E.g. packaging rules make this kind of hard to get into a usable place.

This adds completion for stuff like
- `cargo build --target <tab>` to complete available targets
- `cargo run --example <example>` or `cargo run --bin <bin>` for the binaries (note that this works in conjunction with a specified `-p`/`--package` or `--manifest-dir` arg, e.g. it will only complete examples for that package)
- `cargo whatever -p <local package>` to autocomplete to the packages availabel
- probably some other stuff, I wrote it a while ago

## Install with fisher (not tested but should work)

You should be able to install with [fisherman](https://github.com/fisherman/fisherman) by running

```
fisher thomcc/fish-cargo-completions
```

Again, note that you must install jq in addition.

# License

I think I based `completions/cargo.fish` off of https://github.com/fish-shell/fish-shell/blob/master/share/completions/cargo.fish

Everything else is CC0/public domain, I don't care about the license of the code.
