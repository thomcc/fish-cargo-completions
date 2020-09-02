
# This is like __fish_contains_opt, but prints the value. Handles
# `--foo blah`, `--foo=blah`, `-f blah`, `-f=blah`, and
# short opts can be be in a bundle e.g. `-xaf blah` and `-xaf=blah` are
# still recognized (although only if the preceeding arguments are all
# alphanumeric). We also stop looking after we see `--`.
#
# Usage:
# - `__tcsc_command_opt_value -s p package`: Search commandline for `-p` and `--package`
# - `__tcsc_command_opt_value foo bar -s a`: Search commandline for `--foo`, `--bar`, or `-a`
# - `__tcsc_command_opt_value -s a -s b`: Search commandline for `-a` and `-b`
# - `__tcsc_command_opt_value -s a -- $manual_args`: Search $manual_args for `-p` and `--package`
#
# This last one is useful for testing, as well as if the command line needs to be
# manipulated. If no `--` is passed in, we scan `commandline -co`
function __tcsc_command_opt_value -d "Checks if a specific option has been given in the current commandline, and print its value"
    set -l short_opt
    set -l long_opt
    set -l next_short
    set -l opts_done
    set -l args

    for a in $argv
        if test -n "$opts_done"
            set -a args $a
        else if test -n "$next_short"
            set next_short
            set -a short_opt $a
        else
            switch $a
                case -s
                    set next_short 1
                case '--'
                    set opts_done 1
                case '-*'
                    echo __tcsc_command_opt_value: Unknown option $a >&2
                    return 1
                case '*'
                    set -a long_opt $a
            end
        end
    end
    if test -z "$opts_done"
        set args (commandline -co)
    end

    set -l alts
    if set -q long_opt[1]
        set -l group (string join '|' -- $long_opt)
        set -a alts "--(?:$group)"
    end

    if set -q short_opt[1]
        set -l class (string join '' -- $short_opt)
        set -a alts "-[a-zA-Z0-9]*[$class]"
    end
    if not set -q alts[1]
        echo __tcsc_command_opt_value: no options given $i >&2
        return 1
    end
    set -l joined (string join '|' -- $alts)
    set -l regex "^(?:$joined)(?:=(.*))?\$"
    set -l next_arg

    for c in $args
        if test -n "$next_arg"
            echo "$c"
            return 0
        end
        if test "--" = "$c"
            return 1
        end
        if set -l matches (string match -r "$regex" -- "$c")
            if set -q matches[2]
                echo $matches[2]
                return 0
            else
                set next_arg 1
            end
        end
    end
    return 1
end
