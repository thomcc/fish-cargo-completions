function __cargo_cmdline_package
    set -l nargs (count $argv)
    for i in (seq 1 $nargs)
        set -l c "$argv[$i]"
        switch "$c"
            case -p --package
                if test $i -eq $nargs
                    return 1
                end
                set -l next (math $i + 1)
                echo $argv[$next]
                return 0
            case '-p=*'
                echo (string split '=' -- $c)[2]
                return 0
            case '--package=*'
                echo (string split '=' -- $c)[2]
                return 0
            case --
                return 1
            case '*'
                continue
        end
    end
    return 1
end
