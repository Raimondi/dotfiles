" Vim library file
" Description:	VimPEG Parser compiler.
" Maintainer:	Israel Chauca <israelchauca@gmail.com>
"		Barry Arthur <barry.arthur@gmail.com>
" Version:	0.1
" Last Change:	Wed Oct 01 11:08:03 2014
" License:	Vim License (see :help license)
" Location:	autoload/vimpeg/peg.vim

if exists('g:loaded_vimpeg_peg')
  "    \ || v:version < 700 || &compatible
  "finish
endif
let g:loaded_vimpeg_peg = 1

let vimpeg_peg_version = '0.1'

"TODO fix not_has(p.e(
" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

let s:path = expand('<sfile>')

" Callback functions {{{
function! vimpeg#peg#grammar(elems) abort "{{{
  "echom printf('grammar: a:elems: %s', a:elems[1])
  "if len(a:elems[0]) > 0
  "  let result = a:elems[0][0]
  "else
  "  let result = ''
  "endif
  "echom 'Line: ' . string(result)
  "return result
  return a:elems[1]
endfunction "}}}

function! vimpeg#peg#definitions(elems) abort "{{{
  "echom printf('definitions: a:elems: %s', a:elems)
  let result = []
  for i in a:elems
    "echom printf('i: %s', i)
    if type(i) == type([])
      call extend(result, i)
    else
      call add(result, i)
    endif
  endfor
  "echom printf('definitions: result: %s', result)
  return result
endfunction "}}}

function! vimpeg#peg#definition(elems) abort "{{{
  "echom 'Definition: ' . string(a:elems)
  let s:setting_options = 0
  " Definition
  let label = a:elems[0]
  if !exists('s:root_element')
    let s:root_element = label
  endif
  "let mallet = a:elems[1]
  let expression = a:elems[2]
  "echom expression
  let expression = expression =~# '\m^''' ? 's:p.and(['.expression.']' : expression[:-2]
  let callback = len(a:elems[3]) > 0 ? a:elems[3][0] : ''
  "echom string(s:parser_options)
  let line1 = printf('call %s,', expression)
  if !empty(callback)
    let namespace = exists('s:parser_options') ? get(s:parser_options, 'namespace', '') : ''
    let callback = substitute(callback, '\m\C^#', namespace.'#', '')
    "echom 'using callback='.callback.' in namespace='.get(s:parser_options, 'namespace', 'none')
    let callback = printf(', ''on_match'': ''%s''', callback)
  endif
  let line2 = printf('      \{''id'': %s%s})', label, callback)
  let result = [line1, line2]
  "echom 'Definition: ' . string(result)
  return result
endfunction "}}}

function! vimpeg#peg#expression(elems) abort "{{{
  "echom 'expression: ' . string(a:elems)
  if empty(a:elems[0])
    echoerr 'VimPEG: Empty sequence. Aborting.'
  endif
  if !empty(a:elems[1])
    if !empty(filter(map(copy(a:elems[1]), 'v:val[1]'), 'type(v:val) == 3'))
      echoerr 'VimPEG: Empty sequence. Aborting.'
    endif
    let result = 's:p.or(['.a:elems[0]. ', '. join(map(copy(a:elems[1]), 'v:val[1]'), ', ').'])'
  else
    let result = a:elems[0]
  endif
  "echom 'Expression: ' . string(result)
  return result
endfunction "}}}

function! vimpeg#peg#sequence(elems) abort "{{{
  "echom 'sequence: ' . string(a:elems)
  let sequence = a:elems
  if len(sequence) > 1
    let result = 's:p.and(['.join(sequence, ', ').'])'
  else
    let result = sequence[0]
  endif
  "echom 'Sequence: ' . string(result)
  return result
endfunction "}}}

function! vimpeg#peg#prefix(elems) abort "{{{
  "echom 'prefix: ' . string(a:elems)
  let suffix = a:elems[1]
  if len(a:elems[0]) > 0
    let prefix = a:elems[0][0]
    let result = 's:p.'.(prefix ==# '!' ? 'not_' : '').'has('.suffix.')'
  else
    let result = suffix
  endif
  "echom 'Prefix: ' . string(result)
  return result
endfunction "}}}

function! vimpeg#peg#suffix(elems) abort "{{{
  "echom 'suffix: ' . string(a:elems)
  let primary = a:elems[0]
  if len(a:elems[1]) > 0
    let suffix = a:elems[1][0]
    let result = 's:p.'.(suffix ==# '*' ? 'maybe_many' : (suffix ==# '+' ? 'many' : 'maybe_one')) . '('.primary.')'
  else
    let result = primary
  endif
  "echom 'Suffix: ' . string(result)
  return result
endfunction "}}}

function! vimpeg#peg#primary(elems) abort "{{{
  "echom 'Primary: '.string(a:elems)
  let len = len(a:elems)
  if type(a:elems) == type('')
    let result = a:elems
  elseif len == 2
    let result = a:elems[0]
  else
    let result = a:elems[1]
  endif
  "echom 'Primary: ' . string(result)
  return result
endfunction "}}}

function! vimpeg#peg#callback(elems) abort "{{{
  "echom 'callback: ' . string(a:elems)
  let callback = a:elems[1]
  "echom 'Callback: ' . string(callback)
  return callback
endfunction "}}}

function! vimpeg#peg#options(elems) abort "{{{
  "echom printf('options: a:elems: %s', a:elems)
  return ''
endfunction "}}}

function! vimpeg#peg#option(elems) abort "{{{
  "echom 'option: ' . string(a:elems)
  if exists('s:parser_options')
    if s:setting_options == 0
      "echoerr 'All options must be declared before definitions.'
    endif
    "TODO Simplify this
    let s:parser_options[eval(a:elems[1][0])] = eval(a:elems[3])
  endif
  "echom 'Option: ' . cmd
  return ''
endfunction "}}}

function! vimpeg#peg#identifier(elems) abort "{{{
  "echom 'identifier: ' . string(a:elems)
  let result = "'".a:elems[0]."'"
  "echom 'Identifier: ' . string(result)
  return result
endfunction "}}}

function! vimpeg#peg#option_value(elems) abort "{{{
  "echom 'Option_value: '.string(a:elems)
  return a:elems
endfunction "}}}

function! vimpeg#peg#regex(elems) abort "{{{
  "echom 'regex: ' . string(a:elems)
  let regex = 's:p.e('.a:elems.')'
  "echom 'Regex: ' . string(regex)
  return regex
endfunction "}}}

function! vimpeg#peg#dquoted_string(elems) abort "{{{
  "echom 'dquoted_string: ' . string(a:elems)
  let dquoted_string = a:elems[0].join(a:elems[1], '').a:elems[2]
  "echom 'Dquoted_string: ' . string(dquoted_string)
  return dquoted_string
endfunction "}}}

function! vimpeg#peg#squoted_string(elems) abort "{{{
  "echom 'squoted_string: ' . string(a:elems)
  let squoted_string = a:elems[0].join(a:elems[1], '').a:elems[2]
  "echom 'Squoted_string: ' . string(squoted_string)
  return squoted_string
endfunction "}}}

function! vimpeg#peg#escaped_dquote(elems) abort "{{{
  "echom 'escaped_dquote: ' . string(a:elems)
  let escaped_dquote = a:elems[0]
  "echom 'Escaped_dquote: ' . string(escaped_dquote)
  return escaped_dquote
endfunction "}}}

function! vimpeg#peg#double_backslash(elems) abort "{{{
  "echom 'double_backslash: ' . string(a:elems)
  let double_backslash = a:elems[0]
  "echom 'Double_backslash: ' . string(double_backslash)
  return double_backslash
endfunction "}}}

function! vimpeg#peg#backslash(elems) abort "{{{
  "echom 'backslash: ' . string(a:elems)
  let backslash = a:elems[0]
  "echom 'Backslash: ' . string(backslash)
  return backslash
endfunction "}}}

function! vimpeg#peg#dquote(elems) abort "{{{
  "echom 'dquote: ' . string(a:elems)
  let dquote = a:elems[0]
  "echom 'Dquote: ' . string(dquote)
  return dquote
endfunction "}}}

function! vimpeg#peg#double_squote(elems) abort "{{{
  "echom 'double_squote: ' . string(a:elems)
  let double_squote = a:elems[0]
  "echom 'Double_squote: ' . string(double_squote)
  return double_squote
endfunction "}}}

function! vimpeg#peg#squote(elems) abort "{{{
  "echom 'squote: ' . string(a:elems)
  let squote = a:elems[0]
  "echom 'Squote: ' . string(squote)
  return squote
endfunction "}}}

function! vimpeg#peg#right_arrow(elems) abort "{{{
  "echom 'right_arrow: ' . string(a:elems)
  let right_arrow = a:elems[0]
  "echom 'Right_arrow: ' . string(right_arrow)
  return right_arrow
endfunction "}}}

function! vimpeg#peg#mallet(elems) abort "{{{
  let mallet = a:elems
  "echom 'Mallet: ' . string(mallet)
  return mallet
endfunction "}}}

function! vimpeg#peg#boolean(elems) abort "{{{
  "echom 'boolean: ' . string(a:elems)
  "echom 'Boolean: ' . string(a:elems)
  return a:elems
endfunction "}}}

function! vimpeg#peg#comment(elems) abort "{{{
  "echom 'comment: ' . string(a:elems)
  "echo 'Comment: -->' . string(a:elems) . '<--'
  "return '"'.a:elems
  return ''
endfunction "}}}

function! vimpeg#peg#true(elems) abort "{{{
  "echom 'true: ' . string(a:elems)
  "echom 'True: ' . string(a:elems)
  return 1
endfunction "}}}

function! vimpeg#peg#false(elems) abort "{{{
  "echom 'false: ' . string(a:elems)
  "echom 'False: ' . string(a:elems)
  return 0
endfunction "}}}

function! vimpeg#peg#or(elems) abort "{{{
  "echom 'or: ' . string(a:elems)
  let or = a:elems[0]
  "echom 'Or: ' . string(or)
  return or
endfunction "}}}

function! vimpeg#peg#not(elems) abort "{{{
  "echom 'not: ' . string(a:elems)
  let not = a:elems[0]
  "echom 'Not: ' . string(not)
  return not
endfunction "}}}

function! vimpeg#peg#question(elems) abort "{{{
  "echom 'question: ' . string(a:elems)
  let question = a:elems[0]
  "echom 'Question: ' . string(question)
  return question
endfunction "}}}

function! vimpeg#peg#star(elems) abort "{{{
  "echom 'star: ' . string(a:elems)
  let star = a:elems[0]
  "echom 'Star: ' . string(star)
  return star
endfunction "}}}

function! vimpeg#peg#plus(elems) abort "{{{
  "echom 'plus: ' . string(a:elems)
  let plus = a:elems[0]
  "echom 'Plus: ' . string(plus)
  return plus
endfunction "}}}

function! vimpeg#peg#close(elems) abort "{{{
  "echom 'close: ' . string(a:elems)
  let close = a:elems[0]
  "echom 'Close: ' . string(close)
  return close
endfunction "}}}

function! vimpeg#peg#open(elems) abort "{{{
  "echom 'open: ' . string(a:elems)
  let open = a:elems[0]
  "echom 'Open: ' . string(open)
  return open
endfunction "}}}

function! vimpeg#peg#eol(elems) abort "{{{
  return ''
endfunction "}}}

function! vimpeg#peg#first(elems) abort "{{{
  return a:elems[0]
endfunction "}}}

function! vimpeg#peg#join(elems) abort "{{{
  "echom 'join: ' . string(a:elems)
  let result = join(a:elems, '')
  "echom 'join:result: ' . string(result)
  return result
endfunction "}}}

function! vimpeg#peg#echo(elems) abort "{{{
  "echom 'echo: ' . string(a:elems)
  return a:elems
endfunction "}}}

" }}}

" Public interface {{{
function! vimpeg#peg#parse(lines) abort "{{{
  let s:setting_options = 1
  " Parse the lines
  let result = []
  " TODO: nul is not a good marker for a newline, we could create one on the
  " fly that doesn't exists on the text to be parsed.
  let eol = "\<NL>"
  let grammar = join(a:lines, eol) . eol
  let result = vimpeg#peg#parser#parse(grammar)
  "echo keys(result)
  " Remove empty items
  "echom string(result)
  "call filter(result, 'type(v:val) == type("") && !empty(v:val)')
  "echom string(result)
  return result
endfunction "}}}

function! vimpeg#peg#writefile(force) range abort "{{{
  let parser_path = expand('%:p:r:h').'.vim'

  " See if file exists
  if !empty(glob(parser_path)) && !a:force
    echohl ErrorMsg
    echom 'The file "'.parser_path.'" already exists, add ! to overwrite it.'
    echohl NONE
    exec 'source ' . parser_path
    return 0
  endif

  " Get the source
  let source_path = expand('%')
  let s:parser_options = {}
  "unlet! let s:root_element
  let lines = getline(a:firstline, a:lastline)

  " Add comment marks if needed
  let peg_rules = map(copy(lines), 'v:val =~# ''\m^\s*"\s*'' ? v:val : ''" ''.v:val')
  try
    let peg_commands = vimpeg#peg#parse(lines)
  catch /VimPEG:/
    echohl ErrorMsg
    echom matchstr(v:exception, '^Vim(echoerr):\zs.*')
    echohl NONE
    return -1      "TODO: What should we really return here?
  endtry
  "echom peg_commands
  if !peg_commands.is_matched
    echohl ErrorMsg
    echom printf('Parse Failed: %s', peg_commands.errmsg)
    echohl NONE
    return -1      "TODO: What should we really return here?
  endif
  let root_element = get(s:parser_options, 'root_element', s:root_element)
  let embedded = get(s:parser_options, 'embedded', 0)
  let vimpeg_name = embedded ? 's:vimpeg' : 'vimpeg#parser'
  let namespace = s:get_namespace(parser_path)
  let parser_name = get(s:parser_options, 'parser_name', fnamemodify(source_path, ':p:t:r'))
  let parser_name = parser_name =~# '\m#' ? parser_name : namespace . '#' . parser_name
  let header = [
        \ '" Parser compiled on '.strftime('%c').',',
        \ '" with VimPEG v'.g:vimpeg_version.' and VimPEG Compiler v'.g:vimpeg_peg_version.'',
        \ '" from "'.fnamemodify(source_path, ':p:t').'"',
        \ '" with the following grammar:',
        \ ''
        \ ]
  " TODO: allow changing options with global variables: let foo#bar#debug = 1
  let parser = ['']
  call add(parser, 'let s:p = '.vimpeg_name.'({')
  let parser_options = map(keys(s:parser_options),
        \'printf("      \\ %s: get(g:, %s, %s),", string(v:val), string(namespace."#".v:val), string(s:parser_options[v:val]))')
  call extend(parser, parser_options)
  call add(parser, '      \ })')
  call extend(parser, peg_commands.value)
  let footer = [
        \ '',
        \ 'let g:'.parser_name.' = s:p.GetSym('''.root_element.''')',
        \ 'function! '.namespace.'#parse(input)',
        \ '  if type(a:input) != type('''')',
        \ '    echohl ErrorMsg',
        \ '    echom ''VimPEG: Input must be a string.''',
        \ '    echohl NONE',
        \ '    return []',
        \ '  endif',
        \ '  return g:'.parser_name.'.match(a:input)',
        \ 'endfunction',
        \ 'function! '.namespace.'#parser()',
        \ '  return deepcopy(g:'.parser_name.')',
        \ 'endfunction',
        \ ]
  let content = []
  call extend(content, header)
  call extend(content, peg_rules)
  if embedded
    call extend(content, s:embed_vimpeg())
  endif
  call extend(content, parser)
  call extend(content, footer)

  "echo string(content)
  let result =  writefile(content, parser_path) + 1
  echom 'The parser was built into "'.parser_path.'".'
  exec 'source ' . parser_path
  echom 'The parser was loaded.'
  return result
endfunction "}}}

function! vimpeg#peg#quick_test(lines) abort "{{{
  if &filetype !=? 'vimpeg'
    echoerr 'This is not a vimpeg grammar file.'
  endif
  let linenr = search('\m\C^\s*\.parser_name\s*=')
  if linenr == -1
    echoerr '"parser_name" option not found.'
    return
  endif
  let str = join(map(copy(a:lines), 'substitute(v:val, "\\m\\C^; ", "", "")'), "\<NL>")
  let Parser_func = function(s:get_namespace(expand('%')) . '#parse')
  return call(Parser_func, [str])
endfunction "}}}

function! s:get_namespace(path) "{{{
  let namespace = fnamemodify(a:path, ':p:r')
  let namespace = substitute(namespace, '\m\C^.*[/\\]autoload[/\\]', '', '')
  let namespace = join(split(namespace, '[/\\]'), '#')
  return namespace
endfunction "}}}

function! s:embed_vimpeg() "{{{
  let vimpeg_path = fnamemodify(s:path, ':p:h:h') . '/vimpeg.vim'
  let lines = readfile(vimpeg_path)
  let start_idx = index(lines, '" Start VimPEG')
  let end_idx = index(lines, '" End VimPEG')
  let lines = lines[start_idx : end_idx]
  let idx = index(lines, 'function! vimpeg#parser(options) abort')
  let lines[idx] = 'function! s:vimpeg(options) abort'
  let lines[0] = '" Embedded VimPEG {{{1"'
  let lines[-1] = '" End of embedded VimPEG }}}1"'
  call insert(lines, '')
  return lines
endfunction "}}}

" }}}

let &cpo = s:save_cpo
unlet! s:save_cpo

" vim: et sw=2 fdm=marker
