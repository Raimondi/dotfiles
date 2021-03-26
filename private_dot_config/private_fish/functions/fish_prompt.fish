function fish_prompt --description 'Write out the left prompt'
  set -l last_status $status

  set -l normal_c       $fish_color_normal
  set -l filler_c       $fish_color_cwd_root
  set -l root_c         $fish_color_cwd_root
  set -l user_c         $fish_color_user
  set -l cwd_c          $fish_color_cwd
  set -l host_c         $fish_color_host
  set -l status_c       $fish_color_status
  set -l error_c        $fish_color_error

  # Git prompt
  set -g __fish_git_prompt_color                        "$fish_color_normal"
  set -g __fish_git_prompt_color_flags                  "$fish_color_normal"
  set -g __fish_git_prompt_color_prefix                 "$fish_color_cwd_root"
  set -g __fish_git_prompt_color_suffix                 "$fish_color_cwd_root"
  #set -g __fish_git_prompt_color_bare                  "$fish_color_cwd_root"
  #set -g __fish_git_prompt_color_merging               "$fish_color_cwd_root"
  #set -g __fish_git_prompt_color_branch                "$fish_color_cwd_root"
  #set -g __fish_git_prompt_color_branch_detached       "$fish_color_cwd_root"
  #set -g __fish_git_prompt_color_dirtystate            "$fish_color_cwd_root"
  #set -g __fish_git_prompt_color_stagedstate           "$fish_color_cwd_root"
  #set -g __fish_git_prompt_color_upstream              "$fish_color_cwd_root"

  set -l is_sudo 0
  set -l is_su 0
  set -l is_ssh 0
  set -l is_super 0
  set -l jobs (count (jobs -p))
  set -l nest_lvl
  set -l git (__fish_git_prompt '%s')
  set -l pwd
  set -l host (prompt_hostname)
  set -l length 0
  set -l realhome ~
  set -l dir_length 5

  # Get some info

  set -q SUDO_USER
  and set is_sudo 1

  test "$USER" != "$LOGNAME"
  and set is_su 1

  test (id -u) -eq 0
  and set is_super 1

  test -n "$SSH_CLIENT$SSH_TTY$SSH_CONNECTION"
  and set is_ssh 1

  # First line start here
  # Make sure we have a clean start
  set_color normal

  if test $is_sudo -ne 0
    set_color $filler_c
    echo -n '('
    set_color $user_c
    echo -n 'sudo'
    set_color $filler_c
    echo -n ')'
    set length (math $length + 6)
  end

  if test $is_su -ne 0
    set_color $filler_c
    echo -n '('
    set_color $user_c
    echo -n 'su'
    set_color $filler_c
    echo -n ')'
    set length (math $length + 4)
  end

  if test $is_ssh -ne 0
    set_color $filler_c
    echo -n '('
    set_color $user_c
    echo -n 'ssh'
    set_color $filler_c
    echo -n ')'
    set length (math $length + 5)
  end

  if test $is_super -ne 0
    set_color $root_c
  else
    set_color $user_c
  end
  echo -n $USER
  set length (math $length + (string length "$USER"))

  set_color $filler_c
  echo -n '@'
  set length (math $length + 1)

  set_color $host_c
  echo -n $host
  set length (math $length + (string length "$host"))

  # make space for git info (it's a fix number because getting the
  # actual length is too complicated due to control characters)
  test -n "$git"
  and set length (math $length + 15)

  # count the colon that precedes $PWD
  set length (math $length + 1)
  set remaining (math "$COLUMNS" - $length)

  # Format and print $PWD
  if test $remaining -gt 3
    # Replace $HOME with "~"
    set -l pwd (string replace -r '^'"$realhome"'($|/)' '~$1' "$PWD")

    #echo -n $remaining
    set -l old_pwd $pwd
    while begin
        # make sure we get at least one character from every dir name and $pwd
        # is longer than the remaining space
        test $dir_length -gt 0 -a (string length "$pwd") -gt $remaining
        # Make sure there is something to shorten
        and string match -q -r '/([^/]{2,})/' "$pwd"
      end
      # shorten the dir names to make $pwd fit
      set pwd (string replace -r -a \
            '(\.?[^/]{'"$dir_length"'})[^/]*/' '$1/' "$pwd")
      set dir_length (math $dir_length - 1)
    end
    # If it is still too long, shorten it even more
    if test (string length "$pwd") -gt $remaining
      set count1 (math "$remaining" - 1)
      set count2 (math "$remaining" - 2)
      set pwd …(string match -r '/.{1,'"$count2"'}$|[^/]{1,'"$count1"'}$' "$pwd")
    end
    # If it fits then print it
    if test (string length "$pwd") -le $remaining
      set_color $filler_c
      echo -n ':'
      # Change color if the directory is not modifiable
      test -w "$PWD"
      and set_color $cwd_c
      or set_color $error_c
      test ! -e "$PWD"
      and set_color -r
      echo -n $pwd
      set_color normal
    end
  end

  if test -n "$git"
    set_color $filler_c
    echo -n ':'
    echo -n $git
  end

  # Second line starts here
  echo ""

  if test $last_status -ne 0
    set_color $status_c
    echo -n '('
    set_color $error_c
    echo -n "$last_status!"
    set_color $status_c
    echo -n ')'
  end

  if test $jobs -ne 0
    set_color $filler_c
    echo -n "("
    set_color $user_c
    echo -n "·<:$jobs"
    echo -n "-<$jobs"
    set_color $filler_c
    echo -n ")"
  end

  set_color $filller_c
  test $is_super -eq 1
  and echo -n '#'
  or echo -n '>'

  # Leave things tidy
  set_color normal
end
