# Defined in /Users/israel/.config/fish/config.fish @ line 203
function sudo-my-prompt
	set -l cmd (commandline)
  commandline --replace "sudo $cmd"
end
