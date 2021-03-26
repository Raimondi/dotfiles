" pathogen.vim - path option manipulation
" Maintainer:   Tim Pope <http://tpo.pe/>
" Version:      2.0

" Install in ~/.vim/autoload (or ~\vimfiles\autoload).
"
" For management of individually installed plugins in ~/.vim/bundle (or
" ~\vimfiles\bundle), adding `call pathogen#infect()` to your .vimrc
" prior to `filetype plugin indent on` is the only other setup necessary.
"
" The API is documented inline below.  For maximum ease of reading,
" :set foldmethod=marker

if exists("g:loaded_pathogen") || &cp
  finish
endif
let g:loaded_pathogen = 1

if !exists("s:pathogen_disabled")
  let s:pathogen_disabled = []
endif

" For saving bundle_plugin data, pick a single canonical bundled_plugin file,
" unless already specified by user.

let s:platform_vimfiles = '$HOME/.vim'
if has('win32') || has('dos32') || has('win16') || has('dos16') || has('win95')
  let s:platform_vimfiles = '$HOME/vimfiles'
endif

if !exists('g:bundled_plugin')
  let g:bundled_plugin = fnameescape(expand(s:platform_vimfiles . '/bundled_plugins'))
endif

let s:done_bundles = []

" Point of entry for basic default usage.  Give a directory name to invoke
" pathogen#runtime_append_all_bundles() (defaults to "bundle"), or a full path
" to invoke pathogen#runtime_prepend_subdirectories().  Afterwards,
" pathogen#cycle_filetype() is invoked.
function! pathogen#infect(...) abort " {{{1
  let source_path = a:0 ? a:1 : 'bundle'
  if source_path =~# '[\\/]'
    call pathogen#runtime_prepend_subdirectories(source_path)
  else
    call pathogen#runtime_append_all_bundles(source_path)
  endif
  call pathogen#cycle_filetype()
endfunction " }}}1

" Split a path into a list.
function! pathogen#split(path) abort " {{{1
  if type(a:path) == type([]) | return a:path | endif
  let split = split(a:path,'\\\@<!\%(\\\\\)*\zs,')
  return map(split,'substitute(v:val,''\\\([\\,]\)'',''\1'',"g")')
endfunction " }}}1

" Convert a list to a path.
function! pathogen#join(...) abort " {{{1
  if type(a:1) == type(1) && a:1
    let i = 1
    let space = ' '
  else
    let i = 0
    let space = ''
  endif
  let path = ""
  while i < a:0
    if type(a:000[i]) == type([])
      let list = a:000[i]
      let j = 0
      while j < len(list)
        let escaped = substitute(list[j],'[,'.space.']\|\\[\,'.space.']\@=','\\&','g')
        let path .= ',' . escaped
        let j += 1
      endwhile
    else
      let path .= "," . a:000[i]
    endif
    let i += 1
  endwhile
  return substitute(path,'^,','','')
endfunction " }}}1

" Convert a list to a path with escaped spaces for 'path', 'tag', etc.
function! pathogen#legacyjoin(...) abort " {{{1
  return call('pathogen#join',[1] + a:000)
endfunction " }}}1

" " Remove duplicates from a list.
" function! pathogen#uniq(list) abort " {{{1
"   let list = a:list
"   return filter(list, 'count(list, v:val) == 1')
"   let i = 0
"   let seen = {}
"   while i < len(a:list)
"     if (a:list[i] ==# '' && exists('empty')) || has_key(seen,a:list[i])
"       call remove(a:list,i)
"     elseif a:list[i] ==# ''
"       let i += 1
"       let empty = 1
"     else
"       let seen[a:list[i]] = 1
"       let i += 1
"     endif
"   endwhile
"   return a:list
" endfunction " }}}1

" pathogen#uniq(list [, keepfirst])
function! pathogen#uniq(list,...) " {{{1
  let keepfirst = !a:0 ? 1 : a:0 && a:1
  if keepfirst
    let list = reverse(copy(a:list))
    return reverse(filter(list, 'count(list, v:val) == 1'))
  else
    let list = a:list
    return filter(list, 'count(list, v:val) == 1')
  endif
