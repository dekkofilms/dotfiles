" Run Pathogen (vim package manager)
execute pathogen#infect()

" Set up folding based on markers in the file. `za` toggles folds
" vim:foldmethod=marker:foldlevel=0

" These functions clobber "z 'z and 'Z on the reg, beware.

" ---------- TODOS ---------- {{{1
" Plugin I am considering:
" https://github.com/sjl/gundo.vim.git
" https://github.com/tpope/unimpaired.vim
" https://github.com/skywind3000/asyncrun.vim
" https://github.com/tpope/vim-abolish

" ---------- General ---------- {{{1
" Override Y to behave like C and D
map Y y$

" Save undos after file closes
set undofile
" Number of undos to save
set undolevels=1000
" Number of lines to save for undo
set undoreload=10000

" Set dirs so we don't litter all over
set undodir=~/.vim/cache/undo
set backupdir=~/.vim/cache/backup
set dir=~/.vim/cache/swap

" Prompt to save instead of erroring
set confirm

" Delete comment characters when joining lines
set formatoptions+=j

" Maximum number of tab pages that can be opened from CLI
set tabpagemax=50

" Disable beep on errors
set noerrorbells

" redraw only when we need to.
set lazyredraw

"Wrap lines at words when possible
set linebreak

" show command in bottom bar
set showcmd

" load filetype-specific indent files
filetype plugin indent on

" Turn on line numbers
set relativenumber

" highlight matching [{()}]
set showmatch

" Store lots of :cmdline history
set history=1000

" No sounds
set visualbell

" Reload files changed outside vim
set autoread

" Work with crontabs
augroup CrontabConfig
  autocmd!
  autocmd BufNewFile,BufRead crontab.* set nobackup | set nowritebackup
augroup END

" Use the clipboard as the default register
set clipboard^=unnamed

" Configure backspacing to work 'normally'
set backspace=indent,eol,start

" Delay after typing stops before checking again (used by gitgutter).
" Can cause issues under 1000ms
set updatetime=50

" Remove escape delays (This breaks arrow keys in insert mode)
set noesckeys
set timeout timeoutlen=1000 ttimeoutlen=100

" Autocorrect some typos when trying to quit
abbrev W w
abbrev Wq wq
abbrev Q q

" ---------- Colors ---------- {{{1
" enable syntax processing
if !exists("g:syntax_on")
  syntax enable
endif

" Setup a color theme
set background=dark
colorscheme solarized

command! ToggleBackground :call ToggleBackground()

" Toggle iterm and vim between dark and light
function! ToggleBackground() abort
  if &background == "dark"
    set background=light
    normal :!echo -e "\033]50;SetProfile=Light\a"
  elseif &background == "light"
    set background=dark
    normal :!echo -e "\033]50;SetProfile=Dark\a"
  endif

  if !exists('g:loaded_lightline')
    return
  endif

  try
    if g:colors_name =~# 'solarized'
      runtime autoload/lightline/colorscheme/solarized.vim
      call lightline#init()
      call lightline#colorscheme()
      call lightline#update()
    endif
  catch
  endtry
endfunction

" ---------- Plugins ---------- {{{1
" Ack {{{2
" Use ag instead of ack
let g:ackprg = 'ag --vimgrep --smart-case'

" Highlight hits
let g:ackhighlight = 1

" I type Ag out of habit. The ! prevents jumping to the first hit
abbrev Ag Ack!
abbrev AG Ack!
abbrev ag Ack!

command! OpenQFTabs :call OpenQuickFixInTabs()

