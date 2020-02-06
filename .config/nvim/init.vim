" My neovim config

"-------------------------------------------------------
"Plugin management
"-------------------------------------------------------

call plug#begin('~/.vim/bundle')
    " Fzf fuzy find : install via linuxbrew
    Plug '/home/linuxbrew/.linuxbrew/opt/fzf'
    Plug 'junegunn/fzf.vim'

    "color picker
    Plug 'DougBeney/pickachu'
    " Color scheme
    Plug 'mhartington/oceanic-next'
    "Kill tabs but keep my damn splits 
    Plug 'qpkorr/vim-bufkill'
    "Focus event fix
    Plug 'tmux-plugins/vim-tmux-focus-events'
    "IDE-like suff
    Plug 'majutsushi/tagbar'
    Plug 'scrooloose/nerdtree'

    "Function arguments as text object
    Plug 'vim-scripts/argtextobj.vim'
    "Vim wiki and taskwarrior integration
    Plug 'vimwiki/vimwiki'
    Plug 'tbabej/taskwiki'

    "Additional mapping
    Plug 'tpope/vim-unimpaired'

    "Comment lines
    Plug 'tpope/vim-commentary'
    "Manipulate surrounding ( [ { etc
    Plug 'tpope/vim-surround'
    "Smooth scrolling with crtl+u/d etc
    Plug 'psliwka/vim-smoothie'
    "dot works for more stuff
    Plug 'tpope/vim-repeat'

    "Git integration
    Plug 'tpope/vim-fugitive'
    "Git blame in popup
    Plug 'rhysd/git-messenger.vim' " :GitMessenger

    "Insert closing parenthesis,bracket,etc automagically
    Plug 'jiangmiao/auto-pairs'
    "Javascript and rrelated syntax
    Plug 'pangloss/vim-javascript'
    "Vue stuff 
    Plug 'posva/vim-vue'
    "Snippet collection. Used with coc 
    Plug 'honza/vim-snippets'
    "I want an IDE really
    Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

"Autoinstall plugin manager if not present
" See https://github.com/junegunn/vim-plug/wiki/faq
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


"Coc plugins : 
let g:coc_global_extensions = [
            \ 'coc-tsserver',
            \ 'coc-prettier', 
            \ 'coc-json', 
            \ 'coc-eslint', 
            \ 'coc-css', 
            \ 'coc-emmet',
            \ 'coc-snippets']

""-------------------------------------------------------
"Configuration of plugins
"-------------------------------------------------------
" Workaround some broken plugins which set guicursor indiscriminately.
" Taken from : https://github.com/neovim/neovim/wiki/FAQ
:set guicursor=
:autocmd OptionSet guicursor noautocmd set guicursor=

"always show status line, tab line only if needed
setglobal laststatus=2
setglobal showtabline=1

"Keep one line above cursor at all time
set scrolloff=2

"Allow hidden buffers
set hidden 
set fillchars=vert:│
"allow use of mouse
set mouse=a 
filetype plugin on
"Enable indent plugin
filetype plugin indent on
"Use 4 spaces per tabs"
" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab
"Searches ignore case unless an upercase is typed
set ignorecase
set smartcase
"use system clipboard
set clipboard=unnamed

" Always show side bar for errors so no blinking happens
set signcolumn=yes

set nocompatible
syntax on

"Event more regularly
set updatetime=300
" Don't give completion messages like 'match 1 of 2'
" or 'The only match'
set shortmess+=c

" coc.nvim asks for this :
" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

"-------------------------------------------------------
"UI stuff
"-------------------------------------------------------
" Enable true color support
set termguicolors
"colorscheme gruvbox
set background=dark
colorscheme OceanicNext
"split windows below
set splitbelow

" Set floating window to be slightly transparent
set winbl=10

" Don't show last command
set noshowcmd
"Show line number
set number


autocmd! FileType fzf set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
"-------------------------------------------------------
"Autosave Behavior
"-------------------------------------------------------
"autosave on buffer switch
set autowrite
set autowriteall
"autosave on focus lost
au FocusLost,BufLeave * silent! wa
"Check and reload files automatically that may have been changed outside of VIM
au FocusGained,BufEnter * :checktime
"no swap file since we save all the time
set noswapfile
"-------------------------------------------------------
"MAPPINGS
"-------------------------------------------------------

"Space bar as leader
"map <Space> <Leader>
let mapleader = "\<Space>"


" Use tab for trigger completion with characters ahead and navigate.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use tab to show documentation in preview window
nnoremap <silent> <TAB> :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold !!!!
autocmd CursorHold * silent call CocActionAsync('highlight')

"easier for azerty
nnoremap ² `
nnoremap ` ²

"more azerty : because brackets are too hard to get
"we use ç for [ and à for ]
nmap ç [
nmap à ]
omap ç [
omap à ]
xmap ç [
xmap à ]

"paste on line below with ALT-p
nmap <A-p> :pu<CR>
"Move between splits with CTRL+hjkl
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k

" === coc.nvim === "
"nmap <silent> <leader>dd <Plug>(coc-definition)
"nmap <silent> <leader>dr <Plug>(coc-references)
"nmap <silent> <leader>di <Plug>(coc-implementation)
" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
"
"" Common fixes
"nnoremap <silent>gb :BB<Cr>
"nnoremap <silent>gB :BF<Cr>
"
"" NERDTree
noremap <silent><leader>n <Esc>:NERDTreeToggle<CR>
tnoremap <silent><leader>n <C-\><C-n>:NERDTreeToggle<CR>
"
"" Tagbar
noremap <silent><leader>t <Esc>:TagbarToggle<CR>
tnoremap <silent><leader>t <C-\><C-n>:TagbarToggle<CR>

""Search buffers with FZF
nmap <leader>, :Buffers<CR>
"
""Search Files with FZF
nmap <leader>f :Files<CR>

"Delete buffer with plugin buffkill (does not delete splits)
map <C-c> :BD<cr>
" Allows you to save files you opened without write permissions via sudo
cmap w!! w !sudo tee %


imap jk <Esc>
imap kj <Esc>
"Save filename to cliboard
nmap <silent> <F8> :let @+ = expand("%:p")<CR>

let g:vimwiki_list = [{'syntax': 'markdown', 'ext': '.md'}]
