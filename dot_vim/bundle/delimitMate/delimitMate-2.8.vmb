" Vimball Archiver by Charles E. Campbell
UseVimball
finish
plugin/delimitMate.vim	[[[1
402
" File:        plugin/delimitMate.vim
" Version:     2.7
" Modified:    2013-07-15
" Description: This plugin provides auto-completion for quotes, parens, etc.
" Maintainer:  Israel Chauca F. <israelchauca@gmail.com>
" Manual:      Read ":help delimitMate".
" ============================================================================

" Initialization: {{{

if exists("g:loaded_delimitMate") || &cp
  " User doesn't want this plugin or compatible is set, let's get out!
  finish
endif
let g:loaded_delimitMate = 1
let save_cpo = &cpo
set cpo&vim

if v:version < 700
  echoerr "delimitMate: this plugin requires vim >= 7!"
  finish
endif

let s:loaded_delimitMate = 1
let delimitMate_version = "2.8"

"}}}

" Functions: {{{

function! s:option_init(name, default) "{{{
  let opt_name = "delimitMate_" . a:name
  " Find value to use.
  if !has_key(b:, opt_name) && !has_key(g:, opt_name)
    let value = a:default
  elseif has_key(b:, opt_name)
    let value = b:[opt_name]
  else
    let value = g:[opt_name]
  endif
  call s:set(a:name, value)
endfunction "}}}

function! s:init() "{{{
" Initialize variables:
  " autoclose
  call s:option_init("autoclose", 1)
  " matchpairs
  call s:option_init("matchpairs", string(&matchpairs)[1:-2])
  call s:option_init("matchpairs_list", map(split(s:get('matchpairs', ''), '.:.\zs,\ze.:.'), 'split(v:val, ''^.\zs:\ze.$'')'))
  let pairs = s:get('matchpairs_list', [])
  if len(filter(pairs, 'v:val[0] ==# v:val[1]'))
    echohl ErrorMsg
    echom 'delimitMate: each member of a pair in delimitMate_matchpairs must be different from each other.'
    echom 'delimitMate: invalid pairs: ' . join(map(pairs, 'join(v:val, ":")'), ', ')
    echohl Normal
    return 0
  endif
  call s:option_init("left_delims", map(copy(s:get('matchpairs_list', [])), 'v:val[0]'))
  call s:option_init("right_delims", map(copy(s:get('matchpairs_list', [])), 'v:val[1]'))
  " quotes
  call s:option_init("quotes", "\" ' `")
  call s:option_init("quotes_list",split(s:get('quotes', ''), '\s\+'))
  " nesting_quotes
  call s:option_init("nesting_quotes", [])
  " excluded_regions
  call s:option_init("excluded_regions", "Comment")
  call s:option_init("excluded_regions_list", split(s:get('excluded_regions', ''), ',\s*'))
  let enabled = len(s:get('excluded_regions_list', [])) > 0
  call s:option_init("excluded_regions_enabled", enabled)
  " expand_space
  if exists("b:delimitMate_expand_space") && type(b:delimitMate_expand_space) == type("")
    echom "b:delimitMate_expand_space is '".b:delimitMate_expand_space."' but it must be either 1 or 0!"
    echom "Read :help 'delimitMate_expand_space' for more details."
    unlet b:delimitMate_expand_space
    let b:delimitMate_expand_space = 1
  endif
  if exists("g:delimitMate_expand_space") && type(g:delimitMate_expand_space) == type("")
    echom "delimitMate_expand_space is '".g:delimitMate_expand_space."' but it must be either 1 or 0!"
    echom "Read :help 'delimitMate_expand_space' for more details."
    unlet g:delimitMate_expand_space
    let g:delimitMate_expand_space = 1
  endif
  call s:option_init("expand_space", 0)
  " expand_cr
  if exists("b:delimitMate_expand_cr") && type(b:delimitMate_expand_cr) == type("")
    echom "b:delimitMate_expand_cr is '".b:delimitMate_expand_cr."' but it must be either 1 or 0!"
    echom "Read :help 'delimitMate_expand_cr' for more details."
    unlet b:delimitMate_expand_cr
    let b:delimitMate_expand_cr = 1
  endif
  if exists("g:delimitMate_expand_cr") && type(g:delimitMate_expand_cr) == type("")
    echom "delimitMate_expand_cr is '".g:delimitMate_expand_cr."' but it must be either 1 or 0!"
    echom "Read :help 'delimitMate_expand_cr' for more details."
    unlet g:delimitMate_expand_cr
    let g:delimitMate_expand_cr = 1
  endif
  if ((&backspace !~ 'eol' || &backspace !~ 'start') && &backspace != 2) &&
        \ ((exists('b:delimitMate_expand_cr') && b:delimitMate_expand_cr == 1) ||
        \ (exists('g:delimitMate_expand_cr') && g:delimitMate_expand_cr == 1))
    echom "delimitMate: There seems to be some incompatibility with your settings that may interfer with the expansion of <CR>. See :help 'delimitMate_expand_cr' for details."
  endif
  call s:option_init("expand_cr", 0)
  " expand_in_quotes
  call s:option_init('expand_inside_quotes', 0)
  " jump_expansion
  call s:option_init("jump_expansion", 0)
  " smart_matchpairs
  call s:option_init("smart_matchpairs", '^\%(\w\|\!\|[£$]\|[^[:punct:][:space:]]\)')
  " smart_quotes
  " XXX: backward compatibility. Ugly, should go the way of the dodo soon.
  let quotes = escape(join(s:get('quotes_list', []), ''), '\-^[]')
  let default_smart_quotes = '\%(\w\|[^[:punct:][:space:]' . quotes . ']\|\%(\\\\\)*\\\)\%#\|\%#\%(\w\|[^[:space:][:punct:]' . quotes . ']\)'
  if exists('g:delimitMate_smart_quotes') && type(g:delimitMate_smart_quotes) == type(0)
    if g:delimitMate_smart_quotes
      unlet g:delimitMate_smart_quotes
    else
      unlet g:delimitMate_smart_quotes
      let g:delimitMate_smart_quotes = ''
    endif
  endif
  if exists('b:delimitMate_smart_quotes') && type(b:delimitMate_smart_quotes) == type(0)
    if b:delimitMate_smart_quotes
      unlet b:delimitMate_smart_quotes
      if exists('g:delimitMate_smart_quotes') && type(g:delimitMate_smart_quotes) && g:delimitMate_smart_quotes
        let b:delimitMate_smart_quotes = default_smart_quotes
      endif
    else
      unlet b:delimitMate_smart_quotes
      let b:delimitMate_smart_quotes = ''
    endif
  endif
  call s:option_init("smart_quotes", default_smart_quotes)
  " apostrophes
  call s:option_init("apostrophes", "")
  call s:option_init("apostrophes_list", split(s:get('apostrophes', ''), ":\s*"))
  " tab2exit
  call s:option_init("tab2exit", 1)
  " balance_matchpairs
  call s:option_init("balance_matchpairs", 0)
  " eol marker
  call s:option_init("insert_eol_marker", 1)
  call s:option_init("eol_marker", "")
  " Everything is fine.
  return 1
endfunction "}}} Init()

function! s:get(name, default) "{{{
  let bufoptions = delimitMate#Get()
  return get(bufoptions, a:name, a:default)
endfunction "}}}

function! s:set(...) " {{{
  return call('delimitMate#Set', a:000)
endfunction " }}}

function! s:Map() "{{{
  " Set mappings:
  try
    let save_keymap = &keymap
    let save_iminsert = &iminsert
    let save_imsearch = &imsearch
    let save_cpo = &cpo
    set keymap=
    set cpo&vim
    silent! doautocmd <nomodeline> User delimitMate_map
    if s:get('autoclose', 1)
      call s:AutoClose()
    else
      call s:NoAutoClose()
    endif
    call s:ExtraMappings()
  finally
    let &cpo = save_cpo
    let &keymap = save_keymap
    let &iminsert = save_iminsert
    let &imsearch = save_imsearch
  endtry

  let b:delimitMate_enabled = 1
endfunction "}}} Map()

function! s:Unmap() " {{{
  let imaps =
        \ s:get('right_delims', []) +
        \ s:get('left_delims', []) +
        \ s:get('quotes_list', []) +
        \ s:get('apostrophes_list', []) +
        \ ['<BS>', '<C-h>', '<S-BS>', '<Del>', '<CR>', '<Space>', '<S-Tab>', '<Esc>'] +
        \ ['<Up>', '<Down>', '<Left>', '<Right>', '<LeftMouse>', '<RightMouse>'] +
        \ ['<C-Left>', '<C-Right>'] +
        \ ['<Home>', '<End>', '<PageUp>', '<PageDown>', '<S-Down>', '<S-Up>', '<C-G>g']

  for map in imaps
    if maparg(map, "i") =~# '^<Plug>delimitMate'
      if map == '|'
        let map = '<Bar>'
      endif
      exec 'silent! iunmap <buffer> ' . map
    endif
  endfor
  silent! doautocmd <nomodeline> User delimitMate_unmap
  let b:delimitMate_enabled = 0
endfunction " }}} s:Unmap()

function! s:test() "{{{
  if &modified
    let confirm = input("Modified buffer, type \"yes\" to write and proceed "
          \ . "with test: ") ==? 'yes'
    if !confirm
      return
    endif
  endif
  call delimitMate#Test()
  g/\%^$/d
  0
endfunction "}}}

function! s:setup(...) "{{{
  let swap = a:0 && a:1 == 2
  let enable = a:0 && a:1
  let disable = a:0 && !a:1
  " First, remove all magic, if needed:
  if get(b:, 'delimitMate_enabled', 0)
    call s:Unmap()
    " Switch
    if swap
      echo "delimitMate is disabled."
      return
    endif
  endif
  if disable
    " Just disable the mappings.
    return
  endif
  if !a:0
    " Check if this file type is excluded:
    if exists("g:delimitMate_excluded_ft") &&
          \ index(split(g:delimitMate_excluded_ft, ','), &filetype, 0, 1) >= 0
      " Finish here:
      return 1
    endif
    " Check if user tried to disable using b:loaded_delimitMate
    if exists("b:loaded_delimitMate")
      return 1
    endif
  endif
  " Initialize settings:
  if ! s:init()
    " Something went wrong.
    return
  endif
  if enable || swap || !get(g:, 'delimitMate_offByDefault', 0)
    " Now, add magic:
    call s:Map()
    if a:0
      echo "delimitMate is enabled."
    endif
  endif
endfunction "}}}

function! s:TriggerAbb() "{{{
  if v:version < 703
        \ || ( v:version == 703 && !has('patch489') )
        \ || pumvisible()
    return ''
  endif
  return "\<C-]>"
endfunction "}}}

function! s:NoAutoClose() "{{{
  " inoremap <buffer> ) <C-R>=delimitMate#SkipDelim('\)')<CR>
  for delim in s:get('right_delims', []) + s:get('quotes_list', [])
    if delim == '|'
      let delim = '<Bar>'
    endif
    exec 'inoremap <silent> <Plug>delimitMate' . delim . ' <C-R>=<SID>TriggerAbb().delimitMate#SkipDelim("' . escape(delim,'"') . '")<CR>'
    exec 'silent! imap <unique> <buffer> '.delim.' <Plug>delimitMate'.delim
  endfor
endfunction "}}}

function! s:AutoClose() "{{{
  " Add matching pair and jump to the midle:
  " inoremap <silent> <buffer> ( ()<Left>
  let i = 0
  while i < len(s:get('matchpairs_list', []))
    let ld = s:get('left_delims', [])[i] == '|' ? '<bar>' : s:get('left_delims', [])[i]
    let rd = s:get('right_delims', [])[i] == '|' ? '<bar>' : s:get('right_delims', [])[i]
    exec 'inoremap <expr><silent> <Plug>delimitMate' . ld
                \. ' <SID>TriggerAbb().delimitMate#ParenDelim("' . escape(rd, '|') . '")'
    exec 'silent! imap <unique> <buffer> '.ld
                \.' <Plug>delimitMate'.ld
    let i += 1
  endwhile

  " Exit from inside the matching pair:
  for delim in s:get('right_delims', [])
    let delim = delim == '|' ? '<bar>' : delim
    exec 'inoremap <expr><silent> <Plug>delimitMate' . delim
                \. ' <SID>TriggerAbb().delimitMate#JumpOut("\' . delim . '")'
    exec 'silent! imap <unique> <buffer> ' . delim
                \. ' <Plug>delimitMate'. delim
  endfor

  " Add matching quote and jump to the midle, or exit if inside a pair of matching quotes:
  " inoremap <silent> <buffer> " <C-R>=delimitMate#QuoteDelim("\"")<CR>
  for delim in s:get('quotes_list', [])
    if delim == '|'
      let delim = '<Bar>'
    endif
    exec 'inoremap <expr><silent> <Plug>delimitMate' . delim
                \. ' <SID>TriggerAbb()."<C-R>=delimitMate#QuoteDelim(\"\\\' . delim . '\")<CR>"'
    exec 'silent! imap <unique> <buffer> ' . delim
                \. ' <Plug>delimitMate' . delim
  endfor

  " Try to fix the use of apostrophes (kept for backward compatibility):
  " inoremap <silent> <buffer> n't n't
  for map in s:get('apostrophes_list', [])
    exec "inoremap <silent> " . map . " " . map
    exec 'silent! imap <unique> <buffer> ' . map . ' <Plug>delimitMate' . map
  endfor
endfunction "}}}

function! s:ExtraMappings() "{{{
  " If pair is empty, delete both delimiters:
  inoremap <silent> <Plug>delimitMateBS <C-R>=delimitMate#BS()<CR>
  if !hasmapto('<Plug>delimitMateBS','i')
    if empty(maparg('<BS>', 'i'))
      silent! imap <unique> <buffer> <BS> <Plug>delimitMateBS
    endif
    if empty(maparg('<C-H>', 'i'))
      silent! imap <unique> <buffer> <C-h> <Plug>delimitMateBS
    endif
  endif
  " If pair is empty, delete closing delimiter:
  inoremap <silent> <expr> <Plug>delimitMateS-BS delimitMate#WithinEmptyPair() ? "\<Del>" : "\<S-BS>"
  if !hasmapto('<Plug>delimitMateS-BS','i') && maparg('<S-BS>', 'i') == ''
    silent! imap <unique> <buffer> <S-BS> <Plug>delimitMateS-BS
  endif
  " Expand return if inside an empty pair:
  inoremap <expr><silent> <Plug>delimitMateCR <SID>TriggerAbb()."\<C-R>=delimitMate#ExpandReturn()\<CR>"
  if s:get('expand_cr', 0) && !hasmapto('<Plug>delimitMateCR', 'i') && maparg('<CR>', 'i') == ''
    silent! imap <unique> <buffer> <CR> <Plug>delimitMateCR
  endif
  " Expand space if inside an empty pair:
  inoremap <expr><silent> <Plug>delimitMateSpace <SID>TriggerAbb()."\<C-R>=delimitMate#ExpandSpace()\<CR>"
  if s:get('expand_space', 0) && !hasmapto('<Plug>delimitMateSpace', 'i') && maparg('<Space>', 'i') == ''
    silent! imap <unique> <buffer> <Space> <Plug>delimitMateSpace
  endif
  " Jump over any delimiter:
  inoremap <expr><silent> <Plug>delimitMateS-Tab <SID>TriggerAbb()."\<C-R>=delimitMate#JumpAny()\<CR>"
  if s:get('tab2exit', 0) && !hasmapto('<Plug>delimitMateS-Tab', 'i') && maparg('<S-Tab>', 'i') == ''
    silent! imap <unique> <buffer> <S-Tab> <Plug>delimitMateS-Tab
  endif
  " Jump over next delimiters
  inoremap <expr><buffer> <Plug>delimitMateJumpMany <SID>TriggerAbb()."\<C-R>=delimitMate#JumpMany()\<CR>"
  if !hasmapto('<Plug>delimitMateJumpMany', 'i') && maparg("<C-G>g", 'i') == ''
    imap <silent> <buffer> <C-G>g <Plug>delimitMateJumpMany
  endif
endfunction "}}}

"}}}

" Commands: {{{

" Let me refresh without re-loading the buffer:
command! -bar DelimitMateReload call s:setup(1)
" Quick test:
command! -bar DelimitMateTest call s:test()
" Switch On/Off:
command! -bar DelimitMateSwitch call s:setup(2)
" Enable mappings:
command! -bar DelimitMateOn call s:setup(1)
" Disable mappings:
command! -bar DelimitMateOff call s:setup(0)

"}}}

" Autocommands: {{{

augroup delimitMate
  au!
  " Run on file type change.
  au FileType * call <SID>setup()

  " Run on new buffers.
  au BufNewFile,BufRead,BufEnter,CmdwinEnter *
        \ if !exists('b:delimitMate_was_here') |
        \   call <SID>setup() |
        \   let b:delimitMate_was_here = 1 |
        \ endif
augroup END

"}}}

" This is for the default buffer when it does not have a filetype.
call s:setup()

let &cpo = save_cpo
" GetLatestVimScripts: 2754 1 :AutoInstall: delimitMate.vim
" vim:foldmethod=marker:foldcolumn=4:ts=2:sw=2
autoload/delimitMate.vim	[[[1
655
" File:        autoload/delimitMate.vim
" Version:     2.7
" Modified:    2013-07-15
" Description: This plugin provides auto-completion for quotes, parens, etc.
" Maintainer:  Israel Chauca F. <israelchauca@gmail.com>
" Manual:      Read ":help delimitMate".
" ============================================================================

"let delimitMate_loaded = 1

if !exists('s:options')
  let s:options = {}
endif

function! s:set(name, value) "{{{
  let bufnr = bufnr('%')
  if !has_key(s:options, bufnr)
    let s:options[bufnr] = {}
  endif
  let s:options[bufnr][a:name] = a:value
endfunction "}}}

function! s:get(...) "{{{
  let options = deepcopy(eval('s:options.' . bufnr('%')))
  if a:0
    return options[a:1]
  endif
  return options
endfunction "}}}

function! s:exists(name, ...) "{{{
  let scope = a:0 ? a:1 : 's'
  if scope == 's'
    let bufnr = bufnr('%')
    let name = 'options.' . bufnr . '.' . a:name
  else
    let name = 'delimitMate_' . a:name
  endif
  return exists(scope . ':' . name)
endfunction "}}}

function! s:is_jump(...) "{{{
  " Returns 1 if the next character is a closing delimiter.
  let char = s:get_char(0)
  let list = s:get('right_delims') + s:get('quotes_list')

  " Closing delimiter on the right.
  if (!a:0 && index(list, char) > -1)
        \ || (a:0 && char == a:1)
    return 1
  endif

  " Closing delimiter with space expansion.
  let nchar = s:get_char(1)
  if !a:0 && s:get('expand_space') && char == " "
    if index(list, nchar) > -1
      return 2
    endif
  elseif a:0 && s:get('expand_space') && nchar == a:1 && char == ' '
    return 3
  endif

  if !s:get('jump_expansion')
    return 0
  endif

  " Closing delimiter with CR expansion.
  let uchar = matchstr(getline(line('.') + 1), '^\s*\zs\S')
  if !a:0 && s:get('expand_cr') && char == ""
    if index(list, uchar) > -1
      return 4
    endif
  elseif a:0 && s:get('expand_cr') && uchar == a:1
    return 5
  endif
  return 0
endfunction "}}}

function! s:rquote(char) "{{{
  let pos = matchstr(getline('.')[col('.') : ], escape(a:char, '[]*.^$\'), 1)
  let i = 0
  while s:get_char(i) ==# a:char
    let i += 1
  endwhile
  return i
endfunction "}}}

function! s:lquote(char) "{{{
  let i = 0
  while s:get_char(i - 1) ==# a:char
    let i -= 1
  endwhile
  return i * -1
endfunction "}}}

function! s:get_char(...) "{{{
  let idx = col('.') - 1
  if !a:0 || (a:0 && a:1 >= 0)
    " Get char from cursor.
    let line = getline('.')[idx :]
    let pos = a:0 ? a:1 : 0
    return matchstr(line, '^'.repeat('.', pos).'\zs.')
  endif
  " Get char behind cursor.
  let line = getline('.')[: idx - 1]
  let pos = 0 - (1 + a:1)
  return matchstr(line, '.\ze'.repeat('.', pos).'$')
endfunction "s:get_char }}}

function! s:is_cr_expansion(...) " {{{
  let nchar = getline(line('.')-1)[-1:]
  let schar = matchstr(getline(line('.')+1), '^\s*\zs\S')
  let isEmpty = a:0 ? getline('.') =~ '^\s*$' : empty(getline('.'))
  if index(s:get('left_delims'), nchar) > -1
        \ && index(s:get('left_delims'), nchar)
        \    == index(s:get('right_delims'), schar)
        \ && isEmpty
    return 1
  elseif index(s:get('quotes_list'), nchar) > -1
        \ && index(s:get('quotes_list'), nchar)
        \    == index(s:get('quotes_list'), schar)
        \ && isEmpty
    return 1
  else
    return 0
  endif
endfunction " }}} s:is_cr_expansion()

function! s:is_space_expansion() " {{{
  if col('.') > 2
    let pchar = s:get_char(-2)
    let nchar = s:get_char(1)
    let isSpaces =
          \ (s:get_char(-1)
          \   == s:get_char(0)
          \ && s:get_char(-1) == " ")

    if index(s:get('left_delims'), pchar) > -1 &&
        \ index(s:get('left_delims'), pchar)
        \   == index(s:get('right_delims'), nchar) &&
        \ isSpaces
      return 1
    elseif index(s:get('quotes_list'), pchar) > -1 &&
        \ index(s:get('quotes_list'), pchar)
        \   == index(s:get('quotes_list'), nchar) &&
        \ isSpaces
      return 1
    endif
  endif
  return 0
endfunction " }}} IsSpaceExpansion()

function! s:is_empty_matchpair() "{{{
  " get char before the cursor.
  let open = s:get_char(-1)
  let idx = index(s:get('left_delims'), open)
  if idx == -1
    return 0
  endif
  let close = get(s:get('right_delims'), idx, '')
  return close ==# s:get_char(0)
endfunction "}}}

function! s:is_empty_quotes() "{{{
  " get char before the cursor.
  let quote = s:get_char(-1)
  let idx = index(s:get('quotes_list'), quote)
  if idx == -1
    return 0
  endif
  return quote ==# s:get_char(0)
endfunction "}}}

function! s:cursor_idx() "{{{
  let idx = len(split(getline('.')[: col('.') - 1], '\zs')) - 1
  return idx
endfunction "delimitMate#CursorCol }}}

function! s:get_syn_name() "{{{
  let col = col('.')
  if  col == col('$')
    let col = col - 1
  endif
  return synIDattr(synIDtrans(synID(line('.'), col, 1)), 'name')
endfunction " }}}

function! s:is_excluded_ft(ft) "{{{
  if !exists("g:delimitMate_excluded_ft")
    return 0
  endif
  return index(split(g:delimitMate_excluded_ft, ','), a:ft, 0, 1) >= 0
endfunction "}}}

function! s:is_forbidden(char) "{{{
  if s:is_excluded_ft(&filetype)
    return 1
  endif
  if !s:get('excluded_regions_enabled')
    return 0
  endif
  let region = s:get_syn_name()
  return index(s:get('excluded_regions_list'), region) >= 0
endfunction "}}}

function! s:balance_matchpairs(char) "{{{
  " Returns:
  " = 0 => Parens balanced.
  " > 0 => More opening parens.
  " < 0 => More closing parens.

  let line = getline('.')
  let col = s:cursor_idx() - 1
  let col = col >= 0 ? col : 0
  let list = split(line, '\zs')
  let left = s:get('left_delims')[index(s:get('right_delims'), a:char)]
  let right = a:char
  let opening = 0
  let closing = 0

  " If the cursor is not at the beginning, count what's behind it.
  if col > 0
      " Find the first opening paren:
      let start = index(list, left)
      " Must be before cursor:
      let start = start < col ? start : col - 1
      " Now count from the first opening until the cursor, this will prevent
      " extra closing parens from being counted.
      let opening = count(list[start : col - 1], left)
      let closing = count(list[start : col - 1], right)
      " I don't care if there are more closing parens than opening parens.
      let closing = closing > opening ? opening : closing
  endif

  " Evaluate parens from the cursor to the end:
  let opening += count(list[col :], left)
  let closing += count(list[col :], right)

  " Return the found balance:
  return opening - closing
endfunction "}}}

function! s:is_smart_quote(char) "{{{
  " TODO: Allow using a:char in the pattern.
  let tmp = s:get('smart_quotes')
  if empty(tmp)
    return 0
  endif
  let regex = matchstr(tmp, '^!\?\zs.*')
  " Flip matched value if regex starts with !
  let mod = tmp =~ '^!' ? [1, 0] : [0, 1]
  let matched = search(regex, 'ncb', line('.')) > 0
  let noescaped = substitute(getline('.'), '\\.', '', 'g')
  let odd =  (count(split(noescaped, '\zs'), a:char) % 2)
  let result = mod[matched] || odd
  return result
endfunction "delimitMate#SmartQuote }}}

function! delimitMate#Set(...) "{{{
  return call('s:set', a:000)
endfunction "}}}

function! delimitMate#Get(...) "{{{
  return call('s:get', a:000)
endfunction "}}}

function! delimitMate#ShouldJump(...) "{{{
  return call('s:is_jump', a:000)
endfunction "}}}

function! delimitMate#IsEmptyPair(str) "{{{
  if strlen(substitute(a:str, ".", "x", "g")) != 2
    return 0
  endif
  let idx = index(s:get('left_delims'), matchstr(a:str, '^.'))
  if idx > -1 &&
        \ s:get('right_delims')[idx] == matchstr(a:str, '.$')
    return 1
  endif
  let idx = index(s:get('quotes_list'), matchstr(a:str, '^.'))
  if idx > -1 &&
        \ s:get('quotes_list')[idx] == matchstr(a:str, '.$')
    return 1
  endif
  return 0
endfunction "}}}

function! delimitMate#WithinEmptyPair() "{{{
  " if cursor is at column 1 return 0
  if col('.') == 1
    return 0
  endif
  " get char before the cursor.
  let char1 = s:get_char(-1)
  " get char under the cursor.
  let char2 = s:get_char(0)
  return delimitMate#IsEmptyPair( char1.char2 )
endfunction "}}}

function! delimitMate#SkipDelim(char) "{{{
  if s:is_forbidden(a:char)
    return a:char
  endif
  let col = col('.') - 1
  let line = getline('.')
  if col > 0
    let cur = s:get_char(0)
    let pre = s:get_char(-1)
  else
    let cur = s:get_char(0)
    let pre = ""
  endif
  if pre == "\\"
    " Escaped character
    return a:char
  elseif cur == a:char
    " Exit pair
    return a:char . "\<Del>"
  elseif delimitMate#IsEmptyPair( pre . a:char )
    " Add closing delimiter and jump back to the middle.
    return a:char . s:joinUndo() . "\<Left>"
  else
    " Nothing special here, return the same character.
    return a:char
  endif
endfunction "}}}

function! delimitMate#ParenDelim(right) " {{{
  let left = s:get('left_delims')[index(s:get('right_delims'),a:right)]
  if s:is_forbidden(a:right)
    return left
  endif
  " Try to balance matchpairs
  if s:get('balance_matchpairs') &&
        \ s:balance_matchpairs(a:right) < 0
    return left
  endif
  let line = getline('.')
  let col = col('.')-2
  if s:get('smart_matchpairs') != ''
    let smart_matchpairs = substitute(s:get('smart_matchpairs'), '\\!', left, 'g')
    let smart_matchpairs = substitute(smart_matchpairs, '\\#', a:right, 'g')
    if line[col+1:] =~ smart_matchpairs
      return left
    endif
  endif
  if len(line) == (col + 1) && s:get('insert_eol_marker') == 1
    let tail = s:get('eol_marker')
  else
    let tail = ''
  endif
  return left . a:right . tail . repeat(s:joinUndo() . "\<Left>", len(split(tail, '\zs')) + 1)
endfunction " }}}

function! delimitMate#QuoteDelim(char) "{{{
  if s:is_forbidden(a:char)
    return a:char
  endif
  let char_at = s:get_char(0)
  let char_before = s:get_char(-1)
  let nesting_on = index(s:get('nesting_quotes'), a:char) > -1
  let left_q = nesting_on ? s:lquote(a:char) : 0
  if nesting_on && left_q > 1
    " Nesting quotes.
    let right_q =  s:rquote(a:char)
    let quotes = right_q > left_q + 1 ? 0 : left_q - right_q + 2
    let lefts = quotes - 1
    return repeat(a:char, quotes) . repeat(s:joinUndo() . "\<Left>", lefts)
  elseif char_at == a:char
    " Inside an empty pair, jump out
    return a:char . "\<Del>"
  elseif a:char == '"' && index(split(&ft, '\.'), "vim") != -1 && getline('.') =~ '^\s*$'
    " If we are in a vim file and it looks like we're starting a comment, do
    " not add a closing char.
    return a:char
  elseif s:is_smart_quote(a:char)
    " Seems like a smart quote, insert a single char.
    return a:char
  elseif (char_before == a:char && char_at != a:char)
        \ && !empty(s:get('smart_quotes'))
    " Seems like we have an unbalanced quote, insert one quotation
    " mark and jump to the middle.
    return a:char . s:joinUndo() . "\<Left>"
  else
    " Insert a pair and jump to the middle.
    let sufix = ''
    if !empty(s:get('eol_marker')) && col('.') - 1 == len(getline('.'))
      let idx = len(s:get('eol_marker')) * -1
      let marker = getline('.')[idx : ]
      let has_marker = marker == s:get('eol_marker')
      let sufix = !has_marker ? s:get('eol_marker') : ''
    endif
    return a:char . a:char . s:joinUndo() . "\<Left>"
  endif
endfunction "}}}

function! delimitMate#JumpOut(char) "{{{
  if s:is_forbidden(a:char)
    return a:char
  endif
  let jump = s:is_jump(a:char)
  if jump == 1
    " HACK: Instead of <Right>, we remove the char to be jumped over and
    " insert it again. This will trigger re-indenting via 'indentkeys'.
    " Ref: https://github.com/Raimondi/delimitMate/issues/168
    return "\<Del>".a:char
  elseif jump == 3
    return s:joinUndo() . "\<Right>" . s:joinUndo() . "\<Right>"
  elseif jump == 5
    return "\<Down>\<C-O>I" . s:joinUndo() . "\<Right>"
  else
    return a:char
  endif
endfunction " }}}

function! delimitMate#JumpAny(...) " {{{
  if s:is_forbidden('')
    return ''
  endif
  if !s:is_jump()
    return ''
  endif
  " Let's get the character on the right.
  let char = s:get_char(0)
  if char == " "
    " Space expansion.
    return s:joinUndo() . "\<Right>" . s:joinUndo() . "\<Right>"
  elseif char == ""
    " CR expansion.
    return "\<CR>" . getline(line('.') + 1)[0] . "\<Del>\<Del>"
  else
    return s:joinUndo() . "\<Right>"
  endif
endfunction " delimitMate#JumpAny() }}}

function! delimitMate#JumpMany() " {{{
  let line = split(getline('.')[col('.') - 1 : ], '\zs')
  let rights = ""
  let found = 0
  for char in line
    if index(s:get('quotes_list'), char) >= 0 ||
          \ index(s:get('right_delims'), char) >= 0
      let rights .= s:joinUndo() . "\<Right>"
      let found = 1
    elseif found == 0
      let rights .= s:joinUndo() . "\<Right>"
    else
      break
    endif
  endfor
  if found == 1
    return rights
  else
    return ''
  endif
endfunction " delimitMate#JumpMany() }}}

function! delimitMate#ExpandReturn() "{{{
  if s:is_forbidden("")
    return "\<CR>"
  endif
  let escaped = s:cursor_idx() >= 2
        \ && s:get_char(-2) == '\'
  let expand_right_matchpair = s:get('expand_cr') == 2
        \     && index(s:get('right_delims'), s:get_char(0)) > -1
  let expand_inside_quotes = s:get('expand_inside_quotes')
          \     && s:is_empty_quotes()
          \     && !escaped
  let is_empty_matchpair = s:is_empty_matchpair()
  if !pumvisible(  )
        \ && (   is_empty_matchpair
        \     || expand_right_matchpair
        \     || expand_inside_quotes)
    let val = "\<Esc>a"
    if is_empty_matchpair && s:get('insert_eol_marker') == 2
          \ && !search(escape(s:get('eol_marker'), '[]\.*^$').'$', 'cnW', '.')
      let tail = getline('.')[col('.') - 1 : ]
      let times = len(split(tail, '\zs'))
      let val .= repeat(s:joinUndo() . "\<Right>", times) . s:get('eol_marker') . repeat(s:joinUndo() . "\<Left>", times + 1)
    endif
    let val .= "\<CR>"
    if &smartindent && !&cindent && !&indentexpr
          \ && s:get_char(0) == '}'
      " indentation is controlled by 'smartindent', and the first character on
      " the new line is '}'. If this were typed manually it would reindent to
      " match the current line. Let's reproduce that behavior.
      let shifts = indent('.') / &sw
      let spaces = indent('.') - (shifts * &sw)
      let val .= "^\<C-D>".repeat("\<C-T>", shifts).repeat(' ', spaces)
    endif
    " Expand:
    " XXX zv prevents breaking expansion with syntax folding enabled by
    " InsertLeave.
    let val .= "\<Esc>zvO"
    return val
  else
    return "\<CR>"
  endif
endfunction "}}}

function! delimitMate#ExpandSpace() "{{{
  if s:is_forbidden("\<Space>")
    return "\<Space>"
  endif
  let escaped = s:cursor_idx() >= 2
        \ && s:get_char(-2) == '\'
  let expand_inside_quotes = s:get('expand_inside_quotes')
          \     && s:is_empty_quotes()
          \     && !escaped
  if s:is_empty_matchpair() || expand_inside_quotes
    " Expand:
    return "\<Space>\<Space>" . s:joinUndo() . "\<Left>"
  else
    return "\<Space>"
  endif
endfunction "}}}

function! delimitMate#BS() " {{{
  if s:is_forbidden("")
    let extra = ''
  elseif &bs !~ 'start\|2'
    let extra = ''
  elseif delimitMate#WithinEmptyPair()
    let extra = "\<Del>"
  elseif s:is_space_expansion()
    let extra = "\<Del>"
  elseif s:is_cr_expansion()
    let extra = repeat("\<Del>",
          \ len(matchstr(getline(line('.') + 1), '^\s*\S')))
  else
    let extra = ''
  endif
  return "\<BS>" . extra
endfunction " }}} delimitMate#BS()

function! delimitMate#Test() "{{{
  %d _
  " Check for script options:
  let result = [
        \ 'delimitMate Report',
        \ '==================',
        \ '',
        \ '* Options: ( ) default, (g) global, (b) buffer',
        \ '']
  for option in sort(keys(s:options[bufnr('%')]))
    if s:exists(option, 'b')
      let scope = '(b)'
    elseif s:exists(option, 'g')
      let scope = '(g)'
    else
      let scope = '( )'
    endif
    call add(result,
          \ scope . ' delimitMate_' . option
          \ . ' = '
          \ . string(s:get(option)))
  endfor
  call add(result, '')

  let option = 'delimitMate_excluded_ft'
  call add(result,
        \(exists('g:'.option) ? '(g) ' : '( ) g:') . option . ' = '
        \. string(get(g:, option, '')))

  call add(result, '--------------------')
  call add(result, '')

  " Check if mappings were set.
  let left_delims = s:get('autoclose') ? s:get('left_delims') : []
  let special_keys = ['<BS>', '<S-BS>', '<S-Tab>', '<C-G>g']
  if s:get('expand_cr')
    call add(special_keys, '<CR>')
  endif
  if s:get('expand_space')
    call add(special_keys, '<Space>')
  endif
  let maps =
        \ s:get('right_delims')
        \ + left_delims
        \ + s:get('quotes_list')
        \ + s:get('apostrophes_list')
        \ + special_keys

  call add(result, '* Mappings:')
  call add(result, '')
  for map in maps
    let output = ''
    if map == '|'
      let map = '<Bar>'
    endif
    redir => output | execute "verbose imap ".map | redir END
    call extend(result, split(output, '\n'))
  endfor

  call add(result, '--------------------')
  call add(result, '')
  call add(result, '* Showcase:')
  call add(result, '')
  call setline(1, result)
  call s:test_mappings(s:get('left_delims'), 1)
  call s:test_mappings(s:get('quotes_list'), 0)

  let result = []
  redir => setoptions
  echo " * Vim configuration:\<NL>"
  filetype
  echo ""
  set
  version
  redir END
  call extend(result, split(setoptions,"\n"))
  call add(result, '--------------------')
  setlocal nowrap
  call append('$', result)
  call feedkeys("\<Esc>\<Esc>", 'n')
endfunction "}}}

function! s:test_mappings(list, is_matchpair) "{{{
  let prefix = "normal Go0\<C-D>"
  let last = "|"
  let open = s:get('autoclose') ? 'Open: ' : 'Open & close: '
  for s in a:list
    if a:is_matchpair
      let pair = s:get('right_delims')[index(s:get('left_delims'), s)]
    else
      let pair = s
    endif
    if !s:get('autoclose')
      let s .= pair
    endif
    exec prefix . open . s . last
    exec prefix . "Delete: " . s . "\<BS>" . last
    exec prefix . "Exit: " . s . pair . last
    if s:get('expand_space')
          \ && (a:is_matchpair || s:get('expand_inside_quotes'))
      exec prefix . "Space: " . s . " " . last
      exec prefix . "Delete space: " . s . " \<BS>" . last
    endif
    if s:get('expand_cr')
          \ && (a:is_matchpair || s:get('expand_inside_quotes'))
      exec prefix . "Car return: " . s . "\<CR>" . last
      exec prefix . "Delete car return: " . s . "\<CR>0\<C-D>\<BS>" . last
    endif
    call append('$', '')
  endfor
endfunction "}}}

function! s:joinUndo() "{{{
  if v:version < 704
        \ || ( v:version == 704 && !has('patch849') )
    return ''
  endif
  return "\<C-G>U"
endfunction "}}}

" vim:foldmethod=marker:foldcolumn=4:ts=2:sw=2
doc/delimitMate.txt	[[[1
943
*delimitMate.txt*   Trying to keep those beasts at bay! v2.7     *delimitMate*



  MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
  MMMM  MMMMMMMMM  MMMMMMMMMMMMMMMMMMMMMMMMMM  MMMMM  MMMMMMMMMMMMMMMMMMMMM  ~
  MMMM  MMMMMMMMM  MMMMMMMMMMMMMMMMMMMMMMMMMM   MMM   MMMMMMMMMMMMMMMMMMMMM
  MMMM  MMMMMMMMM  MMMMMMMMMMMMMMMMMMMMM  MMM  M   M  MMMMMMMMMM  MMMMMMMMM  ~
  MMMM  MMM   MMM  MM  MM  M  M MMM  MM    MM  MM MM  MMM   MMM    MMM   MM
  MM    MM  M  MM  MMMMMM        MMMMMMM  MMM  MMMMM  MM  M  MMM  MMM  M  M  ~
  M  M  MM     MM  MM  MM  M  M  MM  MMM  MMM  MMMMM  MMMMM  MMM  MMM     M
  M  M  MM  MMMMM  MM  MM  M  M  MM  MMM  MMM  MMMMM  MMM    MMM  MMM  MMMM  ~
  M  M  MM  M  MM  MM  MM  M  M  MM  MMM  MMM  MMMMM  MM  M  MMM  MMM  M  M
  MM    MMM   MMM  MM  MM  M  M  MM  MMM   MM  MMMMM  MMM    MMM   MMM   MM  ~
  MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM



==============================================================================
 0.- CONTENTS                                           *delimitMate-contents*

    1. Introduction____________________________|delimitMateIntro|
    2. Customization___________________________|delimitMateOptions|
        2.1 Options summary____________________|delimitMateOptionSummary|
        2.2 Options details____________________|delimitMateOptionDetails|
    3. Functionality___________________________|delimitMateFunctionality|
        3.1 Automatic closing & exiting________|delimitMateAutoClose|
        3.2 Expansion of space and CR__________|delimitMateExpansion|
        3.3 Backspace__________________________|delimitMateBackspace|
        3.4 Smart Quotes_______________________|delimitMateSmartQuotes|
        3.5 Balancing matching pairs___________|delimitMateBalance|
        3.6 FileType based configuration_______|delimitMateFileType|
        3.7 Syntax awareness___________________|delimitMateSyntax|
    4. Commands________________________________|delimitMateCommands|
    5. Mappings________________________________|delimitMateMappings|
    6. Functions_______________________________|delimitMateFunctions|
    7. Autocommands____________________________|delimitMateAutocmds|
    8. TODO list_______________________________|delimitMateTodo|
    9. Maintainer______________________________|delimitMateMaintainer|
   10. Credits_________________________________|delimitMateCredits|
   11. History_________________________________|delimitMateHistory|

==============================================================================
 1.- INTRODUCTION                                           *delimitMateIntro*

This plug-in provides automatic closing of quotes, parenthesis, brackets,
etc.; besides some other related features that should make your time in insert
mode a little bit easier.

Most of the features can be modified or disabled permanently, using global
variables, or on a FileType basis, using autocommands.

NOTE 1: If you have any trouble with this plugin, please run |:DelimitMateTest|
in a new buffer to see what is not working.

NOTE 2: Abbreviations set with |:iabbrev| will not be expanded by delimiters
used on delimitMate, you should use <C-]> (read |i_CTRL-]|) to expand them on
the go.

==============================================================================
 2. CUSTOMIZATION                                         *delimitMateOptions*

You can create your own mappings for some features using the global functions.
Read |delimitMateFunctions| for more info.

------------------------------------------------------------------------------
   2.1 OPTIONS SUMMARY                              *delimitMateOptionSummary*

The behaviour of this script can be customized setting the following options
in your vimrc file. You can use local options to set the configuration for
specific file types, see |delimitMateOptionDetails| for examples.

|'loaded_delimitMate'|            Turns off the script.

|'delimitMate_autoclose'|         Tells delimitMate whether to automagically
                                insert the closing delimiter.

|'delimitMate_matchpairs'|        Tells delimitMate which characters are
                                matching pairs.

|'delimitMate_quotes'|            Tells delimitMate which quotes should be
                                used.

|'delimitMate_nesting_quotes'|    Tells delimitMate which quotes should be
                                allowed to be nested.

|'delimitMate_expand_cr'|         Turns on/off the expansion of <CR>.

|'delimitMate_expand_space'|      Turns on/off the expansion of <Space>.

|'delimitMate_jump_expansion'|    Turns on/off jumping over expansions.

|'delimitMate_smart_quotes'|      Turns on/off the "smart quotes" feature.

|'delimitMate_smart_matchpairs'|  Turns on/off the "smart matchpairs" feature.

|'delimitMate_balance_matchpairs'|Turns on/off the "balance matching pairs"
                                feature.

|'delimitMate_excluded_regions'|  Turns off the script for the given regions or
                                syntax group names.

|'delimitMate_excluded_ft'|       Turns off the script for the given file types.

|'delimitMate_eol_marker'|        Determines what to insert after the closing
                                matchpair when typing an opening matchpair on
                                the end of the line.

|'delimitMate_apostrophes'|       Tells delimitMate how it should "fix"
                                balancing of single quotes when used as
                                apostrophes. NOTE: Not needed any more, kept
                                for compatibility with older versions.

------------------------------------------------------------------------------
   2.2 OPTIONS DETAILS                              *delimitMateOptionDetails*

Add the shown lines to your vimrc file in order to set the below options.
Buffer variables take precedence over global ones and can be used along with
autocmd to modify delimitMate's behavior for specific file types, read more in
|delimitMateFileType|.

Note: Use buffer variables only to set options for specific file types using
:autocmd, use global variables to set options for all buffers. Read more in
|g:var| and |b:var|.

------------------------------------------------------------------------------
                                                        *'loaded_delimitMate'*
                                                      *'b:loaded_delimitMate'*
This option prevents delimitMate from loading.
e.g.: >
        let loaded_delimitMate = 1
        au FileType mail let b:loaded_delimitMate = 1
<
------------------------------------------------------------------------------
                                                  *'delimitMate_offByDefault'*
Values: 0 or 1.~
Default: 0~

If this option is set to 1, delimitMate will load, but will not take
effect in any buffer unless |:DelimitMateSwitch| is called in that
buffer.

------------------------------------------------------------------------------
                                                     *'delimitMate_autoclose'*
                                                   *'b:delimitMate_autoclose'*
Values: 0 or 1.                                                              ~
Default: 1                                                                   ~

If this option is set to 0, delimitMate will not add a closing delimiter
automagically. See |delimitMateAutoClose| for details.
e.g.: >
        let delimitMate_autoclose = 0
        au FileType mail let b:delimitMate_autoclose = 0
<
------------------------------------------------------------------------------
                                                    *'delimitMate_matchpairs'*
                                                  *'b:delimitMate_matchpairs'*
Values: A string with |'matchpairs'| syntax, plus support for multi-byte~
        characters.~
Default: &matchpairs                                                         ~

Use this option to tell delimitMate which characters should be considered
matching pairs. Read |delimitMateAutoClose| for details.
e.g: >
        let delimitMate_matchpairs = "(:),[:],{:},<:>"
        au FileType vim,html let b:delimitMate_matchpairs = "(:),[:],{:},<:>"
<
------------------------------------------------------------------------------
                                                        *'delimitMate_quotes'*
                                                      *'b:delimitMate_quotes'*
Values: A string of characters separated by spaces.                          ~
Default: "\" ' `"                                                            ~

Use this option to tell delimitMate which characters should be considered as
quotes. Read |delimitMateAutoClose| for details.
e.g.: >
        let delimitMate_quotes = "\" ' ` *"
        au FileType html let b:delimitMate_quotes = "\" '"
<
------------------------------------------------------------------------------
                                                *'delimitMate_nesting_quotes'*
                                              *'b:delimitMate_nesting_quotes'*
Values: A list of quotes.                                                    ~
Default: []                                                                  ~

When adding a third quote listed in this option is inserted, three quotes will
be inserted to the right of the cursor and the cursor will stay in the middle.
If more quotes are inserted the number of quotes on both sides of the cursor
will stay balanced.
e.g.: >
        let delimitMate_nesting_quotes = ['"','`']
        au FileType python let b:delimitMate_nesting_quotes = ['"']
<
------------------------------------------------------------------------------
                                                     *'delimitMate_expand_cr'*
                                                   *'b:delimitMate_expand_cr'*
Values: 0, 1 or 2                                                             ~
Default: 0                                                                   ~

This option turns on/off the expansion of <CR>. Read |delimitMateExpansion|
for details. NOTE This feature requires that 'backspace' is either set to 2 or
has "eol" and "start" as part of its value.
e.g.: >
        let delimitMate_expand_cr = 1
        au FileType mail let b:delimitMate_expand_cr = 1
<
------------------------------------------------------------------------------
                                                  *'delimitMate_expand_space'*
                                                *'b:delimitMate_expand_space'*
Values: 1 or 0                                                               ~
Default: 0                                                                   ~
This option turns on/off the expansion of <Space>. Read |delimitMateExpansion|
for details.
e.g.: >
        let delimitMate_expand_space = 1
        au FileType tcl let b:delimitMate_expand_space = 1
<
------------------------------------------------------------------------------
                                          *'delimitMate_expand_inside_quotes'*
                                        *'b:delimitMate_expand_inside_quotes'*
Values: 1 or 0                                                                ~
Default: 0                                                                   ~
When this option is set to 1 the expansion of space and cr will also be
applied to quotes. Read |delimitMateExpansion| for details.

e.g.: >
        let delimitMate_expand_inside_quotes = 1
        au FileType mail let b:delimitMate_expand_inside_quotes = 1
<
------------------------------------------------------------------------------
                                                *'delimitMate_jump_expansion'*
                                              *'b:delimitMate_jump_expansion'*
Values: 1 or 0                                                               ~
Default: 0                                                                   ~
This option turns on/off the jumping over <CR> and <Space> expansions when
inserting closing matchpairs. Read |delimitMateExpansion| for details.
e.g.: >
        let delimitMate_jump_expansion = 1
        au FileType tcl let b:delimitMate_jump_expansion = 1
<
------------------------------------------------------------------------------
                                                  *'delimitMate_smart_quotes'*
                                                *'b:delimitMate_smart_quotes'*
Values: String with an optional !  at the beginning followed by a regexp     ~
Default:~
'\%(\w\|[^[:punct:][:space:]]\|\%(\\\\\)*\\\)\%#\|\%#\%(\w\|[^[:space:][:punct:]]\)'                  ~

A bang (!) at the beginning is removed and used to "negate" the pattern. The
remaining text is used as a regexp to be matched on the current line. A single
quote is inserted when the pattern matches and a bang is not present. The bang
changes that, so a single quote is inserted only if the regexp does not match.

This feature is disabled when the variable is set to an empty string, with the
exception of apostrophes.

Note that you need to use '\%#' to match the position of the cursor.  Keep in
mind that '\%#' matches with zero width, so if you need to match the char
under the cursor (which would be the one to the right on insert mode) use
something like '\%#.'.

e.g.: >
        let delimitMate_smart_quotes = '\w\%#'
        au FileType tcl let b:delimitMate_smart_quotes = '!\s\%#\w'
<
------------------------------------------------------------------------------
                                              *'delimitMate_smart_matchpairs'*
                                            *'b:delimitMate_smart_matchpairs'*
Values: Regexp                                                               ~
Default: '^\%(\w\|\!\|[£$]\|[^[:space:][:punct:]]\)'                                ~

This regex is matched against the text to the right of cursor, if it's not
empty and there is a match delimitMate will not autoclose the pair. At the
moment to match the text, an escaped bang (\!) in the regex will be replaced
by the character being inserted, while an escaped number symbol (\#) will be
replaced by the closing pair.
e.g.: >
        let delimitMate_smart_matchpairs = ''
        au FileType tcl let b:delimitMate_smart_matchpairs = '^\%(\w\|\$\)'
<
------------------------------------------------------------------------------
                                            *'delimitMate_balance_matchpairs'*
                                          *'b:delimitMate_balance_matchpairs'*
Values: 1 or 0                                                               ~
Default: 0                                                                   ~

This option turns on/off the balancing of matching pairs. Read
|delimitMateBalance| for details.
e.g.: >
        let delimitMate_balance_matchpairs = 1
        au FileType tcl let b:delimitMate_balance_matchpairs = 1
<
------------------------------------------------------------------------------
                                              *'delimitMate_excluded_regions'*
Values: A string of syntax group names names separated by single commas.     ~
Default: Comment                                                             ~

This options turns delimitMate off for the listed regions, read |group-name|
for more info about what is a region.
e.g.: >
        let delimitMate_excluded_regions = "Comment,String"
<
------------------------------------------------------------------------------
                                                   *'delimitMate_excluded_ft'*
Values: A string of file type names separated by single commas.              ~
Default: Empty.                                                              ~

This options turns delimitMate off for the listed file types, use this option
only if you don't want any of the features it provides on those file types.
e.g.: >
        let delimitMate_excluded_ft = "mail,txt"
<
------------------------------------------------------------------------------
                                             *'delimitMate_insert_eol_marker'*
Values: Integer                                                              ~
Default: 1                                                              ~

Whether to insert the eol marker (EM) or not. The EM is inserted following
rules:

0 -> never
1 -> when inserting any matchpair
2 -> when expanding car return in matchpair

e.g.: >
        au FileType c,perl let b:delimitMate_insert_eol_marker = 2
<
------------------------------------------------------------------------------
                                                    *'delimitMate_eol_marker'*
Values: String.                                                              ~
Default: Empty.                                                              ~

The contents of this string will be inserted after the closing matchpair or
quote when the respective opening matchpair or quote is inserted at the end
of the line.
e.g.: >
        au FileType c,perl let b:delimitMate_eol_marker = ";"
<
------------------------------------------------------------------------------
                                                   *'delimitMate_apostrophes'*
Values: Strings separated by ":".                                            ~
Default: No longer used.                                                     ~

NOTE: This feature is turned off by default, it's been kept for compatibility
with older version, read |delimitMateSmartQuotes| for details.
If auto-close is enabled, this option tells delimitMate how to try to fix the
balancing of single quotes when used as apostrophes. The values of this option
are strings of text where a single quote would be used as an apostrophe (e.g.:
the "n't" of wouldn't or can't) separated by ":". Set it to an empty string to
disable this feature.
e.g.: >
        let delimitMate_apostrophes = ""
        au FileType tcl let delimitMate_apostrophes = ""
<
==============================================================================
 3. FUNCTIONALITY                                   *delimitMateFunctionality*

------------------------------------------------------------------------------
   3.1 AUTOMATIC CLOSING AND EXITING                    *delimitMateAutoClose*

With automatic closing enabled, if an opening delimiter is inserted the plugin
inserts the closing delimiter and places the cursor between the pair. With
automatic closing disabled, no closing delimiters is inserted by delimitMate,
but when a pair of delimiters is typed, the cursor is placed in the middle.

When the cursor is inside an empty pair or located next to the left of a
closing delimiter, the cursor is placed outside the pair to the right of the
closing delimiter.

When |'delimitMate_smart_matchpairs'| is not empty and it matches the text to
the right of the cursor, delimitMate will not automatically insert the closing
pair.

Unless |'delimitMate_matchpairs'| or |'delimitMate_quotes'| are set, this
script uses the values in '&matchpairs' to identify the pairs, and ", ' and `
for quotes respectively.

<S-Tab> will jump over a single closing delimiter or quote, <C-G>g will jump
over contiguous delimiters and/or quotes.

The following table shows the behaviour, this applies to quotes too (the final
position of the cursor is represented by a "|"):

With auto-close: >
                          Type     |  You get
                        =======================
                           (       |    (|)
                        -----------|-----------
                           ()      |    ()|
                        -----------|-----------
                        (<S-Tab>   |    ()|
                        -----------|-----------
                        {("<C-G>g  |  {("")}|
<
Without auto-close: >

                          Type        |  You get
                        =========================
                           ()         |    (|)
                        --------------|----------
                           ())        |    ()|
                        --------------|----------
                        ()<S-Tab>     |    ()|
                        --------------|----------
                        {}()""<C-G>g  |  {("")}|
<
NOTE: Abbreviations will not be expanded by delimiters used on delimitMate,
you should use <C-]> (read |i_CTRL-]|) to expand them on the go.

------------------------------------------------------------------------------
   3.2 EXPANSION OF SPACE AND CAR RETURN                *delimitMateExpansion*

When the cursor is inside an empty pair of any matchpair, <Space> and <CR> can be
expanded, see |'delimitMate_expand_space'| and
|'delimitMate_expand_cr'|:

Expand <Space> to: >

                    You start with  |  You get
                  ==============================
                        (|)         |    ( | )
<
Expand <CR> to: >

                   You start with   |  You get
                  ==============================
                        (|)         |    (
                                    |      |
                                    |    )
<

When you have |'delimitMate_jump_expansion'| enabled, if there is an existing
closing paren/bracket/etc. on the next line, delimitMate will make the cursor
jump over any whitespace/<CR> and place it after the existing closing
delimiter instead of inserting a new one.

When |'delimitMate_expand_cr'| is set to 2, the following will also happen: >

                    You start with  |  You get
                  ==============================
                       (foo|)       |    (foo
                                    |      |
                                    |    )
<

Since <Space> and <CR> are used everywhere, I have made the functions involved
in expansions global, so they can be used to make custom mappings. Read
|delimitMateFunctions| for more details.

------------------------------------------------------------------------------
   3.3 BACKSPACE                                        *delimitMateBackspace*

If you press backspace inside an empty pair, both delimiters are deleted. When
expansions are enabled, <BS> will also delete the expansions.

If you type <S-BS> (shift + backspace) instead, only the closing delimiter
will be deleted. NOTE that this will not usually work when using Vim from the
terminal, see 'delimitMate#JumpAny()' below to see how to fix it.

e.g. typing at the "|": >

                  What  |      Before       |      After
               ==============================================
                  <BS>  |  call expand(|)   |  call expand|
               ---------|-------------------|-----------------
                  <BS>  |  call expand( | ) |  call expand(|)
               ---------|-------------------|-----------------
                  <BS>  |  call expand(     |  call expand(|)
                        |  |                |
                        |  )                |
               ---------|-------------------|-----------------
                 <S-BS> |  call expand(|)   |  call expand(|
<

------------------------------------------------------------------------------
   3.4 SMART QUOTES                                   *delimitMateSmartQuotes*

Only one quote will be inserted following a quote, a "\", following or
preceding a keyword character, or when the number of quotes in the current
line is odd. This should cover closing quotes after a string, opening quotes
before a string, escaped quotes and apostrophes. See more details about
customizing this feature on |'delimitMate_smart_quotes'|.

e.g. typing at the "|": >

                     What |    Before    |     After
                  =======================================
                      "   |  Text |      |  Text "|"
                      "   |  "String|    |  "String"|
                      "   |  let i = "|  |  let i = "|"
                      'm  |  I|          |  I'm|
<
------------------------------------------------------------------------------
   3.4 SMART MATCHPAIRS                           *delimitMateSmartMatchpairs*

This is similar to "smart quotes", but applied to the characters in
|'delimitMate_matchpairs'|. The difference is that delimitMate will not
auto-close the pair when the regex matches the text on the right of the
cursor. See |'delimitMate_smart_matchpairs'| for more details.


e.g. typing at the "|": >

                     What |    Before    |     After
                  =======================================
                      (   |  function|   |  function(|)
                      (   |  |var        |  (|var
<
------------------------------------------------------------------------------
   3.5 BALANCING MATCHING PAIRS                           *delimitMateBalance*

When inserting an opening paren and |'delimitMate_balance_matchpairs'| is
enabled, delimitMate will try to balance the closing pairs in the current
line.

e.g. typing at the "|": >

                     What |    Before    |     After
                  =======================================
                      (   |      |       |     (|)
                      (   |      |)      |     (|)
                      ((  |      |)      |    ((|))
<
------------------------------------------------------------------------------
   3.6 FILE TYPE BASED CONFIGURATION                     *delimitMateFileType*

delimitMate options can be set globally for all buffers using global
("regular") variables in your |vimrc| file. But |:autocmd| can be used to set
options for specific file types (see |'filetype'|) using buffer variables in
the following way: >

   au FileType mail,text let b:delimitMate_autoclose = 0
         ^       ^           ^            ^            ^
         |       |           |            |            |
         |       |           |            |            - Option value.
         |       |           |            - Option name.
         |       |           - Buffer variable.
         |       - File types for which the option will be set.
         - Don't forget to put this event.
<
NOTE that you should use buffer variables (|b:var|) only to set options with
|:autocmd|, for global options use regular variables (|g:var|) in your vimrc.

------------------------------------------------------------------------------
   3.7 SYNTAX AWARENESS                                    *delimitMateSyntax*

The features of this plug-in might not be always helpful, comments and strings
usualy don't need auto-completion. delimitMate monitors which region is being
edited and if it detects that the cursor is in a comment it'll turn itself off
until the cursor leaves the comment. The excluded regions can be set using the
option |'delimitMate_excluded_regions'|. Read |group-name| for a list of
regions or syntax group names.

NOTE that this feature relies on a proper syntax file for the current file
type, if the appropiate syntax file doesn't define a region, delimitMate won't
know about it.

==============================================================================
 4. COMMANDS                                             *delimitMateCommands*

------------------------------------------------------------------------------
:DelimitMateReload                                        *:DelimitMateReload*

Re-sets all the mappings used for this script, use it if any option has been
changed or if the filetype option hasn't been set yet.

------------------------------------------------------------------------------
:DelimitMateOn                                                *:DelimitMateOn*

Enable delimitMate mappings.

------------------------------------------------------------------------------
:DelimitMateOff                                              *:DelimitMateOff*

Disable delimitMate mappings.

------------------------------------------------------------------------------
:DelimitMateSwitch                                        *:DelimitMateSwitch*

Switches the plug-in on and off.

------------------------------------------------------------------------------
:DelimitMateTest                                            *:DelimitMateTest*

This command tests every mapping set-up for this script, useful for testing
custom configurations.

The following output corresponds to the default values, it will be different
depending on your configuration. "Open & close:" represents the final result
when the closing delimiter has been inserted, either manually or
automatically, see |delimitMateExpansion|. "Delete:" typing backspace in an
empty pair, see |delimitMateBackspace|. "Exit:" typing a closing delimiter
inside a pair of delimiters, see |delimitMateAutoclose|. "Space:" the
expansion, if any, of space, see |delimitMateExpansion|. "Visual-L",
"Visual-R" and "Visual" shows visual wrapping, see
|delimitMateVisualWrapping|. "Car return:" the expansion of car return, see
|delimitMateExpansion|. The cursor's position at the end of every test is
represented by an "|": >

            * AUTOCLOSE:
            Open & close: (|)
            Delete: |
            Exit: ()|
            Space: ( |)
            Visual-L: (v)
            Visual-R: (v)
            Car return: (
            |)

            Open & close: {|}
            Delete: |
            Exit: {}|
            Space: { |}
            Visual-L: {v}
            Visual-R: {v}
            Car return: {
            |}

            Open & close: [|]
            Delete: |
            Exit: []|
            Space: [ |]
            Visual-L: [v]
            Visual-R: [v]
            Car return: [
            |]

            Open & close: "|"
            Delete: |
            Exit: ""|
            Space: " |"
            Visual: "v"
            Car return: "
            |"

            Open & close: '|'
            Delete: |
            Exit: ''|
            Space: ' |'
            Visual: 'v'
            Car return: '
            |'

            Open & close: `|`
            Delete: |
            Exit: ``|
            Space: ` |`
            Visual: `v`
            Car return: `
            |`
<

==============================================================================
 5. MAPPINGS                                             *delimitMateMappings*

delimitMate doesn't override any existing map, so you may encounter that it
doesn't work as expected because a mapping is missing. In that case, the
conflicting mappings should be resolved by either disabling the conflicting
mapping or creating a custom mappings.

In order to make custom mappings easier and prevent overwritting existing
ones, delimitMate uses the |<Plug>| + |hasmapto()| (|usr_41.txt|) construct
for its mappings.

These are the default mappings for the extra features:

<BS>         is mapped to <Plug>delimitMateBS
<S-BS>       is mapped to <Plug>delimitMateS-BS
<S-Tab>      is mapped to <Plug>delimitMateS-Tab
<C-G>g       is mapped to <Plug>delimitMateJumpMany

The rest of the mappings correspond to parens, quotes, CR, Space, etc. and they
depend on the values of the delimitMate options, they have the following form:

<Plug>delimitMate + char

e.g.: for "(":

( is mapped to <Plug>delimitMate(

e.g.: If you have <CR> expansion enabled, you might want to skip it on pop-up
menus:

    imap <expr> <CR> pumvisible()
                     \ ? "\<C-Y>"
                     \ : "<Plug>delimitMateCR"


==============================================================================
 6. FUNCTIONS                                           *delimitMateFunctions*

------------------------------------------------------------------------------
delimitMate#WithinEmptyPair()                  *delimitMate#WithinEmptyPair()*

Returns 1 if the cursor is inside an empty pair, 0 otherwise.
e.g.: >

    inoremap <expr> <CR> delimitMate#WithinEmptyPair() ?
             \ "<Plug>delimitMateCR" :
             \ "external_mapping"
<

------------------------------------------------------------------------------
delimitMate#ShouldJump()                            *delimitMate#ShouldJump()*

Returns 1 if there is a closing delimiter or a quote to the right of the
cursor, 0 otherwise.

------------------------------------------------------------------------------
delimitMate#JumpAny()                               *delimitMate#JumpAny()*

This function returns a mapping that will make the cursor jump to the right
when delimitMate#ShouldJump() returns 1, returns the argument "key" otherwise.
e.g.: You can use this to create your own mapping to jump over any delimiter.
>
   inoremap <expr> <C-Tab> delimitMate#JumpAny()
<
==============================================================================
 7. AUTOCOMMANDS                                         *delimitMateAutocmds*

delimitMate emits 2 |User| autocommands to make it easier for users to
leverage delimitMate's support for per-filetype customization.

------------------------------------------------------------------------------
delimitMate_map                                              *delimitMate_map*

This |User| event is emittted just prior to delimitMate defining its
buffer-local key mappings. You can use this command to define your own
mappings that are disabled when delimitMate is turned off or excludes the
current filetype.
>
    au User delimitMate_map call s:delimitMate_map()
    function s:delimitMate_map()
        imap <buffer><expr> <C-Tab> delimitMate#JumpAny()
    endfunction
<
------------------------------------------------------------------------------
delimitMate_unmap                                          *delimitMate_unmap*

This |User| event is emitted just after delimitMate clears its buffer-local
key mappings. You can use this command to clear your own mappings that you set
in response to |delimitMate_map|.
>
    au User delimitMate_unmap call s:delimitMate_unmap()
    function s:delimitMate_unmap()
        silent! iunmap <buffer> <C-Tab>
    endfunction
<
Note: This event may be emitted before |delimitMate_map|, and may be emitted
multiple times in a row without any intervening |delimitMate_map| events.

==============================================================================
 8. TODO LIST                                                *delimitMateTodo*

- Automatic set-up by file type.
- Make block-wise visual wrapping work on un-even regions.

==============================================================================
 9. MAINTAINER                                         *delimitMateMaintainer*

Hi there! My name is Israel Chauca F. and I can be reached at:
    mailto:israelchauca@gmail.com

Feel free to send me any suggestions and/or comments about this plugin, I'll
be very pleased to read them.

==============================================================================
 10. CREDITS                                              *delimitMateCredits*

Contributors: ~

  - Kim Silkebækken                                                         ~
    Fixed mappings being echoed in the terminal.

  - Eric Van Dewoestine                                                     ~
    Implemented smart matchpairs.

Some of the code that makes this script was modified or just shamelessly
copied from the following sources:

  - Ian McCracken                                                          ~
    Post titled: Vim, Part II: Matching Pairs:
    http://concisionandconcinnity.blogspot.com/

  - Aristotle Pagaltzis                                                    ~
    From the comments on the previous blog post and from:
    http://gist.github.com/144619

  - Karl Guertin                                                           ~
    AutoClose:
    http://www.vim.org/scripts/script.php?script_id=1849

  - Thiago Alves                                                           ~
    AutoClose:
    http://www.vim.org/scripts/script.php?script_id=2009

  - Edoardo Vacchi                                                         ~
    ClosePairs:
    http://www.vim.org/scripts/script.php?script_id=2373

This script was inspired by the auto-completion of delimiters on TextMate.

==============================================================================
 11. HISTORY                                               *delimitMateHistory*

  Version      Date      Release notes                                       ~
|---------|------------|-----------------------------------------------------|
    2.8     2013-07-15 * Current release:
                         - Add :DelimitMateOn & :DelimitMateOff.
|---------|------------|-----------------------------------------------------|
    2.7     2013-07-15 * - Lots of bug fixes.
                         - Add delimitMate_offByDefault.
                         - Add delimitMate_eol_marker.
                         - Reduce the number of mappings.
                         - Stop using setline().
                         - Better handling of nested quotes.
                         - Allow a custom pattern for smart_quotes.
|---------|------------|-----------------------------------------------------|
    2.6     2011-01-14 * - Add smart_matchpairs feature.
                         - Add mapping to jump over contiguous delimiters.
                         - Fix behaviour of b:loaded_delimitMate.
|---------|------------|-----------------------------------------------------|
    2.5.1   2010-09-30 * - Remove visual wrapping. Surround.vim offers a much
                           better implementation.
                         - Minor mods to DelimitMateTest.
|---------|------------|-----------------------------------------------------|
    2.5     2010-09-22 * - Better handling of mappings.
                         - Add report for mappings in |:DelimitMateTest|.
                         - Allow the use of "|" and multi-byte characters in
                           |'delimitMate_quotes'| and |'delimitMate_matchpairs'|.
                         - Allow commands to be concatenated using |.
|---------|------------|-----------------------------------------------------|
    2.4.1   2010-07-31 * - Fix problem with <Home> and <End>.
                         - Add missing doc on |'delimitMate_smart_quotes'|,
                           |delimitMateBalance| and
                           |'delimitMate_balance_matchpairs'|.
|---------|------------|-----------------------------------------------------|
    2.4     2010-07-29 * - Unbalanced parens: see :help delimitMateBalance.
                         - Visual wrapping now works on block-wise visual
                           with some limitations.
                         - Arrow keys didn't work on terminal.
                         - Added option to allow nested quotes.
                         - Expand Smart Quotes to look for a string on the
                           right of the cursor.

|---------|------------|-----------------------------------------------------|
    2.3.1   2010-06-06 * - Fix: an extra <Space> is inserted after <Space>
                           expansion.

|---------|------------|-----------------------------------------------------|
    2.3     2010-06-06 * - Syntax aware: Will turn off when editing comments
                           or other regions, customizable.
                         - Changed format of most mappings.
                         - Fix: <CR> expansion doesn't break automatic
                           indentation adjustments anymore.
                         - Fix: Arrow keys would insert A, B, C or D instead
                           of moving the cursor when using Vim on a terminal.

|---------|------------|-----------------------------------------------------|
    2.2     2010-05-16 * - Added command to switch the plug-in on and off.
                         - Fix: some problems with <Left>, <Right> and <CR>.
                         - Fix: A small problem when inserting a delimiter at
                           the beginning of the line.

|---------|------------|-----------------------------------------------------|
    2.1     2010-05-10 * - Most of the functions have been moved to an
                           autoload script to avoid loading unnecessary ones.
                         - Fixed a problem with the redo command.
                         - Many small fixes.

|---------|------------|-----------------------------------------------------|
    2.0     2010-04-01 * New features:
                         - All features are redo/undo-wise safe.
                         - A single quote typed after an alphanumeric
                           character is considered an apostrophe and one
                           single quote is inserted.
                         - A quote typed after another quote inserts a single
                           quote and the cursor jumps to the middle.
                         - <S-Tab> jumps out of any empty pair.
                         - <CR> and <Space> expansions are fixed, but the
                           functions used for it are global and can be used in
                           custom mappings. The previous system is still
                           active if you have any of the expansion options
                           set.
                         - <S-Backspace> deletes the closing delimiter.
                         * Fixed bug:
                         - s:vars were being used to store buffer options.

|---------|------------|-----------------------------------------------------|
    1.6     2009-10-10 * Now delimitMate tries to fix the balancing of single
                         quotes when used as apostrophes. You can read
                         |delimitMate_apostrophes| for details.
                         Fixed an error when |b:delimitMate_expand_space|
                         wasn't set but |delimitMate_expand_space| wasn't.

|---------|------------|-----------------------------------------------------|
    1.5     2009-10-05 * Fix: delimitMate should work correctly for files
                         passed as arguments to Vim. Thanks to Ben Beuchler
                         for helping to nail this bug.

|---------|------------|-----------------------------------------------------|
    1.4     2009-09-27 * Fix: delimitMate is now enabled on new buffers even
                         if they don't have set the file type option or were
                         opened directly from the terminal.

|---------|------------|-----------------------------------------------------|
    1.3     2009-09-24 * Now local options can be used along with autocmd
                         for specific file type configurations.
                         Fixes:
                         - Unnamed register content is not lost on visual
                         mode.
                         - Use noremap where appropiate.
                         - Wrapping a single empty line works as expected.

|---------|------------|-----------------------------------------------------|
    1.2     2009-09-07 * Fixes:
                         - When inside nested empty pairs, deleting the
                         innermost left delimiter would delete all right
                         contiguous delimiters.
                         - When inside an empty pair, inserting a left
                         delimiter wouldn't insert the right one, instead
                         the cursor would jump to the right.
                         - New buffer inside the current window wouldn't
                         have the mappings set.

|---------|------------|-----------------------------------------------------|
    1.1     2009-08-25 * Fixed an error that ocurred when mapleader wasn't
                         set and added support for GetLatestScripts
                         auto-detection.

|---------|------------|-----------------------------------------------------|
    1.0     2009-08-23 * Initial upload.

|---------|------------|-----------------------------------------------------|


  `\|||/´         MMM           \|/            www            __^__          ~
   (o o)         (o o)          @ @           (O-O)          /(o o)\\        ~
ooO_(_)_Ooo__ ooO_(_)_Ooo___oOO_(_)_OOo___oOO__(_)__OOo___oOO__(_)__OOo_____ ~
_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|____ ~
__|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_ ~
_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|_____|____ ~

vim:tw=78:et:ts=8:sw=2:ft=help:norl:formatoptions+=tcroqn:autoindent:
