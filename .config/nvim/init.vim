" My neovim config
" TODO : https://github.com/camspiers/dotfiles/blob/master/files/.config/nvim/init.vim
"-------------------------------------------------------
"Plugin management
"-------------------------------------------------------

call plug#begin('~/.vim/bundle')
    " Fzf fuzy find : install via linuxbrew
    " Plug '/home/linuxbrew/.linuxbrew/opt/fzf'
    " todo : clear up this
   Plug 'junegunn/fzf', { 'do': './install --bin' }
    Plug 'junegunn/fzf.vim'
    "color picker
    Plug 'DougBeney/pickachu'
    " Color scheme
    Plug 'mhartington/oceanic-next'
    Plug 'morhetz/gruvbox'
    Plug 'endel/vim-github-colorscheme'
    
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
    "awesome search and replace with case preservation 
    ":%Subvert/facilit{y,ies}/building{,s}/g
    Plug 'tpope/vim-abolish'
    "Git integration
    Plug 'tpope/vim-fugitive'
    "Git blame in popup
    Plug 'rhysd/git-messenger.vim' " :GitMessenger

    "easily find what key to press for 'f' and 't'
    Plug 'unblevable/quick-scope'      

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
    Plug 'jackguo380/vim-lsp-cxx-highlight'

    Plug 'metakirby5/codi.vim'

    Plug 'tpope/vim-dispatch'


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
            \ 'coc-snippets',
            \ 'coc-clangd',
            \ 'coc-rls']

packadd termdebug
""-------------------------------------------------------
"Configuration
"-------------------------------------------------------
" Workaround some broken plugins which set guicursor indiscriminately.
" Taken from : https://github.com/neovim/neovim/wiki/FAQ
" :set guicursor=
" :autocmd OptionSet guicursor noautocmd set guicursor=

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

set number relativenumber
"Use x spaces per tabs"
" show existing tab with x spaces width
set tabstop=4
" when indenting with '>', use x spaces width
set shiftwidth=4
" On pressing tab, insert x spaces
set expandtab
"Searches ignore case unless an upercase is typed
set ignorecase
set smartcase
"use system clipboard
set clipboard=unnamedplus
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


" Highlight symbol under cursor on CursorHold !!!!
autocmd CursorHold * silent call CocActionAsync('highlight')



"-------------------------------------------------------
"UI stuff
"-------------------------------------------------------
" Enable true color support
set termguicolors
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
"live substition 
set inccommand=nosplit

autocmd! FileType fzf set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END



"use ripgrep
if executable("rg")
    set grepprg=rg\ --vimgrep\ --no-heading
    set grepformat=%f:%l:%c:%m,%f:%l:%m
endif

let g:vimwiki_list = [{'syntax': 'markdown', 'ext': '.md'}]

function! ToggleVerbose()
    if !&verbose
        set verbosefile=~/.log/vim/verbose.log
        set verbose=15
    else
        set verbose=0
        set verbosefile=
    endif
endfunction

"fzf in floating windows
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }

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

" Use leader d to show documentation in preview window
nnoremap <silent> <leader>d :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

"easier for azerty, and actually puts backtick functionnality at same location
nmap ² `
omap ² `
xmap ² `

"more azerty
"nmap ù ^
"omap ù ^
"xmap ù ^
"map ù ^


" set spelllang=en,fr
" set langmap=à@,è`,é~,ç_,’`,ù%
" lmap à @
" lmap è `
" lmap é ~
" lmap ç _
" lmap ù %
" lmap ’ `

" map  µ #
" map! µ #
" map  § <Bslash>
" map! § <Bslash>
" map  ° <Bar>
" map! ° <Bar>

"more azerty : because brackets are too hard to get
"we use ç for [ and à for ]
nmap ç [
nmap à ]
omap ç [
omap à ]
xmap ç [
xmap à ]

map ù <C-^>

"more azerty : use µ for # : especially usefull to search 
nmap µ #

"paste on line below with ALT-p
nmap <A-p> :pu<CR>



"To simulate |i_CTRL-R| in terminal-mode: >
    ":tnoremap <expr> <C-R> '<C-\><C-N>"'.nr2char(getchar()).'pi'

"To use `ALT+{h,j,k,l}` to navigate windows from any mode: >
    :tnoremap <A-h> <C-\><C-N><C-w>h
    :tnoremap <A-j> <C-\><C-N><C-w>j
    :tnoremap <A-k> <C-\><C-N><C-w>k
    :tnoremap <A-l> <C-\><C-N><C-w>l
    :inoremap <A-h> <C-\><C-N><C-w>h
    :inoremap <A-j> <C-\><C-N><C-w>j
    :inoremap <A-k> <C-\><C-N><C-w>k
    :inoremap <A-l> <C-\><C-N><C-w>l
    :nnoremap <A-h> <C-w>h
    :nnoremap <A-j> <C-w>j
    :nnoremap <A-k> <C-w>k
    :nnoremap <A-l> <C-w>l

