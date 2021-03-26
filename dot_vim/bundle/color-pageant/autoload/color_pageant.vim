" Copyright (c) 2017 by Israel Chauca F. <israelchauca@gmail.com>
" Released under the ISC license

if get(g:, 'loaded_color_pageant', 0) || get(s:, 'loaded', 0)
  finish
endif
let s:loaded = 1

let s:all = {}
let s:all.colors = []
let s:all.paths = []
let s:all.header = ['Available Color Schemes']

let s:sel = {}
let s:sel.colors = []
let s:sel.header = ['Selected Color Schemes']

let s:selalt = deepcopy(s:sel)

let s:names = {}

let s:original = get(g:, 'colors_name', 'default')
let s:configpath = expand('<sfile>:p:h:h') . '/.color_pageant.txt'
let s:bufname = 'ColorPageant'

function! color_pageant#eval(expr) "{{{1
  return eval(a:expr)
endfunction

function! s:getconfigpath() "{{{1
  return get(g:, 'color_pageant_config_path', s:configpath)
endfunction

function! s:line2name() "{{{1
  let line = getline('.')
  return substitute(line, '^.\{4}', '', '')
endfunction

function! s:currentname() "{{{1
  let colorscheme = get(g:, 'colors_name', '')
  if index(s:all.colors, colorscheme) < 0
    let colorscheme = get(s:names, colorscheme, '')
  endif
  return colorscheme
endfunction

function! s:write_selection() "{{{1
  let file = s:getconfigpath()
  if writefile(s:sel.colors, file)
    echoe 'Could not save selection to ' . file
    return 1
  endif
  return 0
endfunction

function! s:read_selection() "{{{1
  let file = s:getconfigpath()
  try
    let selection = readfile(file)
  catch
    echoe 'Could not read selection from ' . file
    return 1
  endtry
  let s:sel.colors = selection
  return 0
endfunction

function! color_pageant#handle_cursor() "{{{1
  if line('.') <= 2
    silent! +1
    silent! 3
  endif
  if get(g:, 'color_pageant_auto_load', 0)
    call s:set_colorscheme(s:line2name(), 1)
    call s:update_buffer(s:dict)
  endif
endfunction

function! s:set_colorscheme(colorscheme, ...) "{{{1
  let samecolor = s:currentname() ==# a:colorscheme
  let skipsame = get(a:000, 0, 0)
  if skipsame && samecolor
    return ''
  endif
  if index(s:all.colors, a:colorscheme) >= 0
    let colorscheme = a:colorscheme
  else
    let colorscheme = get(s:names, a:colorscheme, '')
  endif
  if empty(colorscheme)
    return
  endif
  " Reduce number of times errors are displayed
  silent! set background&
  execute 'colorscheme ' . fnameescape(colorscheme)
  let s:names[get(g:, 'colors_name', '')] = colorscheme
  call s:update_buffer(s:dict)
endfunction

function! s:edit(name) "{{{1
  if index(s:all.colors, a:name) < 0
    return
  endif
  let globpattern = printf('colors/%s.vim', a:name)
  let paths = globpath(&runtimepath, globpattern, 0, 1)
  if empty(paths)
    let globpattern = printf('pack/*/start/*/colors/%s.vim', a:name)
    let paths = globpath(&packpath, globpattern, 0, 1)
    if empty(paths)
      let globpattern = printf('pack/*/opt/*/colors/%s,vim', a:name)
      let paths = globpath(&packpath, globpattern, 0, 1)
    endif
  endif
  if empty(paths)
    return 1
  endif
  execute 'edit ' . fnameescape(paths[0])
endfunction

function! s:set_buffer(dict) abort "{{{1
  let winnr = bufwinnr(s:bufname)
  if winnr >= 0
    execute winnr . 'wincmd w'
  else
    execute 'split ' . fnameescape(s:bufname)
  endif
  if a:dict ==# 'sel'
    let s:selalt = deepcopy(s:sel)
    let dict = 'selalt'
  else
    let dict = a:dict
  endif
  call s:update_buffer(dict)
  if empty(&buftype)
    setlocal buftype=nofile
    nnoremap <silent><buffer> <CR> :<C-U>call <SID>set_from_line()<CR>
    nnoremap <silent><buffer> a :<C-U>call <SID>set_from_line()<CR>
    nnoremap <silent><buffer> <Space> :<C-U>call <SID>switch_from_line()<CR>
    nnoremap <silent><buffer> + :<C-U>call <SID>select_from_line()<CR>
    nnoremap <silent><buffer> - :<C-U>call <SID>deselect_from_line()<CR>
    nnoremap <silent><buffer> r :<C-U>call color_pageant#restore()<CR>
    nnoremap <silent><buffer> e :<C-U>call <SID>edit(<SID>line2name())<CR>
  endif
endfunction

function! s:formatline(name, current) "{{{1
  let format = a:name ==? a:current ? '<%s> %s' : '[%s] %s'
  let mark = index(s:sel.colors, a:name) >= 0 ? '*' : ' '
  return printf(format, mark, a:name)
endfunction

