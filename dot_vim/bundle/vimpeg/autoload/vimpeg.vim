" Vim library file
" Description:	Vimpeg - A PEG parser for Vim.
" Maintainers:	Barry Arthur & Israel Chauca
" Version:	0.2
" Last Change:	2011 10 24
" License:	Vim License (see :help license)
" Location:	autoload/vimpeg.vim
" Status:	functional, if not beautiful

"TODO:
" * Currently returns an 'elements' list of all matches - this might be useful
"   in debugging, but not particularly useful afterwards.
" * The predicates 'collect' successful matches (even though the input scanner
"   is repositioned to before the predicated element. I'm not sure if
"   collecting the match is beneficial or even desired. It doesn't hurt
"   scanning, but the semantic 'on_match' functions will need to know that
"   there is an extra element in the 'value' list.
" * There are a bunch of TODO statements littering the code - they need doing
"   too. :)

" HISTORY:
" 0.2 - PEG DSL Release
"   Uses a PEG DSL for describing parsers instead of the manual programmatic
"   API approach.
"   Cleaned up to be usr_41 compliant.
"
" 0.1 - Initial Release
"   Functional PEG parser generator using programmatic API.
"   Bundled with various examples.

if exists('g:loaded_vimpeg_lib')
"      \ || v:version < 700 || &compatible
  "finish
endif
let g:loaded_vimpeg_lib = 1

" Allow use of line continuation.
let s:vimpeg_save_cpo = &cpo
set cpo&vim
" Start VimPEG

" memoization
let s:sym = 0
function! s:NextSym()
  let s:sym += 1
  return s:sym
endfunction

function s:SID()
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfun

function s:callback(func, args) dict abort
  if (type(a:func) == type('')) && (a:func =~# '\m\.')
    if a:func !~# '\m\a:'
      let func = 'g:' . a:func
    endif
    let dict_name = matchstr(func, '\m\C^.*\ze\..\+')
    let dict = eval(dict_name)
    return call(func, [a:args], dict)
  else
    return call(a:func, [a:args])
  endif
endfunction

function s:GetSym(id) dict abort
  let id = a:id
  if type(id) == type('')
    if !has_key(self.Symbols, id)
      echoerr 'Error: GetSym() : Symbol "' . id . '" is undefined.'
    else
      return self.Symbols[id]
    endif
  elseif type(id) == type({})
    return id
  else
    echoerr 'Error: GetSym() : Unknown id type: ' . type(id)
  endif
endfunction

function s:AddSym(symbol) dict abort
  let symbol = a:symbol
  " TODO: For now, don't allow symbol redefinition. May reverse this later.
  if !has_key(self.Symbols, symbol['id'])
    let self.Symbols[symbol['id']] = symbol
    return symbol
  else
    echoerr 'Error: AddSym() : Symbol "' . symbol['id'] . '" already defined.'
  endif
endfunction

" memoization
function s:MkSym(pos, sym) dict
  return a:pos . '_' . a:sym
endfunction

function s:CacheClear() dict
  let self.Cache = {}
endfunction

function s:CacheGet(pos, sym) dict
  return get(self.Cache, self.MkSym(a:pos, a:sym), '')
endfunction

function s:CacheSet(pos, sym, obj) dict
  let self.Cache[self.MkSym(a:pos, a:sym)] = a:obj
endfunction

function s:Expression_CacheClear() dict
  return self.parent.CacheClear()
endfunction

function s:Expression_CacheGet(pos, sym) dict
  return self.parent.CacheGet(a:pos, a:sym)
endfunction

function s:Expression_CacheSet(pos, sym, obj) dict
  return self.parent.CacheSet(a:pos, a:sym, a:obj)
endfunction

function s:Expression_AddSym(symbol) dict abort "{{{2
  return self.parent.AddSym(a:symbol)
endfunction

function s:Expression_GetSym(id) dict abort "{{{2
  return self.parent.GetSym(a:id)
endfunction

function s:Expression_SetOptions(options) dict abort "{{{2
  for o in ['id', 'debug', 'debug_ids', 'verbose', 'on_match']
    if has_key(a:options, o)
      let self[o] = a:options[o]
    endif
  endfor
endfunction

function s:Expression_Copy(...) dict abort "{{{2
  let e = copy(self)
  if a:0
    call e.SetOptions(a:000[0])
  endif
  return e
endfunction

" (input, [{id,debug,verbose}])
function s:Expression_new(pat, ...) dict abort "{{{3
  let e = self.Copy(a:0 ? a:000[0] : {})
  let e.pat = a:pat
  let e.sym = s:NextSym()
  if !empty(e.id)
    call self.AddSym(e)
  endif
  return e
endfunction

function s:Expression_matcher(input) dict abort "{{{3
  let errmsg = ''
  let is_matched = 1
  let ends = [0,0]
  "echo 'peg.Expression: ' . string(a:input) . ' ' . string(self.pat)
  let ends[0] = match(a:input.str, '\m'.self.pat, a:input.pos)
  let ends[1] = matchend(a:input.str, '\m'.self.pat, a:input.pos)
  if ends[0] != a:input.pos
    let errmsg = 'Failed to match "'.self.id.'" /'. self.pat . '/ at byte ' . a:input.pos . ' on "' . a:input.str[a:input.pos : a:input.pos + 30] . '"'
    if self.verbose >= 2
      "echom 'peg.Expression: ' . string(a:input) . ' ' . string(self.pat)
      echohl WarningMsg
      echom errmsg
      echohl None
    endif
    let ends = [a:input.pos,a:input.pos]
    let is_matched = 0
  end
  if is_matched
    if self.verbose
      "echom 'peg.Expression: ' . string(a:input) . ' ' . string(self.pat)
      echom 'Matched "'.self.id.'" /'. self.pat . '/ at byte ' . a:input.pos . ' on "' . a:input.str[a:input.pos : a:input.pos + 30] . '"'
    endif
    let self.value = strpart(a:input.str, ends[0], ends[1] - ends[0])
    if has_key(self, 'on_match')
      let self.value = self.parent.callback(self.on_match, self.value)
    endif
  endif
  return {'id' : self.id, 'pattern' : self.pat, 'ends' : ends, 'pos': ends[1], 'value' : self.value, 'is_matched': is_matched, 'errmsg': errmsg}
endfunction

function s:Expression_skip_white(input) dict abort "{{{3
  if self.parent.optSkipWhite == 1
    if match(a:input.str, '\m\s\+', a:input.pos) == a:input.pos
      let a:input.pos = matchend(a:input.str, '\m\C\s\+', a:input.pos)
    endif
  endif
endfunction

function s:Expression_match(input) dict "{{{3
  let self.value = []
  let save_ic = &ignorecase
  call self.CacheClear()  " memoization
  let &ignorecase = self.parent.optIgnoreCase ? 1 : 0
  try
    let result = self.pmatch({'str': a:input, 'pos': 0})
  catch /VimPEG: (1)/
    let result = {'errmsg': matchstr(v:exception, '^VimPEG: \zs.*'), 'id': '',
          \ 'elements': [], 'pos': -1, 'is_matched': 0, 'value': []}
  endtry
  let &ignorecase = save_ic
  return result
endfunction

function s:Expression_pmatch(input) dict abort "{{{3
  if self.debug && index(self.debug_ids, get(self, 'id', '')) > -1
    echom 'Adding breakpoint for "'.self.id.'"'
    exec printf('breakadd func 6 %sExpression_pmatch', s:SID())
    " Remove the breakpoint until it's needed again.
    exec printf('breakdel func 6 %sExpression_pmatch', s:SID())
  endif
  let save = a:input.pos
  call self.skip_white(a:input)

  " memoization
  let pos = a:input.pos
  let c = self.CacheGet(pos, self.sym)
  if self.parent.optMemoization && type(c) == type({})
    let m = c
  else
    let m = self.matcher(a:input)
    call self.CacheSet(pos, self.sym, m)
  endif

  if !m['is_matched']
    let a:input.pos = save
  else
    let a:input.pos = m['pos']
  endif
  return m
endfunction

function s:ExpressionSequence_new(seq, ...) dict abort "{{{3
  let e = self.Copy(a:0 ? a:000[0] : {})
  let e.seq = a:seq
  let e.sym = s:NextSym()
  if !empty(e.id)
    call self.AddSym(e)
  endif
  return e
endfunction

" TODO: make it backtrack!
function s:ExpressionSequence_matcher(input) dict abort "{{{3
  let elements = []
  let is_matched = 1
  let errmsg = ''
  " TODO: should this be -1 or 0?
  let pos = -1
  for s in self.seq
    let e = copy(self.GetSym(s))
    let e.elements = []
    let m = e.pmatch(a:input)
    " BEA: Expermineting with adding even possible fails for errmsg...
    call add(elements, m)
    if !m['is_matched']
      let is_matched = 0
      break
    endif
    " TODO: do I need to delete these elements if not matched?
    "call add(elements, m)
    unlet s
    unlet m
  endfor
  if is_matched
    if self.verbose >= 3
      echom 'Matched "'.self.id.'" at byte ' . a:input.pos . ' on ' . string(a:input.str[a:input.pos : a:input.pos + 30])
    endif
    let pos = elements[-1]['pos']
    let self.value = map(copy(elements), 'v:val["value"]')
    if has_key(self, 'on_match')
      let self.value = self.parent.callback(self.on_match, self.value)
    endif
  else
    let errmsg = 'Failed to match Sequence at byte ' . a:input.pos
    if self.verbose >= 4
      echohl WarningMsg
      echom printf('%s: %s', self.id, errmsg)
      echohl None
    endif
  endif
  return {'id': self.id, 'elements': elements, 'pos': pos, 'value': self.value, 'is_matched': is_matched, 'errmsg': errmsg}
endfunction

function s:ExpressionOrderedChoice_new(choices, ...) dict abort "{{{3
  let e = self.Copy(a:0 ? a:000[0] : {})
  let e.choices = a:choices
  let e.sym = s:NextSym()
  if !empty(e.id)
    call self.AddSym(e)
  endif
  return e
endfunction

function s:ExpressionOrderedChoice_matcher(input) dict abort "{{{3
  let element = {}
  let is_matched = 0
  let errmsg = ''
  " TODO: -1 or 0?
  let pos = -1
  for c in self.choices
    let e = copy(self.GetSym(c))
    let e.elements = []
    let m = e.pmatch(a:input)
    if m['is_matched']
      let element = m
      let is_matched = 1
      break
    endif
    unlet c
    unlet m
  endfor
  if is_matched
    let pos = element['pos']
    let self.value = element['value']
    if has_key(self, 'on_match')
      let self.value = self.parent.callback(self.on_match, self.value)
    endif
  else
    let errmsg = 'Failed to match Ordered Choice at byte ' . a:input.pos
  endif
  return {'id': self.id, 'elements': [element], 'pos': pos, 'value': self.value, 'is_matched': is_matched, 'errmsg': errmsg}
endfunction

function s:ExpressionMany_new(exp, min, max, ...) dict abort "{{{3
  let e = self.Copy(a:0 ? a:000[0] : {})
  let e.exp = copy(a:exp)
  let e.min = a:min
  let e.max = a:max
  let e.sym = s:NextSym()
  if !empty(e.id)
    call self.AddSym(e)
  endif
  return e
endfunction

function s:ExpressionMany_matcher(input) dict abort "{{{3
  let is_matched = 1
  let pos = a:input['pos']
  let cnt = 0
  let elements = []
  let e = copy(self.GetSym(self.exp))
  let e.elements = []
  let m = e.pmatch(a:input)
  while m['is_matched']
    call add(elements, m)
    "let a:input.pos = m[1]
    let cnt += 1
    if (self.max != 0) && (cnt >= self.max)
      break
    endif
    " unlet m   ?
    let m = e.pmatch(a:input)
  endwhile
  if cnt < self.min
    " TODO: this should be an error
    if self.verbose
      echohl ErrorMsg
      echom printf('%s: Failed to match enough repeated items. Needed %s but only found %s', self.id, self.min, cnt)
      echohl None
    endif
    let is_matched = 0
  endif
  if is_matched
    if cnt != 0
      let pos = elements[-1]['pos']
      let self.value = map(copy(elements), 'v:val["value"]')
      if has_key(self, 'on_match')
        let self.value = self.parent.callback(self.on_match, self.value)
      endif
    endif
  endif
  return {'id': self.id, 'elements': elements, 'pos': pos, 'count': cnt, 'min': self.min, 'max': self.max, 'value': self.value, 'is_matched': is_matched}
endfunction

function s:ExpressionPredicate_new(exp, type, ...) dict abort "{{{3
  let e = self.Copy(a:0 ? a:000[0] : {})
  let e.exp = a:exp
  let e.type = a:type
  let e.sym = s:NextSym()
  if !empty(e.id)
    call self.AddSym(e)
  endif
  return e
endfunction

function s:ExpressionPredicate_matcher(input) dict abort "{{{3
  let is_matched = 0
  let pos = a:input.pos
  let e = copy(self.GetSym(self.exp))
  let e.elements = []
  let element = e.pmatch(a:input)
  let a:input.pos = pos
  if self.type ==# 'has'         " AND predicate
    let is_matched = element['is_matched']
  elseif self.type ==# 'not_has' " NOT predicate
    let is_matched = !element['is_matched']
  endif
  if is_matched
    " TODO: Unsure if it is wise to have this in a predicate... may make for
    " interesting parsers...
    let self.value = element['value']
    if has_key(self, 'on_match')
      let self.value = self.parent.callback(self.on_match, self.value)
    endif
  endif
  return {'id': self.id, 'elements': [element], 'pos': pos, 'type': self.type, 'value': self.value, 'is_matched': is_matched}
endfunction

function s:e(exp, ...) dict abort "{{{2
  return self.Expression.new(a:exp, a:0 ? a:000[0] : {})
endfunction

function s:and(seq, ...) dict abort
  return self.ExpressionSequence.new(a:seq, a:0 ? a:000[0] : {})
endfunction

function s:or(choices, ...) dict abort
  return self.ExpressionOrderedChoice.new(a:choices, a:0 ? a:000[0] : {})
endfunction

function s:maybe_many(exp, ...) dict abort
  return self.ExpressionMany.new(a:exp, 0, 0, a:0 ? a:000[0] : {})
endfunction

function s:many(exp, ...) dict abort
  return self.ExpressionMany.new(a:exp, 1, 0, a:0 ? a:000[0] : {})
endfunction

function s:maybe_one(exp, ...) dict abort
  return self.ExpressionMany.new(a:exp, 0, 1, a:0 ? a:000[0] : {})
endfunction

function s:between(exp, min, max, ...) dict abort
  return self.ExpressionMany.new(a:exp, a:min, a:max, a:0 ? a:000[0] : {})
endfunction

function s:has(exp, ...) dict abort
  return self.ExpressionPredicate.new(a:exp, 'has', a:0 ? a:000[0] : {})
endfunction

function s:not_has(exp, ...) dict abort
  return self.ExpressionPredicate.new(a:exp, 'not_has', a:0 ? a:000[0] : {})
endfunction

function! vimpeg#parser(options) abort
  let peg = {}
  let peg.optSkipWhite = get(a:options, 'skip_white', 0)
  let peg.optIgnoreCase = get(a:options, 'ignore_case', 0)
  let peg.optMemoization = get(a:options, 'memoization', 1)
  let peg.Symbols = {}
  let peg.Cache = {}                " memoization
  let peg.Expression = {}
  let peg.Expression.parent = peg
  let peg.Expression.value = []
  let peg.Expression.id = ''
  let peg.Expression.sym = 0  " memoization
  let peg.Expression.debug = get(a:options, 'debug', 0)
  let peg.Expression.debug_ids = split(get(a:options, 'debug_ids', ''), '\m\C\s*,\s*')
  let peg.Expression.verbose = get(a:options, 'verbose', 0)

  let peg.callback = function('s:callback')

  let peg.GetSym = function('s:GetSym')

  let peg.AddSym = function('s:AddSym')

  " memoization
  let peg.MkSym = function('s:MkSym')

  let peg.CacheClear = function('s:CacheClear')
  let peg.CacheGet = function('s:CacheGet')
  let peg.CacheSet = function('s:CacheSet')

  let peg.Expression.CacheClear = function('s:Expression_CacheClear')
  let peg.Expression.CacheGet = function('s:Expression_CacheGet')
  let peg.Expression.CacheSet = function('s:Expression_CacheSet')
  let peg.Expression.AddSym = function('s:Expression_AddSym')
  let peg.Expression.GetSym = function('s:Expression_GetSym')
  let peg.Expression.SetOptions = function('s:Expression_SetOptions')
  let peg.Expression.Copy = function('s:Expression_Copy')
  let peg.Expression.new = function('s:Expression_new')
  let peg.Expression.matcher = function('s:Expression_matcher')
  let peg.Expression.skip_white = function('s:Expression_skip_white')
  let peg.Expression.match = function('s:Expression_match')
  let peg.Expression.pmatch = function('s:Expression_pmatch')

  let peg.ExpressionSequence = copy(peg.Expression) "{{{2
  let peg.ExpressionSequence.new = function('s:ExpressionSequence_new')
  let peg.ExpressionSequence.matcher = function('s:ExpressionSequence_matcher')

  let peg.ExpressionOrderedChoice = copy(peg.Expression) "{{{2
  let peg.ExpressionOrderedChoice.new = function('s:ExpressionOrderedChoice_new')
  let peg.ExpressionOrderedChoice.matcher = function('s:ExpressionOrderedChoice_matcher')

  let peg.ExpressionMany = copy(peg.Expression) "{{{2
  let peg.ExpressionMany.new = function('s:ExpressionMany_new')
  let peg.ExpressionMany.matcher = function('s:ExpressionMany_matcher')

  let peg.ExpressionPredicate = copy(peg.Expression) "{{{2
  let peg.ExpressionPredicate.new = function('s:ExpressionPredicate_new')
  let peg.ExpressionPredicate.matcher = function('s:ExpressionPredicate_matcher')

  let peg.e = function('s:e')
  let peg.and = function('s:and')
  let peg.or = function('s:or')
  let peg.maybe_many = function('s:maybe_many')
  let peg.many = function('s:many')
  let peg.maybe_one = function('s:maybe_one')
  let peg.between = function('s:between')
  let peg.has = function('s:has')
  let peg.not_has = function('s:not_has')

  return peg
endfunction
" End VimPEG

function! vimpeg#format()
  "echom printf('v:lnum: %s', v:lnum)
  "echom printf('v:count: %s', v:count)
  "echom printf('v:char: %s', v:char)
  let first = v:lnum
  let last = v:lnum + v:count - 1
  if get(g:, 'vimpeg_format_align_mallet', 1)
    let lines = getline(1, '$')
    let mallets = filter(copy(lines), 'v:val =~# ''\m^\w\+\s*::=''')
    call map(mallets, 'substitute(v:val, ''\m\C \+'', " ", "g")')
    call map(mallets, 'strchars(matchstr(v:val, ''\m\C^[^=]\+\S\ze\s*\::=''))')
    "echom printf('mallets substrings: %s', mallets)
    let mallet_length = max(mallets)
    "echom printf('max: %s', mallet_length)
    let fmtstr = printf('%%-%ss::= ', mallet_length + 1)
    call setpos("'[", [0, first, 1, 0])
    call setpos("']", [0, last, 1, 0])
    "'[;']g/^/echom printf('%3s: %s', line('.'), getline('.'))
    silent! '[;']s/\m\C^\(\w\+\)\s*::=\s*/\=printf(fmtstr, submatch(1))/
  else
    silent! '[;']s/\m\C^\(\w\+\)\s*::=\s*/\1 ::= /
  endif
  call setpos("'[", [0, first, 1, 0])
  call setpos("']", [0, last, 1, 0])
  silent! normal! '[=']
  call setpos("'[", [0, first, 1, 0])
  call setpos("']", [0, last, 1, 0])
  silent! '[;']g/\m\C^\w.*\\$/call s:align_bs()
endfunction

function! s:align_bs()
  "echom 'align_backslash'
  let first = line('.')
  let last = first
  let line = getline(last)
  let limit = line('$')
  "echom printf('%3s: %s', last, line)
  while last < limit
        \ && line !~# '\m^\s*;'
        \ && line =~# '\m\\$'
    let last += 1
    let line = getline(last)
    "echom printf('%3s: %s', last, line)
  endwhile
  let lines = getline(first, last)
  call map(lines, 'strchars(matchstr(v:val, ''\m\C^.*\S\ze\s*\\$''))')
  "echom printf('lines mapped: %s', lines)
  let line_length = max(lines) + 1
  let fmtstr = printf('%%-%ss\', line_length)
  "echom printf('fmtstr: %s', string(fmtstr))
  "echom printf('  0: '.fmtstr, 'X')
  call setpos("'[", [0, first, 1, 0])
  call setpos("']", [0, last, 1, 0])
  '[;']s/\m\C^\(.\{}\S\)\s*\\$/\=printf(fmtstr, submatch(1))/
  "call setpos("'[", [0, first, 1, 0])
  "call setpos("']", [0, last, 1, 0])
  '[;']g/^/echom printf('%3s: %s', line('.'), getline('.'))
endfunction

function vimpeg#get_indent()
  if v:lnum == 1
    " first line
    return 0
  endif
  let lnum = v:lnum
  let line = getline(lnum)
  let lines = []
  let equal_string = ''
  let i = -1
  while lnum > 0
        \ && line !~# '\m\C^\s*;'
        \ && (lnum == v:lnum || line =~# '\m\C\%(^\|[^\\]\)\%(\\\\\)*\\$')
    call insert(lines, line)
    if line =~# '\m\C='
      " a posible = of an assignment or option, let's save its info
      let equal_string = matchstr(line, '\m\C^[^=]\{}\%(::\ze=\|[^:]=\s*\|$\)')
      let equal_index = i
    endif
    let lnum -= 1
    let line = getline(lnum)
    let i -= 1
  endwhile
  if empty(lines) || len(lines) == 1
    " not a continued line
    return 0
  endif
  if equal_index < -2
    " the first equal sign in not on the previous line, copy the indentation
    return indent(v:lnum - 1)
  endif
  if equal_index == -2
    " the first equal sign is in the previous line, align with it
    return strdisplaywidth(equal_string)
  endif
  let indent_label = 'vimpeg_indent_continued'
  let multiplier = get(b:, indent_label, get(g:, indent_label, 3))
  return shiftwidth() * multiplier
endfunction

let &cpo = s:vimpeg_save_cpo
" unlet s:vimpeg_save_cpo

" vim: et sw=2 fdm=marker
