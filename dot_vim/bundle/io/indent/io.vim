" Vim indent file
" Language: Io
" Maintainer: June Kim <juneaftn@...>
" Last Change: 2013 Dec 11
" Configuration:
"
" "g:io_indent_old_func"   when 1 indentexpr uses the older indenting function which is
"                          faster but inaccurate. When 0 (default) it uses the
"                          new indenting function.
"
" "g:io_indent_cont"       number of extra levels continued line will be
"                          indented. 3 is the default value.
"
" "g:io_indent_max_incr"   maximum number of indent levels a line can be
"                          increased relative to the previous line. When 0
"                          (default) there is no limit.
"
" "g:io_indent_lone_comma" when 1 (default) decrease indent level of a line
"                          with just a a single comma.

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

if get(g:, 'io_indent_old_func', 0)
  setlocal indentexpr=GetIoIndentOld()
else
  setlocal indentexpr=GetIoIndent()
endif
setlocal nolisp
setlocal nosmartindent
setlocal autoindent
setlocal indentkeys+=0)

" Restore when changing filetype.
let b:undo_indent = "setlocal indentexpr< indentkeys< lisp< smartindent< autoindent<"

" Only define the function once.
if exists("*GetIoIndent")
  finish
endif
let s:keepcpo= &cpo
set cpo&vim

function! GetIoIndent(...)
  " Some help debugging
  let v:lnum = get(a:, 1, v:lnum)
  if v:lnum == 1
    " First line should have no indent.
    return 0
  endif
  let prev_lnum = prevnonblank(v:lnum - 1)
  if prev_lnum == 0
    " Even if it's the first non-blank.
    return 0
  end
  if synIDattr(call('synID', [v:lnum, 1, 0]), 'name') =~# 'String\%(Delim\)\@!'
    " This line is part of a multiline string.
    return 0
  endif
  let cur_line = getline(v:lnum)
  if prev_lnum > 1
    " Find out if the previous line is a continued line.
    let prev_lines = getline(prev_lnum - 1, prev_lnum)
    while prev_lines[0] =~ '\\$' && prev_lnum > 1
      let prev_lnum -= 1
      call insert(prev_lines, getline(prev_lnum - 1))
    endwhile
    if prev_lines[0] !~ '\\$'
      call remove(prev_lines, 0)
    endif
    " Find out if previous line is part of a multiline string.
    let is_string = 0
    while prev_lnum > 1
          \ && synIDattr(
          \   call('synID', [prev_lnum, 1, 0]),
          \   'name'
          \ ) =~# 'String\%(Delim\)\@!'
      let prev_lnum -= 1
      let is_string = 1
    endwhile
    if is_string
      let first_string = matchstr(getline(prev_lnum), '.*\ze"\%(""\)\?[^"]*$')
      let last_string = matchstr(prev_lines[-1], '^[^"]*"\%(""\)\?\zs.*')
      let prev_line = first_string . last_string
    else
      let prev_line = join(prev_lines, '')
    endif
  else
    let prev_line = getline(prev_lnum)
    let prev_lines = [prev_line]
  endif
  if prev_line =~ '\\$'
        \ && synIDattr(
        \   call('synID', [prev_lnum + len(prev_lines) - 1, len(prev_line[-1]), 0]),
        \   'name'
        \ ) !~# 'Comment\|String'
    let plnum_temp = prevnonblank(prev_lnum - 1)
    " We have a continued line. If the two previous lines end with \ let's use
    " the same indentation as the previous one, otherwise add two levels or
    " whatever the user wants.
    if prev_lnum == 1 || getline(prev_lnum - 1) !~ '\\$'
          \ && synIDattr(
          \   call('synID', [prev_lnum - 1, len(getline(prev_lnum - 1)), 0]),
          \   'name'
          \ ) =~# 'Comment'
      let delta = 0
    else
      let delta = get(g:, 'io_indent_cont', 2)
    end
  else
    " Find out the balance between opening and closing parenthesis.
    let parens = substitute(matchstr(prev_line, '[()].*'), '[^()]', '', 'g')
    let parens_list = split(parens, '\zs')
    let delta = count(parens_list, '(') - count(parens_list, ')')
    let max_incr = get(g:, 'io_indent_max_incr', 0)
    if max_incr > 0 && delta > max_incr
      let delta = max_incr
    endif
    if prev_line =~ '^\s*)'
      let delta += 1
    endif
    if cur_line =~ '^\s*)'
      let delta -= 1
    endif
    if cur_line =~'^\s*,$' && get(g:, 'io_indent_lone_comma', 1)
      let delta -= 1
    elseif prev_line =~'^\s*,$' && get(g:, 'io_indent_lone_comma', 1)
      let delta += 1
    endif
    let prev_prev_line = getline(prev_lnum - 1)
    if !empty(prev_prev_line) && prev_prev_line =~ '\\$'
      let delta -= get(g:, 'io_indent_cont', 3)
    endif
  endif
  let indent = indent(prev_lnum) + (delta * shiftwidth())
  return indent > 0 ? indent : 0
endfunction

" Old Indent Code: {{{1
function! GetIoIndentOld()
  let lnum = prevnonblank(v:lnum - 1)

  if lnum == 0
    return 0
  endif

  let ind = indent(lnum)
  let flag = 0
  if getline(lnum) =~ '([^)]*$'
    let ind = ind + &sw
    let flag = 1
  endif

  if getline(v:lnum) =~ '^\s*)'
    let ind = ind - &sw
  endif

  return ind

endfunction "}}}

let &cpo = s:keepcpo
unlet s:keepcpo
" vim: set sw=2 sts=2 et fdm=marker:
