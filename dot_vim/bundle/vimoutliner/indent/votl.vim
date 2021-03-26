""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim indent plugin for filetype name.
" Maintainer:	Israel Chauca F. <israelchauca@gmail.com>
" Version:	0.1
" Description:	Long description.
" Last Change:	2012-06-06
" License:	Vim License (see :help license)
" Location:	indent/votl.vim
" Website:	https://github.com/vimoutliner/vo_base
"
" See vo_base.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help vo_base
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:vo_base_version = '0.1'

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
   finish
endif
let b:did_indent = 1

" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

setlocal indentexpr=votl#my_vo_base_indent(v:lnum)

setlocal indentkeys=
setlocal indentkeys+=!^F
setlocal indentkeys+=o
setlocal indentkeys+=O
setlocal indentkeys+=0<:>
setlocal indentkeys+=0;
setlocal indentkeys+=0<<>
setlocal indentkeys+=0<>>
setlocal indentkeys+=0<Bar>

" Restore when changing filetype.
let b:undo_indent = "setl indentexpr< indentkeys<"

" Only define the function once.
if exists("s:loaded")
  let &cpo = s:save_cpo
  unlet s:save_cpo
  finish
endif
let s:loaded = 1

function GetFileTypeNameIndent()
  " Do magic here.
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=2 sts=2 et fdm=marker:

