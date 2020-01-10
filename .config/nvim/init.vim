" My neovim config

"-------------------------------------------------------
"Plugin management
"-------------------------------------------------------

call plug#begin('~/.vim/bundle')
    " Fzf fuzy find : install via linuxbrew
    Plug '/home/linuxbrew/.linuxbrew/opt/fzf'
    Plug 'junegunn/fzf.vim'
    " Color scheme
    Plug 'morhetz/gruvbox'
    "Kill tabs but keep my damn splits 
    Plug 'qpkorr/vim-bufkill'
    "Focus event fix
    Plug 'tmux-plugins/vim-tmux-focus-events'
    "IDE-like suff
    Plug 'autozimu/LanguageClient-neovim', {'branch': 'next', 'do': 'bash install.sh'}
    Plug 'majutsushi/tagbar'
    Plug 'scrooloose/nerdtree'
    Plug 'Shougo/deoplete.nvim', { 'do': 'UpdateRemotePlugins' }
	Plug 'vim-scripts/argtextobj.vim'
    Plug 'vimwiki/vimwiki'
    Plug 'tbabej/taskwiki', {'branch': 'develop'}
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-surround'

call plug#end()

"Autoinstall plugin manager if not present
" See https://github.com/junegunn/vim-plug/wiki/faq
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

"-------------------------------------------------------
"Configuration of plugins
"-------------------------------------------------------
"# Call the theme one
colorscheme gruvbox
set background=dark


"Enable deoplete
let g:deoplete#enable_at_startup = 1

"TODO : disabled since per documentation it's reenable after calling 
" filetype indent on
" make sure that no regression then delete
"filetype off

let g:LanguageClient_serverCommands = {
\ 'c': ['/usr/local/bin/cquery/bin/cquery', '--log-file=/tmp/cq.log'],
\ 'cpp':['/usr/local/bin/cquery/bin/cquery', '--log-file=/tmp/cq.log']
\ }
 let g:LanguageClient_rootMarkers = {
\ 'c': ['compile_commands.json'],
\ }
 " Use an absolute configuration path if you want system-wide settings
let g:LanguageClient_loadSettings = 1
let g:LanguageClient_settingsPath = '/home/alexandre/.config/nvim/settings.json'
" Automatically start language servers.
let g:LanguageClient_autoStart = 1
" Add language client logging for debug
"let g:LanguageClient_loggingFile="/tmp/languageclientlog.txt"
"let g:LanguageClient_loggingLevel='DEBUG'

let g:tagbar_ctags_bin = "/usr/bin/ctags"    
let g:tagbar_sort = 0
let g:tagbar_compact = 1

" Deoplete.nvim
"set completeopt-=preview

"Line below is commented cauze not necessary because deoplete is installed
"set completefunc=LanguageClient#complete
set formatexpr=LanguageClient_textDocument_rangeFormatting()

" Workaround some broken plugins which set guicursor indiscriminately.
" Taken from : https://github.com/neovim/neovim/wiki/FAQ
:set guicursor=
:autocmd OptionSet guicursor noautocmd set guicursor=



"always show status line, tab line only if needed
setglobal laststatus=2
setglobal showtabline=1


"Keep one line above cursor at all time
set scrolloff=1
"Show line number
set number
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

nnoremap ² `
nnoremap ` ²

"paste on line below with ALT-p
nmap <A-p> :pu<CR>
"
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
"
"" Common fixes
"nnoremap <silent>gb :BB<Cr>
"nnoremap <silent>gB :BF<Cr>
"
"" NERDTree
"noremap <silent><A-n> <Esc>:NERDTreeToggle<CR>
"tnoremap <silent><A-n> <C-\><C-n>:NERDTreeToggle<CR>
"
"" Tagbar
"noremap <silent><A-b> <Esc>:TagbarToggle<CR>
"tnoremap <silent><A-b> <C-\><C-n>:TagbarToggle<CR>
"
""Language client
""nnoremap <silent><F5> :call LanguageClient_contextMenu()<CR>
"
""Search workspace symbols : ALT-w
"nnoremap <silent><A-w> :call LanguageClient_workspace_symbol()<CR>
"
""Search document symbols : ALT-d
"nnoremap <silent><A-d> :call LanguageClient_textDocument_documentSymbol()<CR>
""Go to definition : gd
"nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
""Go to caller : gc
""nnoremap <silent> gc :call LanguageClient#cquery_callers()<CR>
""nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
""nnoremap <silent> lr :call LanguageClient#textDocument_references()<CR>
""nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
"
""Search buffers with FZF
""nmap ; :Buffers<CR>
"
""Search Files with FZF
"nmap , :Files<CR>

"Delete buffer with plugin buffkill (does not delete splits)
map <C-c> :BD<cr>

"Save filename to cliboard
nmap <ilent> <F8> :let @+ = expand("%:p")<CR>

let g:vimwiki_list = [{'syntax': 'markdown', 'ext': '.md'}]
