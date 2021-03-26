function! cscheck#run()
endfunction

let s:default_hl_groups = [
      \ 'ColorColumn',
      \ 'Conceal',
      \ 'Cursor',
      \ 'CursorIM',
      \ 'CursorColumn',
      \ 'CursorLine',
      \ 'Directory',
      \ 'DiffAdd',
      \ 'DiffChange',
      \ 'DiffDelete',
      \ 'DiffText',
      \ 'EndOfBuffer',
      \ 'ErrorMsg',
      \ 'VertSplit',
      \ 'Folded',
      \ 'FoldColumn',
      \ 'SignColumn',
      \ 'IncSearch',
      \ 'LineNr',
      \ 'CursorLineNr',
      \ 'MatchParen',
      \ 'ModeMsg',
      \ 'MoreMsg',
      \ 'NonText',
      \ 'Normal',
      \ 'Pmenu',
      \ 'PmenuSel',
      \ 'PmenuSbar',
      \ 'PmenuThumb',
      \ 'Question',
      \ 'QuickFixLine',
      \ 'Search',
      \ 'SpecialKey',
      \ 'SpellBad',
      \ 'SpellCap',
      \ 'SpellLocal',
      \ 'SpellRare',
      \ 'StatusLine',
      \ 'StatusLineNC',
      \ 'TabLine',
      \ 'TabLineFill',
      \ 'TabLineSel',
      \ 'Title',
      \ 'Visual',
      \ 'VisualNOS',
      \ 'WarningMsg',
      \ 'WildMenu',
      \ 'Menu',
      \ 'Scrollbar',
      \ 'Tooltip',
      \]

