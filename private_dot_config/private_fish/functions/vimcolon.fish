# Defined in /var/folders/d7/9x3nzt_n74z9rw52prcwxq0r0000gn/T//fish.PQB4wN/vimcolon.fish @ line 1
function vimcolon --description I\ often\ think\ I\'m\ in\ Vim
	if commandline -b | grep -q '^$'
    commandline -i ""
  else
    commandline -i :
  end
end
