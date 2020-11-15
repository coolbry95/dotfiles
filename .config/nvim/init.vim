call plug#begin('~/.local/share/nvim/plugged')

"Plug 'fatih/vim-go'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'autozimu/LanguageClient-neovim', {
	\ 'branch': 'next',
	\ 'do': 'bash install.sh',
	\ }

" (Optional) Multi-entry selection UI.
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'iCyMind/NeoSolarized'

" All of your Plugins must be added before the following line
call plug#end()

" \ 'go': ['/home/coolbry95/go/src/github.com/golang/tools/gopls/gopls', '-rpc.trace', '-vv', '-logfile', '/tmp/gopls'],
let g:LanguageClient_serverCommands = {
	\ 'go': ['gopls'],
	\ 'python': ['/usr/local/bin/pyls'],
	\ }
let g:LanguageClient_selectionUI = "fzf"

let g:LanguageClient_loadSettings = 1
let g:LanguageClient_settingsPath = "~/.config/nvim/lsp.json"
" let g:LanguageClient_trace = "verbose"
" let g:LanguageClient_loggingLevel='DEBUG'
" let g:LanguageClient_loggingFile='/tmp/lc.log'
" let g:LanguageClient_serverStderr = '/tmp/lc.stderr'

autocmd BufWritePre *.go :call LanguageClient#textDocument_formatting_sync()

nnoremap <F5> :call LanguageClient_contextMenu()<CR>
" Or map each action separately
nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>

autocmd BufWritePre *.go :call LanguageClient#textDocument_formatting_sync()

" fzf
nnoremap <Leader>b :Buffers<CR>
nnoremap <Leader>f :Files<CR>

" deoplete

let g:deoplete#enable_at_startup = 1

call deoplete#custom#option({
	\ 'ignore_case': v:true,
	\ 'ignore_sources': {'_': ['buffer']},
	\ })

"autocmd CompleteDone * silent! pclose!
autocmd InsertLeave * silent! pclose!

" noinsert does not insert a match, it forces the user to
set completeopt=longest,menuone

inoremap <expr> <C-n> pumvisible() ? '<C-n>' :
  \ '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'
inoremap <expr> <M-,> pumvisible() ? '<C-n>' :
  \ '<C-x><C-o><C-n><C-p><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'

" if pumvisible then tab moves
" if pumvisible then SHIFT tab moves backwards
" else tab
" // this is like how YCM is set up
inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
" shift tab moves backwards up menu	
inoremap <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<Tab>"
" close pop up menu if open with ENTER
inoremap <silent><expr> <CR> pumvisible() ? deoplete#close_popup() : "\<CR>"

syntax on
"colorscheme eink
"colorscheme solarized
colorscheme NeoSolarized
set background=dark
" for when a terminal with true color support is used
set termguicolors

" go plugin
let g:go_play_open_browser = 0
let g:go_fmt_fail_silently = 1
let g:go_fmt_autosave = 0

" swap file
set backupdir=~/.config/nvim/backup//
set directory=~/.config/nvim/swap//
set undodir=~/.config/nvim/undo//

" tabs and spaces
" number of visual spaces per TAB
set tabstop=4
set shiftwidth=4
set noexpandtab

set list

" set numbers on
set number

filetype plugin indent on
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" Run gofmt and goimports on save
autocmd BufWritePre *.go :call LanguageClient#textDocument_formatting_sync()

" i hate bells
set novisualbell
set noerrorbells

set encoding=utf-8

" differences from vim to nvim
set noautoindent
set mouse=""
set nosmarttab
set laststatus=1
" bottom line numbers in the corner
set ruler
