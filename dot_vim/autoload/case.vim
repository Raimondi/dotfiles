function! case#2list(text)
    if empty(a:text)
        return a:text
    elseif a:text =~ '\C\m^\%([a-z0-9]\+\|[A-Z0-9]\+\)$'
        return a:text
    elseif a:text =~ '\C\m^[a-zA-Z][a-z0-9]*\%([A-Z][a-zA-Z0-9]*\)\+$'
        return a:text -> split('\C\m\ze[A-Z]')
                    \ ->map({ idx, val -> tolower(val) })
    elseif a:text =~ '\C\m^[a-zA-Z0-9]\+\%(-[a-zA-Z0-9]\+\)\+$'
        return a:text -> split('\C\m-')
                    \ ->map({ idx, val -> tolower(val) })
    elseif a:text =~ '\C\m^[a-zA-Z0-9]\+\%(_[a-zA-Z0-9]\+\)\+$'
        return a:text -> split('\C\m_')
                    \ ->map({ idx, val -> tolower(val) })
    elseif a:text =~ '\C\m^[a-zA-Z0-9]\+\%(|[a-zA-Z0-9]\+\)\+$'
        return a:text -> split('\C\m|')
                    \ ->map({ idx, val -> tolower(val) })
    elseif a:text =~ '\C\m^[a-zA-Z0-9]\+\%(\.[a-zA-Z0-9]\+\)\+$'
        return a:text -> split('\C\m\.')
                    \ ->map({ idx, val -> tolower(val) })
    elseif a:text =~ '\C\m^[a-zA-Z0-9]\+\%( [a-zA-Z0-9]\+\)\+$'
        return a:text -> split('\C\m ')
                    \ ->map({ idx, val -> tolower(val) })
    else
        return a:text
    endif
endfunction

function! case#2delimiter(text, delimiter)
    let words = case#2list(a:text)
    return words -> join(a:delimiter)
endfunction

function! case#2camel_delimiter(text, delimiter)
    let words = case#2list(a:text)
    return map(copy(words), { idx, val -> val
                \ -> substitute('\C\m^\a', '\u&', '')
                \ })
                \ -> join(a:delimiter)
                \ -> substitute('\C\m^\a', '\l&', '')
endfunction

function! case#2pascal_delimiter(text, delimiter)
    let words = case#2list(a:text)
    return map(copy(words), { idx, val -> val
                \ -> substitute('\C\m^\a', '\u&', '')
                \ })
                \ -> join(a:delimiter)
endfunction

function! case#2upper_delimiter(text, delimiter)
    let words = case#2list(a:text)
    return words -> join(a:delimiter) -> toupper()
endfunction

function! case#2camel(text)
    let words = case#2list(a:text)
    return map(copy(words), { idx, val -> val
                \ -> substitute('\C\m^\a', '\u&', '') })
                \ -> join('')
                \ -> substitute('\C\m^\a', '\l&', '')
endfunction

function! case#2pascal(text)
    let words = case#2list(a:text)
    return map(copy(words), { idx, val -> val
                \ -> substitute('\C\m^\a', '\u&', '')
                \ })
                \ -> join('')
endfunction

function! case#2snake(text)
    return a:text -> case#2delimiter('_')
endfunction

function! case#2camel_snake(text)
    return a:text -> case#2camel_delimiter('_')
endfunction

function! case#2pascal_snake(text)
    return a:text -> case#2pascal_delimiter('_')
endfunction

function! case#2macro(text)
    return a:text -> case#2upper_delimiter('_')
endfunction

function! case#2kebab(text)
    return a:text -> case#2delimiter('-')
endfunction

function! case#2camel_kebab(text)
    return a:text -> case#2camel_delimiter('-')
endfunction

function! case#2pascal_kebab(text)
    return a:text -> case#2pascal_delimiter('-')
endfunction

function! case#2upper_kebab(text)
    return a:text -> case#2upper_delimiter('-')
endfunction

function! case#2doner(text)
    return a:text -> case#2delimiter('|')
endfunction

function! case#2camel_doner(text)
    return a:text -> case#2camel_delimiter('|')
endfunction

function! case#2pascal_doner(text)
    return a:text -> case#2pascal_delimiter('|')
endfunction

function! case#2upper_doner(text)
    return a:text -> case#2upper_delimiter('|')
endfunction

function! case#2dot(text)
    return a:text -> case#2delimiter('.')
endfunction

function! case#2camel_dot(text)
    return a:text -> case#2camel_delimiter('.')
endfunction

function! case#2pascal_dot(text)
    return a:text -> case#2pascal_delimiter('.')