function! cscheck#hlgroups()
  let lines = split(execute('verb hi'), '\n')
  let groups = {}
  let current = {}
  let n = 0
  while !empty(lines)
    let line = remove(lines, 0)
    let current = {
          \ 'name': matchstr(line, '\m^\w\+'),
          \ 'path': '',
          \ 'cleared': 0,
          \ 'link': '',
          \ 'term': '',
          \ 'start': '',
          \ 'stop': '',
          \ 'cterm': '',
          \ 'ctermfg': '',
          \ 'ctermbg': '',
          \ 'gui': '',
          \ 'font': '',
          \ 'guifg': '',
          \ 'guibg': '',
          \ 'guisp': '',
          \}
    if get(lines, 0, '') =~# '\m^\s\+'
      let current.path = matchstr(remove(lines, 0), '^\s\+Last\s\+set\s\+from\s\+\zs.*')
      let current.path = fnamemodify(current.path, ':p')
    endif
    let rest = matchstr(line, '\m^\w\+\s\+xxx\s\+\zs.*')
    if rest =~# '^cleared'
      let current.cleared = 1
    endif
    if rest =~# '^links\s\+to'
      let current.link = matchstr(rest, '\m^links\s\+to\s\+\zs\w\+')
    endif
    if rest =~# '='
      let fontpat = '\m\C\<font=\zs\%(''\%([^'']\|''''\)''\|\S\+\)'
      let font = matchstr(rest, fontpat)
      let rest = substitute(rest, fontpat, '', '')
      let pairs = split(rest, '\s\+')
      call map(pairs, 'split(v:val, ''='', 1)')
      for pair in pairs
        let current[pair[0]] = pair[1]
      endfor
      let current.font = font
    endif
    if get(lines, 0, 'x') =~# '\m^\w'
      let groups[current.name] = current
    endif
    endwhile
    return groups
endfunction

finish
SpecialKey     xxx term=bold ctermfg=81 guifg=CornFlowerBlue
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
EndOfBuffer    xxx links to NonText
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
NonText        xxx term=bold ctermfg=12 gui=bold guifg=CornFlowerBlue
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
Directory      xxx term=bold ctermfg=159 guifg=Cyan
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
ErrorMsg       xxx term=standout ctermfg=15 ctermbg=1 guifg=White guibg=Red
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
IncSearch      xxx term=reverse cterm=reverse gui=reverse guifg=MediumSlateBlue guibg=White
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
Search         xxx term=reverse ctermfg=0 ctermbg=11 guifg=White guibg=MediumSlateBlue
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
MoreMsg        xxx term=bold ctermfg=121 gui=bold guifg=SeaGreen
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
ModeMsg        xxx term=bold cterm=bold gui=bold
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
LineNr         xxx term=underline ctermfg=11 guifg=DimGray
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
CursorLineNr   xxx term=bold ctermfg=11 gui=bold guifg=Yellow
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
Question       xxx term=standout ctermfg=121 gui=bold guifg=Green
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
StatusLine     xxx term=bold,reverse cterm=bold,reverse gui=bold,reverse guifg=DimGray guibg=Black
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
StatusLineNC   xxx term=reverse cterm=reverse gui=reverse guifg=DimGray guibg=Black
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
VertSplit      xxx term=reverse cterm=reverse gui=reverse
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
Title          xxx term=bold ctermfg=225 gui=bold guifg=White
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
Visual         xxx term=reverse ctermbg=242 guibg=Gray14
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
VisualNOS      xxx term=bold,underline cterm=bold,underline gui=bold,underline
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
WarningMsg     xxx term=standout ctermfg=224 guifg=Red
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
WildMenu       xxx term=standout ctermfg=0 ctermbg=11 guifg=Black guibg=Yellow
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
Folded         xxx term=standout ctermfg=14 ctermbg=242 guifg=CornFlowerBlue guibg=Black
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
FoldColumn     xxx term=standout ctermfg=14 ctermbg=242 guifg=Cyan guibg=Grey
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
DiffAdd        xxx term=bold ctermbg=4 guibg=DarkBlue
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
DiffChange     xxx term=bold ctermbg=5 guibg=DarkMagenta
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
DiffDelete     xxx term=bold ctermfg=12 ctermbg=6 gui=bold guifg=Blue guibg=DarkCyan
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
DiffText       xxx term=reverse cterm=bold ctermbg=9 gui=bold guibg=Red
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
SignColumn     xxx term=standout ctermfg=14 ctermbg=242 guifg=Cyan guibg=Grey
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
Conceal        xxx ctermfg=7 ctermbg=242 guifg=LightGrey guibg=DarkGrey
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
SpellBad       xxx term=reverse ctermbg=9 gui=undercurl guisp=Red
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
SpellCap       xxx term=reverse ctermbg=12 gui=undercurl guisp=Blue
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
SpellRare      xxx term=reverse ctermbg=13 gui=undercurl guisp=Magenta
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
SpellLocal     xxx term=underline ctermbg=14 gui=undercurl guisp=Cyan
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
Pmenu          xxx ctermfg=0 ctermbg=13 guifg=Black guibg=LightGray
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
PmenuSel       xxx ctermfg=242 ctermbg=0 guifg=White guibg=MediumSlateBlue
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
PmenuSbar      xxx ctermbg=248 guibg=Grey
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
PmenuThumb     xxx ctermbg=15 guibg=White
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
TabLine        xxx term=underline cterm=underline ctermfg=15 ctermbg=242 gui=underline guibg=DarkGrey
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
TabLineSel     xxx term=bold cterm=bold gui=bold
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
TabLineFill    xxx term=reverse cterm=reverse gui=reverse
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
CursorColumn   xxx term=reverse ctermbg=242 guibg=Grey40
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
CursorLine     xxx term=underline cterm=underline guibg=Grey15
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
ColorColumn    xxx term=reverse ctermbg=1 guibg=DarkRed
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
QuickFixLine   xxx links to Search
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
MatchParen     xxx term=reverse ctermbg=6 guibg=DarkCyan
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
Comment        xxx term=bold ctermfg=14 guifg=CornFlowerBlue
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
Constant       xxx term=underline ctermfg=13 guifg=LightSeaGreen
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
Special        xxx term=bold ctermfg=224 guifg=MediumSlateBlue
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
Identifier     xxx term=underline cterm=bold ctermfg=14 guifg=LightGreen
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
Statement      xxx term=bold ctermfg=11 gui=bold guifg=Turquoise1
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
PreProc        xxx term=underline ctermfg=81 guifg=LightSeaGreen
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
Type           xxx term=underline ctermfg=121 gui=bold guifg=White
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
Underlined     xxx term=underline cterm=underline ctermfg=81 gui=underline guifg=#80a0ff
	Last set from /opt/local/share/vim/vim80/syntax/syncolor.vim
Ignore         xxx ctermfg=0 guifg=bg
	Last set from /opt/local/share/vim/vim80/syntax/syncolor.vim
Error          xxx term=reverse ctermfg=15 ctermbg=9 guifg=White guibg=Red
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
Todo           xxx term=standout ctermfg=0 ctermbg=11 guifg=White guibg=Red
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
String         xxx links to Constant
	Last set from /opt/local/share/vim/vim80/syntax/syncolor.vim
Character      xxx links to Constant
	Last set from /opt/local/share/vim/vim80/syntax/syncolor.vim
Number         xxx links to Constant
	Last set from /opt/local/share/vim/vim80/syntax/syncolor.vim
Boolean        xxx links to Constant
	Last set from /opt/local/share/vim/vim80/syntax/syncolor.vim
Float          xxx links to Number
	Last set from /opt/local/share/vim/vim80/syntax/syncolor.vim
Function       xxx guifg=LightGreen
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
Conditional    xxx links to Statement
	Last set from /opt/local/share/vim/vim80/syntax/syncolor.vim
Repeat         xxx links to Statement
	Last set from /opt/local/share/vim/vim80/syntax/syncolor.vim
Label          xxx links to Statement
	Last set from /opt/local/share/vim/vim80/syntax/syncolor.vim
Operator       xxx links to Statement
	Last set from /opt/local/share/vim/vim80/syntax/syncolor.vim
Keyword        xxx links to Statement
	Last set from /opt/local/share/vim/vim80/syntax/syncolor.vim
Exception      xxx links to Statement
	Last set from /opt/local/share/vim/vim80/syntax/syncolor.vim
Include        xxx guifg=SpringGreen4
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
Define         xxx guifg=SpringGreen4
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
Macro          xxx guifg=SpringGreen4
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
PreCondit      xxx guifg=SpringGreen4
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
StorageClass   xxx links to Type
	Last set from /opt/local/share/vim/vim80/syntax/syncolor.vim
Structure      xxx links to Type
	Last set from /opt/local/share/vim/vim80/syntax/syncolor.vim
Typedef        xxx links to Type
	Last set from /opt/local/share/vim/vim80/syntax/syncolor.vim
Tag            xxx links to Special
	Last set from /opt/local/share/vim/vim80/syntax/syncolor.vim
SpecialChar    xxx links to Special
	Last set from /opt/local/share/vim/vim80/syntax/syncolor.vim
Delimiter      xxx links to Special
	Last set from /opt/local/share/vim/vim80/syntax/syncolor.vim
SpecialComment xxx links to Special
	Last set from /opt/local/share/vim/vim80/syntax/syncolor.vim
Debug          xxx links to Special
	Last set from /opt/local/share/vim/vim80/syntax/syncolor.vim
Normal         xxx guifg=LightGray guibg=Black
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
Cursor         xxx guibg=LimeGreen
	Last set from ~/Documents/Source/dotvim/bundle/aquamarine/colors/aquamarine.vim
OperatorSandwichBuns xxx links to IncSearch
	Last set from ~/Documents/Source/vim-sandwich/plugin/operator/sandwich.vim
OperatorSandwichAdd xxx links to DiffAdd
	Last set from ~/Documents/Source/vim-sandwich/plugin/operator/sandwich.vim
OperatorSandwichDelete xxx links to DiffDelete
	Last set from ~/Documents/Source/vim-sandwich/plugin/operator/sandwich.vim
OperatorSandwichChange xxx links to DiffChange
	Last set from ~/Documents/Source/vim-sandwich/plugin/operator/sandwich.vim
vimTodo        xxx links to Todo
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimCommand     xxx links to Statement
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimStdPlugin   xxx cleared
vimOption      xxx links to PreProc
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimErrSetting  xxx links to vimError
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimAutoEvent   xxx links to Type
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimGroup       xxx links to Type
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimHLGroup     xxx links to vimGroup
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimFuncName    xxx links to Function
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimGlobal      xxx cleared
vimSubst       xxx links to vimCommand
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimNumber      xxx links to Number
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimAddress     xxx links to vimMark
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimAutoCmd     xxx links to vimCommand
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimIsCommand   xxx cleared
vimExtCmd      xxx cleared
vimFilter      xxx cleared
vimLet         xxx links to vimCommand
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimMap         xxx links to vimCommand
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimMark        xxx links to Number
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSet         xxx cleared
vimSyntax      xxx links to vimCommand
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimUserCmd     xxx cleared
vimCmdSep      xxx cleared
vimVar         xxx links to Identifier
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimFBVar       xxx links to vimVar
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimInsert      xxx links to vimString
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimBehaveModel xxx links to vimBehave
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimBehaveError xxx links to vimError
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimBehave      xxx links to vimCommand
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimFTCmd       xxx links to vimCommand
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimFTOption    xxx links to vimSynType
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimFTError     xxx links to vimError
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimFiletype    xxx cleared
vimAugroup     xxx cleared
vimExecute     xxx cleared
vimNotFunc     xxx links to vimCommand
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimFunction    xxx cleared
vimFunctionError xxx links to vimError
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimLineComment xxx links to vimComment
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSpecFile    xxx links to Identifier
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimOper        xxx links to Operator
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimOperParen   xxx cleared
vimComment     xxx links to Comment
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimString      xxx links to String
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimRegister    xxx links to SpecialChar
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimCmplxRepeat xxx links to SpecialChar
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimRegion      xxx cleared
vimSynLine     xxx cleared
vimNotation    xxx links to Special
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimCtrlChar    xxx links to SpecialChar
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimFuncVar     xxx links to Identifier
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimContinue    xxx links to Special
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimAugroupKey  xxx links to vimCommand
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimAugroupError xxx links to vimError
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimEnvvar      xxx links to PreProc
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimFunc        xxx links to vimError
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimParenSep    xxx links to Delimiter
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSep         xxx links to Delimiter
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimOperError   xxx links to Error
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimFuncKey     xxx links to vimCommand
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimFuncSID     xxx links to Special
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimAbb         xxx links to vimCommand
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimEcho        xxx cleared
vimEchoHL      xxx links to vimCommand
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimIf          xxx cleared
vimHighlight   xxx links to vimCommand
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimNorm        xxx links to vimCommand
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimUnmap       xxx links to vimMap
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimUserCommand xxx links to vimCommand
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimFuncBody    xxx cleared
vimFuncBlank   xxx cleared
vimPattern     xxx links to Type
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSpecFileMod xxx links to vimSpecFile
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimEscapeBrace xxx cleared
vimSetEqual    xxx cleared
vimSetString   xxx links to vimString
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSubstRep    xxx cleared
vimSubstRange  xxx cleared
vimUserAttrb   xxx links to vimSpecial
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimUserAttrbError xxx links to Error
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimUserAttrbKey xxx links to vimOption
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimUserAttrbCmplt xxx links to vimSpecial
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimUserCmdError xxx links to Error
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimUserAttrbCmpltFunc xxx links to Special
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimCommentString xxx links to vimString
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimPatSepErr   xxx links to vimPatSep
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimPatSep      xxx links to SpecialChar
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimPatSepZ     xxx links to vimPatSep
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimPatSepZone  xxx links to vimString
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimPatSepR     xxx links to vimPatSep
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimPatRegion   xxx cleared
vimNotPatSep   xxx links to vimString
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimStringCont  xxx links to vimString
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSubstTwoBS  xxx links to vimString
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSubstSubstr xxx links to SpecialChar
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimCollection  xxx cleared
vimSubstPat    xxx cleared
vimSubst1      xxx links to vimSubst
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSubstDelim  xxx links to Delimiter
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSubstRep4   xxx cleared
vimSubstFlagErr xxx links to vimError
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimCollClass   xxx cleared
vimCollClassErr xxx links to vimError
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSubstFlags  xxx links to Special
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimMarkNumber  xxx links to vimNumber
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimPlainMark   xxx links to vimMark
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimPlainRegister xxx links to vimRegister
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSetMod      xxx links to vimOption
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSetSep      xxx links to Statement
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimMapMod      xxx links to vimBracket
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimMapLhs      xxx cleared
vimAutoCmdSpace xxx cleared
vimAutoEventList xxx cleared
vimAutoCmdSfxList xxx cleared
vimEchoHLNone  xxx links to vimGroup
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimMapBang     xxx links to vimCommand
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimMapRhs      xxx cleared
vimMapModKey   xxx links to vimFuncSID
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimMapModErr   xxx links to vimError
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimMapRhsExtend xxx cleared
vimMenuBang    xxx cleared
vimMenuPriority xxx cleared
vimMenuName    xxx links to PreProc
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimMenuMod     xxx links to vimMapMod
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimMenuNameMore xxx links to vimMenuName
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimMenuMap     xxx cleared
vimMenuRhs     xxx cleared
vimBracket     xxx links to Delimiter
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimUserFunc    xxx links to Normal
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimElseIfErr   xxx links to Error
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimBufnrWarn   xxx links to vimWarn
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimNormCmds    xxx cleared
vimGroupSpecial xxx links to Special
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimGroupList   xxx cleared
vimSynError    xxx links to Error
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSynContains xxx links to vimSynOption
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSynKeyContainedin xxx links to vimSynContains
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSynNextgroup xxx links to vimSynOption
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSynType     xxx links to vimSpecial
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimAuSyntax    xxx cleared
vimSynCase     xxx links to Type
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSynCaseError xxx links to vimError
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimClusterName xxx cleared
vimGroupName   xxx links to vimGroup
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimGroupAdd    xxx links to vimSynOption
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimGroupRem    xxx links to vimSynOption
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimIskList     xxx cleared
vimIskSep      xxx links to Delimiter
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSynKeyOpt   xxx links to vimSynOption
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSynKeyRegion xxx cleared
vimMtchComment xxx links to vimComment
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSynMtchOpt  xxx links to vimSynOption
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSynRegPat   xxx links to vimString
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSynMatchRegion xxx cleared
vimSynMtchCchar xxx cleared
vimSynMtchGroup xxx cleared
vimSynPatRange xxx links to vimString
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSynNotPatRange xxx links to vimSynRegPat
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSynRegOpt   xxx links to vimSynOption
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSynReg      xxx links to Type
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSynMtchGrp  xxx links to vimSynOption
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSynRegion   xxx cleared
vimSynPatMod   xxx cleared
vimSyncC       xxx links to Type
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSyncLines   xxx cleared
vimSyncMatch   xxx cleared
vimSyncError   xxx links to Error
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSyncLinebreak xxx cleared
vimSyncLinecont xxx cleared
vimSyncRegion  xxx cleared
vimSyncGroupName xxx links to vimGroupName
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSyncKey     xxx links to Type
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSyncGroup   xxx links to vimGroupName
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSyncNone    xxx links to Type
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimHiLink      xxx cleared
vimHiClear     xxx links to vimHighlight
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimHiKeyList   xxx cleared
vimHiCtermError xxx links to vimError
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimHiBang      xxx cleared
vimHiGroup     xxx links to vimGroupName
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimHiAttrib    xxx links to PreProc
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimFgBgAttrib  xxx links to vimHiAttrib
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimHiAttribList xxx links to vimError
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimHiCtermColor xxx cleared
vimHiFontname  xxx cleared
vimHiGuiFontname xxx cleared
vimHiGuiRgb    xxx links to vimNumber
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimHiTerm      xxx links to Type
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimHiCTerm     xxx links to vimHiTerm
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimHiStartStop xxx links to vimHiTerm
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimHiCtermFgBg xxx links to vimHiTerm
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimHiGui       xxx links to vimHiTerm
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimHiGuiFont   xxx links to vimHiTerm
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimHiGuiFgBg   xxx links to vimHiTerm
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimHiKeyError  xxx links to vimError
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimHiTermcap   xxx cleared
vimHiNmbr      xxx links to Number
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimCommentTitle xxx links to PreProc
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimCommentTitleLeader xxx cleared
vimSearchDelim xxx links to Statement
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSearch      xxx links to vimString
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimEmbedError  xxx links to vimError
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
rubyConditional xxx links to Conditional
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyExceptional xxx links to rubyConditional
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyMethodExceptional xxx links to rubyDefine
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyTodo       xxx links to Todo
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyStringEscape xxx links to Special
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyQuoteEscape xxx links to rubyStringEscape
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyInterpolationDelimiter xxx links to Delimiter
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyInterpolation xxx cleared
rubyInstanceVariable xxx links to rubyIdentifier
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyClassVariable xxx links to rubyIdentifier
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyGlobalVariable xxx links to rubyIdentifier
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyPredefinedVariable xxx links to rubyPredefinedIdentifier
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyInvalidVariable xxx links to Error
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyNoInterpolation xxx links to rubyString
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
NONE           xxx cleared
rubyDelimiterEscape xxx cleared
rubyString     xxx links to String
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyNestedParentheses xxx cleared
rubyNestedCurlyBraces xxx cleared
rubyNestedAngleBrackets xxx cleared
rubyNestedSquareBrackets xxx cleared
rubyRegexpSpecial xxx links to Special
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyRegexpComment xxx links to Comment
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyRegexpParens xxx cleared
rubyRegexpCharClass xxx links to rubyRegexpSpecial
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyRegexpEscape xxx links to rubyRegexpSpecial
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyRegexpBrackets xxx cleared
rubyRegexpQuantifier xxx links to rubyRegexpSpecial
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyRegexpAnchor xxx links to rubyRegexpSpecial
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyRegexpDot  xxx links to rubyRegexpCharClass
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyASCIICode  xxx links to Character
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyInteger    xxx links to Number
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyFloat      xxx links to Float
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyLocalVariableOrMethod xxx cleared
rubyBlockArgument xxx cleared
rubyConstant   xxx links to Type
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubySymbol     xxx links to Constant
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyCapitalizedMethod xxx links to rubyLocalVariableOrMethod
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyBlockParameter xxx links to rubyIdentifier
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyBlockParameterList xxx cleared
rubyPredefinedConstant xxx links to rubyPredefinedIdentifier
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyRegexpDelimiter xxx links to rubyStringDelimiter
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyRegexp     xxx links to rubyString
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyStringDelimiter xxx links to Delimiter
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubySymbolDelimiter xxx links to rubySymbol
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyHeredocStart xxx cleared
rubyHeredoc    xxx links to rubyString
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyAliasDeclaration2 xxx cleared
rubyAliasDeclaration xxx cleared
rubyBoolean    xxx links to Boolean
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyPseudoVariable xxx links to Constant
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyMethodDeclaration xxx cleared
rubyOperator   xxx links to Operator
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyClassDeclaration xxx cleared
rubyModuleDeclaration xxx cleared
rubyFunction   xxx links to Function
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyControl    xxx links to Statement
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyKeyword    xxx links to Keyword
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyBeginEnd   xxx links to Statement
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyDefine     xxx links to Define
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyClass      xxx links to rubyDefine
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyModule     xxx links to rubyDefine
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyMethodBlock xxx cleared
rubyBlock      xxx cleared
rubyConditionalModifier xxx links to rubyConditional
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyRepeatModifier xxx links to rubyRepeat
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyLineContinuation xxx cleared
rubyDoBlock    xxx cleared
rubyCurlyBlockDelimiter xxx cleared
rubyCurlyBlock xxx cleared
rubyArrayDelimiter xxx cleared
rubyArrayLiteral xxx cleared
rubyBlockExpression xxx cleared
rubyCaseExpression xxx cleared
rubyConditionalExpression xxx cleared
rubyRepeat     xxx links to Repeat
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyOptionalDo xxx links to rubyRepeat
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyOptionalDoLine xxx cleared
rubyRepeatExpression xxx cleared
rubyAccess     xxx links to Statement
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyAttribute  xxx links to Statement
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyEval       xxx links to Statement
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyException  xxx links to Exception
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyInclude    xxx links to Include
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubySharpBang  xxx links to PreProc
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubySpaceError xxx links to rubyError
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyComment    xxx links to Comment
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyMultilineComment xxx cleared
rubyDocumentation xxx links to Comment
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyKeywordAsMethod xxx cleared
rubyDataDirective xxx links to Delimiter
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyData       xxx links to Comment
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyIdentifier xxx links to Identifier
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyPredefinedIdentifier xxx links to rubyIdentifier
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
rubyError      xxx links to Error
	Last set from /opt/local/share/vim/vim80/syntax/ruby.vim
vimScriptDelim xxx links to Comment
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimRubyRegion  xxx cleared
pythonStatement xxx links to Statement
	Last set from /opt/local/share/vim/vim80/syntax/python.vim
pythonFunction xxx links to Function
	Last set from /opt/local/share/vim/vim80/syntax/python.vim
pythonConditional xxx links to Conditional
	Last set from /opt/local/share/vim/vim80/syntax/python.vim
pythonRepeat   xxx links to Repeat
	Last set from /opt/local/share/vim/vim80/syntax/python.vim
pythonOperator xxx links to Operator
	Last set from /opt/local/share/vim/vim80/syntax/python.vim
pythonException xxx links to Exception
	Last set from /opt/local/share/vim/vim80/syntax/python.vim
pythonInclude  xxx links to Include
	Last set from /opt/local/share/vim/vim80/syntax/python.vim
pythonAsync    xxx links to Statement
	Last set from /opt/local/share/vim/vim80/syntax/python.vim
pythonDecorator xxx links to Define
	Last set from /opt/local/share/vim/vim80/syntax/python.vim
pythonDecoratorName xxx links to Function
	Last set from /opt/local/share/vim/vim80/syntax/python.vim
pythonDoctestValue xxx links to Define
	Last set from /opt/local/share/vim/vim80/syntax/python.vim
pythonMatrixMultiply xxx cleared
pythonTodo     xxx links to Todo
	Last set from /opt/local/share/vim/vim80/syntax/python.vim
pythonComment  xxx links to Comment
	Last set from /opt/local/share/vim/vim80/syntax/python.vim
pythonQuotes   xxx links to String
	Last set from /opt/local/share/vim/vim80/syntax/python.vim
pythonEscape   xxx links to Special
	Last set from /opt/local/share/vim/vim80/syntax/python.vim
pythonString   xxx links to String
	Last set from /opt/local/share/vim/vim80/syntax/python.vim
pythonTripleQuotes xxx links to pythonQuotes
	Last set from /opt/local/share/vim/vim80/syntax/python.vim
pythonSpaceError xxx cleared
pythonDoctest  xxx links to Special
	Last set from /opt/local/share/vim/vim80/syntax/python.vim
pythonRawString xxx links to String
	Last set from /opt/local/share/vim/vim80/syntax/python.vim
pythonNumber   xxx links to Number
	Last set from /opt/local/share/vim/vim80/syntax/python.vim
pythonBuiltin  xxx links to Function
	Last set from /opt/local/share/vim/vim80/syntax/python.vim
pythonAttribute xxx cleared
pythonExceptions xxx links to Structure
	Last set from /opt/local/share/vim/vim80/syntax/python.vim
pythonSync     xxx cleared
vimPythonRegion xxx cleared
vimAugroupSyncA xxx cleared
vimError       xxx links to Error
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimKeyCodeError xxx links to vimError
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimWarn        xxx links to WarningMsg
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimAuHighlight xxx links to vimHighlight
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimAutoCmdOpt  xxx links to vimOption
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimAutoSet     xxx links to vimCommand
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimCondHL      xxx links to vimCommand
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimElseif      xxx links to vimCondHL
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimFold        xxx links to Folded
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSynOption   xxx links to Special
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimHLMod       xxx links to PreProc
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimKeyCode     xxx links to vimSpecFile
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimKeyword     xxx links to Statement
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimSpecial     xxx links to Type
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
vimStatement   xxx links to Statement
	Last set from /opt/local/share/vim/vim80/syntax/vim.vim
ALEErrorSign   xxx links to Error
	Last set from ~/Documents/Source/vim-ale/autoload/ale/sign.vim
ALEStyleErrorSign xxx links to ALEErrorSign
	Last set from ~/Documents/Source/vim-ale/autoload/ale/sign.vim
ALEWarningSign xxx links to Todo
	Last set from ~/Documents/Source/vim-ale/autoload/ale/sign.vim
ALEStyleWarningSign xxx links to ALEWarningSign
	Last set from ~/Documents/Source/vim-ale/autoload/ale/sign.vim
ALEInfoSign    xxx links to ALEWarningSign
	Last set from ~/Documents/Source/vim-ale/autoload/ale/sign.vim
ALESignColumnWithErrors xxx links to Error
	Last set from ~/Documents/Source/vim-ale/autoload/ale/sign.vim
ALESignColumnWithoutErrors xxx term=standout ctermfg=14 ctermbg=242 guifg=Cyan guibg=Grey
	Last set from ~/Documents/Source/vim-ale/autoload/ale/sign.vim
ALEErrorLine   xxx cleared
ALEWarningLine xxx cleared
ALEInfoLine    xxx cleared
ALEError       xxx links to SpellBad
	Last set from ~/Documents/Source/vim-ale/autoload/ale/highlight.vim
ALEStyleError  xxx links to ALEError
	Last set from ~/Documents/Source/vim-ale/autoload/ale/highlight.vim
ALEWarning     xxx links to SpellCap
	Last set from ~/Documents/Source/vim-ale/autoload/ale/highlight.vim
ALEStyleWarning xxx links to ALEWarning
	Last set from ~/Documents/Source/vim-ale/autoload/ale/highlight.vim
ALEInfo        xxx links to ALEWarning
	Last set from ~/Documents/Source/vim-ale/autoload/ale/highlight.vim
helpHeadline   xxx links to Statement
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpSectionDelim xxx links to PreProc
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpIgnore     xxx links to Ignore
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpExample    xxx links to Comment
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpBar        xxx links to Ignore
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpStar       xxx links to Ignore
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpHyperTextJump xxx links to Identifier
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpHyperTextEntry xxx links to String
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpBacktick   xxx links to Ignore
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpNormal     xxx cleared
helpVim        xxx links to Identifier
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpOption     xxx links to Type
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpCommand    xxx links to Comment
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpHeader     xxx links to PreProc
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpGraphic    xxx cleared
helpNote       xxx links to Todo
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpWarning    xxx links to Todo
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpDeprecated xxx links to Todo
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpSpecial    xxx links to Special
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpLeadBlank  xxx cleared
helpNotVi      xxx links to Special
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpComment    xxx links to Comment
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpConstant   xxx links to Constant
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpString     xxx links to String
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpCharacter  xxx links to Character
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpNumber     xxx links to Number
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpBoolean    xxx links to Boolean
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpFloat      xxx links to Float
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpIdentifier xxx links to Identifier
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpFunction   xxx links to Function
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpStatement  xxx links to Statement
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpConditional xxx links to Conditional
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpRepeat     xxx links to Repeat
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpLabel      xxx links to Label
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpOperator   xxx links to Operator
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpKeyword    xxx links to Keyword
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpException  xxx links to Exception
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpPreProc    xxx links to PreProc
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpInclude    xxx links to Include
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpDefine     xxx links to Define
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpMacro      xxx links to Macro
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpPreCondit  xxx links to PreCondit
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpType       xxx links to Type
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpStorageClass xxx links to StorageClass
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpStructure  xxx links to Structure
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpTypedef    xxx links to Typedef
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpSpecialChar xxx links to SpecialChar
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpTag        xxx links to Tag
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpDelimiter  xxx links to Delimiter
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpSpecialComment xxx links to SpecialComment
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpDebug      xxx links to Debug
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpUnderlined xxx links to Underlined
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpError      xxx links to Error
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpTodo       xxx links to Todo
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
helpURL        xxx links to String
	Last set from /opt/local/share/vim/vim80/syntax/help.vim
scalaKeyword   xxx links to Keyword
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaInstanceDeclaration xxx links to Special
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaCaseFollowing xxx links to Special
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaNameDefinition xxx links to Function
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaQuasiQuotes xxx cleared
scalaBlock     xxx cleared
scalaAkkaSpecialWord xxx links to PreProc
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalatestSpecialWord xxx links to PreProc
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalatestShouldDSLA xxx links to PreProc
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalatestShouldDSLB xxx links to PreProc
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaSymbol    xxx links to Number
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaChar      xxx links to Character
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaEscapedChar xxx links to Function
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaUnicodeChar xxx links to Special
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaOperator  xxx links to Special
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaPostNameDefinition xxx cleared
scalaVariableDeclarationList xxx cleared
scalaTypeDeclaration xxx links to Type
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaInstanceHash xxx links to Type
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaUnimplemented xxx links to Error
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaCapitalWord xxx links to Special
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaTypeTypeDeclaration xxx links to Type
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaSquareBrackets xxx cleared
scalaTypeTypeEquals xxx cleared
scalaTypeStatement xxx cleared
scalaTypeTypeExtension xxx links to Keyword
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaRoundBrackets xxx cleared
scalaTypeTypePostDeclaration xxx links to Special
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaTypeTypePostExtension xxx links to Keyword
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaTypeExtension xxx links to Keyword
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaTypePostExtension xxx links to Keyword
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaTypeAnnotation xxx links to Normal
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaKeywordModifier xxx links to Function
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaSpecial   xxx links to PreProc
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaExternal  xxx links to Include
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaStringEmbeddedQuote xxx links to String
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaString    xxx links to String
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaInterpolationBrackets xxx links to Special
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaInterpolation xxx links to Function
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaInterpolationB xxx links to Normal
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaIString   xxx links to String
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaTripleIString xxx links to String
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaInterpolationBoundary xxx links to Function
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaFInterpolation xxx links to Function
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaFInterpolationB xxx links to Normal
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaFString   xxx links to String
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaTripleString xxx links to String
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaTripleFString xxx links to String
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaNumber    xxx links to Number
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaSquareBracketsBrackets xxx links to Type
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaTypeOperator xxx links to Keyword
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaTypeAnnotationParameter xxx links to Function
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaShebang   xxx links to Comment
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaMultilineComment xxx links to Comment
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaDocLinks  xxx links to Function
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaParameterAnnotation xxx links to Function
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaCommentAnnotation xxx links to Function
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaTodo      xxx links to Todo
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaCommentCodeBlock xxx links to String
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaParamAnnotationValue xxx links to Keyword
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaCommentCodeBlockBrackets xxx links to String
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaAnnotation xxx links to PreProc
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaTrailingComment xxx links to Comment
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaAkkaFSMGotoUsing xxx links to PreProc
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
scalaAkkaFSM   xxx links to PreProc
	Last set from ~/Documents/Source/vim-polyglot/syntax/scala.vim
rgnScala       xxx cleared
