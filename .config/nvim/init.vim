" My neovim config

let g:deoplete#enable_at_startup = 1
filetype off

call plug#begin('~/.vim/bundle')
    " Multi-entry selection UI. FZF
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
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
    
call plug#end()

let g:LanguageClient_serverCommands = {
\ 'c': ['/usr/local/bin/cquery/bin/cquery', '--log-file=/tmp/cq.log'],
\ 'cpp':['/usr/local/bin/cquery/bin/cquery', '--log-file=/tmp/cq.log']
\ }

 let g:LanguageClient_rootMarkers = {
\ 'c': ['compile_commands.json'],
\ }

let g:LanguageClient_loadSettings = 1 " Use an absolute configuration path if you want system-wide settings
let g:LanguageClient_settingsPath = '/home/alexandre/.config/nvim/settings.json'

" Automatically start language servers.
let g:LanguageClient_autoStart = 1


" Add language client logging for debug
"let g:LanguageClient_loggingFile="/tmp/languageclientlog.txt"
"let g:LanguageClient_loggingLevel='DEBUG'

" Deoplete.nvim
"set completeopt-=preview

"Line below is commented cauze not necessary because deoplete is installed
"set completefunc=LanguageClient#complete
set formatexpr=LanguageClient_textDocument_rangeFormatting()


"    function SetLSPShortcuts()
"endfunction()

"augroup LSP
"  autocmd!
"  autocmd FileType cpp,c call SetLSPShortcuts()
"augroup END

"Autoinstall plugin manager if not present
" See https://github.com/junegunn/vim-plug/wiki/faq
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


" Workaround some broken plugins which set guicursor indiscriminately.
" Taken from : https://github.com/neovim/neovim/wiki/FAQ
:set guicursor=
:autocmd OptionSet guicursor noautocmd set guicursor=

set fillchars=vert:│
set mouse=a "allow use of mouse"

"Use 4 spaces per tabs"
filetype plugin indent on
" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab
set number

"Searches ignore case unless an upercase is typed
set ignorecase
set smartcase


set hidden
"let base16colorspace=256
"colorscheme base16-default-dark

"use system clipboard
set clipboard=unnamed

"# Call the theme one
colorscheme gruvbox
set background=dark

let g:tagbar_ctags_bin = "/usr/bin/ctags"    

" Tagbar
	let g:tagbar_sort = 0
	let g:tagbar_compact = 1

" Always show side bar for errors so no blinking happens
set signcolumn=yes

"autosave on buffer switch
set autowrite
set autowriteall
"autosave on focus lost
au FocusLost,BufLeave * silent! wa
"no swap file since we save all the time
set noswapfile

"Check and reload files automatically that may have been changed outside of VIM
au FocusGained,BufEnter * :checktime

"-------------------------------------------------------
"MAPPINGS
"-------------------------------------------------------

"paste on line below with ALT-p
nmap <A-p> :pu<CR>

noremap <C-l> <C-w>l
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k

" Common fixes
nnoremap <silent>gb :BB<Cr>
nnoremap <silent>gB :BF<Cr>

" NERDTree
noremap <silent><A-n> <Esc>:NERDTreeToggle<CR>
tnoremap <silent><A-n> <C-\><C-n>:NERDTreeToggle<CR>


" Tagbar
noremap <silent><A-b> <Esc>:TagbarToggle<CR>
tnoremap <silent><A-b> <C-\><C-n>:TagbarToggle<CR>


"Language client
nnoremap <silent><F5> :call LanguageClient_contextMenu()<CR>

"Search workspace symbols : ALT-w
nnoremap <silent><A-w> :call LanguageClient_workspace_symbol()<CR>

"Search document symbols : ALT-d
nnoremap <silent><A-d> :call LanguageClient_textDocument_documentSymbol()<CR>
"Go to definition : gd
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>

"Go to caller : gc
nnoremap <silent> gc :call LanguageClient#cquery_callers()<CR>


nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
nnoremap <silent> lr :call LanguageClient#textDocument_references()<CR>


"
nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>

"Search buffers with FZF
nmap ; :Buffers<CR>

"Search Files with FZF
nmap , :Files<CR>

"Delete buffer with plugin buffkill (does not delete splits)
map <C-c> :BD<cr>

"Save filename to cliboard
nmap <silent> <F8> :let @+ = expand("%:p")<CR>


