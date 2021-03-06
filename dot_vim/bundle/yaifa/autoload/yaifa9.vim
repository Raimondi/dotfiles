vim9script
" Yaifa: Yet another indent finder, almost...
" Version: 2.1
" Author: Israel Chauca F. <israelchauca@gmail.com>

if exists('s:loaded_yaifa') && !get(g:, 'yaifa_debug', 0)
  "finish
endif
let s:loaded_yaifa = 1

let s:script_dir = expand('<sfile>:p:h:h')

def s:is_continued_line(previous: any, current: any, filetype: string): bool "{{{
  if filetype ==? 'vim'
    return current =~# '\m^\s*\\'
  "elseif ...
  " TODO: Consider other syntaxes for line continuation
  " https://en.wikipedia.org/wiki/Comparison_of_programming_languages_(syntax)
  else
    return previous =~# '\m\\$'
  endif
  return v:false
enddef "}}}

def s:is_comment(line: any, filetype: string): bool "{{{
  if filetype ==# 'vim'
    return line =~# '\m^\s*"'
  "elseif ...
  " TODO: Consider other syntaxes for comments
  " https://en.wikipedia.org/wiki/Comparison_of_programming_languages_(syntax)
  else
    return line =~# '\m^\s*\%(/\*\|\*\|#\|//\)'
  endif
  return v:false
enddef "}}}

