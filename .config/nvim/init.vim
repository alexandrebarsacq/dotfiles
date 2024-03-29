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
    " Plug 'tbabej/taskwiki'

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

    Plug 'antoinemadec/coc-fzf', {'branch': 'release'}

    Plug 'justinmk/vim-sneak'

    Plug 'chrisbra/csv.vim'


call plug#end()



let g:python3_host_prog = '/usr/bin/python3.8'

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
            \ 'coc-pyright',
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

" Use tab to trigger completion with characters ahead and navigate.
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
tnoremap <A-h> <C-\><C-N><C-w>h
tnoremap <A-j> <C-\><C-N><C-w>j
tnoremap <A-k> <C-\><C-N><C-w>k
tnoremap <A-l> <C-\><C-N><C-w>l
inoremap <A-h> <C-\><C-N><C-w>h
inoremap <A-j> <C-\><C-N><C-w>j
inoremap <A-k> <C-\><C-N><C-w>k
inoremap <A-l> <C-\><C-N><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

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
nmap <silent> gh :CocCommand clangd.switchSourceHeader<CR>
nmap <silent> cr <Plug>(coc-refactor)
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

" file formating with clang-format
function FormatFile()
  let l:lines="all"
  pyf /usr/share/clang/clang-format.py
endfunction

map <leader>s :call FormatFile()<cr>


if has('python')
 map <C-S> :pyf /usr/share/clang/clang-format.py<cr>
 imap <C-S> <c-o>:pyf /usr/share/clang/clang-format.py<cr>
elseif has('python3')
 map <C-S> :py3f /usr/share/clang/clang-format.py<cr>
imap <C-S> <c-o>:py3f /usr/share/clang/clang-format.py<cr>
endif

"clear search highlight
nnoremap <leader>h :noh<cr>

"Map caps lock to esc key but clear behavior when exiting vim
au VimEnter * silent! !xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'
au VimLeave * silent! !xmodmap -e 'clear Lock' -e 'keycode 0x42 = Caps_Lock'

"Search word under cursor with ripgrep
nnoremap <Leader>x :Rg <C-R><C-W><CR>



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
hi DiffAdd      term=reverse    ctermfg=NONE          ctermbg=red



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

" Make coc_fzf_preview look like other fzf windows 
" coc_fzf_preview allows to see coc lists in fzf (ex:symbol references)
let g:coc_fzf_preview = ''
let g:coc_fzf_opts = []

" Catch cmocka errors
"[  ERROR   ] --- /home/alexandre/xxx.c:36: error: No mock calls expected but called() was invoked in __wrap_hsm_application_publish_message
set errorformat^=\[\ \ ERROR\ \ \ \]\ ---\ %f:%l:%m

" ***************************UNEXPECTED MESSAGE RECEIVED***************************[  ERROR   ] --- false
" [   LINE   ] --- /home/alexandre/kolibree/xxx.c:24: error: Failure!
"lines are set in backward order because we want to prepend this (^=) to
"existing errorformat
set errorformat^=%Z\[\ \ \ LINE\ \ \ \]\ ---\ %f:%l:\ %m
set errorformat^=%E%.%#\[\ \ ERROR\ \ \ \]\ ---\ false


"for debug
function! ToggleVerbose()
    if !&verbose
        set verbosefile=~/.log/vim/verbose.log
        set verbose=15
    else
        set verbose=0
        set verbosefile=
    endif
endfunction


let g:codi#interpreters = {
\ 'python3': {
       \ 'bin': 'python3',
       \ 'prompt': '^\(>>>\|\.\.\.\) ',
       \ },
   \ }

" add :Qargs command to copy quickfix list to arglist
command! -nargs=0 -bar Qargs execute 'args' QuickfixFilenames()
function! QuickfixFilenames()
  let buffer_numbers = {}
  for quickfix_item in getqflist()
    let buffer_numbers[quickfix_item['bufnr']] = bufname(quickfix_item['bufnr'])
  endfor
  return join(map(values(buffer_numbers), 'fnameescape(v:val)'))
endfunction


autocmd VimEnter * new
autocmd VimEnter * terminal ./watch_compile_command.sh
autocmd VimEnter * set nobuflisted
autocmd VimEnter * hide


" :[range]SortGroup[!] [n|f|o|b|x] /{pattern}/
" e.g. :SortGroup /^header/
" e.g. :SortGroup n /^header/
" See :h :sort for details

