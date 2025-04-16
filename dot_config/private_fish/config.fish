if status is-interactive
    function __ls_after_cd__on_variable_pwd --on-variable PWD
        ls -AGF
    end

    fish_add_path $HOME/go/bin
    fish_add_path $HOME/bin
    fish_add_path $HOME/.cargo/bin

    function perfparser
        hotspot $1 --exportTo $2
    end

    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
    	yazi $argv --cwd-file="$tmp"
    	if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
    		builtin cd -- "$cwd"
    	end
    	rm -f -- "$tmp"
    end

    if test uname = "Linux"
        abbr --add open xdg-open
        function musicfox
            flatpak run --command=musicfox io.github.go_musicfox.go-musicfox
        end
    end

    zoxide init fish | source

    if test "$hostname" = "baldr"
        fastfetch --disk-show-regular false --disk-folders / --localip-show-ipv4 false
    else
        fastfetch --localip-show-ipv4 false
    end
end

