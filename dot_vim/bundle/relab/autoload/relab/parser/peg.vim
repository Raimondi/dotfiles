" Parser compiled on Mon Jan 25 12:18:28 2021,
" with VimPEG v0.2 and VimPEG Compiler v0.1
" from "peg.vimpeg"
" with the following grammar:

" .skip_white = true
" .namespace = 'relab#parser'
" .parser_name = 'parser'
" .root_element = 'vimregexp'
" .ignore_case = false
" .debug = true
" .verbose = 4
" 
" vimregexp ::= engine ? flag * pattern
" pattern ::= branch ( backslash_only '|' branch ) *
" branch ::= concat ( backslash_only '&' concat ) *
" concat ::= flag_or_piece +
" flag_or_piece ::= flag | piece
" ; TODO a multi can't follow another multi √
" ; TODO a multi must follow an atom √
" ; TODO lookarounds must follow an atom √
" piece ::= multi_alone | too_many_multi | propper_piece
" propper_piece ::= atom multi ?
" too_many_multi ::= atom multi multi +
" multi_alone ::= multi +
" atom ::= group | ordinary_atom
" ordinary_atom ::= optional | collection | anchor | class | literal
" 
" flag ::= magic_level | ignore_case | composing_chars
" composing_chars ::= backslash_only 'Z'
" ignore_case ::= backslash_only '[cC]'
" magic_level ::= backslash_only '[VMmv]'
" 
" ; TODO handle numbers greater than 2
" engine ::= backslash_only '@#=\d'
" 
" multi ::= maybe_many | many | maybe_one | exactly | between | at_least \
"         | at_most | wrong_multi_bracket | lookahead | negative_lookahead \
"         | lookbehind | negative_lookbehind | commit | skip_composing \
"         | wrong_at
" maybe_many ::= '\*'
" many ::= backslash_only '+'
" maybe_one ::= backslash_only '=' | backslash_only '?'
" ; TODO make sure syntax is valid for bracketed multi √
" exactly ::= backslash_only '{' '-' ? dec_number '}'
" between ::= backslash_only '{' '-' ? dec_number ',' dec_number '}'
" at_least ::= backslash_only '{' '-' ? dec_number ',}'
" at_most ::= backslash_only '{' '-' ? ',' dec_number '}'
" wrong_multi_bracket ::= backslash_only '{[^}]*}\?'
" ; TODO invalid character following a \@ √
" lookahead ::= backslash_only '@='
" negative_lookahead ::= backslash_only '@!'
" lookbehind ::= backslash_only '@' dec_number ? '<='
" negative_lookbehind ::= backslash_only '@' dec_number ? '<!'
" commit ::= backslash_only '@>'
" skip_composing ::= backslash_only '%C'
" wrong_at ::= backslash_only '@' dec_number ? '[^<>=!]'
" 
" ; TODO handle left unbalanced group √
" ; TODO handle right unbalanced group (indirect left recursive rule)
" group ::= closed_group | right_open_group
" closed_group ::= start_group pattern ? backslash_only ')'
" left_open_group ::= pattern ? backslash_only ')'
" right_open_group ::= start_group pattern ?
" ; TODO only 9 capturing groups
" start_group ::= start_capturing_group | start_non_capturing_group \
"               | start_external_capturing_group
" start_capturing_group ::= backslash_only '('
" start_non_capturing_group ::= backslash_only '%('
" start_external_capturing_group ::= backslash_only 'z('
" 
" ; TODO handle invalid items in optional group √
" ; TODO optional group can't be empty √
" optional ::= backslash_only '%\[' opt_sequence ']'
" opt_sequence ::= opt_item *
" opt_item ::= anchor | class | backref | ext_backref | collection | literal_no_square
" forbidden_in_opt ::= backslash_only '(' | backslash_only ')' \
"                    | backslash_only '%[' | multi
" 
" anchor ::= caret_or_bol | caret | dollar_or_eol | eol | any_or_eol \
"              | bow | eow | bom | eom | bof | eof | in_visual | at_cursor \
"              | at_mark | before_mark | after_mark | at_line | before_line \
"              | after_line | at_column | before_column | after_column \
"              | at_virtual_column | before_virtual_column | after_virtual_column
" caret_or_bol ::= '\^'
" bol ::= '\\_^'
" dollar_or_eol ::= '\$'
" eol ::= '\\_\$'
" any_or_eol ::= backslash_and_eol '\.'
" bow ::= backslash_only '<'
" eow ::= backslash_only '>'
" ; TODO invalid character after \z
" bom ::= backslash_only 'zs'
" eom ::= backslash_only 'ze'
" bof ::= backslash_only '%\^'
" eof ::= backslash_only '%\$'
" ; TODO invalid character after \%
" in_visual ::= backslash_only '%V'
" at_cursor ::= backslash_only '%#'
" at_mark ::= backslash_only '%' "'" '[0-9a-zA-Z<>"^.(){}[\]]'
" before_mark ::= backslash_only '%<' "'" '[0-9a-zA-Z<>"^.(){}[\]]'
" after_mark ::= backslash_only '%>' "'" '[0-9a-zA-Z<>"^.(){}[\]]'
" at_line ::= backslash_only '%' dec_number 'l'
" before_line ::= backslash_only '%<' dec_number 'l'
" after_line ::= backslash_only '%>' dec_number 'l'
" at_column ::= backslash_only '%' dec_number 'c'
" before_column ::= backslash_only '%<' dec_number 'c'
" after_column ::= backslash_only '%>' dec_number 'c'
" at_virtual_column ::= backslash_only '%' dec_number 'v'
" before_virtual_column ::= backslash_only '%<' dec_number 'v'
" after_virtual_column ::= backslash_only '%>' dec_number 'v'
" 
" class ::= ident | ident_no_digits | keyword | keyword_no_digits | fname \
"         | fname_no_digits | print | print_no_digits | whitespace \
"         | non_whitespace | digit | non_digit | hex_digit | non_hex_digit \
"         | octal_digit | non_octal_digit | word | non_word | alpha | non_alpha \
"         | lower_case | non_lower_case | upper_case | non_upper_case | any \
"         | last_sub | backref | ext_backref
" ident ::= backslash_or_eol 'i'
" ident_no_digits ::= backslash_or_eol 'I'
" keyword ::= backslash_or_eol 'k'
" keyword_no_digits ::= backslash_or_eol 'K'
" fname ::= backslash_or_eol 'f'
" fname_no_digits ::= backslash_or_eol 'F'
" print ::= backslash_or_eol 'p'
" print_no_digits ::= backslash_or_eol 'P'
" whitespace ::= backslash_or_eol 's'
" non_whitespace ::= backslash_or_eol 'S'
" digit ::= backslash_or_eol 'd'
" non_digit ::= backslash_or_eol 'D'
" hex_digit ::= backslash_or_eol 'x'
" non_hex_digit ::= backslash_or_eol 'X'
" octal_digit ::= backslash_or_eol 'o'
" non_octal_digit ::= backslash_or_eol 'O'
" word ::= backslash_or_eol 'w'
" non_word ::= backslash_or_eol 'W'
" head ::= backslash_or_eol 'h'
" non_head ::= backslash_or_eol 'H'
" alpha ::= backslash_or_eol 'a'
" non_alpha ::= backslash_or_eol 'A'
" lower_case ::= backslash_or_eol 'l'
" non_lower_case ::= backslash_or_eol 'L'
" upper_case ::= backslash_or_eol 'u'
" non_upper_case ::= backslash_or_eol 'U'
" any ::= backslash_and_eol ? '\.'
" last_sub ::= '\~'
" ; TODO make sure there are no more back refs than capt groups
" backref ::= backslash_only '[0-9]'
" ext_backref ::= backslash_only 'z[0-9]'
" 
" collection ::= coll_start coll_negation ? coll_sequence coll_end
" coll_start ::= backslash_and_eol ? '\['
" coll_negation ::= '\^'
" coll_sequence ::= coll_item +
" coll_item ::= coll_range | coll_char
" ; TODO verify range is not reversed
" coll_range ::= coll_char '-' coll_char
" coll_char ::= coll_class | coll_collation | coll_equivalence | coll_octal \
"             | coll_dec | coll_low_hex | coll_mid_hex | coll_high_hex | escape \
"             | tab | car_return | line_break | '\\-' | '\\]' | '\\\^' | coll_itself
" coll_itself ::= '[^]]'
" coll_end ::= ']'
" coll_equivalence ::= '\[=' '\a' '=]'
" coll_collation ::= '\[\.' '\a' '\.]'
" coll_class ::= '\[:' coll_class_name ':]'
" coll_class_name ::= 'alnum' | 'alpha' | 'blank' | 'cntrl' | 'digit' | 'graph' \
"                   | 'lower' | 'print' | 'punct' | 'xdigit' | 'return' | 'tab' \
"                   | 'escape' | 'backspace' | 'ident' | 'keyword' | 'fname'
" coll_octal ::= '\\o' octal_number
" coll_dec ::= '\\d' dec_number
" coll_low_hex ::= '\\x' low_hex_number
" coll_mid_hex ::= '\\u' mid_hex_number
" coll_high_hex ::= '\\U' high_hex_number
" 
" literal_no_square ::= escape | tab | car_return | line_break | caret | dollar | star \
"           | tilde | period | left_square_bracket | octal_char | dec_char \
"           | low_hex_char | mid_hex_char | high_hex_char | '[^]]'
" literal ::= escape | tab | car_return | line_break | caret | dollar | star \
"           | tilde | period | left_square_bracket | octal_char | dec_char \
"           | low_hex_char | mid_hex_char | high_hex_char | invalid_octal_char \
"           | invalid_dec_char | invalid_hex_char | itself
" itself ::= !'\\[()|&]' '.'
" escape ::= backslash_only 'e'
" tab ::= backslash_only 't'
" car_return ::= backslash_only 'r'
" line_break ::= backslash_only 'n'
" caret ::= backslash_only '\^'
" dollar ::= backslash_only '\$'
" star ::= '\*'
" tilde ::= '\~'
" period ::= backslash_only '\.'
" left_square_bracket ::= backslash_only '\['
" ; TODO invalid character after \%[odxuU]
" octal_char ::= backslash_only '%o' octal_number
" dec_char ::= backslash_only '%d' dec_number
" low_hex_char ::= backslash_only '%x' low_hex_number
" mid_hex_char ::= backslash_only '%u' mid_hex_number
" high_hex_char ::= backslash_only '%U' high_hex_number
" invalid_octal_char ::= backslash_only '%o' '\O'
" invalid_dec_char ::= backslash_only '%d' '\D'
" invalid_hex_char ::= backslash_only '%[xuU]' '\X'
" 
" 
" octal_number ::= '[123]\o\o' | '\o\{1,2}'
" dec_number ::= '\d\+'
" low_hex_number ::= '\x\{1,2}'
" mid_hex_number ::= '\x\{1,4}'
" high_hex_number ::= '\x\{1,8}'
" 
" backslash_only ::= backslash bad_underscore | backslash
" bad_underscore ::= '_'
" backslash_or_eol ::= backslash_and_eol | backslash
" ; TODO not all \ can be turned into \_
" backslash_and_eol ::= backslash '_'
" backslash ::= '\\'

let s:p = vimpeg#parser({
      \ 'root_element': get(g:, 'relab#parser#peg#root_element', 'vimregexp'),
      \ 'skip_white': get(g:, 'relab#parser#peg#skip_white', 1),
      \ 'ignore_case': get(g:, 'relab#parser#peg#ignore_case', 0),
      \ 'verbose': get(g:, 'relab#parser#peg#verbose', 4),
      \ 'parser_name': get(g:, 'relab#parser#peg#parser_name', 'parser'),
      \ 'namespace': get(g:, 'relab#parser#peg#namespace', 'relab#parser'),
      \ 'debug': get(g:, 'relab#parser#peg#debug', 1),
      \ })
call s:p.and([s:p.maybe_one('engine'), s:p.maybe_many('flag'), 'pattern'],
      \{'id': 'vimregexp'})
call s:p.and(['branch', s:p.maybe_many(s:p.and(['backslash_only', s:p.e('|'), 'branch']))],
      \{'id': 'pattern'})
call s:p.and(['concat', s:p.maybe_many(s:p.and(['backslash_only', s:p.e('&'), 'concat']))],
      \{'id': 'branch'})
call s:p.many('flag_or_piece',
      \{'id': 'concat'})
call s:p.or(['flag', 'piece'],
      \{'id': 'flag_or_piece'})



call s:p.or(['multi_alone', 'too_many_multi', 'propper_piece'],
      \{'id': 'piece'})
call s:p.and(['atom', s:p.maybe_one('multi')],
      \{'id': 'propper_piece'})
call s:p.and(['atom', 'multi', s:p.many('multi')],
      \{'id': 'too_many_multi'})
call s:p.many('multi',
      \{'id': 'multi_alone'})
call s:p.or(['group', 'ordinary_atom'],
      \{'id': 'atom'})
call s:p.or(['optional', 'collection', 'anchor', 'class', 'literal'],
      \{'id': 'ordinary_atom'})

call s:p.or(['magic_level', 'ignore_case', 'composing_chars'],
      \{'id': 'flag'})
call s:p.and(['backslash_only', s:p.e('Z')],
      \{'id': 'composing_chars'})
call s:p.and(['backslash_only', s:p.e('[cC]')],
      \{'id': 'ignore_case'})
call s:p.and(['backslash_only', s:p.e('[VMmv]')],
      \{'id': 'magic_level'})


call s:p.and(['backslash_only', s:p.e('@#=\d')],
      \{'id': 'engine'})

call s:p.or(['maybe_many', 'many', 'maybe_one', 'exactly', 'between', 'at_least', 'at_most', 'wrong_multi_bracket', 'lookahead', 'negative_lookahead', 'lookbehind', 'negative_lookbehind', 'commit', 'skip_composing', 'wrong_at'],
      \{'id': 'multi'})
call s:p.e('\*',
      \{'id': 'maybe_many'})
call s:p.and(['backslash_only', s:p.e('+')],
      \{'id': 'many'})
call s:p.or([s:p.and(['backslash_only', s:p.e('=')]), s:p.and(['backslash_only', s:p.e('?')])],
      \{'id': 'maybe_one'})

call s:p.and(['backslash_only', s:p.e('{'), s:p.maybe_one(s:p.e('-')), 'dec_number', s:p.e('}')],
      \{'id': 'exactly'})
call s:p.and(['backslash_only', s:p.e('{'), s:p.maybe_one(s:p.e('-')), 'dec_number', s:p.e(','), 'dec_number', s:p.e('}')],
      \{'id': 'between'})
call s:p.and(['backslash_only', s:p.e('{'), s:p.maybe_one(s:p.e('-')), 'dec_number', s:p.e(',}')],
      \{'id': 'at_least'})
call s:p.and(['backslash_only', s:p.e('{'), s:p.maybe_one(s:p.e('-')), s:p.e(','), 'dec_number', s:p.e('}')],
      \{'id': 'at_most'})
call s:p.and(['backslash_only', s:p.e('{[^}]*}\?')],
      \{'id': 'wrong_multi_bracket'})

call s:p.and(['backslash_only', s:p.e('@=')],
      \{'id': 'lookahead'})
call s:p.and(['backslash_only', s:p.e('@!')],
      \{'id': 'negative_lookahead'})
call s:p.and(['backslash_only', s:p.e('@'), s:p.maybe_one('dec_number'), s:p.e('<=')],
      \{'id': 'lookbehind'})
call s:p.and(['backslash_only', s:p.e('@'), s:p.maybe_one('dec_number'), s:p.e('<!')],
      \{'id': 'negative_lookbehind'})
call s:p.and(['backslash_only', s:p.e('@>')],
      \{'id': 'commit'})
call s:p.and(['backslash_only', s:p.e('%C')],
      \{'id': 'skip_composing'})
call s:p.and(['backslash_only', s:p.e('@'), s:p.maybe_one('dec_number'), s:p.e('[^<>=!]')],
      \{'id': 'wrong_at'})



call s:p.or(['closed_group', 'right_open_group'],
      \{'id': 'group'})
call s:p.and(['start_group', s:p.maybe_one('pattern'), 'backslash_only', s:p.e(')')],
      \{'id': 'closed_group'})
call s:p.and([s:p.maybe_one('pattern'), 'backslash_only', s:p.e(')')],
      \{'id': 'left_open_group'})
call s:p.and(['start_group', s:p.maybe_one('pattern')],
      \{'id': 'right_open_group'})

call s:p.or(['start_capturing_group', 'start_non_capturing_group', 'start_external_capturing_group'],
      \{'id': 'start_group'})
call s:p.and(['backslash_only', s:p.e('(')],
      \{'id': 'start_capturing_group'})
call s:p.and(['backslash_only', s:p.e('%(')],
      \{'id': 'start_non_capturing_group'})
call s:p.and(['backslash_only', s:p.e('z(')],
      \{'id': 'start_external_capturing_group'})



call s:p.and(['backslash_only', s:p.e('%\['), 'opt_sequence', s:p.e(']')],
      \{'id': 'optional'})
call s:p.maybe_many('opt_item',
      \{'id': 'opt_sequence'})
call s:p.or(['anchor', 'class', 'backref', 'ext_backref', 'collection', 'literal_no_square'],
      \{'id': 'opt_item'})
call s:p.or([s:p.and(['backslash_only', s:p.e('(')]), s:p.and(['backslash_only', s:p.e(')')]), s:p.and(['backslash_only', s:p.e('%[')]), 'multi'],
      \{'id': 'forbidden_in_opt'})

call s:p.or(['caret_or_bol', 'caret', 'dollar_or_eol', 'eol', 'any_or_eol', 'bow', 'eow', 'bom', 'eom', 'bof', 'eof', 'in_visual', 'at_cursor', 'at_mark', 'before_mark', 'after_mark', 'at_line', 'before_line', 'after_line', 'at_column', 'before_column', 'after_column', 'at_virtual_column', 'before_virtual_column', 'after_virtual_column'],
      \{'id': 'anchor'})
call s:p.e('\^',
      \{'id': 'caret_or_bol'})
call s:p.e('\\_^',
      \{'id': 'bol'})
call s:p.e('\$',
      \{'id': 'dollar_or_eol'})
call s:p.e('\\_\$',
      \{'id': 'eol'})
call s:p.and(['backslash_and_eol', s:p.e('\.')],
      \{'id': 'any_or_eol'})
call s:p.and(['backslash_only', s:p.e('<')],
      \{'id': 'bow'})
call s:p.and(['backslash_only', s:p.e('>')],
      \{'id': 'eow'})

call s:p.and(['backslash_only', s:p.e('zs')],
      \{'id': 'bom'})
call s:p.and(['backslash_only', s:p.e('ze')],
      \{'id': 'eom'})
call s:p.and(['backslash_only', s:p.e('%\^')],
      \{'id': 'bof'})
call s:p.and(['backslash_only', s:p.e('%\$')],
      \{'id': 'eof'})

call s:p.and(['backslash_only', s:p.e('%V')],
      \{'id': 'in_visual'})
call s:p.and(['backslash_only', s:p.e('%#')],
      \{'id': 'at_cursor'})
call s:p.and(['backslash_only', s:p.e('%'), s:p.e("'"), s:p.e('[0-9a-zA-Z<>"^.(){}[\]]')],
      \{'id': 'at_mark'})
call s:p.and(['backslash_only', s:p.e('%<'), s:p.e("'"), s:p.e('[0-9a-zA-Z<>"^.(){}[\]]')],
      \{'id': 'before_mark'})
call s:p.and(['backslash_only', s:p.e('%>'), s:p.e("'"), s:p.e('[0-9a-zA-Z<>"^.(){}[\]]')],
      \{'id': 'after_mark'})
call s:p.and(['backslash_only', s:p.e('%'), 'dec_number', s:p.e('l')],
      \{'id': 'at_line'})
call s:p.and(['backslash_only', s:p.e('%<'), 'dec_number', s:p.e('l')],
      \{'id': 'before_line'})
call s:p.and(['backslash_only', s:p.e('%>'), 'dec_number', s:p.e('l')],
      \{'id': 'after_line'})
call s:p.and(['backslash_only', s:p.e('%'), 'dec_number', s:p.e('c')],
      \{'id': 'at_column'})
call s:p.and(['backslash_only', s:p.e('%<'), 'dec_number', s:p.e('c')],
      \{'id': 'before_column'})
call s:p.and(['backslash_only', s:p.e('%>'), 'dec_number', s:p.e('c')],
      \{'id': 'after_column'})
call s:p.and(['backslash_only', s:p.e('%'), 'dec_number', s:p.e('v')],
      \{'id': 'at_virtual_column'})
call s:p.and(['backslash_only', s:p.e('%<'), 'dec_number', s:p.e('v')],
      \{'id': 'before_virtual_column'})
call s:p.and(['backslash_only', s:p.e('%>'), 'dec_number', s:p.e('v')],
      \{'id': 'after_virtual_column'})

call s:p.or(['ident', 'ident_no_digits', 'keyword', 'keyword_no_digits', 'fname', 'fname_no_digits', 'print', 'print_no_digits', 'whitespace', 'non_whitespace', 'digit', 'non_digit', 'hex_digit', 'non_hex_digit', 'octal_digit', 'non_octal_digit', 'word', 'non_word', 'alpha', 'non_alpha', 'lower_case', 'non_lower_case', 'upper_case', 'non_upper_case', 'any', 'last_sub', 'backref', 'ext_backref'],
      \{'id': 'class'})
call s:p.and(['backslash_or_eol', s:p.e('i')],
      \{'id': 'ident'})
call s:p.and(['backslash_or_eol', s:p.e('I')],
      \{'id': 'ident_no_digits'})
call s:p.and(['backslash_or_eol', s:p.e('k')],
      \{'id': 'keyword'})
call s:p.and(['backslash_or_eol', s:p.e('K')],
      \{'id': 'keyword_no_digits'})
call s:p.and(['backslash_or_eol', s:p.e('f')],
      \{'id': 'fname'})
call s:p.and(['backslash_or_eol', s:p.e('F')],
      \{'id': 'fname_no_digits'})
call s:p.and(['backslash_or_eol', s:p.e('p')],
      \{'id': 'print'})
call s:p.and(['backslash_or_eol', s:p.e('P')],
      \{'id': 'print_no_digits'})
call s:p.and(['backslash_or_eol', s:p.e('s')],
      \{'id': 'whitespace'})
call s:p.and(['backslash_or_eol', s:p.e('S')],
      \{'id': 'non_whitespace'})
call s:p.and(['backslash_or_eol', s:p.e('d')],
      \{'id': 'digit'})
call s:p.and(['backslash_or_eol', s:p.e('D')],
      \{'id': 'non_digit'})
call s:p.and(['backslash_or_eol', s:p.e('x')],
      \{'id': 'hex_digit'})
call s:p.and(['backslash_or_eol', s:p.e('X')],
      \{'id': 'non_hex_digit'})
call s:p.and(['backslash_or_eol', s:p.e('o')],
      \{'id': 'octal_digit'})
call s:p.and(['backslash_or_eol', s:p.e('O')],
      \{'id': 'non_octal_digit'})
call s:p.and(['backslash_or_eol', s:p.e('w')],
      \{'id': 'word'})
call s:p.and(['backslash_or_eol', s:p.e('W')],
      \{'id': 'non_word'})
call s:p.and(['backslash_or_eol', s:p.e('h')],
      \{'id': 'head'})
call s:p.and(['backslash_or_eol', s:p.e('H')],
      \{'id': 'non_head'})
call s:p.and(['backslash_or_eol', s:p.e('a')],
      \{'id': 'alpha'})
call s:p.and(['backslash_or_eol', s:p.e('A')],
      \{'id': 'non_alpha'})
call s:p.and(['backslash_or_eol', s:p.e('l')],
      \{'id': 'lower_case'})
call s:p.and(['backslash_or_eol', s:p.e('L')],
      \{'id': 'non_lower_case'})
call s:p.and(['backslash_or_eol', s:p.e('u')],
      \{'id': 'upper_case'})
call s:p.and(['backslash_or_eol', s:p.e('U')],
      \{'id': 'non_upper_case'})
call s:p.and([s:p.maybe_one('backslash_and_eol'), s:p.e('\.')],
      \{'id': 'any'})
call s:p.e('\~',
      \{'id': 'last_sub'})

call s:p.and(['backslash_only', s:p.e('[0-9]')],
      \{'id': 'backref'})
call s:p.and(['backslash_only', s:p.e('z[0-9]')],
      \{'id': 'ext_backref'})

call s:p.and(['coll_start', s:p.maybe_one('coll_negation'), 'coll_sequence', 'coll_end'],
      \{'id': 'collection'})
call s:p.and([s:p.maybe_one('backslash_and_eol'), s:p.e('\[')],
      \{'id': 'coll_start'})
call s:p.e('\^',
      \{'id': 'coll_negation'})
call s:p.many('coll_item',
      \{'id': 'coll_sequence'})
call s:p.or(['coll_range', 'coll_char'],
      \{'id': 'coll_item'})

call s:p.and(['coll_char', s:p.e('-'), 'coll_char'],
      \{'id': 'coll_range'})
call s:p.or(['coll_class', 'coll_collation', 'coll_equivalence', 'coll_octal', 'coll_dec', 'coll_low_hex', 'coll_mid_hex', 'coll_high_hex', 'escape', 'tab', 'car_return', 'line_break', s:p.e('\\-'), s:p.e('\\]'), s:p.e('\\\^'), 'coll_itself'],
      \{'id': 'coll_char'})
call s:p.e('[^]]',
      \{'id': 'coll_itself'})
call s:p.e(']',
      \{'id': 'coll_end'})
call s:p.and([s:p.e('\[='), s:p.e('\a'), s:p.e('=]')],
      \{'id': 'coll_equivalence'})
call s:p.and([s:p.e('\[\.'), s:p.e('\a'), s:p.e('\.]')],
      \{'id': 'coll_collation'})
call s:p.and([s:p.e('\[:'), 'coll_class_name', s:p.e(':]')],
      \{'id': 'coll_class'})
call s:p.or([s:p.e('alnum'), s:p.e('alpha'), s:p.e('blank'), s:p.e('cntrl'), s:p.e('digit'), s:p.e('graph'), s:p.e('lower'), s:p.e('print'), s:p.e('punct'), s:p.e('xdigit'), s:p.e('return'), s:p.e('tab'), s:p.e('escape'), s:p.e('backspace'), s:p.e('ident'), s:p.e('keyword'), s:p.e('fname')],
      \{'id': 'coll_class_name'})
call s:p.and([s:p.e('\\o'), 'octal_number'],
      \{'id': 'coll_octal'})
call s:p.and([s:p.e('\\d'), 'dec_number'],
      \{'id': 'coll_dec'})
call s:p.and([s:p.e('\\x'), 'low_hex_number'],
      \{'id': 'coll_low_hex'})
call s:p.and([s:p.e('\\u'), 'mid_hex_number'],
      \{'id': 'coll_mid_hex'})
call s:p.and([s:p.e('\\U'), 'high_hex_number'],
      \{'id': 'coll_high_hex'})

call s:p.or(['escape', 'tab', 'car_return', 'line_break', 'caret', 'dollar', 'star', 'tilde', 'period', 'left_square_bracket', 'octal_char', 'dec_char', 'low_hex_char', 'mid_hex_char', 'high_hex_char', s:p.e('[^]]')],
      \{'id': 'literal_no_square'})
call s:p.or(['escape', 'tab', 'car_return', 'line_break', 'caret', 'dollar', 'star', 'tilde', 'period', 'left_square_bracket', 'octal_char', 'dec_char', 'low_hex_char', 'mid_hex_char', 'high_hex_char', 'invalid_octal_char', 'invalid_dec_char', 'invalid_hex_char', 'itself'],
      \{'id': 'literal'})
call s:p.and([s:p.not_has(s:p.e('\\[()|&]')), s:p.e('.')],
      \{'id': 'itself'})
call s:p.and(['backslash_only', s:p.e('e')],
      \{'id': 'escape'})
call s:p.and(['backslash_only', s:p.e('t')],
      \{'id': 'tab'})
call s:p.and(['backslash_only', s:p.e('r')],
      \{'id': 'car_return'})
call s:p.and(['backslash_only', s:p.e('n')],
      \{'id': 'line_break'})
call s:p.and(['backslash_only', s:p.e('\^')],
      \{'id': 'caret'})
call s:p.and(['backslash_only', s:p.e('\$')],
      \{'id': 'dollar'})
call s:p.e('\*',
      \{'id': 'star'})
call s:p.e('\~',
      \{'id': 'tilde'})
call s:p.and(['backslash_only', s:p.e('\.')],
      \{'id': 'period'})
call s:p.and(['backslash_only', s:p.e('\[')],
      \{'id': 'left_square_bracket'})

call s:p.and(['backslash_only', s:p.e('%o'), 'octal_number'],
      \{'id': 'octal_char'})
call s:p.and(['backslash_only', s:p.e('%d'), 'dec_number'],
      \{'id': 'dec_char'})
call s:p.and(['backslash_only', s:p.e('%x'), 'low_hex_number'],
      \{'id': 'low_hex_char'})
call s:p.and(['backslash_only', s:p.e('%u'), 'mid_hex_number'],
      \{'id': 'mid_hex_char'})
call s:p.and(['backslash_only', s:p.e('%U'), 'high_hex_number'],
      \{'id': 'high_hex_char'})
call s:p.and(['backslash_only', s:p.e('%o'), s:p.e('\O')],
      \{'id': 'invalid_octal_char'})
call s:p.and(['backslash_only', s:p.e('%d'), s:p.e('\D')],
      \{'id': 'invalid_dec_char'})
call s:p.and(['backslash_only', s:p.e('%[xuU]'), s:p.e('\X')],
      \{'id': 'invalid_hex_char'})


call s:p.or([s:p.e('[123]\o\o'), s:p.e('\o\{1,2}')],
      \{'id': 'octal_number'})
call s:p.e('\d\+',
      \{'id': 'dec_number'})
call s:p.e('\x\{1,2}',
      \{'id': 'low_hex_number'})
call s:p.e('\x\{1,4}',
      \{'id': 'mid_hex_number'})
call s:p.e('\x\{1,8}',
      \{'id': 'high_hex_number'})

call s:p.or([s:p.and(['backslash', 'bad_underscore']), 'backslash'],
      \{'id': 'backslash_only'})
call s:p.e('_',
      \{'id': 'bad_underscore'})
call s:p.or(['backslash_and_eol', 'backslash'],
      \{'id': 'backslash_or_eol'})

call s:p.and(['backslash', s:p.e('_')],
      \{'id': 'backslash_and_eol'})
call s:p.e('\\',
      \{'id': 'backslash'})

let g:relab#parser#peg#parser = s:p.GetSym('vimregexp')
function! relab#parser#peg#parse(input)
  if type(a:input) != type('')
    echohl ErrorMsg
    echom 'VimPEG: Input must be a string.'
    echohl NONE
    return []
  endif
  return g:relab#parser#peg#parser.match(a:input)
endfunction
function! relab#parser#peg#parser()
  return deepcopy(g:relab#parser#peg#parser)
endfunction
