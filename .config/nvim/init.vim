call plug#begin('~/.local/share/nvim/plugged')

"Plug 'fatih/vim-go'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'Shougo/deoplete-lsp'

Plug 'autozimu/LanguageClient-neovim', {
	\ 'branch': 'next',
	\ 'do': 'bash install.sh',
	\ }

" (Optional) Multi-entry selection UI.
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'neovim/nvim-lspconfig', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter'

Plug 'iCyMind/NeoSolarized'

" All of your Plugins must be added before the following line
call plug#end()

" BEGIN LSP
" \ 'go': ['/home/coolbry95/go/src/github.com/golang/tools/gopls/gopls', '-rpc.trace', '-vv', '-logfile', '/tmp/gopls'],
"let g:LanguageClient_serverCommands = {
"	\ 'go': ['gopls'],
"	\ 'python': ['/usr/local/bin/pyls'],
"	\ }
"let g:LanguageClient_selectionUI = "fzf"

"let g:LanguageClient_loadSettings = 1
"let g:LanguageClient_settingsPath = "~/.config/nvim/lsp.json"
" let g:LanguageClient_trace = "verbose"
" let g:LanguageClient_loggingLevel='DEBUG'
" let g:LanguageClient_loggingFile='/tmp/lc.log'
" let g:LanguageClient_serverStderr = '/tmp/lc.stderr'

"autocmd BufWritePre *.go :call LanguageClient#textDocument_formatting_sync()

"nnoremap <F5> :call LanguageClient_contextMenu()<CR>
"" Or map each action separately
"nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
"nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
"nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>

"END LSP


lua <<EOF
local lspconfig = require 'lspconfig'
lspconfig.gopls.setup{
	--cmd = {'gopls', '-rpc.trace', '-v', '-logfile', '/tmp/gpls'},
	cmd = {'gopls', 'serve'},
	settings = {
		gopls = {
			gofumpt = true,
			usePlaceholders = true,
			staticcheck = true,
		},
	},
}

function goimports(timeoutms)
	local context = { source = { organizeImports = true } }
	vim.validate { context = { context, "t", true } }

	local params = vim.lsp.util.make_range_params()
	params.context = context

	local method = "textDocument/codeAction"
	local resp = vim.lsp.buf_request_sync(0, method, params, timeoutms)
	if resp and resp[1] then
		local result = resp[1].result
		if result and result[1] then
			local edit = result[1].edit
			vim.lsp.util.apply_workspace_edit(edit)
		end
	end

	vim.lsp.buf.formatting_sync(nil, timeoutms)
end

require'nvim-treesitter.configs'.setup {
	ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
	highlight = {
		enable = true,              -- false will disable the whole extension
	},
}
EOF

"autocmd BufWritePre *.go lua goimports(100000)
autocmd BufWritePre *.go lua vim.lsp.buf.formatting_sync(nil, 1000)

"nnoremap <silent> <space>K    <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <silent> <space>f    <cmd>lua vim.lsp.buf.formatting()<CR>
nnoremap <silent> <space>rn    <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> <space>e    <cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>
nnoremap <silent> [d    <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap <silent> ]d    <cmd>lua vim.lsp.diagnostic.goto_next()<CR>
nnoremap <silent> <space>q    <cmd>lua vim.lsp.diagnostic.set_loclist()<CR>

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

" leave buffer without saving
set hidden

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