"move around buffer
nnoremap <leader>j :bp<CR>
nnoremap <leader>k :bn<CR>
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
""Search Files with FZF
nmap <leader>f :Files<CR>
"" Grep files with ripgrep and fzf
nmap <leader>g :Rg<CR>

" Use <C-l> for trigger snippet expand.
imap <C-l> <Plug>(coc-snippets-expand)

" coc : Introduce function text object
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

"Delete buffer with plugin buffkill (does not delete splits)
map <C-c> :BD<cr>
" Allows you to save files you opened without write permissions via sudo
cmap w!! w !sudo tee %

"leave normal mode fast
imap jk <Esc>
imap kj <Esc>


"Save filename to cliboard
nmap <silent> <F9> :let @+ = expand("%:p")<CR>

map <leader>s :call FormatFile()<cr>


nnoremap <Leader>x :Rg <C-R><C-W><CR>

function FormatFile()
  let l:lines="all"
  pyf /usr/share/clang/clang-format.py
endfunction

function! SwitchColorScheme()
  " if g:colors_name == "gruvbox"
  if g:colors_name == "github"
    colorscheme OceanicNext
    set background=dark
    hi debugPC term=reverse ctermbg=darkblue guibg=darkblue
    hi debugBreakpoint term=reverse ctermbg=red guibg=red
    let $BAT_THEME = 'OneHalfDark'
  else
    colorscheme github
    set background=light
    hi debugPC term=reverse ctermbg=lightblue guibg=lightblue
    hi debugBreakpoint term=reverse ctermbg=red guibg=red
    hi LspCxxHlGroupMemberVariable ctermfg=Green guifg=#008700 cterm=none gui=none
    let $BAT_THEME = 'OneHalfLight'
  endif
endfunction

map <silent> <F8> :call SwitchColorScheme()<CR>




hi debugPC term=reverse ctermbg=darkblue guibg=darkblue
hi debugBreakpoint term=reverse ctermbg=red guibg=red




function! s:list_buffers()
  redir => list
  silent ls
  redir END
  return split(list, "\n")
endfunction

function! s:delete_buffers(lines)
  execute 'bwipeout' join(map(a:lines, {_, line -> split(line)[0]}))
endfunction

command! FZFBD call fzf#run(fzf#wrap({
  \ 'source': s:list_buffers(),
  \ 'sink*': { lines -> s:delete_buffers(lines) },
  \ 'options': '--multi --reverse --bind ctrl-a:select-all+accept'
\ }))


set makeprg=./launchtest.sh\ %


noremap <silent> <F12> :silent CocRestart<CR>

" let g:qs_buftype_blacklist = ['terminal', 'nofile']


"To map <Esc> to exit terminal-mode: while still exiting fzf with ESC
" tnoremap <Esc> <C-\><C-n>

" function! OnFZFOpen() abort
"   tnoremap <Esc> <c-c>
"   startinsert
"   autocmd BufLeave <buffer> tnoremap <Esc> <C-\><C-n>
" endfunction


" Enables UI styles suitable for terminals etc
" function! EnableCleanUI() abort
"   setlocal listchars=
"     \ nonumber
"     \ norelativenumber
"     \ nowrap
"     \ winfixwidth
"     \ laststatus=0
"     \ noshowmode
"     \ noruler
"     \ scl=no
"     \ colorcolumn=
"   autocmd BufLeave <buffer> set laststatus=2 showmode ruler
" endfunction

" Auto Commands {{{
" augroup General
"   autocmd!
"   autocmd! FileType fzf call OnFZFOpen()
" augroup END
"
"" CMake Parser : evite l'ouverture des fichiers buggés mais enleve tout saut
"court meme les bons
" Call stack entries
" let &efm = ' %#%f:%l %#(%m)'
" " Start of multi-line error
" let &efm .= ',%E' . 'CMake Error at %f:%l (message):'
" " End of multi-line error
" let &efm .= ',%Z' . 'Call Stack (most recent call first):'
" " Continuation is message
" let &efm .= ',%C' . ' %m'

" set errorformat+=%D%*\\a:\ Entering\ directory\ '%f'
" set errorformat+=%X%*\\a:\ Leaving\ directory\ '%f'
