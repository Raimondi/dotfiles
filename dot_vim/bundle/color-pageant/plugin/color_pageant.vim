" Copyright (c) 2017 by Israel Chauca F. <israelchauca@gmail.com>
" Released under the ISC license

if get(g:, 'loaded_color_pageant', 0) || get(s:, 'loaded', 0)
  finish
endif
let s:loaded = 1

command! ColorPageant call color_pageant#set_buffer('all')
command! CP call color_pageant#set_buffer('all')
command! CPSelection call color_pageant#set_buffer('sel')
command! CPToggleView call color_pageant#set_buffer('switch')

command! -count=1 CPNext call color_pageant#jump(<count>, 1, 'all')
command! -count=1 CPPrevious call color_pageant#jump(<count>, -1, 'all')
command! -count=1 CPGoTo call color_pageant#jump(<count>, 0, 'all')
command! CPRandom call color_pageant#jump(-1, 0, 'all')

command! CPSelectCurrent call color_pageant#select_current()
command! CPDeselectCurrent call color_pageant#deselect_current()
command! -count=1 CPNextSelected call color_pageant#jump(<count>, 1, 'sel')
command! -count=1 CPPreviousSelected call color_pageant#jump(<count>, -1, 'sel')
command! -count=1 CPGoToSelected call color_pageant#jump(<count>, 0, 'sel')
command! CPRandomSelected call color_pageant#jump(-1, 0, 'sel')

command! CPRestore call color_pageant#restore()
command! CPInfo call color_pageant#print_info()
command! CPRefresh call color_pageant#refresh()
command! CPEditCurrent call color_pageant#edit()

augroup ColorPageant
  autocmd!
  autocmd CursorMoved ColorPageant call color_pageant#handle_cursor()
augroup END

" vim: set et sw=2:
