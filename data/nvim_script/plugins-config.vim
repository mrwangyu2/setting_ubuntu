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

" clear gd
noremap <silent> <leader>nh :noh<CR>

" gen_tags
"let g:gen_tags#gtags_default_map = 1
"noremap <silent> <leader>ct :GenCtags<CR>
"noremap <silent> <leader>cs :GenGTAGS<CR>
"noremap <silent> <leader>cct :ClearCtags<CR>
"noremap <silent> <leader>ccs :ClearGTAGS<CR>

" browse old file
noremap <silent> <leader>h :browse oldfiles<CR>

" far
nnoremap  <silent> <leader>fs :Far <C-r><C-w> **/*.[ch]*
nnoremap  <silent> <leader>fd :Fardo <C-r><C-w>

" vim-workspace
nnoremap <leader>ws :ToggleWorkspace<CR>
let g:workspace_session_name = 'Session.vim'
let g:workspace_session_directory = $HOME . '/.vim/session/'

" lightline
let g:lightline = {'colorscheme':'onedark'}

" gencode
noremap <silent> <leader>ad :GenDeclaration<CR>
noremap <silent> <leader>ai :GenDefinition<CR>

" Ultisnips
"let g:UltiSnipsSnippetDirectories=[$HOME.'/.config/nvim/ultisnips']
"let g:UltiSnipsExpandTrigger="<tab>"
"let g:UltiSnipsJumpForwardTrigger="<tab>"
"let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
"
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
let g:UltiSnipsEditSplit="vertical"

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
let g:floaterm_keymap_toggle = '<leader>tm'

" Telescope
nnoremap ff <cmd>Telescope find_files<cr>
nnoremap fg :execute 'Telescope live_grep default_text=' .expand('<cword>')<cr>
nnoremap fb <cmd>Telescope buffers<cr>
nnoremap fh <cmd>Telescope help_tags<cr>

"nvim-gdb
"let g:loaded_nvimgdb = 0
let g:nvimgdb_use_cmake_to_find_executables = 1
let g:nvimgdb_use_find_executables = 1

" We're going to define single-letter keymaps, so don't try to define them
" in the terminal window.  The debugger CLI should continue accepting text commands.
function! NvimGdbNoTKeymaps()
 tnoremap <silent> <buffer> <esc> <c-\><c-n>
endfunction

let g:nvimgdb_config_override = {
  \ 'key_next': 'n',
  \ 'key_step': 's',
  \ 'key_finish': 'f',
  \ 'key_continue': 'c',
  \ 'key_until': 'u',
  \ 'key_breakpoint': 'b',
  \ 'set_tkeymaps': "NvimGdbNoTKeymaps",
  \ }

" lsp
lua require('lsp/setup')

" cmp
"lua require('lsp/nvim-cmp')

" todo-comments
lua require('todo-comments/setup')
noremap <silent> <leader>td :TodoQuickFix<CR>

" Switch file between .h and .cpp
nnoremap <silent> <leader>gh :e %:r.h<CR>
nnoremap <silent> <leader>gc :e %:r.cpp<CR>

"inc-rename
"lua require("inc_rename/setup")
"nnoremap  <silent> <leader>rn :IncRename <C-r><C-w>

" treesitter
"lua require('treesitter/setup')

" gruvbox
"lua require('gruvbox/setup')

" lualine
lua require('lualine/setup')

" vim-cpp-enhanced-highlight
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_posix_standard = 1
let g:cpp_experimental_simple_template_highlight = 1
let g:cpp_experimental_template_highlight = 1
let g:cpp_concepts_highlight = 1

" bufferline
set termguicolors
lua require("bufferline/setup")
" 切换到下一个缓冲区
nnoremap <silent> <TAB> :BufferLineCycleNext<CR>
" 切换到上一个缓冲区
nnoremap <silent> <S-TAB> :BufferLineCyclePrev<CR>
" 关闭当前缓冲区
nnoremap <silent> <leader>bd :bdelete<CR>

" lualine
lua require('comment/setup')


" vim-ai
"let g:vim_ai_chat['options']['model'] = 'gpt-4'
"let g:vim_ai_chat['options']['temperature'] = 0.2
