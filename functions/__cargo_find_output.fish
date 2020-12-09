
# Takes two arguments, target kind and the dir name where
# it's typically located:
# - `__cargo_find_output bin bin`
# - `__cargo_find_output example examples`
function __cargo_find_output
    # Look for --manifest-path args: both so that we can pass the right
    # thing to cargo metadata (if we have any idea how to parse it), and
    # so that all else fails, we can look in $manifest_dir/bins (or whatever).
    set -l extra_metadata_args
    set -l fallback_search_root "$argv[2]"
    if set -l manifest (__tcsc_command_opt_value manifest-path)
        set extra_metadata_args --manifest-path $manifest
        set -l manifest_dir (dirname $manifest)
        set fallback_search_root "$manifest_dir/$fallback_search_root"
    end
    # Look for a --package arg.
    set -l pkg (__tcsc_command_opt_value package -s p)

    if set -q pkg[1]
        # If they passed a --package arg, we need to know where it is.
        # Eventually the use of JQ should be rewritten to use python
        # the way the `npm` ones were.
        if command -sq jq
            set -l query '.packages[] | select(.name == $pkg) |
                .targets[] | select(.kind[] | contains($kind)) | .name'
            cargo metadata --no-deps --format-version 1 | \
                jq -r $query --arg pkg "$pkg" --arg kind "$argv[1]"
        end
    else
        if command -sq jq
            set -l query '.workspace_root as $ws | .packages[] | select(.id | endswith($ws + ")")) | .targets[]
                | select(.kind[] | contains($kind)) | {name: .name, path: .src_path | sub("^" + $ws + "/"; "")}
                | .name + "\t in " + .path'
            cargo metadata --no-deps --format-version 1 $extra_metadata_args | \
                jq -r $query --arg kind "$argv[1]"
        else if test -d "$fallback_search_root"
            # They didn't pass --no-deps, but `$cwd/examples` or
            # `$explicit_manifest/examples` (or something) exists.
            for e in "$fallback_search_root"/*.rs
                if set -l found (string match -r '/([^/]*?)\\.rs' -- $e)[2]
                    echo $found
                end
            end
        end
    end
end
