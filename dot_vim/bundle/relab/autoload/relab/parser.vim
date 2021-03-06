" read file into s:id_map
let s:id_map = {}
for line in readfile(printf('%s/%s', expand('<sfile>:p:h'), 'id_key.txt'))
  45DebugRELab printf('id_map -> for: line: %s', line)
  let [id, help, desc] = split(line, '\t')
  44DebugRELab printf('id_map -> for: id: %s, help: %s, desc: %s',
        \id, help, desc)
  if has_key(s:id_map, id)
    echoerr 'Duplicated key!'
  else
    let s:id_map[id] = {'help_tag': help, 'line': desc}
  endif
endfor

" parser.init([separator]) {{{
" reset the parser to its initial state
" return the parser
function! s:init(...) dict
  " reset parser
  21DebugRELab printf('%s:', expand('<sfile>'))
  21DebugRELab printf('args: %s', a:)
  let self.magicness = 'm'
  let self.ignorecase = 0
  let self.in_collection = 0
  let self.token = ''
  let self.tokens = []
  let self.nest_stack = []
  let self.input = []
  let self.length = 0
  let self.pos = 0
  let self.capt_groups = 0
  let self.errors = []
  let self.sequence = []
  let self.sep = a:0 ? a:1 : self.sep
  let self.input_remaining = ''
  let self.parent_node = relab#parser#node()
  let self.parent_node.magicness = self.magicness
  let self.parent_node.capt_groups = self.capt_groups
  let self.parent_node.value = 'root'
  let self.parent_node.magic = 'root'
  let self.parent_node.id = 'root'
  let self.parent_node.help = 'pattern'
  " Check if a:sep is valid
  if len(self.sep) > 1 || self.sep =~# '[a-zA-Z0-9]'
    "error
    echoerr printf('RELab: Wrong separator: %s', self.sep)
    return {}
  endif
  return self
endfunction "}}}

" parser.magic() {{{
" TODO should be part of node instead?
" return the \m value of the current token
function! s:magic() dict
  21DebugRELab printf('%s:', expand('<sfile>'))
  21DebugRELab printf('args: %s', a:)
  if self.magicness ==# 'm'
    " already magic or no magic version
    return self.token
  elseif self.magicness ==# 'M'
    " non-magic
    if self.token =~# '\m^\\[.*~[]$'
      return self.token[1:]
    elseif self.token =~# '\m^[.*~[]$'
      return '\' . self.token
    else
      " no magic version
      return self.token
    endif
  elseif self.magicness ==# 'v'
    " very magic
    if self.token =~# '\m^[+?{()@%<>=]'
      return '\' . self.token
    elseif self.token =~# '\m^\\[+?{()@%<>=]'
      return self.token[1:]
    else
      " no magic version
      return self.token
    endif
  elseif self.magicness ==# 'V'
    " very non-magic
    if self.token =~# '\m^\\[[.*~^$]$'
      return self.token[1:]
    elseif self.token =~# '\m^[[.*~^$]$'
      return '\' . self.token
    else
      " no magic version
      return self.token
    endif
  else
    throw 'RELab Parser: What are we doing here?'
  endif
endfunction "}}}

" parser.id() {{{
" TODO should be part of node instead?
" return the string used to retrieve the description from s:id_map
function! s:id() dict
  21DebugRELab printf('%s:', expand('<sfile>'))
  21DebugRELab printf('args: %s', a:)
  let magic_token = self.magic()
  22DebugRELab printf('to id: self.token: %s, magic_token: %s', self.token,
        \ magic_token)
  if self.in_collection
    23DebugRELab printf('to id -> collection')
    if self.token =~# '\m^\\[doxuU]'
      23DebugRELab printf('to id -> collection -> code point')
      " /[\x]
      return substitute(self.token, '\m^\(\\.\).\+', '[\1', '')
    elseif self.token =~#
          \ '\m^\%(\\[-^\]\\ebnrt]\|[^\\]\)-\%(\\[-^\]\\ebnrt]\|[^\\]\)$'
      23DebugRELab printf('to id -> collection -> range')
      " /[a-z]
      return self.ignorecase ? 'a-b' : 'A-B'
    elseif self.token =~# '\m^\[[.=].[.=]\]$'
      23DebugRELab printf('to id -> collection -> collation/equivalence')
      " /[[.a.][=a=]]
      return substitute(self.token, '\m^\(\[[.=]\).[.=]\]$', '[\1\1]', '')
    endif
  elseif magic_token =~# '\m^\\%[<>]\?\d\+[lvc]$'
    23DebugRELab printf('to id -> lcv')
    " /\%23l
    return substitute(self.token, '\m\d\+', '', '')
  elseif magic_token =~# '\m^\\%[<>]\?''.$'
    23DebugRELab printf('to id -> mark')
    " /\%'m
    return substitute(self.token, '.$', 'm', '')
  elseif magic_token =~# '\m^\\{'
    23DebugRELab printf('to id -> multi curly')
    " /.\{}
    let id = '\{'
    let id .= magic_token =~# '\m^\\{-' ? '-' : ''
    let id .= magic_token =~# '\m^\\{-\?\d' ? 'n' : ''
    let id .= magic_token =~# '\m^\\{-\?\d*,' ? ',' : ''
    let id .= magic_token =~# '\m^\\{-\?\d*,\d' ? 'm' : ''
    let id .= '}'
    return id
  elseif magic_token =~# '\m^\\%[doxuU]\d\+$'
    23DebugRELab printf('to id -> code point')
    " /\%d123
    return matchstr(self.token, '\m\C^\\%[doxuU]')
  elseif self.token =~# '\m^\\%#=.\?'
    23DebugRELab printf('to id -> engine')
    " regexp engine
    return '\%#='
  elseif magic_token =~# '\m^\\@\%([!=>]\|\d*<[!=]\)$'
    23DebugRELab printf('to id -> lookaround')
    " look-around
    return substitute(self.token, '\d\+', '123', '')
  elseif magic_token =~# '\m^\\[[.^$~*]$'
    23DebugRELab printf('to id -> literal')
    " escaped literal character
    return magic_token
  endif
  23DebugRELab printf('to id -> else')
  return magic_token
endfunction "}}}

" parser.help_tag(node) {{{
" TODO should be part of node instead?
" return the key used to retrieve the help tag from s:id_map
function! s:help_tag(node) dict
  21DebugRELab printf('%s:', expand('<sfile>'))
  21DebugRELab printf('args: %s', a:)
  return get(get(self.id_map, a:node.id, {}), 'help_tag', '')
endfunction "}}}