function! OpenQuickFixInTabs() abort
  " Close qf list to prevent mark errors
  normal :cclose

  " Save our spot so we can come back
  let current_file = expand('%:p')
  normal mz

  " Building a hash ensures we get each buffer only once
  let buffer_numbers = {}
  for quickfix_item in getqflist()
    let bufnr = quickfix_item['bufnr']
    " Lines without files will appear as bufnr=0
    if bufnr > 0
      " Get absolute path for each buffer
      let buffer_numbers[bufnr] = trim(fnameescape(expand("#" . bufnr . ":p")). ' ')
    endif
  endfor

  execute "normal :silent!$tab drop " . join(values(buffer_numbers)) . "\<CR>"
  " for qf_file in values(buffer_numbers)
  "   " Ignore Errors. Escape filepath strings. Open existing buffer or append new tab.
  "   execute "normal :silent!$tab drop " . qf_file . "\<CR>"
  " endfor

  normal :redraw!

  " Jump back to original file.
  execute "normal :silent!tab drop " . current_file . "\<CR>"
  normal `z

  normal :copen
endfunction

" ---------- Ale ---------- {{{2
" Set up auto fixers
let g:ale_fixers = { 'typescript': ['eslint', 'prettier-eslint'], 'javascript': ['eslint', 'prettier-eslint'], 'python': ['autopep8'], 'python3': ['autopep8'] }
let g:ale_linters = { 'javascript': ['flow', 'eslint'], 'python': ['pylint'], 'python3': ['pylint'] }
let g:ale_yaml_yamllint_options='-d "{extends: relaxed, rules: {line-length: disable}}"'

let g:ale_lint_delay = 50
let g:ale_completion_enabled = 1
let g:ale_set_balloons = 1

let g:ale_sign_error = 'X' " could use emoji
let g:ale_sign_warning = '?' " could use emoji
let g:ale_statusline_format = ['X %d', '? %d', '']
" %linter% is the name of the linter that provided the message
" %s is the error or warning message
let g:ale_echo_msg_format = '%linter% says %s'

" :help ale-reasonml-ols
let g:ale_reason_ols_use_global = 1


" GitGutter has gutter enabled which makes this option unnecessary
" Keep sign column open all the time so changes are less jarring
" let g:ale_sign_column_always = 1

" ---------- CamelCaseMotion ----------{{{2
" Make w and e respect camel (and snake, ironically) case
map <silent> w <Plug>CamelCaseMotion_w
map <silent> b <Plug>CamelCaseMotion_b
map <silent> e <Plug>CamelCaseMotion_e
map <silent> ge <Plug>CamelCaseMotion_ge
sunmap w
sunmap b
sunmap e
sunmap ge

" ---------- CtrlP ---------- {{{2
" Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

" Display hidden files
let g:ctrlp_show_hidden = 1

" ---------- Git Gutter ---------- {{{2
" Don't create any key mappings
let g:gitgutter_map_keys = 0

" Keep gutter open
if exists('&signcolumn')  " Vim 7.4.2201
  set signcolumn=yes
else
  let g:gitgutter_sign_column_always = 1
endif

" ---------- Javascript ---------- {{{2
" let g:javascript_plugin_jsdoc = 0
let g:javascript_plugin_flow = 1

" ---------- LightLine ---------- {{{2
" Always show statusline
set laststatus=2
"
" Don't show current mode since it is in status bar
set noshowmode

" Use defaults, but take out file percentage, and add a clock
let g:lightline = {
      \   'colorscheme': 'solarized',
      \   'active': {
      \     'left': [ [ 'mode', 'paste' ],
      \               [ 'gitbranch', 'readonly', 'filepath' ] ],
      \     'right': [ [],
      \                [ 'lineinfo' ],
      \                [ 'modified', 'fileencoding', 'filetype' ] ]
      \   },
      \   'component_function': {
      \     'filepath': 'PrintFilePath',
      \     'gitbranch': 'fugitive#head',
      \     'time': 'PrintTime'
      \   },
      \ }

" Function used for printing relative file path
function! PrintFilePath() abort
  return fnamemodify(expand("%"), ":~:.")
endfunction

" ---------- NERDTree ---------- {{{2
" Automatically delete the buffer of the file you just deleted with NerdTree:
let NERDTreeAutoDeleteBuffer = 1

" Toggle visibility of hidden files using i and I
let NERDTreeShowHidden=1

" Don't open NERDTree by default
let g:nerdtree_tabs_open_on_gui_startup=0

" Close tree once file is selected
let NERDTreeQuitOnOpen = 1

" Toggle Nerd Tree with control + b
nnoremap <c-b> :NERDTreeFind<CR>

" ---------- Smooth Scroll ---------- {{{2
noremap <silent> <c-u> :call smooth_scroll#up(float2nr(&scroll * 0.75), 15, 2)<CR>
noremap <silent> <c-d> :call smooth_scroll#down(float2nr(&scroll * 0.75), 15, 2)<CR>
" noremap <silent> <c-b> :call smooth_scroll#up(float2nr(&scroll* 1.5), 15, 2)<CR>
" noremap <silent> <c-f> :call smooth_scroll#down(float2nr(&scroll* 1.5), 15, 2)<CR>

" ---------- Sneak ---------- {{{2
map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T

" ---------- Startify ---------- {{{2
let g:startify_session_dir = '~/.vim/cache/session'

" ---------- Leader: General ---------- {{{1
" Map space to leader
let mapleader = " "

" Make space leader behave the same as other keys would
nnoremap <Space> <nop>

" highlight last inserted text
nnoremap <leader>v `[v`]

" turn off search highlight
nnoremap <leader>n :noh<CR>

" Toggle linting with a (for ale)
nnoremap <leader>a :ALEToggle<CR>

" Fix linting errors
nnoremap <leader>af :ALEFix<CR>

" Map keys to navigate between lines with errors and warnings.
nnoremap <leader>an :ALENextWrap<cr>
nnoremap <leader>ap :ALEPreviousWrap<cr>

" Custom mapping for vim.switch
nnoremap <leader>s :Switch<CR>

" Apply last operation to a range of lines
vnoremap <leader>. : normal .<CR>

" Fix indentation for the whole file
map <leader>= gg=G''

" Reload vimrc
nnoremap <leader>rel :source ~/.vimrc<CR>

" Clear CtrlP Caches
nnoremap <leader>p :CtrlPClearAllCaches<CR>

" ---------- Leader: Snippets ---------- {{{1
function! LocalReindent() abort
  normal mz
  normal 10k
  normal 20==
  normal 'z
endfunction

" Generate js function
nnoremap <leader>fun :-1read $HOME/.vim/snippets/function.js<CR>:call LocalReindent()<CR>f(a

" Generate new Promise, and then/catch blocks
nnoremap <leader>prom :read $HOME/.vim/snippets/promise.js<CR>:call LocalReindent()<CR>kJo
nnoremap <leader>then :read $HOME/.vim/snippets/then.js<CR>:call LocalReindent()<CR>f(la
nnoremap <leader>catch :read $HOME/.vim/snippets/catch.js<CR>:call LocalReindent()<CR>o

" Generate conditional blocks
nnoremap <leader>if :-1read $HOME/.vim/snippets/if.js<CR>:call LocalReindent()<CR>f(a
nnoremap <leader>else :read $HOME/.vim/snippets/else.js<CR>:call LocalReindent()<CR>kJo
nnoremap <leader>elif :read $HOME/.vim/snippets/elif.js<CR>:call LocalReindent()<CR>kJf(a

" Generate try-catch block
nnoremap <leader>try :-1read $HOME/.vim/snippets/try.js<CR>:call LocalReindent()<CR>o

" Generate loops
nnoremap <leader>forof :-1read $HOME/.vim/snippets/forof.js<CR>:call LocalReindent()<CR>f)i
nnoremap <leader>forin :-1read $HOME/.vim/snippets/forin.js<CR>:call LocalReindent()<CR>f)i

" ---------- Leader: Custom Functions ---------- {{{1
" Mappings that use custom functions
nnoremap <leader>bot :call UseBottomDiff()<CR>
nnoremap <leader>top :call UseTopDiff()<CR>
nnoremap <leader>req :call JsRequire()<CR>
nnoremap <leader>log :call JsLog()<CR>
nnoremap <leader>js  :call JsStringify()<CR>

" Picks the bottom section of a git conflict
function! UseBottomDiff() abort
  normal /<<<
  normal d/===
  normal dd
  normal />>>
  normal dd
endfunction

" Picks the top section of a git conflict
function! UseTopDiff() abort
  normal /<<<
  normal dd
  normal /===
  normal d/>>>
  normal dd
endfunction

" Creates a variable and require statement, uses z registry
function! JsRequire() abort
  normal "zciWconst z = require('z');
endfunction

" Creates a labelled console.log, uses z registry
function! JsLog() abort
  normal "zciWconsole.log('z', z);
endfunction

" Json stringify Word using z registry
function! JsStringify() abort
  normal "zciwJSON.stringify(z, null, 2)
endfunction

" ---------- Movement & Searching ---------- {{{1
" I override b,w,e, and ge in plugins > CamelCaseMotion

" search as characters are entered
set incsearch

" highlight matches
set hlsearch

" Case insensitive unless a capital character is included
set ignorecase
set smartcase

"Start scrolling when we're 10 lines away
set scrolloff=25

" Don't skip visual lines (wrapped text)
nnoremap j gj
nnoremap k gk
xnoremap j gj
xnoremap k gk

nnoremap gf <c-w>gf
" " Easier split navigation
" NOTE: These have been deprecated in favor of C-h, C-j, C-k, and C-l for
" compatibility with vim-tmux-navigator
" nmap gh <C-w>h
" nmap gj <C-w>j
" nmap gk <C-w>k
" nmap gl <C-w>l

" ---------- Folding ---------- {{{1
" enable folding
set foldenable

" open most folds by default
set foldlevelstart=10

" 10 nested fold max
set foldnestmax=10

" fold based on indent level
set foldmethod=marker

" Custom Folding Colors
augroup FoldColorGroup
  highlight Folded cterm=NONE term=bold ctermfg=white
augroup END

" Custom Fold Content
set foldtext=FoldText()

function! FoldText()
  let line = getline(v:foldstart)

  let nucolwidth = &fdc + &number * &numberwidth
  let windowwidth = winwidth(0) - nucolwidth - 3
  let foldedlinecount = v:foldend - v:foldstart
  let line = trim(substitute(substitute(substitute(substitute(line, '\d', '', 'g'), '-', '', 'g'), '{', '', 'g'), '"', '', 'g'))
  let line = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))

  if windowwidth > 100
    let maxtitlelength = 50
    let titlepadding = maxtitlelength - len(line)
    let fillcharcount = windowwidth - maxtitlelength - len(foldedlinecount) - (v:foldlevel * 2)
    return repeat('  ', v:foldlevel - 1) . '▸ ' . line . repeat(' ', titlepadding - 3) . 'L# ' . foldedlinecount . repeat(' ', fillcharcount) . ' '
  else
    let fillcharcount = windowwidth - len(line) - len(foldedlinecount) - (v:foldlevel * 2)
    return repeat('  ', v:foldlevel - 1) . '▸ ' . line . repeat(' ',fillcharcount) . foldedlinecount . '  '
  endif
endfunction

" ---------- Wildmenu ---------- {{{1
" configure visual autocomplete for command menu
set wildmenu
set wildignorecase
set completeopt+=longest
set wildmode=longest:full,full

" ---------- Cursor ---------- {{{1
" Enable mouse
set mouse=a

" Disable cursor blink
set guicursor=a:blinkon0

" Only highlight current line for current window
" setlocal cursorline
" augroup CursorLineGroup
"   autocmd!
"   autocmd WinEnter,FocusGained * setlocal cursorline
"   autocmd WinLeave,FocusLost   * setlocal nocursorline
" augroup END

" ---------- Spaces and Tabs ---------- {{{1
" Remove trailing whitespace on save
augroup RemoveTrailingWhitespaceGroup
  autocmd!
  autocmd BufWritePre * %s/\s\+$//e
augroup END

" New lines start in better places
set autoindent

" Indentation settings for using 4 spaces instead of tabs.
set softtabstop=2
set shiftwidth=2
set expandtab

" ---------- Python Setup ---------- {{{1
" Turning on(1)/off(0) syntax highlighting for python
let g:python_highlight_all = 1

" ---------- Perf fix ---------- {{{1
" Fix Cursor rendering issue
set ttyfast
set norelativenumber
set number
set noshowcmd