function! s:sort_by_header(bang, pat) range
  let pat = a:pat
  let opts = ""
  if pat =~ '^\s*[nfxbo]\s'
    let opts = matchstr(pat, '^\s*\zs[nfxbo]')
    let pat = matchstr(pat, '^\s*[nfxbo]\s*\zs.*')
  endif
  let pat = substitute(pat, '^\s*', '', '')
  let pat = substitute(pat, '\s*$', '', '')
  let sep = '/'
  if len(pat) > 0 && pat[0] == matchstr(pat, '.$') && pat[0] =~ '\W'
    let [sep, pat] = [pat[0], pat[1:-2]]
  endif
  if pat == ''
    let pat = @/
  endif

  let ranges = []
  execute a:firstline . ',' . a:lastline . 'g' . sep . pat . sep . 'call add(ranges, line("."))'

  let converters = {
        \ 'n': {s-> str2nr(matchstr(s, '-\?\d\+.*'))},
        \ 'x': {s-> str2nr(matchstr(s, '-\?\%(0[xX]\)\?\x\+.*'), 16)},
        \ 'o': {s-> str2nr(matchstr(s, '-\?\%(0\)\?\x\+.*'), 8)},
        \ 'b': {s-> str2nr(matchstr(s, '-\?\%(0[bB]\)\?\x\+.*'), 2)},
        \ 'f': {s-> str2float(matchstr(s, '-\?\d\+.*'))},
        \ }
  let arr = []
  for i in range(len(ranges))
    let end = max([get(ranges, i+1, a:lastline+1) - 1, ranges[i]])
    let line = getline(ranges[i])
    let d = {}
    let d.key = call(get(converters, opts, {s->s}), [strpart(line, match(line, pat))])
    let d.group = getline(ranges[i], end)
    call add(arr, d)
  endfor
  call sort(arr, {a,b -> a.key == b.key ? 0 : (a.key < b.key ? -1 : 1)})
  if a:bang
    call reverse(arr)
  endif
  let lines = []
  call map(arr, 'extend(lines, v:val.group)')
  let start = max([a:firstline, get(ranges, 0, 0)])
  call setline(start, lines)
  call setpos("'[", start)
  call setpos("']", start+len(lines)-1)
endfunction
command! -range=% -bang -nargs=+ SortGroup <line1>,<line2>call <SID>sort_by_header(<bang>0, <q-args>)


" Call this while selecting a commit to have a quickfix list of all modified
" files
command! DiffHistory call s:view_git_history()

function! s:view_git_history() abort
  " Git difftool --name-only ! !^@
  Git difftool --name-only build/star-research
  call s:diff_current_quickfix_entry()
  " Bind <CR> for current quickfix window to properly set up diff split layout after selecting an item
  " There's probably a better way to map this without changing the window
  copen
  nnoremap <buffer> <CR> <CR><BAR>:call <sid>diff_current_quickfix_entry()<CR>
  wincmd p
endfunction

function s:diff_current_quickfix_entry() abort
  " Cleanup windows
  for window in getwininfo()
    if window.winnr !=? winnr() && bufname(window.bufnr) =~? '^fugitive:'
      exe 'bdelete' window.bufnr
    endif
  endfor
  cc
  call s:add_mappings()
  let qf = getqflist({'context': 0, 'idx': 0})
  if get(qf, 'idx') && type(get(qf, 'context')) == type({}) && type(get(qf.context, 'items')) == type([])
    let diff = get(qf.context.items[qf.idx - 1], 'diff', [])
    echom string(reverse(range(len(diff))))
    for i in reverse(range(len(diff)))
      exe (i ? 'leftabove' : 'rightbelow') 'vert diffsplit' fnameescape(diff[i].filename)
      call s:add_mappings()
    endfor
  endif
endfunction

function! s:add_mappings() abort
  nnoremap <buffer>]q :cnext <BAR> :call <sid>diff_current_quickfix_entry()<CR>
  nnoremap <buffer>[q :cprevious <BAR> :call <sid>diff_current_quickfix_entry()<CR>
  " Reset quickfix height. Sometimes it messes up after selecting another item
  11copen
  wincmd p
endfunction


function! HighlightRepeats() range
  let lineCounts = {}
  let lineNum = a:firstline
  while lineNum <= a:lastline
    let lineText = getline(lineNum)
    if lineText != ""
      let lineCounts[lineText] = (has_key(lineCounts, lineText) ? lineCounts[lineText] : 0) + 1
    endif
    let lineNum = lineNum + 1
  endwhile
  exe 'syn clear Repeat'
  for lineText in keys(lineCounts)
    if lineCounts[lineText] >= 2
      exe 'syn match Repeat "^' . escape(lineText, '".\^$*[]') . '$"'
    endif
  endfor
endfunction

command! -range=% HighlightRepeats <line1>,<line2>call HighlightRepeats()
