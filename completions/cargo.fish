# Tab completion for cargo (https://github.com/rust-lang/cargo).
complete -e -c cargo
complete -f -c cargo
complete -c cargo -s h -l help
complete -c cargo -s V -l version -d 'Print version info and exit'
complete -c cargo -l list -d 'List installed commands'
complete -c cargo -s v -l verbose -d 'Use verbose output'
complete -c cargo -s q -l quiet -d 'No output printed to stdout'

function __cargo_packages
    # TODO: consider caching cargo metadata output.
    # TODO: avoid jq dep (note: probably has bugs)
    # echo (cargo metadata --format-version 1
    #      | string match -r '"workspace_members"\\s*:\\s*\\[\"?(.*?)\"?\\]')[2]
    #    | string split '","'
    #    | string replace -r ' .*$' ''
    cargo metadata --no-deps --format-version 1 | jq -r '.workspace_members[] | sub(" .*$"; "")'
end
function __cargo_manifest_paths
    set -l input
    if test (count $argv) -gt 0
        set input $argv[1]
    else
        set input (commandline -ct)
    end
    set -l found
    set -l rx (string escape --style=regex "$PWD")
    if test -z "$input" || string match -vqr '^(~|\.\.|/)' -- "$input"
        set -l jqprog '.workspace_members[] | sub("^(?<name>[^ ]+) .*file://(?<path>.*?)\\\\)"; "\(.path)/Cargo.toml\t\(.name)")'
        if set -l metadata (cargo metadata  --no-deps --format-version 1 2> /dev/null)
            set -l pkgs (echo "$metadata" | jq -r $jqprog | string replace -r "^$rx/" "")
            set -a found $pkgs
        end
    end
    set -l dirs
    set -l paths $input*Cargo.toml $input*/Cargo.toml $input*/*/Cargo.toml
    for p in $input*
        if string match -qr 'Cargo.toml$' -- $p
            set -p paths $p
        end
    end
    set -l searched 0
    for f in $paths
        set searched (math $searched + 1)
        set -a found $f
    end
    if test "$searched" -eq 0
        set paths $input*/*/*/Cargo.toml
        for p in $paths
            set searched (math $searched + 1)
            set -a found $p
        end
    end
    if string match -qr '^\./' -- "$input"
        string join \n $found | sort -fs -k 1,1 -u -t \t
    else
        string replace -r '^\./' '' -- $found | string join \n | sort -fs -k 1,1 -u -t \t
    end
end

set __fish_cargo_subcommands (cargo --list | tail -n +2 | string trim | string replace -r '\s+' '\t')

complete -c cargo -f -n '__fish_use_subcommand' -a '$__fish_cargo_subcommands' -k
complete -c cargo -x -n '__fish_seen_subcommand_from help' -a '$__fish_cargo_subcommands' -k

for x in bench build clean doc fetch generate-lockfile \
    locate-project package pkgid publish \
    read-manifest run rustc test update \
    verify-project metadata

    complete -c cargo -x -n "__fish_seen_subcommand_from $x" -l manifest-path -d 'manifest' -a '(__cargo_manifest_paths)'
end

for x in bench build clean doc rustc test update check clippy run
    complete -c cargo -x -n "__fish_seen_subcommand_from $x" -s p -l package -d 'Package to build' -a '(__cargo_packages)'
end

for x in bench build clean doc run rustc test check clippy
    complete -c cargo -x -n "__fish_seen_subcommand_from $x" -l target -d 'Build for the target triple' -a '(rustup target list --installed)'
end

for x in bench build rustc test check clippy fmt
    complete -c cargo -x -n "__fish_seen_subcommand_from $x" -l bench -d 'Only the specified benchmark'
    complete -c cargo -n "__fish_seen_subcommand_from $x" -l lib -d 'Only this package\'s library'
    complete -c cargo -x -n "__fish_seen_subcommand_from $x" -l test -d 'Only the specified test'
end

for x in bench build run rustc test check clippy fmt
    complete -c cargo -x -n "__fish_seen_subcommand_from $x" -l bin -d 'Run the binary' -a '(__cargo_find_output bin bin)'
    complete -c cargo -x -n "__fish_seen_subcommand_from $x" -l example -d 'Run the example' -a '(__cargo_find_output example examples)'
end

for x in build run rustc test
    complete -c cargo -n "__fish_seen_subcommand_from $x" -l release -d 'Build artifacts in release mode, with optimizations'
end

for x in bench test
    complete -c cargo -n "__fish_seen_subcommand_from $x" -l no-run -d 'Compile but do not run'
end

for x in bench build doc run rustc test
    complete -c cargo -x -n "__fish_seen_subcommand_from $x" -s j -l jobs -d 'Number of jobs to run in parallel'
    complete -c cargo -x -n "__fish_seen_subcommand_from $x" -l features -d 'Space-separated list of features to also build'
    complete -c cargo -n "__fish_seen_subcommand_from $x" -l no-default-features -d 'Do not build the `default` feature'
end

complete -c cargo -n '__fish_seen_subcommand_from doc' -l no-deps -d 'Don\'t build documentation for dependencies'

complete -c cargo -x -n '__fish_seen_subcommand_from new' -l vcs -a 'none hg git' -d 'Specify a vcs to use'
complete -c cargo -x -n '__fish_seen_subcommand_from new' -l name

# This bin does not take any arguments which is why it is not defined above.
complete -c cargo -n '__fish_seen_subcommand_from new' -l bin

complete -c cargo -x -n '__fish_seen_subcommand_from git-checkout' -l url
complete -c cargo -x -n '__fish_seen_subcommand_from git-checkout' -l reference

for x in login publish search
    complete -c cargo -x -n "__fish_seen_subcommand_from $x" -l host -d 'The host to submit the request to'
end

complete -c cargo -n '__fish_seen_subcommand_from doc' -l open -d 'Opens the docs in a browser after the operation'

complete -c cargo -r -n '__fish_seen_subcommand_from owner' -s a -l add -d 'Login of a user to add as an owner'
complete -c cargo -r -n '__fish_seen_subcommand_from owner' -s r -l remove -d 'Login of a user to remove as an owner'

for x in owner yank
    complete -c cargo -r -n "__fish_seen_subcommand_from $x" -l index -d 'Registry index to use'
end

for x in owner publish yank
    complete -c cargo -x -n "__fish_seen_subcommand_from $x" -l token -d 'API token to use when authenticating'
end

complete -c cargo -n '__fish_seen_subcommand_from package' -l no-verify -d 'Don\'t verify the contents by building them'
complete -c cargo -n '__fish_seen_subcommand_from package' -l no-metadata -d 'Ignore warnings about a lack of human-usable metadata'

complete -c cargo -n '__fish_seen_subcommand_from update' -l aggressive -d 'Force updating all dependencies of <name> as well'
complete -c cargo -x -n '__fish_seen_subcommand_from update' -l precise -d 'Update a single dependency to exactly PRECISE'

complete -c cargo -x -n '__fish_seen_subcommand_from yank' -l vers -d 'The version to yank or un-yank'
complete -c cargo -n '__fish_seen_subcommand_from yank' -l undo -d 'Undo a yank, putting a version back into the index'
