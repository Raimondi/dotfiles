# Defined in /Users/israel/.config/fish/config.fish @ line 182
function rationalize_dot
	if commandline -t | grep -q '\(^\|/\)\.\.$'
    commandline -i /..
  else
    commandline -i .
  end
end
