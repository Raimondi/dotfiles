" Vim indent file
" Language:        AWK Script
" Maintainer:      Clavelito <maromomo@hotmail.com>
" Id:              $Date: 2016-03-11 13:08:34+09 $
"                  $Revision: 1.63 $


if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal indentexpr=GetAwkIndent()
setlocal indentkeys-=0#

if exists("*GetAwkIndent")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

function GetAwkIndent()
  let lnum = prevnonblank(v:lnum - 1)
  if lnum == 0
    return 0
  endif

  let cline = getline(v:lnum)
  if cline =~ '^#'
    return 0
  endif

  let line = getline(lnum)
  let [line, lnum, ind] = s:ContinueLineIndent(line, lnum)
  if line =~ '\\$\|\%(&&\|||\|,\)\s*$'
    unlet! s:prev_lnum s:ncp_cnum
    return ind
  endif

  let nnum = lnum
  let [line, lnum] = s:JoinContinueLine(line, lnum, 0)
  let [pline, pnum] = s:JoinContinueLine(line, lnum, 1)
  let ind = s:MorePrevLineIndent(pline, pnum, line, lnum)
  let ind = s:PrevLineIndent(line, lnum, nnum, ind)
  let ind = s:CurrentLineIndent(cline, line, lnum, pline, pnum, ind)
  unlet! s:prev_lnum s:next_lnum s:ncp_cnum

  return ind
endfunction

function s:ContinueLineIndent(line, lnum)
  let [pline, line, lnum, ind] = s:PreContinueLine(a:line, a:lnum)
  if line =~# '^\s*\%(if\|}\=\s*else\s\+if\|for\|}\=\s*while\)\>'
        \ && line =~ '\\$\|\%(&&\|||\)\s*$'
    let ind = ind + &sw * 2
  elseif line =~# '^\s*printf\=\>\s*\%([^,[:blank:]][^,]\{-},\s*\)\+$'
        \ || line =~# '^\s*printf\=\>\%(\s*(\)\@!' && line =~ '\\$'
    let ind = s:GetMatchWidth(line, lnum, '\C\%(\s*printf\=\>\)\@<=.')
  elseif line =~ '(\s*\%([^,[:blank:]][^,]\{-},\s*\)\+$'
        \ && pline !~ '\\$\|\%(&&\|||\|,\)\s*$'
        \ && s:NoClosedPair(lnum, '(', ')', lnum)
    let ind = s:GetMatchWidth(line, lnum, s:ncp_cnum)
  elseif line =~ '\[\s*\%([^,[:blank:]][^,]\{-},\s*\)\+$'
        \ && pline !~ '\\$\|\%(&&\|||\|,\)\s*$'
        \ && s:NoClosedPair(lnum, '\M[', '\M]', lnum)
    let ind = s:GetMatchWidth(line, lnum, s:ncp_cnum)
  elseif line =~# '^\%(function\|func\)\s\+\h\w*\s*(\s\{2,}\\$'
        \ && s:NoClosedPair(lnum, '(', ')', lnum)
    let ind = &sw * 2 > s:ncp_cnum ? s:ncp_cnum : &sw * 2
  elseif line =~# '\h\w*\s*(.*\\$'
        \ && pline !~ '\\$\|\%(&&\|||\|,\)\s*$'
        \ && s:NoClosedPair(lnum, '(', ')', lnum)
    let ind = s:GetMatchWidth(line, lnum, s:ncp_cnum)
  elseif line =~ '[^<>=!]==\@!'
        \ && line =~ '\\$\|\%(&&\|||\)\s*$'
        \ && pline !~ '\\$\|\%(&&\|||\)\s*$'
    let ind = s:GetMatchWidth(line, lnum, '\%([^<>=!]=\)\@<=.')
  elseif ind && line =~ '\\$' && pline !~ '\\$\|\%(&&\|||\|,\)\s*$'
    let ind = ind + &sw
  endif

  return [line, lnum, ind]
endfunction