" parser.line(node) {{{
" TODO should be part of node instead?
" return the description of the given node
function! s:line(node) dict
  21DebugRELab printf('%s:', expand('<sfile>'))
  21DebugRELab printf('args: %s', a:000)
  " get the line corresponding to the given node
  let id = a:node.id
  23DebugRELab printf('line: %s', id)
  let line = get(self.id_map, id,
        \ {'line': 'ERROR: contact this plugin''s author'}).line
  23DebugRELab printf('line: %s', line)
  if id ==? 'x'
    23DebugRELab 'line -> literal'
    " a literal character
    if strchars(a:node.magic) == 1
      23DebugRELab 'line -> literal -> single'
      " unescaped character
      let char = a:node.value
      let code = char2nr(char)
    elseif a:node.value =~# '\m^\\[^etrbn]'
      23DebugRELab 'line -> literal -> escaped'
      " escaped non-special character
      let char = strcharpart(a:node.value, 1)
      let code = char2nr(char)
    elseif a:node.value ==# '\e'
      23DebugRELab 'line -> literal -> escape'
      " an escape
      let char = '<Esc>'
      let code = 27
    elseif a:node.value ==# '\t'
      23DebugRELab 'line -> literal -> tab'
      " a tab
      let char = '<Tab>'
      let code = 9
    elseif a:node.value ==# '\n'
      23DebugRELab 'line -> literal -> car return'
      " a car return
      let char = '<CR>'
      let code = 13
    elseif a:node.value ==# '\b'
      23DebugRELab 'line -> literal -> backspace'
      " a backspace
      let char = '<BS>'
      let code = 8
    else
      23DebugRELab 'line -> literal -> single'
      " a literal character
      let char = a:node.value
      let code = char2nr(char)
    endif
    if id ==# 'X'
      23DebugRELab 'line -> literal -> match case'
      " matching case
      let line = printf(line, char, code)
    elseif tolower(char) ==# toupper(char)
      23DebugRELab 'line -> literal -> no case'
      " this character has no case
      let line = get(self.id_map, 'X',
            \ {'line': 'ERROR: contact this plugin''s author'}).line
      let line = printf(line, char, code)
    else
      23DebugRELab 'line -> literal -> ignore case'
      " ignoring case
      let line = printf(line, tolower(char), char2nr(tolower(char)),
            \ toupper(char), char2nr(toupper(char)))
    endif
  elseif id ==# 'A-B'
    23DebugRELab 'line -> range match case'
    " collection range, match case
    let line = printf(line, a:node.first, char2nr(a:node.first),
          \ a:node.second, char2nr(a:node.second))
  elseif id ==# 'a-b'
    23DebugRELab 'line -> range ignore case'
    " collection range, ignore case
    let line = printf(line,
          \ tolower(a:node.first), char2nr(tolower(a:node.first)),
          \ tolower(a:node.second), char2nr(tolower(a:node.second)),
          \ toupper(a:node.first), char2nr(toupper(a:node.first)),
          \ toupper(a:node.second), char2nr(toupper(a:node.second))
          \ )
  elseif id =~# '^\m\\{'
    23DebugRELab 'line -> brackets'
    " curly multi
    if empty(a:node.min)
      23DebugRELab 'line -> brackets -> empty min'
      " no min value
      if empty(a:node.max)
        23DebugRELab 'line -> brackets -> empty min -> empty max'
        " no max value, nothing to do
      else
        23DebugRELab 'line -> brackets -> empty min -> non empty max'
        " only a max value
        let line = printf(line, a:node.max)
      endif
    else
      23DebugRELab 'line -> brackets -> non empty min'
      " there is a min
      if empty(a:node.max)
        23DebugRELab 'line -> brackets -> non empty min -> empty max'
        " no max, just the min
        let line = printf(line, a:node.min)
      else
        23DebugRELab 'line -> brackets -> non empty min -> non empty max'
        " there are both min and max
        let line = printf(line, a:node.min, a:node.max)
      endif
    endif
  elseif id =~# '\m^\\@123<[=!]$'
    23DebugRELab 'line -> look behind'
    " look-behind
    let line = printf(line, matchstr(a:node.magic, '\d\+'))
  elseif id =~# '\m^\%(\[\\\|\\%\)[doxuU]'
    23DebugRELab 'line -> code point'
    " code point, either insidea a collection or outside of it
    " this dictionary will map the base nonation in regexp to the base
    " notation in the expression
    let code_map = {'d': '%s', 'o': '0%s', 'x': '0x%s', 'u': '0x%s',
          \ 'U': '0x%s'}
    let key = matchstr(id, '\m^\%(\[\\\|\\%\)\zs.')
    23DebugRELab printf('line -> code point: magicness: %s, key: %s',
          \ a:node.magic, key)
    let number = matchstr(a:node.magic, '\m^\\%\?.0\?\zs.\+')
    23DebugRELab printf('line -> code point: number: %s', number)
    " get the expression to be evaluated
    let expr = printf(code_map[key], number)
    23DebugRELab printf('line -> code point: expr: %s', expr)
    " get the decimal base representation
    let dec = eval(expr)
    23DebugRELab printf('line -> code point: dec: %s', dec)
    " get the character from the decimal value
    let char = nr2char(dec)
    let char_is_lower = char =~# '\%#=2^[[:lower:]]$'
    let char2 = char_is_lower ? toupper(char) : tolower(char)
    let has_case = tolower(char) !=# toupper(char)
    if a:node.ignorecase && has_case
      23DebugRELab 'line -> code point -> ignore case'
      " ignoring case, match both cases
      let line = get(self.id_map, id . 'i',
            \ {'line': 'ERROR: contact this plugin''s author'}).line
      let line = printf(line, char, char2)
    else
      23DebugRELab 'line -> code point -> match case'
      " either the character has no case or we are matching case
      let line = printf(line, char)
    endif
  elseif id ==# '\('
    23DebugRELab 'line -> start capturing group'
    " start capturing group
    let line = printf(line, a:node.capt_groups)
  elseif id ==# '\)'
    23DebugRELab 'line -> end capturing group'
    " end capturing group
    let line = printf(line, a:node.capt_groups)
  elseif has_key(self.id_map, id)
    23DebugRELab 'line -> has key'
    " nothing to do here, the description format is as it should
  else
    23DebugRELab 'line -> else'
    " We should not get here either
    echoerr printf('RELab error 3: no map_id for this id: %s', id)
  endif
  let indent = repeat(' ', (a:node.level * 2))
  let line = printf('%s%s => %s', indent, a:node.value, line)
  return line
endfunction "}}}

" parser.lines() {{{
" return a list of descriptions of every item in the parsed regexp
function! s:lines() dict
  21DebugRELab printf('%s:', expand('<sfile>'))
  21DebugRELab printf('args: %s', a:)
  let lines = []
  if !empty(self.errors)
    return extend(lines, self.errors[0].error)
  endif
  call add(lines, '')
  return extend(lines, map(copy(self.sequence), 'self.line(v:val)'))
endfunction "}}}

