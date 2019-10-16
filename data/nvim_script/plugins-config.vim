" PLUGINS CONFIG

" easymotion
hi link EasyMotionTarget ErrorMsg
hi link EasyMotionShade  Comment
map e <Plug>(easymotion-bd-f)

" NERDCommenter
"nmap ; <Plug>NERDCommenterToggle
"vmap ; <Plug>NERDCommenterToggle

" NERDTree
"map <silent> <C-t> :NERDTreeToggle<CR>
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

" ale - check grammar
"let g:ale_linters_explicit = 1
"let g:ale_linters = {
  "\   'csh': ['shell'],
  "\   'zsh': ['shell'],
  "\   'go': ['gofmt', 'golint'],
  "\   'python': ['flake8', 'mypy', 'pylint'],
  "\   'c': ['gcc', 'cppcheck'],
  "\   'cpp': ['clang', 'cppcheck'],
  "\   'text': [],
  "\}
"let g:ale_completion_delay = 500
"let g:ale_echo_delay = 20
"let g:ale_lint_delay = 500
"let g:ale_echo_msg_format = '[%linter%] %code: %%s'
"let g:ale_lint_on_text_changed = 'normal'
"let g:ale_lint_on_insert_leave = 1
"let g:airline#extensions#ale#enabled = 1
"let g:ale_c_gcc_options = '-Wall -O2 -std=c99'
"let g:ale_cpp_gcc_options = '-Wall -O2 -std=c++11'
"let g:ale_cpp_clang_options = '-Wall -O2 -std=c++17 -stdlib=libc++ -I/usr/include/clang/6.0.1/include -I/usr/include/x86_64-linux-gnu/c++/7 -isystem /usr/include/c++/7'
"let g:ale_cpp_clang_options = ' -O2 -std=c++11 -isystem /usr/include/c++/7 -I/home/frank/develop/c/ctp_api/6.3.15/include -I/usr/include/clang/6.0.1/include -I/usr/include/x86_64-linux-gnu/c++/7 '
"let g:ale_cpp_cppcheck_options = ' -O2 -std=c++11 -isystem /usr/include/c++/7 -I/home/frank/develop/c/ctp_api/6.3.15/include -I/usr/include/clang/6.0.1/include -I/usr/include/x86_64-linux-gnu/c++/7 '
"let g:ale_c_cppcheck_options = '' 
 
" vim-cpp-enhanced-highlight
"let c_no_curly_error = 1
"let g:cpp_class_scope_highlight = 1
"let g:cpp_member_variable_highlight = 1
"let g:cpp_class_decl_highlight = 1
"let g:cpp_experimental_simple_template_highlight = 1
"let g:cpp_experimental_template_highlight = 1
"let g:cpp_concepts_highlight = 1
"let g:cpp_no_function_highlight = 1 


 "syntastic
  "let g:syntastic_enable_balloons = 1
  "let g:syntastic_auto_jump=0
  "let g:syntastic_always_populate_loc_list=1
  "let g:syntastic_auto_loc_list=1
  "let g:syntastic_loc_list_height=5
  "let g:syntastic_enable_signs=1
  "let g:syntastic_error_symbol='✗'
  "let g:syntastic_warning_symbol='⚠'
  "let g:ycm_show_diagnostics_ui = 0

"syntastic for clang
  "let g:syntastic_cpp_compiler='clang++'
  "let g:syntastic_cpp_compiler_options=' -std=c++17 -stdlib=libc++ -I/usr/include/clang/6.0.1/include -I/usr/include/x86_64-linux-gnu/c++/7 -I/usr/include/c++/7 '


" highlight
"let c_no_curly_error = 1
"let g:cpp_simple_highlight = 1

" fzf 
"source $HOME/.config/nvim/plugin_script/fzf.vim

" LeaderF
noremap <silent> <leader>o :LeaderfFunction<CR>

" Asyncrun
let g:asyncrun_open = 80
noremap <silent> <leader>m :AsyncRun cd build && make<CR>
noremap <silent> <leader>mr :AsyncRun rm -rf build && mkdir build && cd build && cmake .. && make<CR>
noremap <silent> <leader>rl :AsyncRun cd bin && ./unit_test --gtest_list_tests<CR>
noremap <silent> <leader>rt :AsyncRun cd bin && ./unit_test --gtest_filter=test_ctp_
noremap <silent> <leader>ro :AsyncStop<CR>

" vim-over
  nnoremap <leader>s :OverCommandLine<CR>%s/<C-r><C-w>/

" clangd server
"if executable('clangd')
    augroup lsp_clangd
        autocmd!
        autocmd User lsp_setup call lsp#register_server({
                    \ 'name': 'clangd',
                    \ 'cmd': {server_info->['clangd']},
                    \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
                    \ })
        autocmd FileType c setlocal omnifunc=lsp#complete
        autocmd FileType cpp setlocal omnifunc=lsp#complete
        autocmd FileType objc setlocal omnifunc=lsp#complete
        autocmd FileType objcpp setlocal omnifunc=lsp#complete
    augroup end
"endif

" vim_lsp
noremap <silent> <leader>ld :LspDefinition<CR>
noremap <silent> <leader>ln :LspNextReference<CR>
noremap <silent> <leader>lp :LspPreviousReference<CR>
noremap <silent> <leader>ln :LspRename<CR>


" gen_tags
let g:gen_tags#gtags_default_map = 1
noremap <silent> <leader>ct :GenCtags<CR>
noremap <silent> <leader>cs :GenGTAGS<CR>
noremap <silent> <leader>cct :ClearCtags<CR>
noremap <silent> <leader>ccs :ClearGTAGS<CR>

noremap <silent> <leader>gs :cscope find s <C-r><C-w><CR>
noremap <silent> <leader>gc :cscope find c <C-r><C-w><CR>
noremap <silent> <leader>gf :cscope find f <C-r><C-w><CR>

" mru
"let g:mru_file_list_size = 7
"let g:mru_ignore_patterns = 'fugitive\|\.it/\|\_^/tmp/'

" browse old file
noremap <silent> <leader>h :browse oldfiles<CR>

" far
nnoremap  <silent> <leader>fs :Far <C-r><C-w> **/*.[ch]*
nnoremap  <silent> <leader>fd :Far <C-r><C-w> **/*.[ch]*

" vim-workspace
nnoremap <leader>ws :ToggleWorkspace<CR>
let g:workspace_session_name = 'Session.vim'
let g:workspace_session_directory = $HOME . '/.vim/session/'

" quickr-cscope.vim
