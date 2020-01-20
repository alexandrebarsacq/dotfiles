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
    "Git integration
    Plug 'tpope/vim-fugitive'
    "Comment lines
    Plug 'tpope/vim-commentary'
    "Manipulate surrounding ( [ { etc
    Plug 'tpope/vim-surround'

    Plug 'psliwka/vim-smoothie'

    "Insert closing parenthesis,bracket,etc automagically
    Plug 'jiangmiao/auto-pairs'
    "Javascript and rrelated syntax
    Plug 'yuezk/vim-js'
    Plug 'MaxMEllon/vim-jsx-pretty'

    "I want an IDE really
    Plug 'neoclide/coc.nvim', {'branch': 'release', 'do': 'CocInstall coc-tsserver coc-eslint coc-json coc-prettier coc-css'}
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


"TODO : disabled since per documentation it's reenable after calling 
" filetype indent on
" make sure that no regression then delete
"filetype off

"let g:LanguageClient_serverCommands = {
"\ 'c': ['/usr/local/bin/cquery/bin/cquery', '--log-file=/tmp/cq.log'],
"\ 'cpp':['/usr/local/bin/cquery/bin/cquery', '--log-file=/tmp/cq.log']
"\ }
" let g:LanguageClient_rootMarkers = {
"\ 'c': ['compile_commands.json'],
"\ }
" " Use an absolute configuration path if you want system-wide settings
"let g:LanguageClient_loadSettings = 1
"let g:LanguageClient_settingsPath = '/home/alexandre/.config/nvim/settings.json'
"" Automatically start language servers.
"let g:LanguageClient_autoStart = 1
"" Add language client logging for debug
""let g:LanguageClient_loggingFile="/tmp/languageclientlog.txt"
""let g:LanguageClient_loggingLevel='DEBUG'
"
"let g:tagbar_ctags_bin = "/usr/bin/ctags"    
"let g:tagbar_sort = 0
"let g:tagbar_compact = 1
"
" Deoplete.nvim
"set completeopt-=preview

"Line below is commented cauze not necessary because deoplete is installed
"set completefunc=LanguageClient#complete
"set formatexpr=LanguageClient_textDocument_rangeFormatting()

" Workaround some broken plugins which set guicursor indiscriminately.
" Taken from : https://github.com/neovim/neovim/wiki/FAQ
:set guicursor=
:autocmd OptionSet guicursor noautocmd set guicursor=

"always show status line, tab line only if needed
setglobal laststatus=2
setglobal showtabline=1

"Keep one line above cursor at all time
set scrolloff=1

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

"paste on line below with ALT-p
nmap <A-p> :pu<CR>
"
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
noremap <silent><leader>b <Esc>:TagbarToggle<CR>
tnoremap <silent><leader>b <C-\><C-n>:TagbarToggle<CR>

""Search buffers with FZF
""nmap ; :Buffers<CR>
"
""Search Files with FZF
"nmap , :Files<CR>

"Delete buffer with plugin buffkill (does not delete splits)
map <C-c> :BD<cr>
" Allows you to save files you opened without write permissions via sudo
cmap w!! w !sudo tee %

"Save filename to cliboard
nmap <silent> <F8> :let @+ = expand("%:p")<CR>

let g:vimwiki_list = [{'syntax': 'markdown', 'ext': '.md'}]
