" Yaifa: Yet another indent finder, almost...
" Version: 2.1
" Author: Israel Chauca F. <israelchauca@gmail.com>

if exists('g:loaded_yaifa') && !get(g:, 'yaifa_debug', 0)
  finish
endif
let g:loaded_yaifa = 1

function! s:log(level, message) "{{{
  if a:level <= get(g:, 'yaifa_debug', 0)
    echomsg printf('yaifa[%s]: %s', a:level, a:message)
  endif
endfunction "}}}

function! s:apply_settings(force, bufnr) "{{{
  " Does the user wants it ignored?
  let skip_it = get(b:, 'yaifa_disabled', get(g:, 'yaifa_disabled', 0))
  if !a:force && skip_it
    " Seems like we are skipping this buffer
    return
  endif
  if has('job')
    " We can be a bit slow on big files, this should mask it.
    if has('nvim')
      " Neovim
      call jobstart(yaifa#magic(a:bufnr))
    else
      " Vim
      call job_start(yaifa#magic(a:bufnr))
    endif
  else
    call yaifa#magic(a:bufnr)
  endif
endfunction "}}}


augroup Yaifa
  au!
  au BufReadPost * call s:apply_settings(0, bufnr('%'))
augroup End

command! -nargs=0 -bar -bang Yaifa call s:apply_settings(<bang>0, bufnr('%'))
command! -bar TestYaifa call yaifa9#test()

if get(g:, 'yaifa_debug', 0)
  function! s:l2str(line) "{{{
    if a:line.tab
      let type = 'tab'
    elseif a:line.space && a:line.mixed
      let type = 'either'
    elseif a:line.space
      let type = 'space'
    elseif a:line.mixed
      let type = 'mixed'
    elseif a:line.crazy
      let type = 'crazy'
    else
      let type = 'empty'
    endif
    let line = substitute(a:line.line, '\m\t', '|-------', 'g')
    let line = substitute(line, '\m ', nr2char(183), 'g')
    return printf('[%s:%2s]%-6s: %.60s',
          \ a:line.linenr, a:line.length, type, line)
  endfunction "}}}

  command! -count=1 -nargs=* DebugYaifa call s:log(<count>, <args>)
else
  command! -count=1 -nargs=* DebugYaifa :
endif
