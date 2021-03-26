function select_libros
    set -l origin ~/Downloads/Torrents/libros/
    if not fzf --version 2>&1 >/dev/null
        echo "\"fzf\" was not found!" >&2
        return 1
    end
    set -l destination ~/Desktop
    set selection (
    if fd --version 2>&1 >/dev/null
        fd . --type=f $origin
    else
        find $origin -type f
    end | fzf --with-nth=-1 --delimiter=/ --multi --query="$argv" )
    if test $status -eq 0 #set selection ($find | $chooser)
        echo "destination: $destination"
        for book in $selection
            printf 'copying %s"%s"%s... %s\n' \
               (set_color yellow) \
               (echo -n "$book" | sed -e 's/.*\///') \
               (set_color normal) \
               (
            if cp $book $destination 2>&1 >/dev/null
                set_color green
                echo "done!"
            else
                set_color red
                echo "failed!"
            end )
            set_color normal
        end
    else
        echo 'no books were selected' >&2
    end
end
