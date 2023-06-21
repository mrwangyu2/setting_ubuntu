" PLUGINS CONFIG
" easymotion
hi link EasyMotionTarget ErrorMsg
hi link EasyMotionShade  Comment
map e <Plug>(easymotion-bd-f)

" Commenter
"nmap <silent> ; :call CommentLine()<CR>  
"vmap <silent> ; :call CommentLine()<CR>  

"nmap <silent> ' :call UnCommentLine()<CR>  
"vmap <silent> ' :call UnCommentLine()<CR>  

" NERDTree
map <Leader>e :NERDTreeToggle<CR>
let g:NERDTreeBookmarksFile = expand($HOME.'/.vim/.NERDTreeBookmarks')
let g:NERDTreeWinPos = "left"
let g:NERDTreeShowBookmarks = 1
let g:NERDTreeWinSize = 40
let g:NERDTreeChristmasTree = 0
let g:NERDTreeCaseSensitiveSort = 1
let g:NERDTreeQuitOnOpen = 0
let g:NERDTreeShowHidden = 1
let g:NERDTreeMouseMode = 2
let NERDTreeAutoDeleteBuffer=1
let g:NERDTreeIgnore=[
      \'\.pyc$', '\.pyo$', '\.py\$class$', '\.obj$',
      \ '\.o$', '\.so$', '\.egg$', '^\.git$', '^\.svn$' ]
let g:NERDTreeQuitOnOpen = 1

" ack
let g:ackprg = 'ag --nogroup --nocolor --colum'
nnoremap <Leader>fa :Ack!<Space>

" quit vim
map <Leader>q :wqa!<CR>

" which key
nnoremap <silent> <leader> :WhichKey '<Space>'<CR>
set timeoutlen=500

" ClangFormat
nnoremap <silent> <leader>fo :ClangFormat <CR>

" LeaderF
noremap <silent> <leader>o :LeaderfFunction<CR>
noremap <silent> <leader>bb :LeaderfBuffer<CR>
let g:Lf_ShowDevIcons = 0
let g:Lf_WindowPosition = "popup"
" let g:Lf_StlColorscheme = "one"


" Asyncrun
let g:asyncrun_open = 80
noremap <silent> <leader>m :AsyncRun cd build && make<CR>
noremap <silent> <leader>mr :AsyncRun rm -rf build && mkdir build && cd build && cmake .. && make<CR>
noremap <silent> <leader>lt :AsyncRun cd bin && ./unit_test --gtest_list_tests<CR>
noremap <silent> <leader>rt :AsyncRun cd bin && ./unit_test --gtest_filter=test_ctp_
noremap <silent> <leader>ro :AsyncStop<CR>

" vim-over
  nnoremap <leader>s :OverCommandLine<CR>%s/<C-r><C-w>/

" clangd server
"if executable('clangd')
    "augroup lsp_clangd
        "autocmd!
        "autocmd User lsp_setup call lsp#register_server({
                    "\ 'name': 'clangd',
                    "\ 'cmd': {server_info->['clangd']},
                    "\ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
                    "\ })
        "autocmd FileType c setlocal omnifunc=lsp#complete
        "autocmd FileType cpp setlocal omnifunc=lsp#complete
        "autocmd FileType objc setlocal omnifunc=lsp#complete
        "autocmd FileType objcpp setlocal omnifunc=lsp#complete
    "augroup end
"endif

" vim_lsp
"noremap <silent> <leader>gd :LspDefinition<CR>
"noremap <silent> <leader>pd gd :LspPeekDefinition<CR>
"noremap <silent> <leader>gi <C-]>
"noremap <silent> <leader>gn :LspNextReference<CR>
"noremap <silent> <leader>gp :LspPreviousReference<CR>
"noremap <silent> <leader>rn :LspRename<CR>

" clear gd
noremap <silent> <leader>nh :noh<CR>


