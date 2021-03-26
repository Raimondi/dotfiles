function! votl#brainstorm#parse_outline(lines) "{{{
    let root = {}
    let root.children = []
    let root.level = -1
    let root.text = ''
    let root.type = 'root'
    let lines = []
    let node = root
    for line in a:lines
        call add(lines, line)
        let [_, indent, text, marker; _] =
                    \ matchlist(line, '^\(\t*\)\(\(.\).*\)')
        let level = len(indent)
        let delta = level - node.level
        let type = marker =~# '^[ |:;<>]$' ? marker : 'header'
        if node.type !=# 'header'
            if delta == 0
                if node.type ==# type
                    " append line to current node
                    call add(node.lines, text)
                else
                    " create a new node
                endif
            elseif delta > 0
                if delta > 1
                    " delta too large
                    throw 8
                else
                    " create a new node under the current header
                endif
            elseif delta < 0
                " create new node under the corresponding header
            endif

        elseif delta > 0
            " new child
            if delta > 1
                " indentation change is too large
                throw 1
            endif
            let node = call('s:new_child', [text, type], node)
        elseif delta < 0
            " new uncle
            while node.level > level && has_key(node, 'parent')
                let node = node.parent
            endwhile
            let node = call('s:new_child', [text, type], node.parent)
        else
            " new sibling
            let node = call('s:new_child', [text, type], node.parent)
        endif
    endfor
    let root.lines = lines
    return root
endfunction "}}}

function! s:new_child(text, type) dict "{{{
    let new = copy(self)
    if has_key(new, 'lines')
        call remove(new, 'lines')
    endif
    let new.children = []
    let new.parent = self
    let new.text = a:text
    let new.type = a:type
    if !empty(new.parent.children)
        let new.previous = self.children[-1]
        let new.previous.next = new
    endif
    call add(self.children, new)
    let new.level = self.level + 1
    return new
endfunction "}}}

function! votl#brainstorm#walker(node, callbacks, ...) "{{{
    let state = a:0 ? a:1 : {}
    for key in ['text', 'level']
        echom printf('a:node: %s', a:node[key])
    endfor
    let Leave = get(a:callbacks, 'leave', {node, state -> state})
    let Enter = get(a:callbacks, 'enter', {node, state -> state})
    let Leaf = get(a:callbacks,  'leaf',  {node, state -> state})
    for child in a:node.children
        let state = Enter(a:node, state)
        if empty(a:node.children)
            let state = Leaf(a:node, state)
            continue
        endif
        call votl#brainstorm#walker(child, a:callbacks, state)
        let state = Leave(a:node, state)
    endfor
    return state
endfunction "}}}

function! s:perm_enter_cb(node, state, ...) "{{{
    echom printf('a:node.text: %s', a:node.text)
    if a:node.level > 2
        " nesting is too deep
        throw 2
    elseif a:node.level == 0
        if a:node.text ==? 'categories'
            let a:state.categories = {}
            if !has_key(a:state, 'attributes')
                let a:state.attributes = {}
            endif
        elseif a:node.text ==? 'attributes'
            if !has_key(a:state, 'attributes')
                let a:state.attributes = {}
            endif
        elseif a:node.text ==? 'priorities'
            let a:state.priorities = []
        else
            " Unkown element
            throw 3
        endif
    elseif a:node.level == 1
        if a:node.parent.text ==? 'categories'
            let a:state.categories[a:node.text] = []
        elseif a:node.parent.text ==? 'priorities'
            call add(a:state.priorities,
                        \ {'name': a:node.text, 'categories': []})
        endif
    elseif a:node.level == 2
        if a:node.parent.parent.text ==? 'attributes'
            if !has_key(a:state.attributes, a:node.text)
                let a:state.attributes[a:node.text] =
                            \ {'name': a:node.text, 'actions': []}
            endif
            call add(a:state.attributes[a:node.text].actions,
                        \ a:node.parent.text)
        elseif a:node.parent.parent.text ==? 'categories'
            call add(a:state.categories[a:node.parent.text],
                        \ a:node.text)
        elseif a:node.parent.parent.text ==? 'priorities'
            call add(a:state.priorities[-1].categories, a:node.text)
        endif
    endif
    return a:state
endfunction "}}}

function! s:perm_process_lines(lines) abort "{{{
    " priorities = [
    "               {
    "                 'name': priority1,
    "                 'categories': [
    "                                 'category1', ...], ...}, ...]
    " categories = {
    "               'category1':  [
    "                               'attribute1', 'attribute2', ...], ...}
    " attributes      = {
    "               'attribute1': [
    "                             'action1', ...]}
    let tree = votl#brainstorm#parse_outline(a:lines)
    let tree = votl#brainstorm#walker(tree,
                \ {'enter': function('s:perm_enter_cb')})
    let lines = []
    let priorities = deepcopy(tree.priorities)
    echom printf('priorities: %s', priorities)
    let attributes = deepcopy(tree.attributes)
    echom printf('attributes: %s', attributes)
    let categories = deepcopy(tree.categories)
    echom printf('categories: %s', categories)
    for category in keys(categories)
        let idx = 0
        while idx < len(categories[category])
            let val = categories[category][idx]
            if !has_key(attributes, val)
                " wrong value in category
                throw 6
            endif
            " map string (key) to attribute
            let categories[category][idx] = deepcopy(get(attributes, val, {}))
            let idx += 1
        endwhile
    endfor
    " categories = {
    "               'category1': [
    "                              attribute1, ...], ...}
    for priority in priorities
        call map(priority.categories,
                    \ {key, val ->
                    \   deepcopy(get(categories, val, []))})
        " priority.categories = [
        "                         [
        "                           attribute1, ...], ...]
        call add(lines, priority.name)
        " create all possible paths
        echom printf('priority.categories: %s', priority.categories)
        let priority.outcomes = s:permutate(priority.categories)
        " remove attributes that are not common among categories
        call map(priority.outcomes,
                    \ {idx, val -> s:perm_filter_attributes(val)})
        " remove outcomes that don't share attributes (the last element has no
        " actions left)
        call filter(priority.outcomes, {idx, val -> !empty(val[-1].actions)})
        call extend(lines, s:perm_outcomes2lines(priority.outcomes))
    endfor
    return lines
endfunction "}}}

function! s:permutate(list) "{{{
    " takes a list of lists and recursively permutates their elements
    if len(a:list) < 2
        return a:list[0]
    endif
    let permutations = []
    for i1 in a:list[0]
        for i2 in s:permutate(a:list[1:])
            if type(i2) == v:t_list
                let attribute = [i1] + deepcopy(i2)
            else
                let attribute = [deepcopy(i1), deepcopy(i2)]
            endif
            if index(permutations, attribute) >= 0
                continue
            endif
            call add(permutations, attribute)
        endfor
    endfor
    return permutations
endfunction "}}}

function! s:perm_filter_attributes(list) "{{{
    " Recursively remove attributes not present in the previous attribute
    if len(a:list) < 2
        return a:list
    endif
    call filter(a:list[1].actions,
                \ {idx, val -> index(a:list[0].actions, val) >= 0})
    let tail = s:perm_filter_attributes(a:list[1:])
    return a:list[:0] + tail
endfunction "}}}

function! s:perm_outcomes2lines(outcomes) "{{{
    " remove repeated leading attributes to turn this
    " [
    "   [a, b, c]
    "   [a, b, d]
    "   [e, f, g]
    "   [e, f, h]
    " ]
    " into
    " [a, b, c, d, e, f, g, h]
    " each item should be properly indented
    for outcome in a:outcomes
        " remove elements that have the same number of attributes than the
        " previous element
        call filter(outcome, {idx, val -> idx == 0
                    \|| len(val.actions) < len(outcome[idx - 1].actions)})
        if len(outcome[-1].actions) == 1
            " add action's name to the list
            call add(outcome, {'name': outcome[-1].actions[0],
                        \ 'actions': []})
        else
            " more than one action for this outcome, error?
            throw 7
        endif
        " add the propper indentation
        call map(outcome, {idx, val -> {
                    \ 'name': repeat("\t", idx + 1) . val.name,
                    \ 'actions': val.actions}})
    endfor
    let i = 0
    let max = max(map(copy(a:outcomes), {idx, val -> len(val)}))
    " go through every outcome and leave only the first occurrence of every
    " leading item intact, turn the rest into empty dicts
    while i < max
        let current = []
        let j = 0
        while j < len(a:outcomes)
            let outcome = a:outcomes[j]
            let attribute = get(outcome, i, '')
            if i >= len(outcome)
                let j += 1
                continue
            elseif index(current, attribute.name) >= 0
                let a:outcomes[j][i] = {}
            else
                let current = [attribute.name]
            endif
            let j += 1
        endwhile
        let i += 1
    endwhile
    let lines = []
    for outcome in a:outcomes
        " remove the empty items
        call filter(outcome, {idx, val -> !empty(val)})
        call map(outcome, 'v:val.name')
        call extend(lines, outcome)
    endfor
    return lines
endfunction "}}}

function! votl#brainstorm#perm_decision_tree() abort "{{{
    let pos = getpos('.')
    let lines = getline(1, '$')
    let start_output = index(lines, 'Output')
    if start_output >= 0
        let lines = lines[0:start_output - 1]
        silent! execute printf('%s;$delete _', (start_output + 1))
    endif
    let output = s:perm_process_lines(lines)
    call map(output, {idx, val -> "\t" . val})
    call insert(output, 'Output')
    call append('$', output)
    call setpos('.', pos)
endfunction "}}}

function! votl#brainstorm#bin_sort_set_up(add_more) abort "{{{
    " look for categories
    let fence_linenr = s:bin_sort_search_fence()
    let sep_marker = repeat('=', 34)
    let fence = sep_marker . ' Sorting Bins ' . sep_marker
    if fence_linenr == 0 || fence_linenr == line('$')
        " ask for categories
        " add categories
        if !fence_linenr
            $put = fence
            let fence_linenr = line('$')
        endif
        echo 'Could not find any bins, let''s add some'
        call s:bin_sort_add_categories()
    elseif a:add_more
        " we have some bins, let's add more
        echon 'Some bins found, add more? (y/N)'
        let answer = nr2char(getchar())
        while answer !~? '[ny\d13\d27]'
            let answer = nr2char(getchar())
        endwhile
        redraw!
        if answer ==? 'y'
            call s:bin_sort_add_categories()
        endif
    endif
    if fence_linenr == line('$')
        " there are no categories
        echohl WarningMsg
        echom 'There are no bins where to place the items!'
        echohl Normal
        return 0
    endif
    return fence_linenr
endfunction "}}}

function! s:bin_sort_add_categories() "{{{
    let new_category = input('type new category: ')
    while !empty(new_category)
        $put = new_category
        redraw!
        let new_category = input(printf('%s was added, type new category: ',
                    \ string(new_category)))
    endwhile
    " split undo here
    let &undolevels = &undolevels
    return 1
endfunction "}}}

function! s:bin_sort_search_fence() "{{{
    let marker_re = '^=\+ Sorting Bins =\+$'
    return search(marker_re, 'ncw')
endfunction "}}}

function! votl#brainstorm#rotate(linenr) "{{{
    let pos = getcurpos()
    let fence_linenr = votl#brainstorm#bin_sort_set_up(0)
    if !fence_linenr
        call setpos('.', pos)
        return
    endif
    let before_fence = fence_linenr - 1
    let linenr = a:linenr ? a:linenr : 1
    execute printf('%s move %s', linenr, before_fence)
    call setpos('.', pos)
endfunction "}}}

function! votl#brainstorm#displace() "{{{
    let pos = getcurpos()
    let fence_linenr = votl#brainstorm#bin_sort_set_up(0)
    if !fence_linenr || getline('.') =~# '^\S'
        call setpos('.', pos)
        return
    endif
    let before_fence = fence_linenr - 1
    execute printf('%s move %s | %s<', pos[1], before_fence, fence_linenr)
    call setpos('.', pos)
endfunction "}}}

function! votl#brainstorm#place(the_bin) "{{{
    let pos = getcurpos()
    let fence_linenr = votl#brainstorm#bin_sort_set_up(0)
    if !fence_linenr || pos[1] >= fence_linenr
        call setpos('.', pos)
        return
    endif
    " Get the bins
    let bins = getline((fence_linenr + 1), '$')
    let format = '%' . (float2nr(log10(len(bins)))) . 's. %s'
    call map(bins, {idx, val -> {
                \ 'index': (idx + 1),
                \ 'linenr': (idx + fence_linenr + 1),
                \ 'name': val,
                \ 'pretty': printf(format, (idx + 1),
                \                  matchstr(val, '^\s*\zs.*'))}})
    call filter(bins, {idx, val -> val.name !~# '^\t'})
    let the_bin = a:the_bin
    if empty(the_bin)
        " let's get a name or index
        redraw!
        echo 'Sorting bins:'
        for bin in bins
            echo bin.pretty
        endfor
        let the_bin = input('enter the number or name of the bin: ')
        if empty(the_bin)
            " we got nothing, bail out
            call setpos('.', pos)
            return
        endif
    endif
    call filter(bins,
                \ {idx, val -> the_bin =~# '^\d\+$' && val.index == the_bin
                \ || stridx(tolower(val.name), tolower(the_bin)) == 0})
    redraw!
    if len(bins) != 1
        " incorrect choice of bin
        if len(bins) > 1
            let message = 'more than one bin match "%s"'
        elseif len(bins) == 0
            if the_bin =~# '^\d\+$'
                let message = 'invalid index: %s'
            else
                let message = 'no bin starts with "%s"'
            endif
        endif
        echohl WarningMsg
        echom printf(message, the_bin)
        echohl Normal
        return
    endif
    let bin = bins[0]
    let command = printf('%smove %s | %s>', pos[1], bin.linenr, bin.linenr)
    execute command
    call setpos('.', pos)
    return 1
endfunction "}}}

function! s:random_number(ceiling) "{{{
    return str2nr(matchstr(reltimestr(reltime()), '\.0*\zs\d\+')) % a:ceiling
endfunction "}}}

function! votl#brainstorm#randomize() "{{{
    let line_count = line('$')
    g/^/execute printf('.move %s', s:random_number(line_count) + 1)
endfunction "}}}
