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
let g:gen_tags#gtags_default_map = 1
noremap <silent> <leader>ct :GenCtags<CR>
noremap <silent> <leader>cs :GenGTAGS<CR>
noremap <silent> <leader>cct :ClearCtags<CR>
noremap <silent> <leader>ccs :ClearGTAGS<CR>

noremap <silent> <leader>gs :cscope find s <C-r><C-w><CR>
noremap <silent> <leader>gc :cscope find c <C-r><C-w><CR>
noremap <silent> <leader>gf :cscope find f <C-r><C-w><CR>

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
autocmd FileType python call deoplete#enable()
let g:jedi#auto_vim_configuration = 0
let g:jedi#popup_on_dot = 0
"let g:jedi#popup_select_first = 1
let g:jedi#show_call_signatures = "1"

" Ultisnips
let g:UltiSnipsSnippetDirectories=[$HOME.'/.config/nvim/ultisnips']
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
