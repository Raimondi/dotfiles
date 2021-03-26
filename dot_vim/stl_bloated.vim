" Functions {{{1

function! s:ignore_filetype()
  return &filetype =~? 'help\|netrw'
endfunction

function! s:is_too_big(...)
  let limit = get(a:000, '1', 20*1024*1024)
  "if wordcount().bytes >= limit
  if line('$') > 5000
    return 1
  endif
  return 0
endfunction

" Moon phase and paste flag for the statusline. Weird, eh? {{{2
function! Moon()
  " Show moon phase:
  " Phase of the Moon calculation
  let time = localtime()
  let fullday = 86400
  let offset = 592500
  let period = 2551443
  let phase = (time - offset) % period
  let phase = phase / fullday
  return printf('[%d]', phase)
endfunction

" Buffer size: {{{2
function! FileSize()
  let bytes = wordcount().bytes
  if bytes <= 0
    let number = 0
    let sufix = ''
  elseif bytes < 1024
    let number = bytes
    let sufix = ''
  elseif bytes < 1024 * 1024
    let number = bytes / 1024.0
    let sufix = 'K'
  elseif bytes < 1024 * 1024 * 1024
    let number = bytes / (1024 * 1024.0)
    let sufix = 'M'
  elseif bytes < 1024 * 1024 * 1024 * 1024
    let number = bytes / (1024 * 1024 * 1024.0)
    let sufix = 'G'
  else
    let number = bytes / (1024 * 1024 * 1024 * 1024.0)
    let sufix = 'wTf?!'
  endif
  return printf('%3.1f%s', number, sufix)
endfunction

" Show info about the char under the cursor: {{{2
function! CharUnderCursorInfo()
  let char = char2nr(strcharpart(getline('.')[col('.') - 1:], 0, 1))
  return printf('%d,#%x,0%o', char, char, char)
endfunction

" Add flag and highlight wrong values: {{{2
" Add a:label to the statusline. Highlight it as
" 'error' unless its value is in a:expr (a comma separated string)
function! AddStatuslineFlag(label, expr, prefix, sufix)
  let format = '%s%%#ErrorMsg#%%{RenderStlFlag(%s,%s,1)}'
  let format .= '%%*%%{RenderStlFlag(%s,%s,0)}%s'
  let expr = type(a:expr) == type('') ? a:expr : string(a:expr)
  let strexpr = string(expr)
  let &statusline .= printf(format,
        \ a:prefix, a:label, expr, a:label, strexpr, a:sufix)
endfunction

" Render stl flag: {{{2
" returns a:value or ''
function! RenderStlFlag(label, expr, criteria)
  let expr_value = eval(a:expr)
  let result = a:criteria ? expr_value : !expr_value
  return result ? a:label : ''
endfunction

" Indicate tabstop value: {{{2
function! IndentStatus(prefix, sufix)
  let state = &expandtab ? nr2char(183) : nr2char(8677)
  let format = '%s%s%s/%s%s'
  return printf(format, a:prefix, state, &shiftwidth, &tabstop, a:sufix)
endfunction

" Warn on mixed indenting and wrong et value: {{{2
let b:stl_indent_warning = ''
function! STLIndentWarning()
  if s:is_too_big() || &readonly || !&modifiable || s:ignore_filetype()
    return ''
  elseif exists('b:stl_indent_warning')
    return b:stl_indent_warning
  endif
  let pos = getpos('.')
  let cat = {}
  let cat.spaces = {'regex': ' \+\t*\S'}
  let cat.tabs = {'regex':  '\t\+ *\S'}
  let cat.mixed = {'regex':  '\( \+\t\+\|\t\+ \+\)\S'}
  for key in keys(cat)
    1
    let linenr = search('^' . cat[key].regex, 'W')
    while linenr
      if join(map(synstack(linenr,col('.')),
            \ 'synIDattr(v:val,''name'')')) =~? 'string\|comment'
        let regex = printf('^\%%>%sl%s', linenr, cat[key].regex)
        let linenr = search(regex, 'W')
      else
        break
      endif
    endwhile
    let cat[key].value = linenr
  endfor
  call setpos('.', pos)
  let items = []
  if cat.tabs.value && cat.spaces.value
    call add(items, 'mixed-indent')
  endif
  if cat.mixed.value
    call add(items, 'wrong-sts/sw')
  endif
  if (cat.spaces.value && !&expandtab) || (cat.tabs.value && &expandtab)
    call add(items, 'wrong-et')
  endif
  let b:stl_indent_warning =
        \empty(items) ? '' : printf('[%s]', join(items, ','))
  return b:stl_indent_warning
endfunction

