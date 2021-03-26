set nocompatible
set viminfofile=NONE
let &rtp = expand('<sfile>:p:h:h') . ',' . $VIMRUNTIME . ',' . expand('<sfile>:p:h:h') . '/after'
set backspace=2
set cmdheight=2
set hidden
set number
set timeoutlen=80
set laststatus=2
"ru plugin/delimitMate.vim
"let runVimTests = expand('<sfile>:p:h').'/build/runVimTests'
"if isdirectory(runVimTests)
"  let &rtp = runVimTests . ',' . &rtp
"endif
"let vimTAP = expand('<sfile>:p:h').'/build/VimTAP'
"if isdirectory(vimTAP)
"  let &rtp = vimTAP . ',' . &rtp
"endif

"augroup VIMRC
"  au!
"  for event in ['VimEnter', 'BufEnter', 'BufLeave', 'BufWinEnter', 'BufWinLeave', 'BufUnload', 'BufHidden', 'BufNew']
"    exec printf('au %s * echom "**%s** " . expand("<afile>")', event, event)
"  endfor
"augroup END
