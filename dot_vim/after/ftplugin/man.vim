set modifiable
silent %s/.//eg
set nomodifiable nomodified
let &keywordprg = 'env MANPAGER="vim -c ''set ft=man'' -" man'
1
nnoremap <expr>K v:count ? ':<C-U>Man '.v:count.'<cword><CR>' : ':Man <cword><CR>'