def s:analyze_lines(lines: list<string>, filetype: string, defaults:dict<any>): dict<any> "{{{
  let times = []
  call add(times, reltime())
  extend(defaults,
        \ {'type': 'space',
        \  'indent': 4,
        \  'tabstop': 8,
        \  'max_lines': 0,
        \ },
        \ 'keep')
  let previous: dict<any> = {
        \ 'line': '',
        \ 'linenr': 0,
        \ 'indent': 'X',
        \ 'delta': '',
        \ 'tab': 0,
        \ 'space': 0,
        \ 'mixed': 0,
        \ 'crazy': 0,
        \ 'tabs': 0,
        \ 'spaces': 0,
        \ 'length': 0,
        \ 'skipped': 0}
  let lines_d = map(copy(lines), 'extend(deepcopy(previous), '
        \ .. '{''line'': v:val, ''linenr'': v:key + 1, '
        \ .. '''indent'': matchstr(v:val, ''\m^\s*'')}, ''force'')')
  let mixed = {}
  let space = {}
  let tab = 0
  let processed_count = 0
  let ignored_count = 0
  let hint_count = 0
  let max_lines = defaults.max_lines
  let current_line = ''
  call add(times, reltime())
  while !empty(lines_d) && (max_lines == 0
        \ || (processed_count - ignored_count) < max_lines)
    processed_count += 1
    let current = remove(lines_d, 0)
    let skip_msg = ''
    if s:is_continued_line(previous.line, current.line, filetype)
      skip_msg = 'line continuation'
      " Use the properties of the "main" line since that's the one with the
      " correct indentation.
      let current_line = current.line
      current = copy(previous)
      current.line = current_line
      previous = current
    elseif s:is_comment(current.line, filetype)
      skip_msg = 'comment'
    endif
    if !empty(skip_msg)
      " This is meaningless line, just skip it.
      3DebugYaifa s:l2str(current)
      3DebugYaifa printf('Hint: none (%s)', skip_msg)
      ignored_count += 1
      continue
    endif
    echom 'type of current.length: ' .. type(current.length)
    let current.length =
          \ len(substitute(current.indent, '\t', repeat(' ', 8), 'g'))
    " Determine indentation type.
    if current.indent =~# '\m^ \+$'
      current.space = 1
      current.spaces = len(matchstr(current.indent, '\m^\zs *'))
      if current.spaces < 8
        " This line could also use mixed indentation.
        current.mixed = 1
      endif
    elseif current.indent =~# '\m^\t\+ \+$'
      current.mixed = 1
      current.spaces = len(matchstr(current.indent, '\m^\t*\zs *'))
      current.tabs = len(matchstr(current.indent, '\m^\t*'))
    elseif current.indent =~# '\m^\t\+$'
      current.tab = 1
      current.tabs = len(matchstr(current.indent, '\m^\t*'))
    elseif current.indent =~# '\m \t'
      current.crazy = 1
    endif
    3DebugYaifa s:l2str(current)
    current.delta = current.length - previous.length
    if empty(current.line) || current.line =~# '\m^\s*$'
      " Skip empty or blank lines
      current.skipped = 1
      3DebugYaifa printf('Hint: none (%3s:empty line)', current.delta)
    elseif previous.indent ==# current.indent
      " Skip lines without indentation change
      3DebugYaifa printf('Hint: none (%3s: same indent)', current.delta)
    elseif current.crazy
      " Skip lines with crazy indentation
      current.skipped = 1
      3DebugYaifa printf('Hint: none (%3s:crazy indent)', current.delta)
    elseif (current.mixed && current.spaces >= 8)
      " Skip mixed lines with too many spaces, looks like crazy indentation
      current.skipped = 1
      3DebugYaifa printf('Hint: none (%3s:mixed & wrong number of spaces)',
            \ current.delta)
    elseif previous.skipped
      " Not enough context to analyze this line, just skip it.
      3DebugYaifa printf('Hint: none (%3s:previous was skipped)',
            \ current.delta)
    elseif (current.delta <= 1) || (current.delta > 8)
      " Ignore indent change too small or too big
      3DebugYaifa printf('Hint: none (%3s:wrong change size)', current.delta)
    elseif (previous.length == 0 || previous.tab) && current.tab
      " Indent change hints at tabs
      " Increment tab count
      tab += 1
      hint_count += 1
      3DebugYaifa printf('Hint: tab   (%3s)', current.delta)
    elseif (previous.length == 0 || previous.space) && current.space
          \ && !current.mixed
      " Indent change hints at spaces
      " Increment space count
      let space[current.delta] = get(space, current.delta, 0) + 1
      hint_count += 1
      3DebugYaifa printf('Hint: space (%3s)', current.delta)
    elseif (previous.mixed && previous.space || previous.length == 0)
          \ && current.space && current.mixed
      " Indent change hints at spaces or mixed
      " Increment space and mixed count
      space[current.delta] = get(space, current.delta, 0) + 1
      mixed[current.delta] = get(mixed, current.delta, 0) + 1
      hint_count += 1
      3DebugYaifa printf('Hint: either(%3s)', current.delta)
    elseif previous.tab && current.mixed && (previous.tabs == current.tabs)
      " Indent change hints at mixed
      " Increment mixed count
      mixed[current.delta] = get(mixed, current.delta, 0) + 1
      hint_count += 1
      3DebugYaifa printf('Hint: mixed (%3s)', current.delta)
    elseif previous.mixed && current.tab
          \ && (previous.tabs == current.tabs - 1)
      " Indent change hints at mixed
      " Increment mixed count
      mixed[current.delta] = get(mixed, current.delta, 0) + 1
      hint_count += 1
      3DebugYaifa printf('Hint: mixed (%3s)', current.delta)
    elseif previous.mixed && current.mixed && (previous.tabs == current.tabs)
      " Indent change hints at mixed
      " Increment mixed count
      mixed[current.delta] = get(mixed, current.delta, 0) + 1
      hint_count += 1
      3DebugYaifa printf('Hint: mixed (%3s)', current.delta)
    else
      " Nothing to do here
      3DebugYaifa printf('Hint: none  (%3s)', current.delta)
    endif
    previous = current
  endwhile
  let time = reltimestr(reltime(remove(times, -1)))
  2DebugYaifa printf('Time taken to analyze all lines: %s', time)
  let max_space = max(space)
  let max_mixed = max(mixed)
  let max_tab   = tab
  let result = {'type': '', 'indent': 0}
  if max_space * 1.1 >= max_mixed && max_space >= max_tab
    " Go with spaces
    let line_count = 0
    let indent = 0
    for i in range(8, 1, -1)
      if get(space, i, 0) > floor(line_count * 1.1)
        " Give preference to higher indentation
        let indent = i
        let line_count = space[i]
      endif
    endfor
    if indent == 0
      " No guess on size, return defaults
      let result.type = defaults.type
      let result.indent = defaults.indent
    else
      let result.type = 'space'
      let result.indent = indent
    endif
  elseif max_mixed > max_tab
    " Go with mixed
    let line_count = 0
    let indent = 0
    for i in range(8, 1, -1)
      if get(mixed, i, 0) > floor(line_count * 1.1)
        " Give preference to higher indentation
        let indent = i
        let line_count = mixed[i]
      endif
    endfor
    if indent == 0
      " No guess on size, return defaults
      let result.type = defaults.type
      let result.indent = defaults.indent
    else
      let result.type = 'mixed'
      let result.indent = indent
    endif
  else
    " Go with tabs
    let result.type = 'tab'
    let result.indent = defaults.tabstop
  endif
  if get(g:, 'yaifa_debug', 0) > 1
    " Print some info for debugging
    2DebugYaifa printf('Processed lines count: %s', processed_count)
    2DebugYaifa printf('Hints count: %s', hint_count)
    if tab > 0
      2DebugYaifa printf('    tab  (8) => %s', tab)
    endif
    for key in keys(space)
      if space[key] > 0
        2DebugYaifa printf('    space(%s) => %s', key, space[key])
      endif
    endfor
    for key in keys(mixed)
      if mixed[key] > 0
        2DebugYaifa printf('    mixed(%s) => %s', key, mixed[key])
      endif
    endfor
    2DebugYaifa  'max_space: ' . max_space
    2DebugYaifa  'max_mixed: ' . max_mixed
    2DebugYaifa  'max_tab: ' . max_tab
  endif
  let time = reltimestr(reltime(remove(times, -1)))
  1DebugYaifa printf('Time taken to guess: %s', time)
  1DebugYaifa 'Result: ' . string(result)
  return result
enddef "}}}

def yaifa9#magic(bufnr: number): string "{{{
  let lines = getline(1, '$')
  let default_shiftwidth =
        \ get(b:, 'yaifa_shiftwidth', get(g:, 'yaifa_shiftwidth', 4))
  let default_tabstop = get(b:, 'yaifa_tabstop', get(g:, 'yaifa_tabstop', 8))
  let default_expandtab =
        \ get(b:, 'yaifa_expandtab', get(g:, 'yaifa_expandtab', 1))
  let default_type = ''
  if default_expandtab
    default_type = 'space'
  elseif !default_shiftwidth || default_shiftwidth == default_tabstop
    default_type = 'tab'
  else
    default_type = 'mixed'
  endif
  let defaults = {}
  let defaults.max_lines = 1024
  let defaults.type = default_type
  let defaults.indent = default_shiftwidth
  let defaults.tabstop = default_tabstop
  " Do the guess work
  let result = s:analyze_lines(lines, &filetype, defaults)
  if result.type ==# 'tab'
    " Use tabs
    let expandtab = 0
    let shiftwidth = 0
    let softtabstop = 0
    let tabstop = default_tabstop
  elseif result.type ==# 'mixed'
    " Use tabs and spaces
    let expandtab = 0
    let shiftwidth = result.indent
    let softtabstop = result.indent
    let tabstop = 8
  else
    " Use spaces only
    let expandtab = 1
    let shiftwidth = result.indent
    let softtabstop = result.indent
    let tabstop = 8
  endif
  let template = 'setlocal %s tabstop=%s shiftwidth=%s softtabstop=%s'
  let set_cmd = printf(template, expandtab, tabstop, shiftwidth, softtabstop)
  if !exists('b:indent_options_set')
    for option in ['expandtab', 'shiftwidth', 'softtabstop', 'tabstop']
      call setbufvar(bufnr, printf('&%s', option), get(l:, option))
    endfor
    let b:indent_options_set = 1
    if !exists('b:undo_ftplugin') || b:undo_ftplugin =~# '\m^[ \t:]*$'
      let b:undo_ftplugin = 'unlet! b:indent_options_set'
    else
      let b:undo_ftplugin .= ' | unlet! b:indent_options_set'
    endif
  endif
  1DebugYaifa set_cmd
  return set_cmd
enddef "}}}

def yaifa9#test(): dict<any> "{{{
  let start_time = reltime()
  let results = {}
  let results.files = []
  let testdirspat = s:script_dir . '/test/*'
  let testdirs = glob(testdirspat, 0, 1)
  call map(testdirs, 'fnamemodify(v:val, '':p:h'')')
  call filter(testdirs, 'isdirectory(v:val)')
  for dir in testdirs
    let files = glob(dir . '/*', 0, 1)
    echom printf('dir name: %s', fnamemodify(dir, ':t'))
    " Directories with test files should be named <type>-<value>
    let [type, value] = split(fnamemodify(dir, ':t'), '-')
    for file in files
      let lines = readfile(file)
      let test_time = reltime()
      " Do some guessing
      let result = s:analyze_lines(lines, '', {'max_lines': 1024 * 2})
      let test_time = reltimefloat(reltime(test_time)) * 100
      let test_time = floor(test_time) / 100.0
      let test_path = printf('%s/%s', fnamemodify(dir, ':p:h:t'),
            \ fnamemodify(file, ':p:t'))
      let result.path = file
      let result.error = 0
      let result.exp_type = type
      let result.exp_value = value
      if result.type ==? type
        if result.indent != value
          let result.error = 2
          echohl WarningMsg
          echom printf('%ss:%s failed: wrong value, expected %s but got %s',
                \ test_time, test_path, result.exp_value, result.indent)
          echohl Normal
        else
          echom printf('%ss:%s passed: type %s and value %s',
                \ test_time, test_path, result.type, result.indent)
        endif
      else
        echohl WarningMsg
          echom printf('%ss:%s failed: wrong type, expected %s but got %s',
              \ test_time, test_path, result.exp_type, result.type)
        echohl Normal
        let result.error = 1
      endif
      call add(results.files, result)
    endfor
  endfor
  echom ' '
  echom printf('Elapsed time: %s seconds',
        \ reltimestr(reltime(start_time)))
  for file in results.files
    let file.path = fnamemodify(file.path, ':~:.')
  endfor
  let results.passed_files = filter(copy(results.files), '!v:val.error')
  let results.failed_files = filter(copy(results.files), 'v:val.error')
  let results.failed_types = filter(copy(results.files), 'v:val.error == 1')
  let results.failed_values = filter(copy(results.files), 'v:val.error == 2')
  if empty(results.failed_files)
    echom 'All tests passed'
  else
    echohl WarningMsg
    echom 'Failed tests:'
    echohl Normal
  endif
  for file in results.failed_files
    echom printf('%s: exp: %s-%s, act: %s-%s', file.path, file.exp_type,
          \ file.exp_value, file.type, file.indent)
  endfor
  let g:yaifa_test_result = results
  return results
enddef "}}}
