function set_colors -d 'Use the given colors to ses fish_colors'

  if type -q argparse
    set options 'g/grey=' 'h/help' 'a-autosuggestion=' 'b-command=' \
       'c-comment=' 'd-cwd=' 'e-cwd_root=' 'f-end=' 'z-error=' 'ñ-escape=' \
       'i-history_current=' 'j-host=' 'k-match=' 'l-normal=' 'm-operator=' \
       'n-param=' 'o-quote=' 'p-redirection=' 'q-search_match=' 'r-status=' \
       's-user=' 't-valid_path=' 'u-pager_completion=' 'v-pager_description=' \
       'w-pager_prefix=' 'x-pager_progress=' 'y-pager_secondary='
    argparse --name=set_colors --max=5 $options -- $argv
    or return

    set -q _flag_help
    and echo '
        set_colors [-h|--help]
        set_colors [OPTIONS] color1[ color2[ color3[ color4[ color5]]]]

Automatically set fish\'s colors with the given colors.

The following options are available:

        -h, --help		show this text
        -g, --grey		overrides the default value (555) for
                                fish_color_search\'s background
        --autosuggestion	overrides fish_color_autosuggestion
        --command		overrides fish_color_command
        --comment		overrides fish_color_comment
        --cwd			overrides fish_color_cwd
        --cwd_root		overrides fish_color_cwd_root
        --end			overrides fish_color_end
        --error			overrides fish_color_error
        --escape		overrides fish_color_escape
        --history_current	overrides fish_color_history_current
        --host			overrides fish_color_host
        --match			overrides fish_color_match
        --normal		overrides fish_color_normal
        --operator		overrides fish_color_operator
        --param			overrides fish_color_param
        --quote			overrides fish_color_quote
        --redirection		overrides fish_color_redirection
        --search_match		overrides fish_color_search_match
        --status		overrides fish_color_status
        --user			overrides fish_color_user
        --valid_path		overrides fish_color_valid_path
        --pager_completion	overrides fish_pager_color_completion
        --pager_description	overrides fish_pager_color_description
        --pager_prefix		overrides fish_pager_color_prefix
        --pager_progress	overrides fish_pager_color_progress
        --pager_secondary	overrides fish_pager_color_secondary
'
    and return

    set -q _flag_grey
    and  set -l grey $_flag_grey
    or set -l grey 555
  end

  switch (count $argv)
    case 5
      set color $argv[1]
      set -g fish_color_user              $color
      set -g fish_color_cwd               $color
      set -g fish_color_host              $color
      set -g fish_color_normal            $color
      set -g fish_color_command           $color
      set -g fish_pager_color_prefix      $color
      set color $argv[2]
      set -g fish_color_param             $color
      set -g fish_color_redirection       $color
      set -g fish_color_operator          $color
      set color $argv[3]
      set -g fish_color_quote             $color
      set -g fish_color_escape            $color
      set -g fish_color_match             $color
      set -g fish_color_history_current   $color
      set -g fish_color_cwd_root          $color
      set -g fish_pager_color_completion  $color
      set color $argv[4]
      set -g fish_color_autosuggestion    $color
      set -g fish_color_comment           $color
      set color $argv[5]
      set -g fish_pager_color_progress    $color
      set -g fish_pager_color_description $color
      set -g fish_color_end               $color
      set -g fish_color_status            $color
      set -g fish_pager_color_secondary   $color
      set -g fish_color_error             $color
      # Special
      set -g fish_color_valid_path        --underline
      set -g fish_color_search_match      --background=$grey

    case 4
      set color $argv[1]
      set -g fish_color_user              $color
      set -g fish_color_cwd               $color
      set -g fish_color_host              $color
      set -g fish_color_normal            $color
      set -g fish_pager_color_description $color
      set -g fish_color_param             $color
      set color $argv[2]
      set -g fish_color_command           $color
      set -g fish_color_redirection       $color
      set -g fish_color_operator          $color
      set -g fish_pager_color_progress    $color
      set -g fish_pager_color_completion  $color
      set color $argv[3]
      set -g fish_color_quote             $color
      set -g fish_color_escape            $color
      set -g fish_color_match             $color
      set -g fish_color_history_current   $color
      set -g fish_color_cwd_root          $color
      set -g fish_pager_color_prefix      $color
      set -g fish_color_autosuggestion    $color
      set color $argv[4]
      set -g fish_color_comment           $color
      set -g fish_color_end               $color
      set -g fish_color_status            $color
      set -g fish_pager_color_secondary   $color
      set -g fish_color_error             $color
      # Special
      set -g fish_color_valid_path        --underline
      set -g fish_color_search_match      --background=$grey

    case 3
      set color $argv[1]
      set -g fish_color_user              $color
      set -g fish_color_cwd               $color
      set -g fish_color_host              $color
      set -g fish_color_normal            $color
      set -g fish_pager_color_description $color
      set -g fish_pager_color_prefix      $color
      set -g fish_color_param             $color
      set -g fish_color_quote             $color
      set -g fish_color_command           $color
      set -g fish_color_escape            $color
      set color $argv[2]
      set -g fish_color_redirection       $color
      set -g fish_color_operator          $color
      set -g fish_pager_color_progress    $color
      set -g fish_pager_color_completion  $color
      set -g fish_color_end               $color
      set -g fish_color_autosuggestion    $color
      set color $argv[3]
      set -g fish_color_match             $color
      set -g fish_color_history_current   $color
      set -g fish_color_cwd_root          $color
      set -g fish_color_comment           $color
      set -g fish_color_status            $color
      set -g fish_pager_color_secondary   $color
      set -g fish_color_error             $color
      # Special
      set -g fish_color_valid_path        --underline
      set -g fish_color_search_match      --background=$grey

    case 2
      set color $argv[1]
      set -g fish_color_user              $color
      set -g fish_color_cwd               $color
      set -g fish_color_host              $color
      set -g fish_color_normal            $color
      set -g fish_pager_color_prefix      $color
      set -g fish_color_param             $color
      set -g fish_color_quote             $color
      set -g fish_color_command           $color
      set -g fish_pager_color_completion  $color
      set color $argv[2]
      set -g fish_color_redirection       $color
      set -g fish_color_operator          $color
      set -g fish_pager_color_progress    $color
      set -g fish_color_end               $color
      set -g fish_color_autosuggestion    $color
      set -g fish_pager_color_description $color
      set -g fish_color_match             $color
      set -g fish_color_history_current   $color
      set -g fish_color_cwd_root          $color
      set -g fish_color_escape            $color
      set -g fish_color_comment           $color
      set -g fish_color_status            $color
      set -g fish_pager_color_secondary   $color
      set -g fish_color_error             $color
      # Special
      set -g fish_color_valid_path        --underline
      set -g fish_color_search_match      --reverse

    case 1
      set color $argv[1]
      set -g fish_color_user              $color
      set -g fish_color_cwd               $color
      set -g fish_color_host              $color
      set -g fish_color_normal            $color
      set -g fish_pager_color_description $color
      set -g fish_pager_color_prefix      $color
      set -g fish_color_param             $color
      set -g fish_color_quote             $color
      set -g fish_color_command           $color --bold
      set -g fish_pager_color_completion  $color
      set -g fish_color_redirection       $color
      set -g fish_color_operator          $color
      set -g fish_pager_color_progress    $color
      set -g fish_color_end               $color
      set -g fish_color_autosuggestion    $color --bold
      set -g fish_color_match             $color
      set -g fish_color_history_current   $color
      set -g fish_color_cwd_root          $color --bold
      set -g fish_color_escape            $color
      set -g fish_color_comment           $color
      set -g fish_color_status            $color --bold
      set -g fish_pager_color_secondary   $color
      set -g fish_color_error             $color
      # Special
      set -g fish_color_valid_path        --underline
      set -g fish_color_search_match      --reverse

  end

  # override defaults
  set -q _flag_autosuggestion
  and set -g fish_color_autosuggestion $_flag_autosuggestion
  set -q _flag_command
  and set -g fish_color_command $_flag_command
  set -q _flag_comment
  and set -g fish_color_comment $_flag_comment
  set -q _flag_cwd
  and set -g fish_color_cwd $_flag_cwd
  set -q _flag_cwd_root
  and set -g fish_color_cwd_root $_flag_cwd_root
  set -q _flag_end
  and set -g fish_color_end $_flag_end
  set -q _flag_error
  and set -g fish_color_error $_flag_error
  set -q _flag_escape
  and set -g fish_color_escape $_flag_escape
  set -q _flag_history_current
  and set -g fish_color_history_current $_flag_history_current
  set -q _flag_host
  and set -g fish_color_host $_flag_host
  set -q _flag_match
  and set -g fish_color_match $_flag_match
  set -q _flag_normal
  and set -g fish_color_normal $_flag_normal
  set -q _flag_operator
  and set -g fish_color_operator $_flag_operator
  set -q _flag_param
  and set -g fish_color_param $_flag_param
  set -q _flag_quote
  and set -g fish_color_quote $_flag_quote
  set -q _flag_redirection
  and set -g fish_color_redirection $_flag_redirection
  set -q _flag_search_match
  and set -g fish_color_search_match $_flag_search_match
  set -q _flag_status
  and set -g fish_color_status $_flag_status
  set -q _flag_user
  and set -g fish_color_user $_flag_user
  set -q _flag_valid_path
  and set -g fish_color_valid_path $_flag_valid_path

  set -q _flag_pager_completion
  and set -g fish_pager_color_completion $_flag_pager_completion
  set -q _flag_pager_description
  and set -g fish_pager_color_description $_flag_pager_description
  set -q _flag_pager_prefix
  and set -g fish_pager_color_prefix $_flag_pager_prefix
  set -q _flag_pager_progress
  and set -g fish_pager_color_progress $_flag_pager_progress
  set -q _flag_pager_secondary
  and set -g fish_pager_color_secondary $_flag_pager_secondary

end
