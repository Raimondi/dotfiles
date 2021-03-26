if exists("current_compiler")
  finish
endif
let current_compiler = "crystal"

" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

" Older Vim don't define :CompilerSet
if exists(":CompilerSet") != 2
  command -nargs=* -bang CompilerSet if <bang>0 | set <args> | else | setlocal <args> | endif
endif

" Set the errorformat as required.
CompilerSet errorformat=
  \%ESyntax\ error\ in\ line\ %l:\ %m,
  \%ESyntax\ error\ in\ %f:%l:\ %m,
  \%EError\ in\ %f:%l:\ %m,
  \%Ein\ %f:%l:\ %m,
  \%Z%p^,
  \%-C%.%#
CompilerSet makeprg=crystal\ run\ --no-codegen\ --no-color\ %

let &cpo = s:save_cpo
unlet s:save_cpo