" parser.match_group(line_offset[, group_number])  {{{
" return a regexp that will match the given capturing group of the currently
" parsed regexp
function! s:match_group(line_offset, ...) dict
  21DebugRELab printf('%s:', expand('<sfile>'))
  21DebugRELab printf('args: %s', a:)
  " generate a regexp that will match the given capturing group of the
  " currently parsed regexp
  23DebugRELab printf('match group: line_offset: %s, group: %s, regexp: %s',
        \ a:line_offset, (a:0 ? a:1 : 'all'), self.input)
  if self.capt_groups < get(a:, 1, 0)
    23DebugRELab printf('match group: arg > available groups')
    " not enough groups to get the wanted one
    let items = []
  elseif get(a:, 1, 0) > 9
    23DebugRELab printf('match group: arg > 9')
    " there can't be more than 9 capturing groups
    let items = []
  else
    23DebugRELab printf('match group: arg > 0')
    " let's start with magic and match case
    let items = ['\m\C']
    if a:line_offset
      " if a line offset was given, add it now
      call add(items, printf('\%%>%sl', a:line_offset))
    endif
    23DebugRELab printf('match group: capt_groups: %s',
          \ map(copy(self.sequence), 'get(v:val, ''capt_groups'', 0)'))
    for node in self.sequence
      23DebugRELab printf('match group: node.magic: %s', node.magic)
      if node.is_branch()
        23DebugRELab printf('match group -> is_branch:')
        " \| or \&
        if a:0 && node.capt_groups == a:1 && node.is_capt_group
          23DebugRELab printf('match group -> branch -> add \ze:')
          " if this is at the same level as the wanted capturing group, then
          " end the match before we add the item
          call add(items, '\ze')
        endif
        " now we add the item
        call add(items, node.magic)
        if a:0 && node.capt_groups == a:1
          23DebugRELab printf('match group -> branch -> add \zs:')
          " If this is at the same level as the wanted capturing group, then
          " start the match after the item
          call add(items, '\zs')
        endif
        if a:line_offset && node.level == -1
          23DebugRELab printf('match group -> is_branch -> add line nr:')
          " If outside of a group, then add line here too
          call add(items, printf('\%%>%sl', a:line_offset))
        endif
      elseif node.starts_capt_group()
        23DebugRELab printf('match group -> starts_capt_group:')
        " \(
        " add item
        call add(items, node.magic)
        if a:0 && node.capt_groups == a:1
          23DebugRELab printf('match group -> starts_capt_group -> add \zs:')
          " if starting wanted capturing group, then start match after the
          " item
          call add(items, '\zs')
        endif
      elseif node.ends_capt_group()
        23DebugRELab printf('match group -> ends_capt_group:')
        " \) after a \(
        if a:0 && node.capt_groups == a:1 && node.is_capt_group
          23DebugRELab printf('match group -> ends_capt_group -> add \ze:')
          " if ending wanted capturing group, then end match before the item
          call add(items, '\ze')
        endif
        " add item
        call add(items, node.magic)
      elseif node.is_boundary()
        23DebugRELab printf('match group -> is_boundary:')
        " \zs or \ze
        if a:0 && a:1 == 0
          23DebugRELab printf('match group -> is_boundary -> add node:')
          " if inside wanted capturing groups, then add item
          call add(items, node.magic)
        endif
      elseif node.id ==# '\%l'
        23DebugRELab printf('match group -> is_line_nr:')
        " \%l or its variants
        if a:line_offset
          " if a line offset was given, add it to the item's
          let linenr = matchstr(node.magic, '\d\+') + a:line_offset
          call add(items, substitute(node.magic, '\d\+', linenr, ''))
        else
          " otherwise just add the item
          call add(items, node.magic)
        endif
      elseif node.value ==# '\'
        23DebugRELab printf('match group -> single backslash:')
        " a single \ (at the end of the regex?)
        " " add item
        call add(items, '\\')
      elseif node.id ==# '\%^'
        23DebugRELab printf('match group -> is_bof:')
        " \%^
        if a:line_offset
          " if a line offset was given, then replace it with an appropriate
          " %\l
          call add(items, printf('\%%%sl\_^', a:line_offset))
        else
          " otherwise just add it
          call add(items, node.magic)
        endif
      elseif node.magic ==# '[' && node.id ==? 'x'
        23DebugRELab printf('match group -> literal [:')
        " a literal [
        " add item
        call add(items, '\[')
      else
        23DebugRELab printf('match group -> else:')
        " add item
        call add(items, node.magic)
      endif
    endfor
  endif
  if len(items) - (a:line_offset > 0) > 1
    " if any items were added, then join them
    let group_re = join(filter(items, '!empty(v:val)'), '')
  else
    " otherwise just set it to an empty string
    let group_re = ''
  endif
  23DebugRELab printf('match group: result: %s', group_re)
  return group_re
endfunction "}}}

" parser.match_groups(...) {{{
" return a list of regexps that match the capturing groups in the currently
" parsed regexp
function! s:match_groups(...) dict
  21DebugRELab printf('%s:', expand('<sfile>'))
  21DebugRELab printf('args: %s', a:)
  23DebugRELab printf('match group: regexp: %s', self.input)
  let offset = get(a:, 1, 0)
  let groups = []
  call add(groups, self.match_group(offset))
  for group in range(0, self.capt_groups)
    call add(groups, self.match_group(offset, group))
  endfor
  return filter(groups, '!empty(v:val)')
endfunction "}}}

" parser.in_optional_group() {{{
" we are currently between \%[ and ]
function! s:in_optional_group() dict
  21DebugRELab printf('%s:', expand('<sfile>'))
  21DebugRELab printf('args: %s', a:)
  return get(get(self.nest_stack, -1, {}), 'id', '') ==# '\%['
endfunction "}}}

" parser.map(key) {{{
" helper function to generate the other s:<plural>() functions
function! s:map(key) dict
  21DebugRELab printf('%s:', expand('<sfile>'))
  21DebugRELab printf('args: %s', a:)
  return map(copy(self.sequence), 'get(v:val, a:key, '''')')
endfunction "}}}

" parser.magics() {{{
" return a list of every node's magic value
function! s:magics() dict
  21DebugRELab printf('%s:', expand('<sfile>'))
  21DebugRELab printf('args: %s', a:)
  return map(copy(self.sequence), 'v:val.magic')
endfunction "}}}

" parser.values() {{{
" return a list of every node's original value
function! s:values() dict
  21DebugRELab printf('%s:', expand('<sfile>'))
  21DebugRELab printf('args: %s', a:)
  return map(copy(self.sequence), 'get(v:val, ''value'', '''')')
endfunction "}}}

