call plug#begin('~/.local/share/nvim/plugged')

"Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
"Plug 'Shougo/deoplete-lsp'

Plug 'hrsh7th/nvim-compe'

" (Optional) Multi-entry selection UI.
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'neovim/nvim-lspconfig', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter'

Plug 'overcache/NeoSolarized'

" All of your Plugins must be added before the following line
call plug#end()

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

nnoremap <silent> <space>K    <cmd>lua vim.lsp.buf.code_action()<CR>
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

lua <<EOF
vim.o.completeopt = "menuone,noselect"

require'compe'.setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'disable';
  throttle_time = 80;
  source_timeout = 200;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = true;

  source = {
    path = true;
    buffer = true;
    calc = false;
    vsnip = false;
    nvim_lsp = true;
    nvim_lua = true;
    spell = true;
    tags = true;
    snippets_nvim = false;
    treesitter = true;
  };
}


local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  --elseif vim.fn.call("vsnip#available", {1}) == 1 then
  --  return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  --elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
  --  return t "<Plug>(vsnip-jump-prev)"
  else
    return t "<S-Tab>"
  end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

EOF

" deoplete start

"let g:deoplete#enable_at_startup = 1
"
"call deoplete#custom#option({
"	\ 'ignore_case': v:true,
"	\ 'ignore_sources': {'_': ['buffer']},
"	\ })
"
""autocmd CompleteDone * silent! pclose!
"autocmd InsertLeave * silent! pclose!


" noinsert does not insert a match, it forces the user to
"set completeopt=longest,menuone
"
"inoremap <expr> <C-n> pumvisible() ? '<C-n>' :
"  \ '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'
"inoremap <expr> <M-,> pumvisible() ? '<C-n>' :
"  \ '<C-x><C-o><C-n><C-p><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'
"
"" if pumvisible then tab moves
"" if pumvisible then SHIFT tab moves backwards
"" else tab
"" // this is like how YCM is set up
"inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
"" shift tab moves backwards up menu	
"inoremap <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<Tab>"
"" close pop up menu if open with ENTER
"inoremap <silent><expr> <CR> pumvisible() ? deoplete#close_popup() : "\<CR>"
" deoplete end

" leave buffer without saving
set hidden

syntax on
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

set nohlsearch
set incsearch
set signcolumn=yes

" show > for tabs
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
"set noautoindent
set mouse=""
set nosmarttab
set laststatus=1
" bottom line numbers in the corner
set ruler
