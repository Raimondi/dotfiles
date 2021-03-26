" if there is another, bail
if exists("b:did_indent")
  finish
endif

let b:did_indent = 1

setlocal nosmartindent

" indent expression and keys that trigger it
setlocal indentexpr=GetTclIndent()
setlocal indentkeys-=:,0#

" say something once, why say it again
if exists("*GetTclIndent")
  finish
endif

function! XXis_continued_line(lnum) "{{{1
  return a:lnum <= 1 || getline(a:lnum - 1) =~ '\\$'
endfunction

function! XXget_start_of_line(lnum) "{{{1
  let lnum = a:lnum
  while lnum > 1
    let line = getline(lnum)
    if getline(lnum - 1) !~ '\\$'
      " Not a continued line, line starts here
      break
    elseif XXis_in_string([lnum, 1])
      " String at the sol
      if line[0] != '"'
        " It doesn't start on this line
        let lnum -= 1
        continue
      endif
      " Line starts with a double quote and, since a string is a valid
      " command, let's see if the double quote starts a new string
      if XXis_in_string([lnum, 2])
        " Second char is part of a string too
        " Let's check if it starts a new string
        if line[1] != '"'
          " First double quote starts a string, line starts here
          break
        end
        " Second char is a double quote too
        if XXis_in_string([lnum, 3])
          " Third char is also part of a string
          " Let's see if the second double quote starts a new string
          if line[2] != '"'
            " Second double quote starts a new string, keep looking
            let lnum -= 1
          else
            " Second double quote ends the string, line starts here
            break
          endif
        endif
      else
        " The double quote ends a string, keep looking
        let lnum -= 1
        continue
      endif
    endif
    let lnum -= 1
  endwhile
  return lnum
endfunction

function! XXget_prev_non_blank_lnum(lnum) "{{{1
  let lnum = a:lnum - 1
  while lnum > 1 && getline(lnum) !~ '\S'
    let lnum -= 1
  endwhile
  return lnum
endfunction

function! XXis_in_string_or_comment(pos) "{{{1
  return synIDattr(synID(a:pos[0], a:pos[1], 1), 'name') =~? 'string\|comment'
endfunction

function! XXis_in_comment(pos) "{{{1
  return synIDattr(synID(a:pos[0], a:pos[1], 1), 'name') =~? 'comment'
endfunction

function! XXis_in_string(pos) "{{{1
  return synIDattr(synID(a:pos[0], a:pos[1], 1), 'name') =~? 'string'
endfunction

function! XXget_curly_balance(lnum) "{{{1
  let cur_lnum = XXget_start_of_line(a:lnum)
  call cursor(cur_lnum, 1)
  let col = 0
  let open_found = 0
  let closing = 0
  let trailing = 0
  let leading = 0
  let line = getline(cur_lnum)
  while cur_lnum <= a:lnum
    let flags = col == 0 ? 'cW' : 'zW'
    let pos = searchpos('[{}]', flags, cur_lnum)
    let col = pos[1]
    if col == 0
      " Nothing found
      let cur_lnum += 1
      let line = getline(cur_lnum)
      continue
    endif
    if !XXis_in_string_or_comment(pos)
      if line[col - 1] == '{'
        if !open_found
          let leading = closing
          let open_found += 1
        endif
        let trailing += 1
      elseif line[col - 1] == '}'
        let closing += 1
        let trailing -= trailing > 0
      endif
    endif
    if !open_found
      let leading = closing
    endif
  endwhile
  return [leading, trailing]
endfunction

function! GetTclIndent(...) "{{{1
  let lnum = a:0 ? a:1 : v:lnum
  if lnum <= 1
    return 0
  endif
  if XXis_in_string([lnum, 1])
    return indent(lnum)
  endif
  let continued_extra = get(g:, 'tcl_indent_cont', get(g:, 'indent_cont', 2))
  if XXis_continued_line(lnum)
    if XXis_continued_line(lnum - 1)
      return indent(lnum - 1)
    else
      return indent(lnum - 1) + continued_extra * shiftwidth()
    endif
  endif
  let cur_pos = getcurpos()
  let prev_lnum = XXget_prev_non_blank_lnum(lnum)
  let prev_lnum = XXget_start_of_line(prev_lnum)
  let [prev_lead, prev_trail] = XXget_curly_balance(prev_lnum)
  let prev_lead = prev_lead ? prev_lead - 1 : 0
  let leading = !XXis_in_comment([lnum, 1]) && getline(lnum) =~ '^\s*}'
  return indent(prev_lnum) + (prev_trail - prev_lead - leading) * shiftwidth()
endfunction