function! s:update_buffer(dict) "{{{1
  if !bufexists(s:bufname)
    " Nothing to update
    return
  endif
  " Decide what to update
  if a:dict ==# 'switch'
    let s:dict = getline(1) ==# s:all.header ? 'selalt' : 'all'
  else
    let s:dict = a:dict
  endif
  let lazyredraw = &lazyredraw
  set lazyredraw
  let view = winsaveview()
  if @% != s:bufname
    " Switch to buffer if needed
    let current = @%
    execute 'keepalt buffer ' . fnameescape(s:bufname)
  endif
  " Update content
  setlocal modifiable
  silent %delete _
  let colors = copy(s:[s:dict].colors)
  let loaded = s:currentname()
  call map(colors, 's:formatline(v:val, loaded)')
  let lines = s:[s:dict].header + [''] + colors
  call setline(1, lines)
  if !empty(get(l:, 'current', ''))
    " Restore window
    execute 'keepalt buffer ' . fnameescape(current)
  endif
  call winrestview(view)
  setlocal nomodifiable
  let &lazyredraw = lazyredraw
endfunction

function! s:set_from_line() "{{{1
  let colorscheme = s:line2name()
  call s:set_colorscheme(colorscheme)
endfunction

function! s:random(...) "{{{1
  return str2nr(matchstr(reltimestr(reltime()), '\d\+$')[1:])
        \ % get(a:000, 0, 99999)
endfunction

function! s:select(colorscheme) "{{{1
  if index(s:all.colors, a:colorscheme) < 0
    return 1
  endif
  call uniq(sort(add(s:sel.colors, a:colorscheme)))
  call uniq(sort(add(s:selalt.colors, a:colorscheme)))
  call s:write_selection()
  call s:update_buffer(s:dict)
  call color_pageant#print_info()
endfunction

function! s:deselect(colorscheme) "{{{1
  let index = index(s:sel.colors, a:colorscheme)
  if index < 0
    return 1
  endif
  call remove(s:sel.colors, index)
  call s:write_selection()
  call s:update_buffer(s:dict)
  call color_pageant#print_info()
endfunction

function! s:switch(colorscheme) "{{{1
  if index(s:sel.colors, a:colorscheme) >= 0
    call s:deselect(a:colorscheme)
  else
    call s:select(a:colorscheme)
  endif
endfunction

function! s:select_from_line() "{{{1
  let colorscheme = s:line2name()
  call s:select(colorscheme)
endfunction

function! s:deselect_from_line() "{{{1
  let colorscheme = s:line2name()
  call s:deselect(colorscheme)
endfunction

function! s:switch_from_line() "{{{1
  let colorscheme = s:line2name()
  call s:switch(colorscheme)
endfunction

function! s:set_from_line() "{{{1
  let colorscheme = s:line2name()
  call s:set_colorscheme(colorscheme)
endfunction

function! color_pageant#refresh() "{{{1
  let s:all.paths = globpath(&runtimepath, 'colors/*.vim', 0, 1)
  let s:all.paths += globpath(&packpath, 'pack/*/start/*/colors/*.vim', 0, 1)
  let s:all.paths += globpath(&packpath, 'pack/*/opt/*/colors/*.vim', 0, 1)
  let s:all.colors = map(copy(s:all.paths), 'fnamemodify(v:val, '':t:r'')')
  " Some clean up
  call filter(uniq(sort(s:all.colors)), '!empty(v:val)')
  call filter(s:sel.colors, 'index(s:all.colors, v:val) >= 0')
  let dict = get(s:, 'dict', 'all')
  call s:update_buffer(dict)
endfunction

function! color_pageant#jump(amount, direction, dict) abort "{{{1
  let name = s:currentname()
  let index = index(s:[a:dict].colors, name)
  if a:amount == -1
    let index = s:random(len(s:all.colors))
  elseif a:direction == 1
    let index += a:amount
  elseif a:direction == -1
    let index -= a:amount
  else
    let index = a:amount - 1
  endif
  if empty(s:[a:dict].colors)
    return
  endif
  let index = index % (len(s:[a:dict].colors))
  let name = s:[a:dict].colors[index]
  execute 'colorscheme ' . fnameescape(name)
  redraw
  call color_pageant#print_info()
endfunction

function! color_pageant#restore() "{{{1
  call s:set_colorscheme(s:original)
  call color_pageant#print_info()
endfunction

function! color_pageant#print_info() "{{{1
  let name = s:currentname()
  let index = index(s:all.colors, name) + 1
  let is_selected = index(s:sel.colors, name) >= 0 ? '+' : ' '
  echo printf('[%s] %s %d/%d', is_selected, name, index, len(s:all.colors))
endfunction

function! color_pageant#set_buffer(dict) abort "{{{1
  call s:set_buffer(a:dict)
endfunction

function! color_pageant#select_current() "{{{1
  let colorscheme = s:currentname()
  call s:select(colorscheme)
endfunction

function! color_pageant#deselect_current() "{{{1
  let colorscheme = s:currentname()
  call s:deselect(colorscheme)
endfunction

function! color_pageant#switch_current() "{{{1
  let colorscheme = s:currentname()
  call s:switch(colorscheme)
endfunction

function! color_pageant#edit() "{{{1
  let name = s:currentname()
  call s:edit(name)
endfunction

" Useful stuff? think not, change it! {{{1
call s:read_selection()
call color_pageant#refresh()

" vim: set et sw=2:
