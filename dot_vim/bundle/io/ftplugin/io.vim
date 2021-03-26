" Vim filetype plugin.
" Language:	Io
" Maintainer:	Israel Chauca F. <israelchauca@gmail.com>
" Description:	Filetype plugin for the Io language.
" Last Change:	2013-12-21
" License:	Vim License (see :help license)
"
" "g:io_eval_cmd" or "b:io_eval_cmd" specify the executable that will be used
" to evaluate the code.

" Only do this when not done yet for this buffer.
if exists("b:did_ftplugin")
  finish
endif

" Don't load another filetype plugin for this buffer.
let b:did_ftplugin = 1

" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

" Restore things when changing filetype.
let b:undo_ftplugin = "setl com< ofu<"
      \ . "|nunmap <buffer><leader>io"
      \ . "|xunmap <buffer><leader>io"
      \ . "|delcommand IoEval"

" Set completion with CTRL-X CTRL-O to autoloaded function.
"if exists('&ofu')
"  setlocal ofu=iocomplete#Complete
"endif

" Set 'comments' to the default.
setlocal comments&

command! -buffer -bang -range=% -nargs=* IoEval silent <line1>,<line2>call s:io_eval(<bang>0, <q-args>)

if !hasmapto('<Plug>IoEval', 'n')
  silent! nmap <unique><buffer><leader>io <Plug>IoEval
endif
if !hasmapto('<Plug>IoEval', 'v')
  silent! xmap <unique><buffer><leader>io <Plug>IoEval
endif

if exists('*s:io_eval')
  let &cpo = s:save_cpo
  finish
endif

nnoremap <Plug>IoEval :IoEval<CR>
xnoremap <Plug>IoEval :IoEval<CR>

function! s:io_eval(bang, code) range
  " TODO find a good use for the bang.
  let io_cmd = get(b:, 'io_eval_cmd', get(g:, 'io_eval_cmd', 'io'))
  if executable(io_cmd) != 1
    echohl ErrorMsg
    echom 'Io: Vim could not find "' . io_cmd . '".'
    echohl Normal
    return
  endif
  let save_lazy = &lazyredraw
  set lazyredraw
  let lines = empty(a:code) ? getline(a:firstline, a:lastline) : [a:code]
  let bufnr = bufnr('IoEvalOutput')
  let winnr = bufwinnr(bufnr)
  if bufnr == -1
    new IoEvalOutput
  elseif winnr == winnr()
    " It's weird to be here. Just stay in this window and don't move.
  elseif winnr > -1
    exec winnr . "wincmd w"
  else
    split
    exec "buffer " . bufnr
  endif
  %d_
  call setline(1, lines)
  exec "%!" . io_cmd
  setl buftype=nofile
  let &lazyredraw = save_lazy
  redraw
endfunction

" Teardown:{{{1
"reset &cpo back to users setting
let &cpo = s:save_cpo

" Template From: https://github.com/dahu/Area-41/
" vim: set sw=2 sts=2 et fdm=marker:
