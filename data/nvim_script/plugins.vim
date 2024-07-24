call plug#begin('~/.config/vim-plugins')

"Plug 'w0rp/ale'
"Plug 'vim-syntastic/syntastic'
"Plug 'prabirshrestha/asyncomplete.vim'
"Plug 'gilligan/vim-lldb'
"Plug 'scrooloose/nerdcommenter'
"Plug 'prompt-toolkit/pyvim'
"Plug 'vim-scripts/a.vim'
"Plug 'prabirshrestha/vim-lsp'
"Plug 'ajh17/vimcompletesme'
"Plug 'jsfaint/gen_tags.vim'
""Plug 'vim-denops/denops.vim'
"Plug 'matsui54/denops-popup-preview.vim'
"Plug 'voldikss/vim-skylight'
"Plug 'ludovicchabant/vim-gutentags'
""Plug 'vim-scripts/comments.vim'
"Plug 'davidhalter/jedi-vim'
"Plug 'deoplete-plugins/deoplete-jedi'
"Plug 'Shougo/deoplete.nvim', {'do': ':autocmd VimEnter * UpdateRemotePlugins'}
"Plug 'vim-scripts/AutoComplPop'
""Plug 'hrsh7th/nvim-cmp'
"Plug 'hrsh7th/cmp-nvim-lsp'
"Plug 'hrsh7th/cmp-vsnip'
"Plug 'hrsh7th/cmp-path'
"Plug 'hrsh7th/cmp-buffer'
"Plug 'tenfyzhong/vim-gencode-cpp'
"Plug 'nvim-lua/plenary.nvim'
"Plug 'smjonas/inc-rename.nvim'
"Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
"Plug 'eriks47/generate.nvim'
" ============================

"Plug 'vim-scripts/vim-maximizer'
"Plug 'prabirshrestha/async.vim'

"Plug 'greyblake/vim-preview'
"Plug 'kshenoy/vim-signature'
"Plug 'simeji/winresizer'
"Plug 'AndrewRadev/linediff.vim'
"Plug 'vim-scripts/OmniCppComplete'
"Plug 'MattesGroeger/vim-bookmarks'
"Plug 'hrsh7th/cmp-vsnip'
"Plug 'hrsh7th/vim-vsnip'





" for UI
Plug 'joshdick/onedark.vim'
"Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " codes highlight
"Plug 'ellisonleao/gruvbox.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-tree/nvim-web-devicons'
" Plug 'ryanoasis/vim-devicons' Icons without colours
Plug 'akinsho/bufferline.nvim', { 'tag': '*' }


" for quich action
Plug 'liuchengxu/vim-which-key'
Plug 'tmux-plugins/vim-tmux'
Plug 'christoomey/vim-tmux-navigator'
Plug 'Lokaltog/vim-easymotion'
Plug 'jiangmiao/auto-pairs'
Plug 'osyo-manga/vim-over'
Plug 't9md/vim-choosewin' " switch and selected windows
Plug 'preservim/tagbar'
Plug 'voldikss/vim-floaterm'
Plug 'nvim-lua/plenary.nvim'

"for search
Plug 'mileszs/ack.vim'
Plug 'brooth/far.vim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension'}

" for project manage
Plug 'thaerkh/vim-workspace'
Plug 'airblade/vim-gitgutter'

" for file manage
Plug 'scrooloose/nerdtree'

" for comment
Plug 'numToStr/Comment.nvim'
Plug 'folke/todo-comments.nvim'

" for language
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'williamboman/nvim-lsp-installer'
Plug 'neovim/nvim-lspconfig'
"Plug 'onsails/lspkind-nvim'
Plug 'SirVer/ultisnips'
"Plug 'honza/vim-snippets'
Plug 'rafamadriz/friendly-snippets'
"Plug 'wesleyche/SrcExpl'
Plug 'dominikduda/vim_current_word'

" for c++
"Plug 'bfrg/vim-cpp-modern'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'skywind3000/asyncrun.vim'
Plug 'skywind3000/vim-preview'
"Plug 'sakhnik/nvim-gdb'
"Plug 'mfussenegger/nvim-dap'

" for python
Plug 'nvie/vim-flake8'
Plug 'python-mode/python-mode', {'for': 'python', 'branch': 'develop'}
Plug 'psf/black'
Plug 'metakirby5/codi.vim'

" for debug
"Plug 'rcarriga/nvim-dap-ui'

call plug#end()