function s:MorePrevLineIndent(pline, pnum, line, lnum)
  let [pline, pnum, ind] = s:PreMorePrevLine(a:pline, a:pnum, a:line, a:lnum)
  while pnum
        \ &&
        \ (pline =~# '^\s*\%(if\|else\s\+if\|for\|while\)\s*(.*)\s*$'
        \ && s:AfterParenPairNoStr(pnum, 0)
        \ || pline =~# '^\s*}\=\s*else\>\s*$'
        \ || pline =~# '^\s*do\>\s*$'
        \ || pline =~# '^\s*}\s*\%(else\s\+if\|while\)\s*(.*)\s*$'
        \ && s:AfterParenPairNoStr(pnum, 0))
    let ind = indent(pnum)
    if pline =~# '^\s*do\>\s*$'
          \ && s:NoClosedPair(pnum, '\C\<do\>', '\C\<while\>', a:lnum)
      break
    elseif pline =~# '^\s*}\=\s*else\>'
      let [pline, pnum] = s:GetIfLine(pline, pnum)
    elseif pline =~# '^\s*}\=\s*while\>'
      let [pline, pnum] = s:GetDoLine(pline, pnum)
    endif
    let [pline, pnum] = s:JoinContinueLine(pline, pnum, 1)
  endwhile

  return ind
endfunction

function s:PrevLineIndent(line, lnum, nnum, ind)
  let ind = a:ind
  if a:line =~# '^\s*\%(else\|do\)\s*{\=\s*$'
        \ || a:line =~# '^\s*}\s*else\s*{\=\s*$'
        \ || a:line =~ '^\s*{\s*$'
    let ind = indent(a:lnum) + &sw
  elseif a:line =~# '^\s*do\>\s*\S'
        \ && s:GetHideStringLine(a:line) !~# '\%(;\|}\)\s*while\>\s*(.*)'
    let ind = indent(a:lnum)
  elseif (a:line =~# '^\s*\%(if\|else\s\+if\|for\)\s*(.*)\s*{\=\s*$'
        \ || a:line =~# '^\s*}\s*else\s\+if\s*(.*)\s*{\=\s*$'
        \ || a:line =~# '^\s*while\s*(.*)\s*{\s*$'
        \ || a:line =~# '^\s*while\s*(.*)\s*$'
        \ && get(s:GetDoLine(a:line, a:lnum), 1) == a:lnum)
        \ && s:AfterParenPairNoStr(a:lnum, 1)
    let ind = indent(a:lnum) + &sw
  elseif a:line =~ '{' && s:NoClosedPair(a:lnum, '{', '}', a:nnum)
    let ind = indent(a:lnum) + &sw
  elseif a:line =~# '^\s*\(case\|default\)\>'
    let ind = ind + &sw
  endif

  return ind
endfunction

function s:CurrentLineIndent(cline, line, lnum, pline, pnum, ind)
  let ind = a:ind
  if a:cline =~ '^\s*}'
    let ind = ind - &sw
  elseif a:cline =~ '^\s*{\s*\%(#.*\)\=$'
        \ &&
        \ (a:line =~# '^\s*\%(if\|else\s\+if\|while\|for\)\s*(.*)'
        \ && s:AfterParenPairNoStr(a:lnum, 0)
        \ || a:line =~# '^\s*\%(else\|do\)\s*$')
    let ind = ind - &sw
  elseif a:cline =~# '^\s*else\>'
    let ind = s:CurrentElseIndent(a:line, a:lnum, a:pline, a:pnum)
  elseif a:cline =~# '^\s*\(case\|default\)\>'
    let ind = ind - &sw
  endif

  return ind
endfunction

function s:PreContinueLine(line, lnum)
  let [line, lnum] = s:SkipCommentLine(a:line, a:lnum)
  let pnum = prevnonblank(lnum - 1)
  let pline = getline(pnum)
  let [pline, pnum] = s:SkipCommentLine(pline, pnum)
  let ind = indent(lnum)
  if line =~ '\\$\|\%(&&\|||\|,\)\s*\%(#.*\)\=$'
    let pline = s:GetHideStringLine(pline)
    let line = s:GetHideStringLine(line)
  endif

  return [pline, line, lnum, ind]
endfunction

function s:JoinContinueLine(line, lnum, prev)
  if a:prev && s:GetPrevNonBlank(a:lnum)
    let lnum = s:prev_lnum
    let line = getline(lnum)
  elseif a:prev
    let lnum = 0
    let line = ""
  else
    let line = a:line
    let lnum = a:lnum
  endif
  let [line, lnum] = s:SkipCommentLine(line, lnum)
  if line =~ '#'
    let line = s:GetHideStringLine(line)
  endif
  let pnum = lnum
  while pnum && s:GetPrevNonBlank(pnum)
    let pline = getline(s:prev_lnum)
    if pline =~ '^\s*#'
      let pnum = s:prev_lnum
      continue
    elseif pline =~ '#'
      let pline = s:GetHideStringLine(pline)
    endif
    if pline !~ '\\$\|\%(&&\|||\|,\)\s*$'
      break
    endif
    let pnum = s:prev_lnum
    let lnum = s:prev_lnum
    let line = pline. line
  endwhile

  return [line, lnum]
endfunction

function s:SkipCommentLine(line, lnum)
  let line = a:line
  let lnum = a:lnum
  while lnum && line =~ '^\s*#' && s:GetPrevNonBlank(lnum)
    let lnum = s:prev_lnum
    let line = getline(lnum)
  endwhile

  return [line, lnum]
endfunction

function s:JoinNextContinueLine(line, lnum)
  let line = a:line
  let lnum = a:lnum
  if line =~ '#'
    let line = s:GetHideStringLine(line)
  endif
  let nnum = lnum
  while nnum && line =~ '\\$\|\%(&&\|||\|,\)\s*$' && s:GetNextNonBlank(nnum)
    let nnum = s:next_lnum
    let nline = getline(nnum)
    if nline =~ '^\s*#'
      continue
    elseif nline =~ '#'
      let nline = s:GetHideStringLine(nline)
    endif
    let line = line. nline
  endwhile

  return [line, lnum]
endfunction

function s:GetPrevNonBlank(lnum)
  let s:prev_lnum = prevnonblank(a:lnum - 1)

  return s:prev_lnum
endfunction

function s:GetNextNonBlank(lnum)
  let s:next_lnum = nextnonblank(a:lnum + 1)

  return s:next_lnum
endfunction

function s:PreMorePrevLine(pline, pnum, line, lnum)
  let pline = a:pline
  let pnum = a:pnum
  let line = a:line
  let lnum = a:lnum
  if a:line =~# '^\s*}\=\s*while\>'
    let [line, lnum] = s:GetDoLine(line, lnum)
  elseif a:line =~# '^\s*}\=\s*else\>'
    let [line, lnum] = s:GetIfLine(line, lnum)
  elseif a:line =~ '^\s*}'
    let [line, lnum] = s:GetStartBraceLine(line, lnum)
  endif
  if lnum != a:lnum
    let [pline, pnum] = s:JoinContinueLine(line, lnum, 1)
  endif
  let ind = indent(lnum)

  return [pline, pnum, ind]
endfunction

function s:GetStartBraceLine(line, lnum)
  let line = a:line
  let lnum = a:lnum
  let [line, lnum] = s:GetStartPairLine(line, '}', '{', lnum)
  if line =~# '^\s*}\=\s*else\>'
    let [line, lnum] = s:GetIfLine(line, lnum)
  endif

  return [line, lnum]
endfunction

function s:GetStartPairLine(line, item1, item2, lnum)
  let save_cursor = getpos(".")
  call cursor(a:lnum, strlen(getline(a:lnum)))
  let lnum = search(a:item1, 'cbW', a:lnum)
  while lnum && s:InsideAwkItemOrCommentStr()
    let lnum = search(a:item1, 'bW', a:lnum)
  endwhile
  if lnum
    let lnum = searchpair(
          \ a:item2, '', a:item1, 'bW', 's:InsideAwkItemOrCommentStr()')
  endif
  if lnum > 0
    let line = getline(lnum)
    let [line, lnum] = s:JoinContinueLine(line, lnum, 0)
  else
    let line = a:line
    let lnum = a:lnum
  endif
  call setpos(".", save_cursor)

  return [line, lnum]
endfunction

function s:GetIfLine(line, lnum)
  let save_cursor = getpos(".")
  let cline = getline(v:lnum)
  call cursor(a:lnum, 1)
  let lnum = searchpair('\C\<if\>', '', '\C\<else\>', 'bW',
        \ 'getline(".") =~# "^\\s*}\\=\\s*else\\s\\+if\\>"'
        \. '|| cline =~# "^\\s*else\\>"'
        \. '&& a:line =~# "^\\s*}\\=\\s*else\\>\\%(\\s\\+if\\>\\)\\@!"'
        \. '&& a:line !~# "^\\s*}\\=\\s*else\\>\\s*{\\s*\\%(#.*\\)\\=$"'
        \. '&& a:line =~# "^\\s*}\\=\\s*else\\>\\s*[^#[:blank:]]"'
        \. '&& indent(line(".")) >= indent(a:lnum)'
        \. '|| indent(line(".")) > indent(a:lnum)'
        \. '|| s:InsideAwkItemOrCommentStr()')
  call setpos(".", save_cursor)
  if lnum > 0
    let line = getline(lnum)
    let [line, lnum] = s:JoinNextContinueLine(line, lnum)
  else
    let line = a:line
    let lnum = a:lnum
  endif

  return [line, lnum]
endfunction

function s:GetDoLine(line, lnum)
  let save_cursor = getpos(".")
  call cursor(a:lnum, 1)
  let lnum = s:SearchDoLoop(a:lnum)
  call setpos(".", save_cursor)
  if lnum
    let line = getline(lnum)
  else
    let line = a:line
    let lnum = a:lnum
  endif

  return [line, lnum]
endfunction

function s:SearchDoLoop(snum)
  let lnum = 0
  let onum = 0
  while search('\C^\s*do\>', 'ebW')
    let save_cursor = getpos(".")
    let lnum = searchpair('\C\<do\>', '', '\C\<while\>', 'W',
          \ 'indent(line(".")) > indent(get(save_cursor, 1))'
          \. '|| s:InsideAwkItemOrCommentStr()', a:snum)
    if lnum < onum || lnum < 1
      let lnum = 0
      break
    elseif lnum == a:snum
      let lnum = get(save_cursor, 1)
      break
    else
      let onum = lnum
      let lnum = 0
    endif
    call setpos(".", save_cursor)
  endwhile

  return lnum
endfunction

function s:NoClosedPair(lnum, item1, item2, nnum)
  let snum = 0
  let enum = 0
  let s:ncp_cnum = 0
  let save_cursor = getpos(".")
  call cursor(a:nnum, strlen(getline(a:nnum)))
  let snum = search(a:item1, 'cbW', a:lnum)
  while snum
    if s:InsideAwkItemOrCommentStr()
      let snum = search(a:item1, 'bW', a:lnum)
      continue
    endif
    let s:ncp_cnum = col(".")
    let enum = searchpair(
          \ a:item1, '', a:item2, 'W', 's:InsideAwkItemOrCommentStr()')
    if snum == enum
      call cursor(snum, s:ncp_cnum)
      let s:ncp_cnum = 0
      let snum = search(a:item1, 'bW', a:lnum)
      continue
    endif
    break
  endwhile
  call setpos(".", save_cursor)

  return s:ncp_cnum
endfunction

function s:GetMatchWidth(line, lnum, item)
  let line = getline(a:lnum)
  if type(a:item) == type("")
    let msum = match(line, a:item)
    if a:line =~ '\\$' && strpart(line, msum) =~ '^\s*\\$'
      let ind = indent(a:lnum) + &sw
    else
      let tsum = matchend(line, '\t*', 0)
      let ind = strwidth(strpart(line, 0, msum)) - tsum + tsum * &tabstop + 1
    endif
  elseif type(a:item) == type(0)
    let msum = match(strpart(line, a:item), '\S')
    if a:line =~ '\\$' && msum > 1 && strpart(line, a:item) =~ '^\s*\\$'
      let ind = indent(a:lnum) + &sw
    else
      let tsum = matchend(line, '\t*', 0)
      let msum = strwidth(strpart(line, 0, a:item + msum))
      let ind = msum - tsum + tsum * &tabstop
    endif
  else
    let ind = indent(a:lnum)
  endif

  return ind
endfunction

function s:CurrentElseIndent(line, lnum, pline, pnum)
  if a:line =~# '^\s*\%(if\|}\=\s*else\s\+if\)\s*(.*)\s*\S'
        \ && a:line !~ '{\s*$'
        \ && s:GetHideStringLine(a:line) !~# '\%(;\|}\)\s*else\>\%(\s\+if\)\@!'
    let ind = indent(a:lnum)
  elseif a:pline =~# '^\s*\%(if\|}\=\s*else\s\+if\)\s*(.*)'
        \ && s:AfterParenPairNoStr(a:pnum, 0)
    let ind = indent(a:pnum)
  else
    let ind = indent(get(s:GetIfLine(a:line, a:lnum), 1))
  endif

  return ind
endfunction

function s:GetHideStringLine(line)
  return s:InsideAwkItemOrCommentStr(a:line)
endfunction

function s:InsideAwkItemOrCommentStr(...)
  let line = a:0 ? a:1 : getline(".")
  let cnum = a:0 ? strlen(line) : col(".")
  let sum = match(line, '\S')
  let slash = 0
  let dquote = 0
  let bracket = 0
  let laststr = ""
  let nb_laststr = ""
  let rt_line = ""
  let slist = split(line, '\zs')
  while sum < cnum
    let str = slist[sum]
    if str == '#' && !slash && !dquote
      return a:0 ? rt_line : 1
    elseif str == '\' && (slash || dquote) && slist[sum + 1] == '\'
      let str = laststr
      let sum += 1
    elseif str == '[' && slash && !bracket && laststr != '\'
      let bracket = 1
      if slist[sum + 1] == '^' && slist[sum + 2] == ']'
        let str = ']'
        let sum += 2
      elseif slist[sum + 1] == ']'
        let str = ']'
        let sum += 1
      endif
    elseif str == '[' && slash && bracket && laststr != '\'
          \ && (slist[sum + 1] == ':'
          \ || slist[sum + 1] == '.'
          \ || slist[sum + 1] == '=')
          \ && slist[matchend(line, '['. slist[sum + 1]. ']', sum + 2)] == ']'
      let str = ']'
      let sum = matchend(line, '['. slist[sum + 1]. ']', sum + 2)
    elseif str == ']' && slash && bracket && laststr != '\'
      let bracket = 0
    elseif str == '/' && !slash && !dquote
          \ && (!strlen(nb_laststr)
          \ || nb_laststr =~ '}\|(\|\%o176\|,\|=\|&\||\|!\|+\|-\|*\|?\|:\|;'
          \ || strpart(line, 0, sum)
          \   =~# '\%(\%(^\|:\)\s*case\|\<printf\=\|\<return\)\>\s*$')
      let slash = 1
      let rt_line = rt_line. str
    elseif str == '/' && slash && laststr != '\' && !bracket
      let slash = 0
    elseif str == '"' && !dquote && !slash
      let dquote = 1
      let rt_line = rt_line. str
    elseif str == '"' && dquote && laststr != '\'
      let dquote = 0
    endif
    if str !~ '\s'
      let nb_laststr = str
    endif
    let laststr = str
    let sum += 1
    if !slash && !dquote
      let rt_line = rt_line. str
    endif
  endwhile

  return a:0 ? rt_line : slash || dquote
endfunction

function s:AfterParenPairNoStr(lnum, brace)
  let snum = 0
  let enum = 0
  let cnum = 0
  let estr = ""
  let save_cursor = getpos(".")
  call cursor(a:lnum, 1)
  let snum = search('(', 'cW', a:lnum)
  while snum && s:InsideAwkItemOrCommentStr()
    let snum = search('(', 'W', a:lnum)
  endwhile
  if snum
    let enum = searchpair('(', '', ')', 'W', 's:InsideAwkItemOrCommentStr()')
  endif
  if enum > 0
    let cnum = col(".")
    let estr = strpart(getline(enum), cnum)
  endif
  call setpos(".", save_cursor)

  if cnum && a:brace && estr =~ '^\s*{\=\s*\%(#.*\)\=$'
    return 1
  elseif cnum && estr =~ '^\s*\%(#.*\)\=$'
    return 1
  else
    return 0
  endif
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: set sts=2 sw=2 expandtab:
