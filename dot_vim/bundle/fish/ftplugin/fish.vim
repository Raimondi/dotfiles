setlocal comments=:#
setlocal commentstring=#%s
setlocal define=\\v^\\s*function>
setlocal foldexpr=fish#Fold()
setlocal foldmethod=expr
setlocal formatoptions+=ron1
setlocal formatoptions-=t
setlocal include=\\v^\\s*\\.>
setlocal iskeyword=@,48-57,-,_,.,/
setlocal suffixesadd^=.fish

" Use the 'j' format option when available.
if v:version ># 703 || v:version ==# 703 && has('patch541')
    setlocal formatoptions+=j
endif

if executable('fish_indent')
    setlocal formatexpr=
    setlocal formatprg=fish_indent
endif

if executable('fish')
    setlocal omnifunc=fish#Complete
    for s:path in split(system("fish -c 'echo $fish_function_path'"))
        execute 'setlocal path+='.s:path
    endfor
else
    setlocal omnifunc=syntaxcomplete#Complete
endif

" Use the 'man' wrapper function in fish to include fish's man pages.
" Have to use a script for this; 'fish -c man' would make the the man page an
" argument to fish instead of man.
execute 'setlocal keywordprg=fish\ '.expand('<sfile>:p:h:h').'/bin/man.fish'

let b:match_ignorecase = 0
if has('patch-7.3.1037')
    let s:if = '\%(else\s\+\)\@15<!if'
else
    let s:if = '\%(else\s\+\)\@<!if'
endif

let b:match_words =
            \ '\<\%(begin\|function\|'.s:if.'\|switch\|while\|for\)\>'
            \.':\<\%(else\%(\s*if\)\?\|case\)\>:\<end\>'

let b:endwise_addition = 'end'
let b:endwise_words = 'begin,function,if,switch,while,for'
let b:endwise_syngroups = 'fishKeyword,fishConditional,fishRepeat'