endfunction

function! case#2upper_dot(text)
    return a:text -> case#2upper_delimiter('.')
endfunction

function! case#2space(text)
    return a:text -> case#2delimiter(' ')
endfunction

function! case#2camel_space(text)
    return a:text -> case#2camel_delimiter(' ')
endfunction

function! case#2pascal_space(text)
    return a:text -> case#2pascal_delimiter(' ')
endfunction

function! case#2upper_space(text)
    return a:text -> case#2upper_delimiter(' ')
endfunction

if !exists('viml_source')
    finish
endif

let v:errors = []
for name in ['one-two-three', 'One-Two-Three',
            \ 'one_two_three', 'One_Two_Three',
            \ 'one|two|three', 'One|Two|Three',
            \ 'oneTwoThree', 'OneTwoThree',
            \]

    let expected = 'oneTwoThree'
    let result = name -> case#2camel()
    eval result -> assert_equal(expected, printf('%s -> 2camel()', name))

    let expected = 'OneTwoThree'
    let result = name -> case#2pascal()
    eval result -> assert_equal(expected, printf('%s -> 2pascal()', name))

    let expected = 'one_two_three'
    let result = name -> case#2snake()
    eval result -> assert_equal(expected, printf('%s -> 2snake()', name))

    let expected = 'one_Two_Three'
    let result = name -> case#2camel_snake()
    eval result -> assert_equal(expected, printf('%s -> 2camel_snake()', name))

    let expected = 'One_Two_Three'
    let result = name -> case#2pascal_snake()
    eval result -> assert_equal(expected, printf('%s -> 2pascal_snake()', name))

    let expected = 'ONE_TWO_THREE'
    let result = name -> case#2macro()
    eval result -> assert_equal(expected, printf('%s -> 2macro()', name))

    let expected = 'one-two-three'
    let result = name -> case#2kebab()
    eval result -> assert_equal(expected, printf('%s -> 2kebab()', name))

    let expected = 'one-Two-Three'
    let result = name -> case#2camel_kebab()
    eval result -> assert_equal(expected, printf('%s -> 2camel_kebab()', name))

    let expected = 'One-Two-Three'
    let result = name -> case#2pascal_kebab()
    eval result -> assert_equal(expected, printf('%s -> 2pascal_kebab()', name))

    let expected = 'ONE-TWO-THREE'
    let result = name -> case#2upper_kebab()
    eval result -> assert_equal(expected, printf('%s -> 2upper_kebab()', name))

    let expected = 'one|two|three'
    let result = name -> case#2doner()
    eval result -> assert_equal(expected, printf('%s -> 2doner()', name))

    let expected = 'one|Two|Three'
    let result = name -> case#2camel_doner()
    eval result -> assert_equal(expected, printf('%s -> 2camel_doner()', name))

    let expected = 'One|Two|Three'
    let result = name -> case#2pascal_doner()
    eval result -> assert_equal(expected, printf('%s -> 2pascal_doner()', name))

    let expected = 'ONE|TWO|THREE'
    let result = name -> case#2upper_doner()
    eval result -> assert_equal(expected, printf('%s -> 2upper_doner()', name))

    let expected = 'one.two.three'
    let result = name -> case#2dot()
    eval result -> assert_equal(expected, printf('%s -> 2dot()', name))

    let expected = 'one.Two.Three'
    let result = name -> case#2camel_dot()
    eval result -> assert_equal(expected, printf('%s -> 2camel_dot()', name))

    let expected = 'One.Two.Three'
    let result = name -> case#2pascal_dot()
    eval result -> assert_equal(expected, printf('%s -> 2pascal_dot()', name))

    let expected = 'ONE.TWO.THREE'
    let result = name -> case#2upper_dot()
    eval result -> assert_equal(expected, printf('%s -> 2upper_dot()', name))

    let expected = 'one two three'
    let result = name -> case#2space()
    eval result -> assert_equal(expected, printf('%s -> 2space()', name))

    let expected = 'one Two Three'
    let result = name -> case#2camel_space()
    eval result -> assert_equal(expected, printf('%s -> 2camel_space()', name))

    let expected = 'One Two Three'
    let result = name -> case#2pascal_space()
    eval result -> assert_equal(expected, printf('%s -> 2pascal_space()', name))

    let expected = 'ONE TWO THREE'
    let result = name -> case#2upper_space()
    eval result -> assert_equal(expected, printf('%s -> 2upper_space()', name))

endfor

for error in v:errors
    echohl WarningMsg
    echom error -> matchstr('line \d\+:.*')
    echohl Normal
endfor