" parser.ids() {{{
" return a list of every node's id
function! s:ids() dict
  return map(copy(self.sequence), 'get(v:val, ''id'', '''')')
endfunction "}}}

" parser.collection_ends() {{{
" look forward for a closing ]
function! s:collection_ends() dict
  21DebugRELab printf('%s:', expand('<sfile>'))
  21DebugRELab printf('args: %s', a:)
  let ahead = strcharpart(self.input, self.pos)
  if ahead[0] ==# '^'
    return ahead =~# '\m^\^\%(\\[-ebrtndoxuU^$\]]\|[^\]]\)\+]'
  else
    return ahead =~# '\m^\%(\\[-ebrtndoxuU^$\]]\|[^\]]\)\+]'
  endif
  " why doesn't this work instead of the if block? probably obvious why...
  return ahead =~# '\m^\^\?\%(\\[-ebrtndoxuU^$\]]\|[^\]]\)\+]'
endfunction "}}}

" parser.add_error(node, {{{
" handles adding an error
function! s:add_error(node, ...) dict
  21DebugRELab printf('%s:', expand('<sfile>'))
  21DebugRELab printf('args: %s', a:)
  let a:node.is_error = 1
  let error = []
  let arrow = printf('%s%s',
        \ repeat('-', a:node.pos), repeat('^', strchars(a:node.value)))
  call add(error, arrow)
  call add(error, printf('Error: %s', (a:0 ? a:1 : a:node.value . ':')))
  let a:node.error = error
  call add(self.errors, a:node)
endfunction "}}}

" parser.incomplete_in_coll() {{{
" return 1 if the token is incomplete, 0 otherwise
function! s:incomplete_in_coll() dict
  21DebugRELab printf('%s:', expand('<sfile>'))
  21DebugRELab printf('args: %s', a:)
  let next = self.token . strcharpart(self.input, self.pos)
  let ahead = strcharpart(self.input, self.pos, 1)
  if empty(self.parent_node.children) && self.token ==# '^'
    23DebugRELab printf('incomplete_in_coll -> negate: %s', next)
    " if ^ is at the beginning it's complete
    return 0
  elseif self.token =~#
        \ '\m^\%(\\[\\ebnrt]\|[^\\]\)-\%(\\[\\ebnrt]\|[^\\]\)$'
    23DebugRELab printf('incomplete_in_coll -> range done: %s', next)
    " range is complete
    return 0
  elseif next =~# '\m^\%(\\[\\enbrt]\|[^\\]\)-\%(\\[\\ebnrt]\|[^\\]\)'
    23DebugRELab printf('incomplete_in_coll -> range coming: %s', next)
    " range is incomplete
    return 1
  elseif self.token =~# '\m^\\[-\\ebnrt\]^]$'
    23DebugRELab printf('incomplete_in_coll -> escaped done: %s', next)
    " escaped character is complete
    return 0
  elseif self.token ==# '\' && ahead =~# '\m^[-\\ebnrtdoxuU\]^]$'
    23DebugRELab printf('incomplete_in_coll -> escaped incomplete: %s', next)
    " escaped character is incomplete
    return 1
  elseif self.token ==# '\'
    23DebugRELab printf('incomplete_in_coll -> escaped coming: %s', next)
    " escaped character is coming
    return 0
  elseif self.token =~# '\m^\[\([.=]\).\1\]$'
    23DebugRELab printf('incomplete_in_coll -> equivalence done: %s', next)
    " either an equivalence class or a collation element is complete
    return 0
  elseif next =~# '\m^\[\([.=]\).\1\]'
    23DebugRELab printf('incomplete_in_coll -> equivalence coming: %s', next)
    " either an equivalence class or a collation element is incomplete
    return 1
  elseif self.token =~# '\m^\[:\a\+:\]$'
    23DebugRELab printf('incomplete_in_coll -> collation done: %s', next)
    " a character class expression is complete
    return 0
  elseif next =~# '\m^\[:\a\+:\]'
    23DebugRELab printf('incomplete_in_coll -> collation coming: %s', next)
    " a character class expression is incomplete
    return 1
  endif
  let next = self.token . ahead
  if next =~# '\m^\\d\d*$'
    23DebugRELab printf('incomplete_in_coll -> dec: %s', next)
    " a decimal code point is incomplete
    return 1
  elseif next =~# '\m^\\o0\?\o\{,3}$'
        \ && printf('0%s', matchstr(next, '0\?\zs\o\+')) <= 0377
    23DebugRELab printf('incomplete_in_coll -> oct: %s', next)
    " an octal code point is incomplete
    return 1
  elseif next =~# '\m^\\x\x\{,2}$'
    23DebugRELab printf('incomplete_in_coll -> hex2: %s', next)
    " a two digits hexadecimal code point is incomplete
    return 1
  elseif next =~# '\m^\\u\x\{,4}$'
    23DebugRELab printf('incomplete_in_coll -> hex4: %s', next)
    " a four digits hexadecimal code point is incomplete
    return 1
  elseif next =~# '\m^\\U\x\{,8}$'
    23DebugRELab printf('incomplete_in_coll -> hex8: %s', next)
    " an eight digits hexadecimal code point is incomplete
    return 1
  elseif next =~# '\m^\\[duUx].$'
    23DebugRELab printf('incomplete_in_coll -> code point: %s', next)
    " a code point is incomplete
    return 1
  else
    " it is complete
    return 0
  endif
endfunction "}}}

" parser.is_incomplete() {{{
" return 1 if the token is incomplete, 0 otherwise
function! s:is_incomplete() dict
  21DebugRELab printf('%s:', expand('<sfile>'))
  21DebugRELab printf('args: %s', a:)
  " check if self.token is incomplete
  if self.in_collection
    " inside a collection hte rules are different
    return self.incomplete_in_coll()
  endif
  let token = self.magic()
  if token =~# '\m^\\\%(@\%(\d*\%(<\?\)\)\)$'
        \ || token =~# '\m^\\\%(%[<>]\?\%(\d*\|''\)$\)'
        \ || token =~# '\m^\\\%(_\|#\|{[^}]*\|z\)\?$'
    23DebugRELab printf('is_incomplete -> main: %s', token)
    " an atom starting with one of \@, \%, \_, \#, {, or \z
    " is incomplete
    return 1
  endif
  let ahead = strcharpart(self.input, self.pos, 1)
  let next = token . ahead
  if next =~# '\m^\\%d\d*$'
    23DebugRELab printf('is_incomplete -> dec: %s', next)
    " a decimal code point is incomplete
    return 1
  elseif next =~# '\m^\\%o0\?\o\{,3}$'
        \ && printf('0%s', matchstr(next, '0\?\zs\o\+')) <= 0377
    23DebugRELab printf('is_incomplete -> oct: %s', next)
    " an octal code point is incomplete
    return 1
  elseif next =~# '\m^\\%x\x\{,2}$'
    23DebugRELab printf('is_incomplete -> hex2: %s', next)
    " a two character hexadecimal code point is incomplete
    return 1
  elseif next =~# '\m^\\%u\x\{,4}$'
    23DebugRELab printf('is_incomplete -> hex4: %s', next)
    " a four character hexadecimal code point is incomplete
    return 1
  elseif next =~# '\m^\\%U\x\{,8}$'
    23DebugRELab printf('is_incomplete -> hex8: %s', next)
    " a eight character hexadecimal code point is incomplete
    return 1
  elseif next =~# '\m^\\%[duUx].$'
    23DebugRELab printf('is_incomplete -> code point: %s', next)
    " a code point is incomplete
    return 1
  endif
  23DebugRELab printf('is_incomplete -> else: next: %s', next)
  " it is complete
  return 0
endfunction "}}}

" parser.next() {{{
" finds the next token and stores it in parser.token
" returns 1 if a token was found, 0 otherwise.
function! s:next() dict
  21DebugRELab printf('%s:', expand('<sfile>'))
  21DebugRELab printf('args: %s', a:)
  " put the next token into self.token
  if self.pos == 0 && !empty(matchstr(self.input, '^\\%#=.\?'))
    22DebugRELab printf('regexp engine token')
    " \%#= must be the first thing
    let self.token = matchstr(self.input, '^\\%#=.\?')
    let self.pos = strchars(self.token)
  elseif !empty(self.sep)
        \ && strcharpart(self.input, self.pos, 1) ==# self.sep
    22DebugRELab printf('separator found')
    " remove the separator if any was given
    let self.token = ''
    let self.pos += 1
    let self.input_remaining = self.input[self.pos : ]
  else
    22DebugRELab printf('get a regular token')
    " get a regular token
    let self.token = strcharpart(self.input, self.pos, 1)
    let self.pos += 1
    while (self.pos < self.length) && self.is_incomplete()
      let self.token .= strcharpart(self.input, self.pos, 1)
      let self.pos += 1
    endwhile
  endif
  if !empty(self.token)
    " add token if it's not empty
    call add(self.tokens, self.token)
  endif
  return !empty(self.token)
endfunction "}}}

" parser.parse(input) {{{
" parses the input and returns the parser.
function! s:parse(input) dict
  21DebugRELab printf('%s:', expand('<sfile>'))
  21DebugRELab printf('args: %s', a:)
  " parse the given regexp
  if type(self.input) != v:t_list
    call self.init()
  endif
  23DebugRELab printf('')
  23DebugRELab printf('starting to parse: %s', a:input)
  let input = empty(self.sep) ? a:input : a:input[1:]
  let self.input = input
  let self.length = strchars(input)
  while self.next()
    " get ready to process the new token
    let token = self.token
    let magicness = self.magicness
    let ignorecase = self.ignorecase
    let magic = self.magic()
    let pos = self.pos
    let id = self.id()
    let node =
          \ self.parent_node.new(token, magicness, ignorecase, magic, pos, id)
    call add(self.sequence, node)
    23DebugRELab printf('parse -> token: %s, magicness: %s, ignorecase: %s, '
          \ . 'magic: %s, pos: %s, id: %s', token, magicness, ignorecase,
          \ magic, pos, id)

    if self.in_collection && node.ends_collection() "{{{
      23DebugRELab  'parse -> ends collection'
      " a ] that ends a collection
      call remove(self.nest_stack, -1)
      let self.parent_node = node.parent.parent
      let self.in_collection = 0
      let node.level -= 1
      "}}}

    elseif self.in_collection && node.id ==# '^' "{{{
      23DebugRELab printf('parse -> collection -> negate')
      " a ^ inside a collection
      if empty(node.previous)
        23DebugRELab printf('parse -> collection -> negate -> special')
        " the ^ negates the collection
        let node.id = '[^'
      else
        " a literal ^
        23DebugRELab printf('parse -> collection -> negate -> literal')
        let node.id = node.ignorecase ? 'x' : 'X'
      endif
      "}}}

    elseif self.in_collection && node.is_coll_range_id() "{{{
      23DebugRELab printf('parse -> collection -> range')
      " a range in a collection
      if node.value[0] ==# '\'
        " a special character or an escaped one
        let node.first = strcharpart(node.value, 0, 2)
        let node.second = strcharpart(node.value, 3)
      else
        let node.first = strcharpart(node.value, 0, 1)
        let node.second = strcharpart(node.value, 2)
      endif
      " a map from regexp representation to actual character
      let dict = {'\e': "\e", '\b': "\b", '\n': "\n", '\t': "\t", '\\': '\',
            \ '\]': ']', '\^': '^', '\-': '-'}
      let node.first = get(dict, node.first, node.first)
      23DebugRELab printf('parse -> collection -> range: '
            \ . 'first: %s, second: %s', node.first, node.second)
      let node.second = get(dict, node.second, node.second)
      if node.first ># node.second
        " range is reversed, that's not good
        let errormessage = 'reverse range in character class'
        call self.add_error(node, errormessage)
      endif
      "}}}

    elseif node.is_engine() "{{{
      23DebugRELab  printf('parse -> engine')
      " \%#= which regexp engine to use
      if matchstr(node.value, '^\m\\%#=\zs.\?') !~# '\m^[0-2]$'
        " there are only 3 valid values to chose the engine, this is not one
        " of those
        let errormessage = '\%#= can only be followed by 0, 1, or 2'
        call self.add_error(node, errormessage)
      endif
      "}}}

    elseif node.is_branch() "{{{
      23DebugRELab  printf('parse -> is_branch')
      " either \& or \|
      " Move node one level up in the hierarchy
      call remove(node.siblings, -1)
      call add(node.parent.siblings, node)
      let node.parent.next = node
      let node.previous = node.parent
      let node.siblings = node.parent.siblings
      let node.parent = node.parent.parent
      let node.level -= 1
      let self.parent_node = node
      "}}}

    elseif self.in_optional_group() && node.is_invalid_in_optional() "{{{
      23DebugRELab  printf('parse -> invalid in optional')
      " it's invalid between \%[ and ]
      let errormessage =
            \ printf('%s is not valid inside \%%[]', node.value)
      call self.add_error(node, errormessage)
      "}}}

    elseif node.starts_group() "{{{
      23DebugRELab  printf('parse -> starts group')
      " \(, \%( or [
      call add(self.nest_stack, node)
      let self.parent_node = node
      if node.starts_collection()
        23DebugRELab  printf('parse -> starts group -> collection')
        " [
        if self.collection_ends()
          " The collection is terminated by a ']', so treat this as the
          " start of the collection
          let self.in_collection = 1
        else
          " Treat this as a literal character
          call remove(self.nest_stack, -1)
          let self.parent_node = node.parent
          let node.id = node.ignorecase ? 'x' : 'X'
        endif
      elseif node.starts_capt_group()
        23DebugRELab  printf('parse -> starts group -> capt group')
        " start a capturing group
        let self.capt_groups += 1
        let node.capt_groups = self.capt_groups
        let node.is_capt_group = 1
        23DebugRELab  printf('parse -> starts group -> capt group: '
              \ . 'node.capt_groups: %s', node.capt_groups)
        if self.capt_groups > 9
          " there can only be 9 capturing groups
          let errormessage = 'more than 9 capturing groups'
          call self.add_error(node, errormessage)
        endif
      else
        " non capturing group
        23DebugRELab  printf('parse -> starts group -> non capturing group')
        let node.is_capt_group = 0
      endif
      "}}}

    elseif node.ends_group() "{{{
      23DebugRELab  printf('parse -> ends group')
      " either \) or ]
      if node.is_paired()
        23DebugRELab  printf('parse -> ends group -> is paired')
        " we have both halves, let's go up one level
        call remove(self.nest_stack, -1)
        let self.parent_node = node.parent.parent
        let node.level -= 1
        if node.ends_opt_group()
          23DebugRELab printf('parse -> ends group -> is paired -> opt group')
          " \%[...]
          if empty(node.previous)
            " an optional group can not be empty
            let errormessage = printf('empty %s%s', node.parent.value,
                  \ node.value)
            call self.add_error(node, errormessage)
          else
            " change the node's id accordingly
            let node.id = '\%]'
          endif
        elseif node.is_capt_group
          " capturing group, nothing to do here
        else
          " non capturing group, change the node's id
          let node.id = '\%)'
        endif
      else
        23DebugRELab  printf('parse -> ends group -> is not paired')
        " it is unpaired
        if node.id ==# ']'
          " an unpaired ] is to be matched literally
          let node.id = node.ignorecase ? 'x' : 'X'
        elseif empty(self.nest_stack)
          " an unpaired \) is an error
          let errormessage = printf('unmatched %s', node.value)
          call self.add_error(node, errormessage)
        else
          " a \) is invalid inside an optional group \%[...]
          let errormessage = printf('unmatched %s', node.value)
          call self.add_error(node, errormessage)
        endif
      endif
      "}}}

    elseif node.has_underscore() "{{{
      23DebugRELab  printf('parse -> has underscore')
      " \_<something>
      if node.is_valid_underscore()
        23DebugRELab  printf('parse -> has underscore -> valid')
        " a valid one, not much to do
      else
        23DebugRELab  printf('parse -> has underscore -> invalid')
        " no bueno
        let errormessage = 'invalid use of \_'
        call self.add_error(node, errormessage)
      endif
      "}}}

    elseif node.is_multi() "{{{
      23DebugRELab  printf('parse -> multi')
      " a multi
      if !empty(node.previous) && node.previous.is_multi()
        23DebugRELab  printf('parse -> multi -> follows multi')
        " a multi can not follow another multi
        let errormessage =
              \ printf('%s can not follow a multi', node.value)
        call self.add_error(node, errormessage)
      elseif node.follows_nothing()
        23DebugRELab  printf('parse -> multi -> follows nothing')
        " a multi must follow something legal
        let errormessage =
              \ printf('%s follows nothing', node.value)
        call self.add_error(node, errormessage)
      elseif node.is_multi_bracket()
        23DebugRELab  printf('parse -> multi -> brackets')
        " \{...}
        if node.is_valid_bracket()
          23DebugRELab  printf('parse -> multi -> brackets -> valid')
          " we got a valid one!
          let node.min = matchstr(node.value, '\m\\{-\?\zs\d*')
          let node.max = matchstr(node.value, '\m\\{-\?\d*,\zs\d*')
        else
          23DebugRELab  printf('parse -> multi -> brackets -> invalid')
          " not so lucky now
          let errormessage =
                \ printf('syntax error in %s', node.value)
          call self.add_error(node, errormessage)
        endif
      endif
      "}}}

    elseif node.is_back_reference() "{{{
      23DebugRELab  printf('parse -> back reference')
      " \1 to \9
      if strcharpart(node.value, 1, 1) > self.capt_groups
        " can't have more back-references than capturing groups
        23DebugRELab  printf('parse -> back reference -> illegal')
        let errormessage = 'illegal back reference'
        call self.add_error(node, errormessage)
      endif
      "}}}

    elseif node.is_look_around() "{{{
      23DebugRELab  printf('parse -> look around')
      " look around
      if node.follows_nothing()
        23DebugRELab  printf('parse -> look around -> illegal')
        " must follow something valid
        let errormessage = printf('%s follows nothing', node.value)
        call self.add_error(node, errormessage)
      endif
      "}}}

    elseif node.starts_with_at() "{{{
      23DebugRELab  printf('parse -> starts with @')
      " starts with \@ other than a look around
      if node.id !=# '\@>'
        " an invalid one
        let errormessage = printf('invalid character after %s',
              \ (node.magicness ==# 'v' ? '@' : '\@'))
        call self.add_error(node, errormessage)
      endif
      "}}}

    elseif node.like_code_point() "{{{
      23DebugRELab  printf('parse -> like code point: magicness: %s',
            \ node.magic)
      " could be a code point
      if node.is_code_point()
        23DebugRELab  printf('parse -> like code point -> hexadecimal 8')
        " we have a winner, not much to do
      else
        23DebugRELab  printf('parse -> like code point -> invalid code point')
        " loser here
        let errormessage = printf('invalid character after %s',
              \ matchstr(node.value, '\\\?%[duUx]'))
        call self.add_error(node, errormessage)
      endif
      "}}}

    elseif node.is_mark() "{{{
      23DebugRELab  printf('parse -> mark')
      " a mark
      "}}}

    elseif node.is_lcv() "{{{
      23DebugRELab  printf('parse -> lcv')
      " match a line, column or virtual cloumn
      "}}}

    elseif node.is_invalid_percent() "{{{
      23DebugRELab  printf('parse -> invalid percent')
      " starts with \% but it's invalid
      let errormessage = printf('invalid character after %s',
            \ matchstr(node.value, '\\\?%'))
      call self.add_error(node, errormessage)
      "}}}

    elseif node.is_invalid_z() "{{{
      23DebugRELab  printf('parse -> invalid percent')
      " starts with \z but it's invalid
      let errormessage = printf('invalid character after %s',
            \ matchstr(node.value, '\\\?z'))
      call self.add_error(node, errormessage)
      "}}}

    elseif node.is_case() "{{{
      " \c or \C
      let self.ignorecase = node.id ==# '\c'
      23DebugRELab  printf('parse -> case: %s', self.ignorecase)
      "}}}

    elseif node.is_magic() "{{{
      23DebugRELab  printf('parse -> magicness')
      " \V, \M, \m or \v
      let self.magicness = node.id[1]
      "}}}

    elseif node.value !=? 'x' && has_key(self.id_map, node.id) "{{{
      23DebugRELab  printf('parse -> has_key: node.id: %s', node.id)
      " it's not a literal and has an entry in the id_map
      "}}}

    else
      if !empty(self.sep) && node.value ==# '\' . self.sep
        " if a separator was given, then unescape it
        let node.value = self.sep
      endif
      23DebugRELab  printf('parse -> literal match')
      " literal
      let node.id = node.ignorecase ? 'x' : 'X'
    endif
    " add a description
    "let node.line = node.is_error ? '' : self.line(node)
  endwhile
  if !empty(self.nest_stack)
    23DebugRELab  printf('parse -> non-empty nest stack')
    " we have some items left were we shouldn't
    for node in self.nest_stack
      23DebugRELab  printf('parse -> non-empty nest stack -> loop: %s',
            \ node.value)
      if node.starts_opt_group()
        " we started an optional group but we didn't finish it
        let errormessage = printf('missing ] after %s', node.value)
      else
        " likewise with a \( or \%(
        let errormessage = printf('unmatched %s', node.value)
      endif
      " we add an error now
      call self.add_error(node, errormessage)
    endfor
  endif
  return self
endfunction "}}}

" relab#parser#new([separator]) {{{
" returns a Vim regexp parser that will consider the given separator when
" parsing the input.
function! relab#parser#new(...)
  21DebugRELab printf('%s:', expand('<sfile>'))
  21DebugRELab printf('args: %s', a:)
  let parser = {}
  let parser.id_map = s:id_map
  let parser.sep = a:0 ? a:1 : ''
  " defining the dict functions this way makes debugging easier because we
  " avoid numbered functions in errors and when expanding <sfile>
  let parser.init = function('s:init')
  let parser.magic = function('s:magic')
  let parser.id = function('s:id')
  let parser.help_tag = function('s:help_tag')
  let parser.line = function('s:line')
  let parser.in_optional_group = function('s:in_optional_group')
  let parser.map = function('s:map')
  let parser.collection_ends = function('s:collection_ends')
  let parser.add_error = function('s:add_error')
  let parser.incomplete_in_coll = function('s:incomplete_in_coll')
  let parser.is_incomplete = function('s:is_incomplete')
  let parser.next = function('s:next')
  let parser.parse = function('s:parse')
  let parser.match_group = function('s:match_group')
  let parser.match_groups = function('s:match_groups')
  let parser.magics = function('s:magics')
  let parser.values = function('s:values')
  let parser.lines = function('s:lines')
  let parser.ids = function('s:ids')
  return parser.init(get(a:, '1', ''))
endfunction "}}}

" Node
function! s:ends_capt_group() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " look for a matching item
  return get(self.get_left_pair(), 'magic', '') ==# '\('
        \ && self.magic ==# '\)'
endfunction "}}}

function! s:ends_collection() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " look for a matching item
  return get(self.get_left_pair(), 'magic', '') ==# '['
        \ && self.magic ==# ']'
endfunction "}}}

function! s:ends_group() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " either ] or \)
  return self.magic ==# ']' || self.magic ==# '\)'
endfunction "}}}

function! s:ends_non_capt_group() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " \) after \%(
  return get(self.get_left_pair(), 'magic', '') ==# '\%('
        \ && self.magic ==# '\)'
endfunction "}}}

function! s:ends_opt_group() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " ] after \%[
  return get(self.get_left_pair(), 'magic', '') ==# '\%['
        \ && self.magic ==# ']'
endfunction "}}}

function! s:follows_nothing() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " if the previous item exists and it's a \& or \| and it's last children isn't a \) or it's a look around
  return empty(self.previous) || (self.previous.is_branch()
        \ && !get(self.previous.children, -1, self.previous).magic ==# '\)')
        \ || self.previous.is_look_around()
endfunction "}}}

function! s:get_left_pair() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " look back for the matching item
  let pairs = {}
  let pairs['\('] = '\)'
  let pairs['\%('] = '\)'
  let pairs['\%['] = ']'
  let pairs['['] = ']'
  let parent = self.parent
  while !empty(parent) && parent.id !=# 'root'
    if parent.is_branch()
      " keep looking back
      let parent = parent.previous
    elseif get(pairs, parent.id, '') ==# self.magic
      " found!
      return parent
    else
      " There isn't one
      break
    endif
  endwhile
  return {}
endfunction "}}}

function! s:has_underscore() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " \_<something>
  return self.magic =~# '\m^\\_.'
endfunction "}}}

function! s:is_back_reference() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " \1 to \9
  return self.id =~# '\m^\\[1-9]$'
endfunction "}}}

function! s:is_boundary() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " either \zs or \ze
  return self.magic ==# '\zs' || self.magic ==# '\ze'
endfunction "}}}

function! s:is_branch() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " either \& or \|
  return self.magic ==# '\|' || self.magic ==# '\&'
endfunction "}}}

function! s:is_case() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " either \c or \C
  return self.magic ==? '\c'
endfunction "}}}

function! s:is_code_point() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " a valid code point
  return self.magic =~#
        \ '\m^\\%\(d\d\+\|o0\?\o\{1,3}\|x\x\{1,2}\|u\x\{1,4}\|U\x\{1,8}\)$'
endfunction "}}}

function! s:is_coll_range() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " a range in a collection
  return self.magic =~#
        \ '\m^\%(\\[-^\]\\ebnrt]\|[^\\]\)-\%(\\[-^\]\\ebnrt]\|[^\\]\)$'
endfunction "}}}

function! s:is_coll_range_id() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " is the id a-b or A-B ?
  return self.id ==? 'a-b'
endfunction "}}}

function! s:is_engine() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " is the id \%#= ?
  return self.id ==# '\%#='
endfunction "}}}

function! s:is_group() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " one of \(, \%(, \), \|, \&
  return index(['\(', '\%(', '\)', '\|', '\&'], self.id) >= 0
endfunction "}}}

function! s:is_invalid_in_optional() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " is it an invalid item when inside \%[...] ?
  return self.is_multi() || self.is_group() || self.is_look_around()
        \ || self.starts_opt_group()
endfunction "}}}

function! s:is_invalid_percent() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " does it start with \% but is invalid?
  return self.magic =~# '\m^\\%[^V#^$C]\?$'
endfunction "}}}

function! s:is_invalid_z() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " does it start with \z but is invalid?
  return self.magic =~# '\m^\\z[^se]\?$'
endfunction "}}}

function! s:is_lcv() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " is it one of \%l, \%c or \%v or any variant?
  return self.magic =~# '\m^\\%[<>]\?\d*[clv]'
endfunction "}}}

function! s:is_look_around() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " is it a propper look around?
  return self.id =~# '\m^\\@\%([!=>]\|\d*<[!=]\)$'
endfunction "}}}

function! s:is_magic() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " is it a magic item?
  return self.magic =~? '\m^\\[mv]$'
endfunction "}}}

function! s:is_mark() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " is it a mark?
  return self.magic =~# '\m^\\%[<>]\?''[a-zA-Z0-9''[\]<>]$'
endfunction "}}}

function! s:is_multi() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " maybe a multi?
  return self.magic =~# '\m^\%(\\[?=+]\|\*\)$\|^\\{'
endfunction "}}}

function! s:is_multi_bracket() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " \{...}
  return self.magic =~# '\m^\\{'
endfunction "}}}

function! s:is_paired() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " does it have a pair?
  return !empty(self.get_left_pair())
endfunction "}}}

function! s:is_valid_bracket() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " do we have a valid curly multi?
  return self.magic =~# '\m^\\{-\?\d*,\?\d*\\\?}$'
endfunction "}}}

function! s:is_valid_underscore() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " does it start with \_ and is valid?
  return self.magic =~# '\m^\\_[iIkKfFpPsSdDxXoOwWhHaAlLuU^$[.]$'
endfunction "}}}

function! s:item_or_eol() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " is it a propper atom extended to match an eol?
  return self.magic =~# '\m^\\_[$^.iIkKfFpPsSdDxXoOwWhHaAlLuU]$'
endfunction "}}}

function! s:like_code_point() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " maybe a code point?
  return self.magic =~# '\m^\\%[douUx]'
endfunction "}}}

function! s:new(token, magicness, ignorecase, magic, pos, id) dict "{{{
  31DebugRELab printf('%s:', expand('<sfile>'))
  31DebugRELab printf('args: %s', a:)
  " return a new child node
  let n = copy(self)
  let n.is_error = 0
  let n.error = []
  let n.magicness = a:magicness
  let n.ignorecase = a:ignorecase
  let n.parent = self
  let n.siblings = self.children
  let n.children = []
  let n.previous = get(self.children, -1, {})
  let n.next = {}
  let n.value = a:token
  let n.magic = a:magic
  let n.id = a:id
  let n.level += 1
  let n.line = ''
  let n.pos = a:pos - strchars(a:token)
  if !empty(n.previous)
    let n.previous.next = n
  endif
  call add(self.children, n)
  32DebugRELab  printf('new: node: %s', filter(copy(n), 'type(v:val) <= 1'))
  return n
endfunction "}}}

function! s:starts_capt_group() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " is it a \(
  return self.magic ==# '\('
endfunction "}}}

function! s:starts_collection() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " is it a [
  return self.magic ==# '['
endfunction "}}}

function! s:starts_group() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " is it one of \(, \%( or \%[
  return self.magic ==# '[' || self.magic =~# '\m^\\%\?($'
        \ || self.magic ==# '\%['
endfunction "}}}

function! s:starts_non_capt_group() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " is it \%(
  return self.magic ==# '\%('
endfunction "}}}

function! s:starts_opt_group() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " is it \%[
  return self.magic ==# '\%['
endfunction "}}}

function! s:starts_with_at() dict "{{{
  34DebugRELab printf('%s:', expand('<sfile>'))
  " does it start with \@ ?
  return self.magic =~# '\m^\\@'
endfunction "}}}

function! relab#parser#node() "{{{
  31DebugRELab printf('%s:', expand('<sfile>'))
  31DebugRELab printf('args: %s', a:)
  let node = {}
  let node.value = ''
  let node.magic = ''
  let node.id = ''
  let node.help = ''
  let node.magicness = ''
  let node.capt_groups = -1
  let node.is_capt_group = 0
  let node.ignorecase = 0
  let node.parent = {}
  let node.siblings = []
  let node.children = []
  let node.level = 0
  " defining the dict functions this way makes debugging easier because we
  " avoid numbered functions in errors and when expanding <sfile>
  let node.is_magic = function('s:is_magic')
  let node.is_branch = function('s:is_branch')
  let node.starts_group = function('s:starts_group')
  let node.starts_capt_group = function('s:starts_capt_group')
  let node.starts_non_capt_group = function('s:starts_non_capt_group')
  let node.starts_opt_group = function('s:starts_opt_group')
  let node.starts_collection = function('s:starts_collection')
  let node.ends_group = function('s:ends_group')
  let node.ends_capt_group = function('s:ends_capt_group')
  let node.ends_non_capt_group = function('s:ends_non_capt_group')
  let node.ends_opt_group = function('s:ends_opt_group')
  let node.ends_collection = function('s:ends_collection')
  let node.item_or_eol = function('s:item_or_eol')
  let node.is_engine = function('s:is_engine')
  let node.is_multi = function('s:is_multi')
  let node.is_multi_bracket = function('s:is_multi_bracket')
  let node.is_valid_bracket = function('s:is_valid_bracket')
  let node.is_look_around = function('s:is_look_around')
  let node.is_group = function('s:is_group')
  let node.is_invalid_in_optional = function('s:is_invalid_in_optional')
  let node.is_back_reference = function('s:is_back_reference')
  let node.starts_with_at = function('s:starts_with_at')
  let node.is_boundary = function('s:is_boundary')
  let node.has_underscore = function('s:has_underscore')
  let node.is_valid_underscore = function('s:is_valid_underscore')
  let node.is_coll_range = function('s:is_coll_range')
  let node.is_coll_range_id = function('s:is_coll_range_id')
  let node.like_code_point = function('s:like_code_point')
  let node.is_code_point = function('s:is_code_point')
  let node.is_invalid_percent = function('s:is_invalid_percent')
  let node.is_mark = function('s:is_mark')
  let node.is_lcv = function('s:is_lcv')
  let node.is_invalid_z = function('s:is_invalid_z')
  let node.is_case = function('s:is_case')
  let node.follows_nothing = function('s:follows_nothing')
  let node.get_left_pair = function('s:get_left_pair')
  let node.is_paired = function('s:is_paired')
  let node.new = function('s:new')
  return node
endfunction "}}}

" New approach

function! s:new_node(state) "{{{
  31DebugRELab printf('%s:', expand('<sfile>'))
  31DebugRELab printf('args: %s', a:)
  let node = {}
  let node.literal = ''
  let node.magic = ''
  let node.id = node.magic
  let node.help = ''
  let node.magic_level = a:state.magic_level
  let node.capt_groups = -1
  let node.is_capt_group = 0
  let node.ignorecase = 0
  let node.siblings = []
  let node.children = []
  let node.level = 0
  if empty(a:state.ancestors)
    let node.parent = {}
  else
    let node.parent = a:state.ancestors[-1]
  endif
  " defining the dict functions this way makes debugging easier because we
  " avoid numbered functions in errors and when expanding <sfile>
  "let node.new = function('s:new')
  return node
endfunction "}}}

" s:magic(token, magic_level) {{{
" TODO should be part of node instead?
" return the \m value of the current token
function! s:magic(token, magic_level)
  21DebugRELab printf('%s:', expand('<sfile>'))
  21DebugRELab printf('args: %s', a:)
  if a:magic_level ==# 'm'
    " already magic
    return a:token
  elseif a:magic_level ==# 'M'
    " non-magic
    if a:token =~# '\m^\\[.*~[]'
      return a:token[1:]
    elseif a:token =~# '\m^[.*~[]'
      return '\' . a:token
    else
      " no change needed
      return a:token
    endif
  elseif a:magic_level ==# 'v'
    " very magic
    if a:token =~# '\m^[+?{()@%<>=]'
      return '\' . a:token
    elseif a:token =~# '\m^\\[+?{()@%<>=]'
      return a:token[1:]
    else
      " no change needed
      return a:token
    endif
  elseif a:magic_level ==# 'V'
    " very non-magic
    if a:token =~# '\m^\\[[.*~^$]'
      return a:token[1:]
    elseif a:token =~# '\m^[[.*~^$]'
      return '\' . a:token
    else
      " no change needed
      return a:token
    endif
  else
    throw 'RELab Parser: What are we doing here?'
  endif
endfunction "}}}

" s:magic2id(token) {{{
" return the id of the current token
function! s:magic2id(token, state)
  21DebugRELab printf('%s:', expand('<sfile>'))
  21DebugRELab printf('args: %s', a:)
  return get(s:id_map, a:token, a:state.ignorecase ? 'x' : 'X')
endfunction "}}}

" State:
" * ignorecase
" * magic_level
" * index
" * is_in_collection
" * is_in_optional
" * nest_level
" * is_start
" * max_capturing
" * capturing_count
" * is_first
" * separator
" * ancestors

function! s:parse(input, state) "{{{
  " parses the input and returns the parser.
  21DebugRELab printf('%s:', expand('<sfile>'))
  21DebugRELab printf('args: %s', a:)
  " parse the given regexp
  let state = deepcopy(a:state)
  if state.index >= strchars(a:input)
    let state.elements = []
    return state
  endif
  let state.start = 1
  let token = strcharpart(a:input, state.index, 1)
  let state.index += 1
  if token ==# '\'
    let token .= strcharpart(a:input, state.index, 1)
    let state.index += 1
    if !state.is_in_collection
      if token ==# '\_'
        let token .= strcharpart(a:input, state.index, 1)
        let state.index += 1
      endif
    else
    endif
  endif
  let magic = s:magic(token, state.magic_level)
  let node = s:new_node(state)
  if state.is_first && state.index == 0 && a:input =~# '\m^\\%#=\d'
    " Looks like selecting regexp engine
    let state.is_first = 0
    if a:input =~# '\m^\\%#=[0-2]'
      let token = strcharpart(a:input, 0, 5)
      let state.index = 5
    else
      let state.index = 0
      let token = ''
      " TODO add error
    endif
  elseif state.is_in_collection " {{{
    if magic ==# '[' && strcharpart(a:input, state.index) =~# '\m^\[:\a\+:]'
      let ahead = strcharget(state.input, state.index)
      let class = matchstr(ahead, '\m^:\a\+:]')
      let equivalence = matchstr(ahead, '\m^=.=]')
      let collation = matchstr(ahead, '\m^\..\.]')
      if !empty(class)
        let token .= class
        let state.index += strchars(class)
        let name = token[2:-3]
        if index(['alnum', 'alpha', 'backspace', 'blank', 'cntrl', 'digit',
              \ 'escape', 'graph', 'lower', 'print', 'punct', 'return',
              \ 'space', 'tab', 'upper', 'xdigit']) >= 0
          let node.id = token
        else
          " TODO add error
        endif
      elseif !empty(equivalence)
        let token .= equivalence
        let state.index += strchars(equivalence)
        let node.id = '[==]'
      elseif !empty(collation)
        let token .= collation
        let state.index += strchars(collation)
        let node.id = '[..]'
      else
        let node.id = state.ignorecase ? 'x' : 'X'
      endif
    elseif magic ==# ']'
      let node.literal = token
      let node.magic = magic
      let node.id = ']'
      let state.is_in_collection = 0
      call remove(state.ancestors, -1)
      let new_state = s:parse(a:input, state)
    elseif magic ==# '\d'
      let ahead = strcharpart(a:input, state.index)
      let digits = matchstr(ahead, '\m^\d\+')
      if empty(digits)
        let node.literal = token
        let node.magic = 'd'
        let node.id = state.ignorecase ? 'x' : 'X'
      else
        let node.digits = digits
        let state.index += strchars(digits)
        let node.literal = token . digits
        let node.magic = magic
        let node.id = state.ignorecase ? '[\di' : '[\d'
      endif
    elseif magic ==# '\o'
      let ahead = strcharpart(a:input, state.index)
      let digits = matchstr(ahead, '\m^\%([123]\o\o\|\o\o\?\)')
      if empty(digits)
        let node.literal = token
        let node.magic = 'o'
        let node.id = state.ignorecase ? 'x' : 'X'
      else
        let node.digits = digits
        let state.index += strchars(digits)
        let node.literal = token . digits
        let node.magic = magic
        let node.id = state.ignorecase ? '[\oi' : '[\o'
      endif
    elseif magic ==# '\x'
      let ahead = strcharpart(a:input, state.index)
      let digits = matchstr(ahead, '\m^\x\{1,2}')
      if empty(digits)
        let node.literal = token . digits
        let node.magic = 'x'
        let node.id = state.ignorecase ? 'x' : 'X'
      else
        let node.digits = digits
        let state.index += strchars(digits)
        let node.literal = token
        let node.magic = magic
        let node.id = state.ignorecase ? '[\xi' : '[\x'
      endif
    elseif magic ==# '\u'
      let ahead = strcharpart(a:input, state.index)
      let digits = matchstr(ahead, '\m^\x\{1,4}')
      if empty(digits)
        let node.literal = token
        let node.magic = 'u'
        let node.id = state.ignorecase ? 'x' : 'X'
      else
        let node.digits = digits
        let state.index += strchars(digits)
        let node.literal = token . digits
        let node.magic = magic
        let node.id = state.ignorecase ? '[\ui' : '[\u'
      endif
    elseif magic ==# '\U'
      let ahead = strcharpart(a:input, state.index)
      let digits = matchstr(ahead, '\m^\x\{1,8}')
      if empty(digits)
        let node.literal = token
        let node.magic = 'U'
        let node.id = state.ignorecase ? 'x' : 'X'
      else
        let node.digits = digits
        let state.index += strchars(digits)
        let node.literal = token . digits
        let node.magic = magic
        let node.id = state.ignorecase ? '[\Ui' : '[\U'
      endif
    elseif magic =~# '\m^\\[etrbn]$'
      let node.id = '[' . magic
    else
      let node.id = state.ignorecase ? 'x' : 'X'
    endif

    " }}}
  elseif state.is_in_optional
  else
    if magic ==# '[' || magic ==# '\_['
      let node.literal = token
      let node.magic = magic
      let node.id = magic
      let state.is_in_collection = 1
      let state.is_start_of_collection = 1
      call add(state.ancestors, node)
      let new_state = s:parse(a:input, state)
      if new_state.is_in_collection
        " there is no closing ], take [ as a literal
        let node.id = 'X'
        let state.is_in_collection = 0
        call remove(state.ancestors, -1)
        let new_state = s:parse(a:input, state)
      else
      endif
      call insert(new_state.elements, node, 0)
    else
      let node.literal = token
      let node.magic = magic
      let node.id = state.ignorecase ? 'x' : 'X'
      let new_state = s:parse(a:input, state)
    endif
  endif
  if !exists('new_state')
    let new_state = s:parse(a:input, state)
  endif
  if empty(node.literal)
    let node.literal = token
  endif
  if empty(node.magic)
    let node.magic = magic
  endif
  if empty(node.id)
    let node.id = state.ignorecase ? 'x' : 'X'
  endif
  if index(new_state.elements, node) < 0
    call insert(new_state.elements, node, 0)
  endif
  return new_state
endfunction "}}}

" relab#parser#new() {{{
" returns a Vim regexp parser that will consider the given separator when
" parsing the input.
function! relab#parser#new(...)
  21DebugRELab printf('%s:', expand('<sfile>'))
  21DebugRELab printf('args: %s', a:)
  let state = {
        \ 'separator': '',
        \ 'ignorecase': 0,
        \ 'magic_level': 'm',
        \ 'index': 0,
        \ 'is_in_collection': 0,
        \ 'is_in_optional': 0,
        \ 'nest_level': 0,
        \ 'is_start': 1,
        \ 'max_capturing': 9,
        \ 'capturing_count': 0,
        \ 'is_first': 1,
        \ 'ancestors': [],
        \}
  let node = s:new_node(state)
  call add(state.ancestors, node)
  call extend(state, get(a:, 1, {}), 'force')
  " defining the dict functions this way makes debugging easier because we
  " avoid numbered functions in errors and when expanding <sfile>
  return {input -> s:parse(input, state)}
endfunction "}}}
