# Defined in /var/folders/d7/9x3nzt_n74z9rw52prcwxq0r0000gn/T//fish.feQ7ct/asciibanner.fish @ line 2
function asciibanner --argument text
	set font_dir ~/Downloads/figlet-fonts-fork
  for font in {$font_dir}/contributed/*.flf {$font_dir}/international/*flf \
     {$font_dir}/jave/*.flf {$font_dir}/jave-more/*flf {$font_dir}/ours/*.flf
    echo $font
    figlet -w 78 -c -f "$font" "$text" | sed -e '/^[ \t]*$/d;'
    echo
  end
end
