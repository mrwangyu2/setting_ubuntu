" KEYMAPPINGS
"DISABLED DEFAULT MAPPING: UNSET SHORTCUTS {{{
" Unmapping help from F1 and Ctrl-F1 for use toggling the reference manual
" the :h topic feature works, and <leader><F1> displays quickref
inoremap <F1> <nop>
nnoremap <F1> <nop>
vnoremap <F1> <nop>
"unmap the suspend function
map <C-z> <Nop>
"}}}

" Set mapleader
let g:mapleader="\<Space>"

" Toggle paste mode
nmap <silent> <F4> :set invpaste<CR>:set paste?<CR>
imap <silent> <F4> <ESC>:set invpaste<CR>:set paste?<CR>

" spacebar create/open/close folding
nmap <silent> <Space> za
vmap <silent> <Space> zf

" enable/disable list
nmap <silent> <C-l> :set nolist!<CR>

" Map escape key to jj or <leader>e
imap jj <ESC>

"" Fast saving
nmap <leader>w :w!<cr>

" switch between header file and cpp file
nmap<leader>t :A<cr>

" :W sudo saves the file
" (useful for handling the permission-denied error)
command W w !sudo tee % > /dev/null

" fzf
"nnoremap <silent> <leader>ff :FZF<CR>

