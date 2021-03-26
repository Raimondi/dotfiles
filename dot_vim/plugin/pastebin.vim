let fmt = 'command! -range=%% Pastebin%s <line1>,<line2>w !%s %s'
      \ . ' | tr -d ''\n'' | %s'
if executable('pbcopy')
  let clip = 'pbcopy'
elseif executable('xclip')
  let clip = 'xclip -i -selection clipboard'
else
  let clip = 'cat'
endif

let cmd = 'curl -s -F'
exe printf(fmt, 'Vpaste', cmd, '"text=<-" http://vpaste.net', clip)
exe printf(fmt, 'Sprunge', cmd, '"sprunge=<-" http://sprunge.us', clip)
exe printf(fmt, 'Ix', cmd, '"f:1=<-" ix.io', clip)
exe printf(fmt, 'Clbin', cmd, '"clbin=<-" https://clbin.com', clip)

let cmd = 'nc'
exe printf(fmt, 'Termbin', cmd,   'termbin.com 9999', clip)
exe printf(fmt, 'Qbin', cmd,   'qbin.io 99', clip)
exe printf(fmt, 'Tcp', cmd, 'tcp.st 7777 | grep URL | cut -d " " -f 2', clip)