" gen_tags
"let g:gen_tags#gtags_default_map = 1
"noremap <silent> <leader>ct :GenCtags<CR>
"noremap <silent> <leader>cs :GenGTAGS<CR>
"noremap <silent> <leader>cct :ClearCtags<CR>
"noremap <silent> <leader>ccs :ClearGTAGS<CR>
"
"noremap <silent> <leader>gs :cscope find s <C-r><C-w><CR>
"noremap <silent> <leader>gc :cscope find c <C-r><C-w><CR>
"noremap <silent> <leader>gf :cscope find f <C-r><C-w><CR>

" browse old file
noremap <silent> <leader>h :browse oldfiles<CR>

" far
nnoremap  <silent> <leader>fs :Far <C-r><C-w> **/*.[ch]*
nnoremap  <silent> <leader>fd :Fardo <C-r><C-w>

" vim-workspace
nnoremap <leader>ws :ToggleWorkspace<CR>
let g:workspace_session_name = 'Session.vim'
let g:workspace_session_directory = $HOME . '/.vim/session/'

" onedark
"let g:onedark_termcolors=256

" lightline
let g:lightline = {'colorscheme':'onedark'}

" gencode
noremap <silent> <leader>ad :GenDeclaration<CR>
noremap <silent> <leader>ai :GenDefinition<CR>

" deoplete and jedi
"let g:deoplete#enable_at_startup=1
"let g:deoplete#auto_complete=1
"autocmd FileType python call deoplete#enable()
"let g:jedi#auto_vim_configuration = 0
"let g:jedi#popup_on_dot = 0
""let g:jedi#popup_select_first = 1
"let g:jedi#show_call_signatures = "1"
"
" Ultisnips
let g:UltiSnipsSnippetDirectories=[$HOME.'/.config/nvim/ultisnips']
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

"" SrcExpl
"nnoremap <leader>se :SrcExplToggle<CR>
"nnoremap <leader>so :SrcExplClose<CR>
"let g:SrcExpl_jumpKey="<ENTER>"
"let g:SrcExpl_gobackKey = "<leader>sb"
"let g:SrcExpl_colorSchemeList = [
"        \ "Red",
"        \ "Cyan",
"        \ "Green",
"        \ "Yellow",
"        \ "Magenta"
"    \ ]

" Codi
noremap <silent> <leader>i :Codi<CR>
noremap <silent> <leader>ic :Codi!<CR>
highlight CodiVirtualText guifg=Cyan
let g:codi#virtual_text = 0
let g:codi#width = 60
let g:codi#rightalign = 0
"let g:codi#virtual_text_prefix = "> "
let g:codi#interpreters = {
      \ 'python': {
        \ 'bin': 'python3',
        \ 'prompt': '^\(>>>\|\.\.\.\) ',
        \ },
      \ }


" coc-snippets
" Use <C-l> for trigger snippet expand.
imap <C-l> <Plug>(coc-snippets-expand)

" Use <C-j> for select text for visual placeholder of snippet.
vmap <C-n> <Plug>(coc-snippets-select)

" Use <C-j> for jump to next placeholder, it's default of coc.nvim
let g:coc_snippet_next = '<c-n>'

" Use <C-k> for jump to previous placeholder, it's default of coc.nvim
let g:coc_snippet_prev = '<c-p>'

" Use <C-j> for both expand and jump (make expand higher priority.)
imap <C-s> <Plug>(coc-snippets-expand-jump)

" Use <leader>x for convert visual selected code to snippet
xmap <leader>x  <Plug>(coc-convert-snippet)

inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>cf  <Plug>(coc-format-selected)
nmap <leader>cf  <Plug>(coc-format-selected

let g:coc_disable_startup_warning = 1

" tagbar
map <Leader>t :TagbarToggle fjc<CR>

" PreviewTag
noremap <silent> <leader>p :PreviewTag<CR>
noremap <silent> <leader>po :PreviewClose<CR>

" floaterm 
let g:floaterm_keymap_new    = '<F7>'
let g:floaterm_keymap_prev   = '<F8>'
let g:floaterm_keymap_next   = '<F9>'
let g:floaterm_keymap_toggle = '<F10>'