endfunction " }}}1



" \ on Windows unless shellslash is set, / everywhere else.
function! pathogen#separator() abort " {{{1
  return !exists("+shellslash") || &shellslash ? '/' : '\'
endfunction " }}}1

" Convenience wrapper around glob() which returns a list.
function! pathogen#glob(pattern) abort " {{{1
  let files = split(glob(a:pattern),"\n")
  return map(files,'substitute(v:val,"[".pathogen#separator()."/]$","","")')
endfunction "}}}1

" Like pathogen#glob(), only limit the results to directories.
function! pathogen#glob_directories(pattern) abort " {{{1
  return filter(pathogen#glob(a:pattern),'isdirectory(v:val)')
endfunction " }}}1

" parse all bundled_plugin files in &rtp
" NOTE: This (re)sets s:pathogen_disabled
function! pathogen#parse_bundled_plugins_files() " {{{1
  " set of 'bundled_plugins' files in root of runtime-path entries
  " can have more than one, but most typically expected to be a single entry
  " as ~/.vim/bundled_plugins
  let bpfs = filter(map(pathogen#split(&rtp), 'findfile("bundled_plugins", v:val)'), 'len(v:val) != 0')

  let s:pathogen_disabled = []
  for bpf in bpfs
    let bundled_plugins = readfile(bpf)

    let bundle = ''
    for line in bundled_plugins
      " skip blank lines
      if line =~ '^\s*$'
        continue
      endif
      " capture paths as new bundles
      if line =~ ':\s*$'
        let bundle = substitute(line, ':\s*$', '', '')
        continue
      endif
      " collect this plugin in the extant bundle
      let plugin = tolower(line)
      let status = 1
      if plugin =~ '^\s*-'
        let status = 0
      endif
      let plugin = substitute(plugin, '^\s*-\?\s*', '', '')
      if status == 0
        call add(s:pathogen_disabled, plugin)
      endif
    endfor
  endfor

  let s:pathogen_disabled = pathogen#uniq(s:pathogen_disabled)
endfunction " }}}1

function! pathogen#list_bundle_plugins(bnd) " {{{1
  let plugins = []
  for plg in pathogen#list_plugins(0)
    if match(fnamemodify(plg, ':h'), a:bnd . '$') != -1
      call add(plugins, tolower(fnamemodify(plg, ':t')))
    endif
  endfor
  return pathogen#uniq(plugins)
endfunction " }}}1

" write plugin information to bundled_plugin file
function! pathogen#save_bundled_plugin_file() " {{{1
  let plugins = []
  for bnd in pathogen#list_bundle_dirs()
    call add(plugins, bnd . ':')
    for plg in pathogen#list_bundle_plugins(bnd)
      let status = ' '
      if pathogen#is_disabled_plugin(plg)
        let status = '-'
      endif
      call add(plugins, status . plg)
    endfor
  endfor
  "echo "Saving " . g:bundled_plugin
  if writefile(plugins, g:bundled_plugin) == -1
    echoe "Couldn't save " . g:bundled_plugin . " file!"
  endif
endfunction " }}}1

" Turn filetype detection off and back on again if it was already enabled.
function! pathogen#cycle_filetype() " {{{1
  if exists('g:did_load_filetypes')
    filetype off
    filetype on
  endif
endfunction " }}}1

" Checks if a bundle is 'disabled'. A bundle is considered 'disabled' if
" its 'basename()' is included in g:pathogen_disabled[]' or ends in a tilde.
function! pathogen#is_disabled(path) " {{{1
  if a:path =~# '\~$'
    return 1
  elseif !exists("g:pathogen_disabled")
    return 0
  endif
endfunction " }}}1

function! pathogen#enable_plugin(plugin) " {{{1
  let plugin = tolower(a:plugin)
  let idx = index(s:pathogen_disabled, plugin)
  if idx != -1
    call remove(s:pathogen_disabled, idx)
    call pathogen#save_bundled_plugin_file()
    return 1
  endif
  return 0
endfunction " }}}1

function! pathogen#disable_plugin(plugin) " {{{1
  let plugin = tolower(a:plugin)
  if index(s:pathogen_disabled, plugin) == -1
    call add(s:pathogen_disabled, plugin)
    call pathogen#save_bundled_plugin_file()
    return 1
  endif
  return 0
endfunction " }}}1

" Prepend all subdirectories of path to the rtp, and append all after
" directories in those subdirectories.
function! pathogen#runtime_prepend_subdirectories(path) " {{{1
  let sep    = pathogen#separator()
  let before = pathogen#glob_directories(a:path.sep."*[^~]")
  let after  = pathogen#glob_directories(a:path.sep."*[^~]".sep."after")
  "let before = filter(pathogen#glob_directories(a:path.sep."*"), '!pathogen#is_disabled(v:val)')
  "let after  = filter(pathogen#glob_directories(a:path.sep."*".sep."after"), '!pathogen#is_disabled(v:val[0:-7])')
  let rtp = pathogen#split(&rtp)
  let path = expand(a:path)
  call filter(rtp,'v:val[0:strlen(path)-1] !=# path')
  let &rtp = pathogen#join(pathogen#uniq(before + rtp + after))
  return &rtp
endfunction " }}}1

" For each directory in rtp, check for a subdirectory named dir.  If it
" exists, add all subdirectories of that subdirectory to the rtp, immediately
" after the original directory.  If no argument is given, 'bundle' is used.
" Repeated calls with the same arguments are ignored.  Multiple arguments can
" be used.
function! pathogen#runtime_append_all_bundles(...) " {{{1
  let sep = pathogen#separator()
  let l:names = a:0 ? (type(a:000[0]) == 3 ? a:000[0] : a:000) : [ 'bundle' ]
  let list = []
  call pathogen#parse_bundled_plugins_files()
  " Set runtimepath.
  let dict = {}
  let rtp = pathogen#split(&rtp)
  for path in rtp
    let dict[path] = []
  endfor
  for name in names
    if index(s:done_bundles, name) >= 0
      continue
    endif
    let s:done_bundles += [name]
    for path in keys(dict)
      if path =~# '\<after$'
        let dict[path] +=  pathogen#glob_directories(substitute(path,'after$',name,'').sep.'*[^~]'.sep.'after')
      else
        let dict[path] +=  pathogen#glob_directories(path.sep.name.sep.'*[^~]')
      endif
    endfor
  endfor
  for path in rtp
    if path =~# '\<after$'
      let list +=  [path] + dict[path]
    else
      let list +=  dict[path]+ [path]
    endif
  endfor
  call filter(list , ' !pathogen#is_disabled_plugin(v:val)') " remove disabled plugin directories from the list
  let &rtp = pathogen#join(pathogen#uniq(list))
  " Create or update bundled_plugin file.
  call pathogen#save_bundled_plugin_file()
  return 1
endfunction " }}}1

" Takes an argument that can be 0 (all), 1 (enabled) or -1 (disabled) and returns a
" list of the plugins contained in every "bundle" dir, filtered according to
" the given argument.
" This asumes append_all_bundles() has been already called and
" s:pathogen_disabled is set.
function! pathogen#list_plugins(arg) " {{{1
  let sep = pathogen#separator()
  let list = []
  for name in s:done_bundles
    for dir in pathogen#split(&rtp)
      if dir !~# '\<after$'
        let list +=  pathogen#glob_directories(dir.sep.name.sep.'*[^~]')
      endif
    endfor
  endfor
  if a:arg == 0 && type(a:arg) != 1
    return list
  elseif a:arg == 1
    return filter(list , ' !pathogen#is_disabled_plugin(v:val)') " remove disabled plugin directories from the list
  elseif a:arg == -1
    return filter(list , ' pathogen#is_disabled_plugin(v:val)') " remove enabled plugin directories from the list
  else
    echoe 'Something is wrong with this argument: '.a:arg
    return ''
  endif
endfunction " }}}1

" Returns a list of all "bundle" dirs.
function! pathogen#list_bundle_dirs() " {{{1
  return s:done_bundles
endfunction " }}}1

" Check if plugin is disabled of not
function! pathogen#is_disabled_plugin(path) " {{{1
  let plugname = a:path =~# "after$"
        \ ? fnamemodify(a:path, ":h:t")
        \ : fnamemodify(a:path, ":t")
  return count(s:pathogen_disabled, plugname, 1)
endfunction " }}}1

" Invoke :helptags on all non-$VIM doc directories in runtimepath.
function! pathogen#helptags() " {{{1
  let sep = pathogen#separator()
  for dir in pathogen#split(&rtp)
    if (dir.sep)[0 : strlen($VIMRUNTIME)] !=# $VIMRUNTIME.sep && filewritable(dir.sep.'doc') == 2 && !empty(glob(dir.sep.'doc'.sep.'*')) && (!filereadable(dir.sep.'doc'.sep.'tags') || filewritable(dir.sep.'doc'.sep.'tags'))
      helptags `=dir.'/doc'`
    endif
  endfor
endfunction " }}}1

" Single point of call from user-land. Removes the need to do the 'filetype'
" dance in ~/.vimrc
" Stolen from Araxia's fork of pathogen :-)
function! pathogen#infect(...) " {{{1
  let l:names = a:0 ? (type(a:000[0]) == 3 ? a:000[0] : a:000) : [ 'bundle' ]
  let l:filetype_was_on = exists('g:did_load_filetypes')
  filetype off
  call pathogen#runtime_append_all_bundles(l:names)
  call pathogen#helptags()
  if l:filetype_was_on | filetype on | endif
  if $MYVIMRC == ''
    return 'finish'
  else
    return ''
  endif
endfunction " }}}1

" :Plugin complement:
function! s:plugin(action, ...) " {{{1
  let actions = ['enable', 'disable', 'list', 'install', 'remove']
  if len(filter(copy(actions), 'v:val =~? ''^''.a:action')) == 0
    echom 'Action not supported.'
    return ''
  endif

  if a:action =~? '^e\%[nable]'
    if a:0 > 0
      " Enable plugins:
      for i in a:000
        if pathogen#enable_plugin(i)
          echom 'Pathogen: The plugin "'.i.'" was enabled.'
          call pathogen#helptags()
        else
          echom 'Pathogen: The plugin "'.i.'" could not be enabled, it might be already enabled or not installed.'
        endif
      endfor
    else
      echom 'You must provide one or more plugin names.'
    endif
  elseif a:action =~? '^d\%[isable]'
    if a:0 > 0
      " Disable plugins:'
      for i in a:000
        if pathogen#disable_plugin(i)
          echom 'Pathogen: The plugin "'.i.'" was disabled.'
          call pathogen#helptags()
        else
          echom 'Pathogen: The plugin "'.i.'" could not be disabled, it might either be already disabled or not installed.'
        endif
      endfor
    else
      echom 'You must provide one or more plugin names.'
    endif
  elseif a:action =~? '^l\%[ist]'
    if a:0 == 0 || (a:0 == 1 && a:1 ==? 'all')
      " List all plugins:
      echom 'All plugins managed by pathogen:'
      let list = s:plugin_list(0)
    elseif a:0 == 1 && a:1 ==? 'enabled'
      " List enabled plugins:
      echom 'Enabled plugins managed by pathogen:'
      let list = s:plugin_list(1)
    elseif a:0 == 1 && a:1 ==? 'disabled'
      " List disabled plugins:
      echom 'Disabled plugins managed by pathogen:'
      let list = s:plugin_list(-1)
    else
      echom 'Wrong arguments. Use :Plugin list [all|enabled|disabled]'
      return ''
    endif
    for p in list
      echom p
    endfor
  elseif a:action =~? '^i\%[nstall]'
    call s:call_vam('install', copy(a:000))
  elseif a:action =~? '^r\%[emove]'
    call s:call_vam('remove', copy(a:000))
  else
    echom 'Action not supported: ' . a:action
  endif
endfunction " }}}1

" Biscuit Support {{{1
" Vim Plugin Bisect tool to locate plugins failing a test
function! pathogen#biscuit(testfile)
  set nocompatible nomore

  " TODO: replace this with bundle_parse
  call pathogen#infect('bundle/local')

  exe "source " . a:testfile

  " whether we echo pass/fail or use quit/cquit is yet to be decided
  if Biscuit() == 0
    !echo "failed"
  else
    !echo "passed"
  endif
  quit
endfunction

" Use Vim Addon Manager.
function! s:call_vam(action, list) "{{{1
  try
    if a:action == 'install'
      call s:install_recursively(a:list)
    else
      call vam#install#UninstallAddons(a:list)
    endif
    call pathogen#helptags()
  catch /^Vim\%((\a\+)\)\=:E117/
    echohl WarningMsg
    echom 'Pathogen: The plugin "Vim Addon Manager" must be installed in order to use the "'.a:action.'" action.'
    echohl None
  catch
    echohl ErrorMsg
    echom 'Pathogen: '.substitute(v:exception, '^Vim\%((\a\+)\):', '', '')
    echohl None
  endtry
endfunction " }}}1

" Install files and its dependencies
function! s:install_recursively(list)
  let installed = []

  for plugin in a:list
    if index(installed, plugin) == -1
      " Don't try to install dependencies again
      call add(installed, plugin)
      let infoFile = vam#AddonInfoFile(plugin)
      if !filereadable(infoFile) && !vam#IsPluginInstalled(plugin)
        call vam#install#Install([plugin])
      endif
      let info = vam#AddonInfo(plugin)
      let dependencies = get(info,'dependencies', {})

      " Install dependencies
      call s:install_recursively(keys(dependencies))
    endif
  endfor
endf

" Format output for :Plugin list.
function! s:plugin_list(opt) " {{{1
  let enbldMrk = '[ + ]'
  let dsbldMrk = '[ - ]'

  return map(pathogen#list_plugins(a:opt), '(pathogen#is_disabled_plugin(v:val) ? dsbldMrk : enbldMrk) . '' '' . v:val')
endfunction " }}}1


" Provides completion for :Plugin
function! s:command_complete(ArgLead, CmdLine, CursorPos) " {{{1
  if a:CmdLine[: a:CursorPos ] =~? '\m\(^\s*\||\s*\)\S\+[ ]\+\S*$'
    " Complete actions:
    return join(['enable ', 'disable ', 'list ', 'install ', 'remove '], "\n")
  elseif a:CmdLine[: a:CursorPos ] =~?
        \'\m\(^\s*\||\s*\)\S\+ e\%[nable]\([ ]\+\S\+\)*[ ]\+\S*$'
    " Complete enable action, list disabled plugins:
    return join(map(pathogen#list_plugins(-1), 'substitute(v:val, ''^.*''.pathogen#separator().''\(.\{-}\)$'',''\1'',"")'), "\n")
  elseif a:CmdLine[: a:CursorPos ] =~?
        \'\m\(^\s*\||\s*\)\S\+ d\%[isable]\([ ]\+\S\+\)*[ ]\+\S*$'
    " Complete disable action, list enabled plugins:
    return join(map(pathogen#list_plugins(1), 'substitute(v:val, ''^.*''.pathogen#separator().''\(.\{-}\)$'',''\1'',"")'), "\n")
  elseif a:CmdLine[: a:CursorPos ] =~?
        \'\m\(^\s*\||\s*\)\S\+ l\%[ist][ ]\+\S*$'
    " Complete list action, list options:
    return join(['all', 'enabled', 'disabled'], "\n")
  elseif a:CmdLine[: a:CursorPos ] =~?
        \'\m\(^\s*\||\s*\)\S\+ \(i\%[nstall]\|r\%[emove]\)\([ ]\+\S\+\)*[ ]\+\S*$'
    try
      " Get list of available plugins to install or remove:
      let result = match(a:CmdLine[: a:CursorPos ],
            \ '\m\(^\s*\||\s*\)\S\+ i\%[nstall]\([ ]\+\S\+\)*[ ]\+\S*$' ) > -1
            \ ?
            \ vam#install#DoCompletion(a:ArgLead, a:CmdLine, a:CursorPos, 'installable')
            \ :
            \ vam#install#DoCompletion(a:ArgLead, a:CmdLine, a:CursorPos)
      return join(result, "\n")
    catch /^Vim\%((\a\+)\)\=:E117/
      echohl WarningMsg
      echom 'Pathogen: The plugin "Vim Addon Manager" must be installed in order to use the install/remove actions.'
      echohl None
      return ''
    endtry
  else
    return ''
  endif
endfunction " }}}1


" Like findfile(), but hardcoded to use the runtimepath.
function! pathogen#runtime_findfile(file,count) "{{{1
  let rtp = pathogen#join(1,pathogen#split(&rtp))
  return fnamemodify(findfile(a:file,rtp,a:count),':p')
endfunction " }}}1

" Backport of fnameescape().
function! pathogen#fnameescape(string) " {{{1
  if exists('*fnameescape')
    return fnameescape(a:string)
  elseif a:string ==# '-'
    return '\-'
  else
    return substitute(escape(a:string," \t\n*?[{`$\\%#'\"|!<"),'^[+>]','\\&','')
  endif
endfunction " }}}1

function! s:find(count,cmd,file,lcd) " {{{1
  let rtp = pathogen#join(1,pathogen#split(&runtimepath))
  let file = pathogen#runtime_findfile(a:file,a:count)
  if file ==# ''
    return "echoerr 'E345: Can''t find file \"".a:file."\" in runtimepath'"
  elseif a:lcd
    let path = file[0:-strlen(a:file)-2]
    execute 'lcd `=path`'
    return a:cmd.' '.pathogen#fnameescape(a:file)
  else
    return a:cmd.' '.pathogen#fnameescape(file)
  endif
endfunction " }}}1

function! s:Findcomplete(A,L,P) " {{{1
  let sep = pathogen#separator()
  let cheats = {
        \'a': 'autoload',
        \'d': 'doc',
        \'f': 'ftplugin',
        \'i': 'indent',
        \'p': 'plugin',
        \'s': 'syntax'}
  if a:A =~# '^\w[\\/]' && has_key(cheats,a:A[0])
    let request = cheats[a:A[0]].a:A[1:-1]
  else
    let request = a:A
  endif
  let pattern = substitute(request,'\'.sep,'*'.sep,'g').'*'
  let found = {}
  for path in pathogen#split(&runtimepath)
    let path = expand(path, ':p')
    let matches = split(glob(path.sep.pattern),"\n")
    call map(matches,'isdirectory(v:val) ? v:val.sep : v:val')
    call map(matches,'expand(v:val, ":p")[strlen(path)+1:-1]')
    for match in matches
      let found[match] = 1
    endfor
  endfor
  return sort(keys(found))
endfunction " }}}1

" Use:
" :Plugin action [argument]
command! -bar -nargs=+ -complete=custom,<SID>command_complete Plugin call <SID>plugin(<f-args>)
command! -bar Helptags :call pathogen#helptags()
command! -bar -bang -range=1 -nargs=1 -complete=customlist,s:Findcomplete Ve       :execute s:find(<count>,'edit<bang>',<q-args>,0)
command! -bar -bang -range=1 -nargs=1 -complete=customlist,s:Findcomplete Vedit    :execute s:find(<count>,'edit<bang>',<q-args>,0)
command! -bar -bang -range=1 -nargs=1 -complete=customlist,s:Findcomplete Vopen    :execute s:find(<count>,'edit<bang>',<q-args>,1)
command! -bar -bang -range=1 -nargs=1 -complete=customlist,s:Findcomplete Vsplit   :execute s:find(<count>,'split',<q-args>,<bang>1)
command! -bar -bang -range=1 -nargs=1 -complete=customlist,s:Findcomplete Vvsplit  :execute s:find(<count>,'vsplit',<q-args>,<bang>1)
command! -bar -bang -range=1 -nargs=1 -complete=customlist,s:Findcomplete Vtabedit :execute s:find(<count>,'tabedit',<q-args>,<bang>1)
command! -bar -bang -range=1 -nargs=1 -complete=customlist,s:Findcomplete Vpedit   :execute s:find(<count>,'pedit',<q-args>,<bang>1)
command! -bar -bang -range=1 -nargs=1 -complete=customlist,s:Findcomplete Vread    :execute s:find(<count>,'read',<q-args>,<bang>1)

" vim:set ft=vim ts=8 sw=2 sts=2:
