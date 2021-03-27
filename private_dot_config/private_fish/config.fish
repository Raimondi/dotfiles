#  Get script directory
# set DIR (cd (dirname (status -f)); and pwd)
#umask 0027

set -xg EDITOR vim
set -xg VISUAL vim
set -xg PAGER "less -X"
#set -xg fish_user_paths ~/bin
set -xg VIDIR_EDITOR_ARGS '-c :set nolist ft=vidir-ls'
set -xg CDPATH . ~
if test -d ~/Documents/Source
  set CDPATH $CDPATH ~/Documents/Source
end
set temp_path $PATH
set -xg PATH
for dir in                                                        \
  $temp_path                                                      \
  /sbin                                                           \
  /bin                                                            \
  /usr/sbin                                                       \
  /usr/bin                                                        \
  /opt/local/sbin                                                 \
  /usr/local/bin                                                  \
  /opt/local/Library/Frameworks/Python.framework/Versions/2.7/bin \
  ~/Library/Python/3.7/bin                                        \
  /opt/local/bin                                                  \
  ~/.local/bin                                                    \
  ~/.luarocks/bin                                                 \
  ~/.cargo/bin                                                    \
  ~/Source/fzf/bin                                                \
  ~/bin                                                           \

  test -n "$PATH"
  and set idx (contains --index "$dir" $PATH)
  and test -n "$idx"
  and set -eg PATH[$idx]
  test -e "$dir"
  and set -xg PATH $dir $PATH
end
set -e temp_path

if set -q -U fish_user_abbreviations
  set -e -U fish_user_abbreviations
end
if not set -q -g fish_user_abbreviations
  set -gx fish_user_abbreviations
end

# XQuartz libs are not in the usual place.
set -xg CPLUS_INCLUDE_PATH /usr/X11R6/include

set -xg GOPATH $HOME/Source/golang

if not status --is-interactive
  exit
end
##########################################
# What follows is for interactive shell. #
##########################################

if test -d ~/.config/ls_colors
  set ls_colors ~/.config/ls_colors
else if test -d ~/.ls_colors
  set ls_colors ~/.ls_colors
end

if type -f gdircolors 1>/dev/null 2>/dev/null
  eval (gdircolors  --c-shell $ls_colors \
     | string replace setenv 'set -xg')
else if type -f dircolors 1>/dev/null 2>/dev/null
  eval (dircolors  --c-shell $ls_colors \
     | string replace setenv 'set -xg')
end

set -g __sensitive_dir "$HOME/.config/sensitive"
if test -r "$__sensitive_dir/fish.fish"
  source "$__sensitive_dir/fish.fish"
end

set -l plugin_dir ~/.config/fish/plugins

#source "$plugin_dir/z-fish/z.fish"
source "$plugin_dir/repos/repos.fish"
source "$plugin_dir/cd_on_error.fish"
source "$plugin_dir/fbell.fish"

# http://www.colourlovers.com/palette/694737/Thought_Provoking
#colorscheme ECD078 D95B43 C02942 542437 53777A
#colorscheme 53777A D95B43 C02942 542437 ECD078

# http://www.colourlovers.com/palette/123774/Homage_to_the_Chefs
#colorscheme FFF2AF D31900 7CB490 FF6600

# Candidates for black bg
# http://www.colourlovers.com/palette/848743/%28%E2%97%95_%E2%80%9D_%E2%97%95%29
#colorscheme BD1550 8A9B0F E97F02 F8CA00
# http://wwew.colourlovers.com/palette/92095/Giant_Goldfish
#colorscheme FA6900 69D2E7 F38630 A7DBD8 E0E4CC
# http://www.colourlovers.com/palette/694737/Thought_Provoking
#colorscheme 53777A D95B43 C02942 542437 ECD078
# http://www.colourlovers.com/palette/123774/Homage_to_the_Chefs
#colorscheme FFF2AF D31900 7CB490 FF6600
# http://www.colourlovers.com/palette/1930/cheer_up_emo_kid
#colorscheme 4ECDC4 C44D58 FF6B6B 556270 C7F464
# http://www.colourlovers.com/palette/953498/Headache
#colorscheme 80BCA3 E6AC27 BF4D28 655643 F6F7BD
# http://www.colourlovers.com/palette/557539/vivacious
#colorscheme -s 1693A7 F8FCC1 C8CF02 E6781E CC0C39
# http://www.colourlovers.com/palette/510617/Love_Flowers
#colorscheme -s 7D9E3C 73581D FFFEC0 FFE2A6 FE9F8C

#set colors \
#"BD1550 8A9B0F E97F02 F8CA00" \
#"FA6900 69D2E7 A7DBD8 F38630 E0E4CC" \
#"69D2E7 A7DBD8 F38630 E0E4CC FA6900" \
#"A7DBD8 F38630 E0E4CC FA6900 69D2E7" \
#"F38630 E0E4CC FA6900 69D2E7 A7DBD8" \
#"E0E4CC FA6900 69D2E7 A7DBD8 F38630" \
#"53777A D95B43 C02942 542437 ECD078" \
#"FFF2AF D31900 7CB490 FF6600" \
#"4ECDC4 C44D58 FF6B6B 556270 C7F464" \
#"80BCA3 E6AC27 BF4D28 655643 F6F7BD" \
#\
#"1693A7 CC0C39 E6781E C8CF02 F8FCC1" \
#"F8FCC1 1693A7 CC0C39 E6781E C8CF02" \
#"C8CF02 F8FCC1 1693A7 CC0C39 E6781E" \
#"E6781E C8CF02 F8FCC1 1693A7 CC0C39" \
#"CC0C39 E6781E C8CF02 F8FCC1 1693A7" \
#\
#"F8FCC1 C8CF02 E6781E CC0C39 1693A7" \
#"C8CF02 E6781E CC0C39 1693A7 F8FCC1" \
#"E6781E CC0C39 1693A7 F8FCC1 C8CF02" \
#"CC0C39 1693A7 F8FCC1 C8CF02 E6781E" \
#"1693A7 F8FCC1 C8CF02 E6781E CC0C39" \
#\
#"FE9F8C 7D9E3C 73581D FFFEC0 FFE2A6" \
#"FFE2A6 FE9F8C 7D9E3C 73581D FFFEC0" \
#"FFFEC0 FFE2A6 FE9F8C 7D9E3C 73581D" \
#"73581D FFFEC0 FFE2A6 FE9F8C 7D9E3C" \
#"7D9E3C 73581D FFFEC0 FFE2A6 FE9F8C" \
#\
#"FE9F8C FFE2A6 FFFEC0 73581D 7D9E3C" \
#"FFE2A6 FFFEC0 73581D 7D9E3C FE9F8C" \
#"FFFEC0 73581D 7D9E3C FE9F8C FFE2A6" \
#"73581D 7D9E3C FE9F8C FFE2A6 FFFEC0" \
#"7D9E3C FE9F8C FFE2A6 FFFEC0 73581D" \
#
#set random (dd if=/dev/urandom bs=6 count=1 2>/dev/null | cksum | cut -f1 -d " ")
#set lucky (math "($random % "(count $colors)") + 1")
#eval "colorscheme -s $colors[$lucky]"
colorscheme -s FA6900 69D2E7 A7DBD8 F38630 E0E4CC
set -g fish_color_autosuggestion 555
set -g fish_color_search_match      --background=555

if type -f fortune >/dev/null 2>/dev/null
  set -l fortune "fortune -a"
  if type -f cowsay >/dev/null 2>/dev/null
    set -l cow_file (ls -1 /opt/local/share/cowsay/cows | random_line)
    set fortune "$fortune | cowsay -f \"$cow_file\""
  end
  if type -f lolcat >/dev/null 2>/dev/null
    set fortune "$fortune | lolcat"
  end
  eval $fortune
  echo
end
set -g gls_options -Alh -I '.*.sw?' -I '.*.un~' --group-directories-first --color=auto
abbr -a l 'gls $gls_options '

set -g fbell_actions bell
set -g fbell_ignored theme_showcase colorscheme scim ggdb
set -g fbell_time_limit 15

# Configure __fish_git_prompt
#set -g __fish_git_prompt_showcolorhints			true
set -g __fish_git_prompt_showdirtystate			true
#set -g __fish_git_prompt_char_dirtystate		'*'
#set -g __fish_git_prompt_char_stagedstate		'+'
#set -g __fish_git_prompt_char_invalidstate		'#'
set -g __fish_git_prompt_showstashstate			true
#set -g __fish_git_prompt_char_stashstate		'$'
set -g __fish_git_prompt_showuntrackedfile		true
#set -g __fish_git_prompt_char_untrackedfiles		'%'
set -g __fish_git_prompt_showupstream			true
#set -g __fish_git_prompt_char_upstream_equal		'='
#set -g __fish_git_prompt_char_upstream_behind		'<'
#set -g __fish_git_prompt_char_upstream_ahead		'>'
#set -g __fish_git_prompt_char_upstream_diverged	'<>'
set -g __fish_git_prompt_show_informative_status	true
#set -g __fish_git_prompt_char_cleanstate		'√'
set -g __fish_git_prompt_char_stateseparator		' '

# Defined in /opt/local/share/fish/functions/__fish_git_prompt.fish @ line 678
function __fish_git_prompt_set_color
	set -l user_variable_name "$argv[1]"
    set -l user_variable
    if set -q $user_variable_name
        set user_variable $$user_variable_name
    end
    set -l user_variable_bright

    set -l default default_done
    switch (count $argv)
        case 1 # No defaults given, use prompt color
            set default $___fish_git_prompt_color
            set default_done $___fish_git_prompt_color_done
        case 2 # One default given, use normal for done
            set default "$argv[2]"
            set default_done (set_color normal)
        case 3 # Both defaults given
            set default "$argv[2]"
            set default_done "$argv[3]"
    end

    set -l variable _$user_variable_name
    set -l variable_done "$variable"_done

    if not set -q $variable
        if test -n "$user_variable"
            set -g $variable (eval "set_color $user_variable")
            set -g $variable_done (set_color normal)
        else
            set -g $variable $default
            set -g $variable_done $default_done
        end
    end
end

if random 1 2 2> /dev/null > /dev/null
  starship init fish | source
else

  source ("/opt/local/bin/starship" init fish --print-full-init | sed -e {s/random/starship session/;}| psub)
end
