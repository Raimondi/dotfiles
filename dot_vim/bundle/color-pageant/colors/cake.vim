" Vim color file - cake
" Generated by http://bytefluent.com/vivify 2016-01-29
set background=light
if version > 580
	hi clear
	if exists("syntax_on")
		syntax reset
	endif
endif

let g:colors_name = "cake"

"hi PreCondit -- no settings --
"hi Include -- no settings --
"hi CTagsMember -- no settings --
"hi CTagsGlobalConstant -- no settings --
"hi Ignore -- no settings --
hi Normal guifg=#575757 guibg=#ffffff guisp=#ffffff gui=NONE ctermfg=240 ctermbg=15 cterm=NONE
"hi CTagsImport -- no settings --
"hi CTagsGlobalVariable -- no settings --
"hi EnumerationValue -- no settings --
"hi Union -- no settings --
"hi Question -- no settings --
"hi VisualNOS -- no settings --
"hi ModeMsg -- no settings --
"hi Define -- no settings --
"hi PreProc -- no settings --
"hi EnumerationName -- no settings --
"hi MoreMsg -- no settings --
"hi DefinedName -- no settings --
"hi LocalVariable -- no settings --
"hi CTagsClass -- no settings --
"hi Macro -- no settings --
"hi Underlined -- no settings --
"hi clear -- no settings --
hi IncSearch guifg=NONE guibg=#e2afe4 guisp=#e2afe4 gui=NONE ctermfg=NONE ctermbg=182 cterm=NONE
hi WildMenu guifg=#fffaff guibg=#e372e1 guisp=#e372e1 gui=NONE ctermfg=15 ctermbg=170 cterm=NONE
hi SignColumn guifg=#c2c2c2 guibg=NONE guisp=NONE gui=NONE ctermfg=7 ctermbg=NONE cterm=NONE
hi SpecialComment guifg=#707070 guibg=NONE guisp=NONE gui=NONE ctermfg=242 ctermbg=NONE cterm=NONE
hi Typedef guifg=#e4afce guibg=NONE guisp=NONE gui=NONE ctermfg=182 ctermbg=NONE cterm=NONE
hi Title guifg=#268efd guibg=NONE guisp=NONE gui=NONE ctermfg=33 ctermbg=NONE cterm=NONE
hi Folded guifg=#697c91 guibg=NONE guisp=NONE gui=NONE ctermfg=60 ctermbg=NONE cterm=NONE
hi Float guifg=#75a1ff guibg=NONE guisp=NONE gui=NONE ctermfg=111 ctermbg=NONE cterm=NONE
hi StatusLineNC guifg=#ebe6eb guibg=#855785 guisp=#855785 gui=NONE ctermfg=255 ctermbg=96 cterm=NONE
hi NonText guifg=#c2c2c2 guibg=NONE guisp=NONE gui=NONE ctermfg=7 ctermbg=NONE cterm=NONE
hi DiffText guifg=#809a32 guibg=#bae472 guisp=#bae472 gui=NONE ctermfg=107 ctermbg=149 cterm=NONE
hi ErrorMsg guifg=NONE guibg=#f8b6a5 guisp=#f8b6a5 gui=NONE ctermfg=NONE ctermbg=217 cterm=NONE
hi Debug guifg=#707070 guibg=NONE guisp=NONE gui=NONE ctermfg=242 ctermbg=NONE cterm=NONE
hi PMenuSbar guifg=#b75fc9 guibg=#a87ea8 guisp=#a87ea8 gui=NONE ctermfg=134 ctermbg=139 cterm=NONE
hi Identifier guifg=#0c8df0 guibg=NONE guisp=NONE gui=NONE ctermfg=33 ctermbg=NONE cterm=NONE
hi SpecialChar guifg=#707070 guibg=NONE guisp=NONE gui=NONE ctermfg=242 ctermbg=NONE cterm=NONE
hi Conditional guifg=#f279b3 guibg=NONE guisp=NONE gui=NONE ctermfg=211 ctermbg=NONE cterm=NONE
hi StorageClass guifg=#89b7e1 guibg=NONE guisp=NONE gui=NONE ctermfg=110 ctermbg=NONE cterm=NONE
hi Todo guifg=#ffffff guibg=#ff4d5e guisp=#ff4d5e gui=bold ctermfg=15 ctermbg=203 cterm=bold
hi Special guifg=#707070 guibg=NONE guisp=NONE gui=NONE ctermfg=242 ctermbg=NONE cterm=NONE
hi LineNr guifg=#ffffff guibg=#e34faf guisp=#e34faf gui=NONE ctermfg=15 ctermbg=169 cterm=NONE
hi StatusLine guifg=#ffffff guibg=#e34faf guisp=#e34faf gui=NONE ctermfg=15 ctermbg=169 cterm=NONE
hi Label guifg=#e4afce guibg=NONE guisp=NONE gui=NONE ctermfg=182 ctermbg=NONE cterm=NONE
hi PMenuSel guifg=#f2f2f2 guibg=#4a314a guisp=#4a314a gui=NONE ctermfg=255 ctermbg=239 cterm=NONE
hi Search guifg=NONE guibg=#ebbfed guisp=#ebbfed gui=NONE ctermfg=NONE ctermbg=225 cterm=NONE
hi Delimiter guifg=#707070 guibg=NONE guisp=NONE gui=NONE ctermfg=242 ctermbg=NONE cterm=NONE
hi Statement guifg=#7eb833 guibg=NONE guisp=NONE gui=NONE ctermfg=107 ctermbg=NONE cterm=NONE
hi SpellRare guifg=NONE guibg=#ededed guisp=#ededed gui=NONE ctermfg=NONE ctermbg=255 cterm=NONE
hi Comment guifg=#00a1b3 guibg=NONE guisp=NONE gui=NONE ctermfg=37 ctermbg=NONE cterm=NONE
hi Character guifg=#707070 guibg=NONE guisp=NONE gui=NONE ctermfg=242 ctermbg=NONE cterm=NONE
hi TabLineSel guifg=#262626 guibg=#ededed guisp=#ededed gui=NONE ctermfg=235 ctermbg=255 cterm=NONE
hi Number guifg=#75a1ff guibg=NONE guisp=NONE gui=NONE ctermfg=111 ctermbg=NONE cterm=NONE
hi Boolean guifg=#bf75bf guibg=NONE guisp=NONE gui=NONE ctermfg=133 ctermbg=NONE cterm=NONE
hi Operator guifg=#eb67d1 guibg=NONE guisp=NONE gui=NONE ctermfg=169 ctermbg=NONE cterm=NONE
hi CursorLine guifg=NONE guibg=#f5f5f5 guisp=#f5f5f5 gui=NONE ctermfg=NONE ctermbg=255 cterm=NONE
hi TabLineFill guifg=NONE guibg=#e3ede6 guisp=#e3ede6 gui=NONE ctermfg=NONE ctermbg=194 cterm=NONE
hi WarningMsg guifg=NONE guibg=#fffccc guisp=#fffccc gui=NONE ctermfg=NONE ctermbg=230 cterm=NONE
hi DiffDelete guifg=#aa3c3c guibg=#ffcccc guisp=#ffcccc gui=NONE ctermfg=131 ctermbg=224 cterm=NONE
hi CursorColumn guifg=NONE guibg=#f5f5f5 guisp=#f5f5f5 gui=NONE ctermfg=NONE ctermbg=255 cterm=NONE
hi Function guifg=#0c8df0 guibg=NONE guisp=NONE gui=NONE ctermfg=33 ctermbg=NONE cterm=NONE
hi FoldColumn guifg=#c2c2c2 guibg=NONE guisp=NONE gui=NONE ctermfg=7 ctermbg=NONE cterm=NONE
hi Visual guifg=#ebedff guibg=#e34faf guisp=#e34faf gui=NONE ctermfg=189 ctermbg=169 cterm=NONE
hi SpellCap guifg=#adacbe guibg=NONE guisp=NONE gui=NONE ctermfg=7 ctermbg=NONE cterm=NONE
hi VertSplit guifg=#e3e3e3 guibg=NONE guisp=NONE gui=NONE ctermfg=254 ctermbg=NONE cterm=NONE
hi Exception guifg=#f786f7 guibg=NONE guisp=NONE gui=NONE ctermfg=213 ctermbg=NONE cterm=NONE
hi Keyword guifg=#f279b3 guibg=NONE guisp=NONE gui=NONE ctermfg=211 ctermbg=NONE cterm=NONE
hi Type guifg=#f041aa guibg=NONE guisp=NONE gui=NONE ctermfg=13 ctermbg=NONE cterm=NONE
hi DiffChange guifg=#e7f0f5 guibg=#4fd6b4 guisp=#4fd6b4 gui=NONE ctermfg=195 ctermbg=79 cterm=NONE
hi Cursor guifg=#782164 guibg=#fd35fd guisp=#fd35fd gui=NONE ctermfg=89 ctermbg=13 cterm=NONE
hi SpellLocal guifg=NONE guibg=#f0fff0 guisp=#f0fff0 gui=NONE ctermfg=NONE ctermbg=194 cterm=NONE
hi Error guifg=#db6097 guibg=#fff0f0 guisp=#fff0f0 gui=NONE ctermfg=168 ctermbg=224 cterm=NONE
hi PMenu guifg=#4f5152 guibg=#f7c6ed guisp=#f7c6ed gui=NONE ctermfg=239 ctermbg=225 cterm=NONE
hi SpecialKey guifg=#c2c2c2 guibg=NONE guisp=NONE gui=NONE ctermfg=7 ctermbg=NONE cterm=NONE
hi Constant guifg=#bf75bf guibg=NONE guisp=NONE gui=NONE ctermfg=133 ctermbg=NONE cterm=NONE
hi Tag guifg=#707070 guibg=NONE guisp=NONE gui=NONE ctermfg=242 ctermbg=NONE cterm=NONE
hi String guifg=#e87021 guibg=NONE guisp=NONE gui=NONE ctermfg=166 ctermbg=NONE cterm=NONE
hi PMenuThumb guifg=#48aadb guibg=#da6be0 guisp=#da6be0 gui=NONE ctermfg=74 ctermbg=170 cterm=NONE
hi MatchParen guifg=#ededed guibg=#7a8aff guisp=#7a8aff gui=NONE ctermfg=255 ctermbg=12 cterm=NONE
hi Repeat guifg=#e4afce guibg=NONE guisp=NONE gui=NONE ctermfg=182 ctermbg=NONE cterm=NONE
hi SpellBad guifg=#e47849 guibg=#ffe5e5 guisp=#ffe5e5 gui=NONE ctermfg=173 ctermbg=224 cterm=NONE
hi Directory guifg=#4a4a4a guibg=NONE guisp=NONE gui=NONE ctermfg=239 ctermbg=NONE cterm=NONE
hi Structure guifg=#e4afce guibg=NONE guisp=NONE gui=NONE ctermfg=182 ctermbg=NONE cterm=NONE
hi DiffAdd guifg=#39ac39 guibg=#c7ffc7 guisp=#c7ffc7 gui=NONE ctermfg=71 ctermbg=194 cterm=NONE
hi TabLine guifg=#969696 guibg=#ededed guisp=#ededed gui=NONE ctermfg=246 ctermbg=255 cterm=NONE
hi conceal guifg=#707070 guibg=NONE guisp=NONE gui=NONE ctermfg=242 ctermbg=NONE cterm=NONE
hi colorcolumn guifg=NONE guibg=#f5f5f5 guisp=#f5f5f5 gui=NONE ctermfg=NONE ctermbg=255 cterm=NONE
hi cursorlinenr guifg=#969696 guibg=NONE guisp=NONE gui=NONE ctermfg=246 ctermbg=NONE cterm=NONE