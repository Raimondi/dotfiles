let s:entries = {}
let s:extensions = {}
let s:filetypes = {}
let s:items = [
      \ {
      \   'name': 'opml',
      \   'extensions': 'opml',
      \   'filetypes': '',
      \   'import': 'votlxopml#2votl',
      \   'export': 'votlxopml#2opml',
      \ }
      \ ]
function! s:setup(item) "{{{1
  let name       = get(a:item, 'name', '')
  let extensions = get(a:item, 'extensions, '')
  let import_func = get(a:item, 'import', '')
  let export_func = get(a:item, 'export', '')
  let filetypes  = get(a:item, 'filetypes', empty(extensions) ? name : '')
  exec 'autocmd! VOx' . name . '2otl
  if !empty(filetypes)
    exec 'autocmd VOx' . name . '2otl FileType '
          \ . filetypes
          \ . ' command -nargs=? -buffer -complete=file VO2otl'
          \ . ' call s:export(<bang>0, ''' . name . ''', [<f-args>])'
    for ft in split(filetypes, ',')
      let s:filetypes[ft] = name
    endfor
  endif
  if !empty(extensions)
    exec 'autocmd VOx' . name . '2otl BufRead,BufNewFile '
          \ . join(map(split(extensions, ','), '"*." . v:val'), ',')
          \ . ' command -nargs=? -buffer -complete=file VO2otl'
          \ . ' call s:export(<bang>0, ''' . name . ''', [<f-args>])'
    for ext in split(extensions, ',')
      let s:extensions[ext] = name
    endfor
  endif
  let s:entries[name] = a:item
  if !empty(import_func)
    exec 'command! -bang -nargs=? -complete=file VOImport'
          \ . substitute(name, '.', '\u&', '')
          \ . ' call s:import(<bang>0, ''' . name . ''', [<f-args>])'
  endif
  if !empty(export_func)
    exec 'command! -bang -nargs=? -complete=file VOExport'
          \ . substitute(name, '.', '\u&', '')
          \ . ' call s:export(<bang>0, ''' . name . ''', [<f-args>])'
  endif
endfunction
function! s:import(key, bang, args) abort "{{{1
  let source_name = get(a:args, 0, expand('%'))
  let source_name = fnamemodify(source_name, ':p')
  if !filereadable(source_name)
    call s:echo('File is not readable.', 'ErrorMsg')
    return
  endif
  let lines = call(s:entries[a:key].import, [source_name])
  let dest_name = fnamemodify(source_name, ':p:r') . '.otl'
  if !empty(glob(dest_name)) && !bang
    let confirm = confirm('"' . dest_name
          \ . '" already exists, Do you want to overwrite it?',
          \ "&Yes\n&No", 2)
    if confirm == 2 or confirm == 0
      return
    endif
  endif
  exec 'silent edit ' . fnameescape(dest_name)
  silent %d_
  call setline(1, lines)
endfunction
function! s:export(key, bang, args) "{{{1
  let source_name = get(a:args, 0, expand('%'))
  let source_name = fnamemodify(source_name, ':p')
  
endfunction
function! s:echo(msg, hl) "{{{1
  exec 'echohl ' . a:hl
  echom a:msg
  echohl NONE
endfunction