" Warn on "long lines": {{{2
"return a warning for "long lines" where "long" is either &textwidth or 80 (if
"no &textwidth is set)
"
"return '' if no long lines
"return '[#x,my,$z] if long lines are found, were x is the number of long
"lines, y is the median length of the long lines and z is the length of the
"longest line
function! STLLongLineWarning(...)
  if s:is_too_big() || &readonly || !&modifiable || s:ignore_filetype()
    let b:stl_long_line_warning = ''
  elseif !exists('b:stl_long_line_warning')
    let threshold = &textwidth ? &textwidth : get(a:000, 0, 80)
    let lengths = map(getline(1,'$'), 'strdisplaywidth(v:val)')
    call filter(lengths, 'v:val > threshold')
    if !empty(lengths)
      let len_count = len(lengths)
      call sort(lengths)
      if len_count == 1
        let median = lengths[0]
      elseif len_count % 2
        let median = lengths[(len_count/2) - 1]
      else
        let median = (lengths[(len_count/2) - 1] + lengths[len_count/2])/2
      endif
      let b:stl_long_line_warning =
            \ printf('[#%s,m%s,$%s]', len_count, median, max(lengths))
    else
      let b:stl_long_line_warning = ''
    endif
  endif
  return b:stl_long_line_warning
endfunction

" Warn on trailing spaces: {{{2
" return '[\s]' if trailing white space is detected
" return '' otherwise
let b:stl_trail_space_warning = ''
function! STLTrailSpaceWarning()
  if s:is_too_big() || &readonly || !&modifiable || s:ignore_filetype()
    let b:stl_trail_space_warning = ''
    return b:stl_trail_space_warning
  endif
  if exists('b:stl_trail_space_warning')
    return b:stl_trail_space_warning
  endif
  if search('\s\+$', 'nw', 0, )
    let b:stl_trail_space_warning = '[\s$]'
  else
    let b:stl_trail_space_warning = ''
  endif
  return b:stl_trail_space_warning
endfunction

" Autocmds {{{1

augroup statusline
  autocmd!
  " Recalculate the tab warning flag when idle and after writing
  autocmd TextChanged,InsertLeave * unlet! b:stl_indent_warning

  " Recalculate the long line warning when idle and after saving
  autocmd TextChanged,InsertLeave * unlet! b:stl_long_line_warning

  " Recalculate the trailing whitespace warning when idle, and after saving
  autocmd TextChanged,InsertLeave * unlet! b:stl_trail_space_warning

augroup END

" Status Line {{{1
" -----------

" Reset status line:
set statusline=

" Default color:
set statusline+=%0*

set statusline+=%<


" File path:
"set statusline+=%#identifier#
set statusline+=%f
"set statusline+=%*

" Modified flag:
set statusline+=%#warningmsg#
set statusline+=%(\ %M\ %)

set statusline+=%*

" File size:
"set statusline+=%#identifier#
set statusline+=(%{FileSize()})
"set statusline+=%*

" Buffer number:
"set statusline+=%#identifier#
set statusline+=:%n/
"set statusline+=%*

" Number of buffers:
"set statusline+=%#identifier#
set statusline+=%{len(filter(range(1,bufnr('$')),'buflisted(v:val)'))}
"set statusline+=%*


"Indent settings
"set statusline+=%#identifier#
set statusline+=[%{IndentStatus(',','')}]

"set statusline+=[

" Type of  file flag:
set statusline+=%y

" Help flag:
"set statusline+=%#identifier#
"set statusline+=%H

" Preview window flag:
"set statusline+=%#identifier#
set statusline+=%w

" Use error color:
set statusline+=%#warningmsg#

" Readonly flag:
set statusline+=%r

" Return to default color:
set statusline+=%*

"display a warning if fileformat isnt unix
set statusline+=%#ErrorMsg#
set statusline+=%{&ff!='unix'?'['.&ff.']':''}
set statusline+=%*

" Alert me if file encoding is not UTF-8:
set statusline+=%#ErrorMsg#
set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
set statusline+=%*

" display a warning if &et is wrong, or we have mixed-indenting
set statusline+=%#ErrorMsg#
set statusline+=%{STLIndentWarning()}
set statusline+=%*

" puts the trailing spaces flag on the statusline
set statusline+=%#ErrorMsg#
set statusline+=%{STLTrailSpaceWarning()}
set statusline+=%*

" Alert me of long lines:
set statusline+=%#ErrorMsg#
set statusline+=%{STLLongLineWarning(90)}
set statusline+=%*

"set statusline+=]

"display a warning if &paste is set
set statusline+=%#ErrorMsg#
set statusline+=%{&paste?'[paste]':''}
set statusline+=%*

" Start right aligned items:
set statusline+=\ %=

" Display date and time:
"set statusline+=\(%{strftime(\"%D\ %T\",getftime(expand(\"%:p\")))}\)

" Display moon face:
"set statusline+=\ Moon:%{Moon()}

" Show decimal, hexadecimal and octal values of char under the cursor.
"set statusline+=[%{CharUnderCursorInfo()}]
set statusline+=[ga]

" Indent level. No indentation is level 1
"set statusline+=%{(indent('.')/&sw+1).'\|'}

" Hex representation of char under the cursor:
"set statusline+=0x\%B,

" Line number
set statusline+=%l:

" Column number:
set statusline+=%c

" Virtual column number:
set statusline+=%V

" Percentage through file/Number of lines in buffer:
set statusline+=\ %P/%L

" vim: set et sw=2:
