-- Auto install packer.nvim if not exists
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd 'packadd packer.nvim'
end

--require('plugins')
require('packer').startup(function()
  -- Packer can manage itself
	use 'wbthomason/packer.nvim'

	use {
		'hrsh7th/nvim-cmp',
		requires = {
			-- Install snippet engine (This example installs [hrsh7th/vim-vsnip](https://github.com/hrsh7th/vim-vsnip))
			'hrsh7th/vim-vsnip',
			-- Install the buffer completion source
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-nvim-lua',
			'ray-x/cmp-treesitter',
		}
	}


	-- (Optional) Multi-entry selection UI.
	--use { 'junegunn/fzf', { 'do': { -> fzf#install() } }
	--use 'junegunn/fzf.vim'

	use {
		'nvim-telescope/telescope.nvim',
		requires = {
			'nvim-lua/popup.nvim',
			'nvim-lua/plenary.nvim',
			'nvim-telescope/telescope-fzy-native.nvim',
		}
	}

	use 'neovim/nvim-lspconfig'
	--use 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
	use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

	use 'overcache/NeoSolarized'


end)

vim.g.mapleader = " "
vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })
--vim.g.maplocalleader = ' '

local lspconfig = require 'lspconfig'

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

lspconfig.pylsp.setup{
	cmd = { "pylsp" },
	filetypes = { "python" },
	root_dir = function(fname)
		local root_files = {
			'pyproject.toml',
			'setup.py',
			'setup.cfg',
			'requirements.txt',
			'Pipfile',
		}
		return lspconfig.util.root_pattern(unpack(root_files))(fname) or lspconfig.util.find_git_ancestor(fname)
	end,
	single_file_support = true,
	capabilities = capabilities,
}

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
    capabilities = capabilities,
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

-- TODO
--"autocmd BufWritePre *.go lua goimports(100000)
vim.cmd [[ autocmd BufWritePre *.go lua vim.lsp.buf.formatting_sync(nil, 1000) ]]

vim.api.nvim_set_keymap('n', '<Space>K',  [[<Cmd>lua vim.lsp.buf.code_action()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Space>f',  [[<Cmd>lua vim.lsp.buf.formatting()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Space>rn',  [[<Cmd>lua vim.lsp.buf.rename()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gd',  [[<Cmd>lua vim.lsp.buf.definition()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'K',  [[<Cmd>lua vim.lsp.buf.hover()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-]',  [[<Cmd>lua vim.lsp.buf.implementation()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-k',  [[<Cmd>lua vim.lsp.buf.signature_help()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gD',  [[<Cmd>lua vim.lsp.buf.type_definition()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gr',  [[<Cmd>lua vim.lsp.buf.references()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'g0',  [[<Cmd>lua vim.lsp.buf.document_symbol()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gW',  [[<Cmd>lua vim.lsp.buf.workspace_symbol()<CR>]], { noremap = true, silent = true })
--vim.api.nvim_set_keymap('n', 'gD',  [[<Cmd>lua vim.lsp.buf.declaration()<CR>]], { noremap = true, silent = true }) -- this is used twice
vim.api.nvim_set_keymap('n', '<Space>e',  [[<Cmd>lua vim.lsp.buf.show_line_diagnostics()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '[d',  [[<Cmd>lua vim.lsp.buf.goto_prev()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ']d',  [[<Cmd>lua vim.lsp.buf.goto_next()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Space>q',  [[<Cmd>lua vim.lsp.buf.set_loclist()<CR>]], { noremap = true, silent = true })

require('telescope').setup {
    defaults = {
        file_sorter = require('telescope.sorters').get_fzy_sorter,

        mappings = {
            i = {
                ["<C-x>"] = false,
                ["<C-q>"] = require('telescope.actions').send_to_qflist,
            },
        }
    },

    extensions = {
        fzy_native = {
            override_generic_sorter = false,
            override_file_sorter = true,
        }
    }
}
-- This will load fzy_native and have it override the default file sorter
require('telescope').load_extension('fzy_native')

vim.api.nvim_set_keymap('n', 'ff',  [[<Cmd>lua require('telescope.builtin').find_files()<CR>]], { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', 'fg',  [[<Cmd>lua require('telescope.builtin').live_grep()<CR>]], { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', 'fb',  [[<Cmd>lua require('telescope.builtin').buffers()<CR>]], { noremap = true, silent = false })
vim.api.nvim_set_keymap('n', 'fh',  [[<Cmd>lua require('telescope.builtin').help_tags()<CR>]], { noremap = true, silent = false })

local cmp = require'cmp'

local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
    return false
  end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

cmp.setup {

	completion = {
		copleteopt = 'menu,menuone,noselect'
	},

	preselect = cmp.PreselectMode.None,

	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
		end,
	},

	formatting = {
		format = function(entry, vim_item)
			-- fancy icons and a name of kind
			--vim_item.kind = require("lspkind").presets.default[vim_item.kind] .. " " .. vim_item.kind

			-- set a name for each source
			vim_item.menu = ({
				buffer = "[Buffer]",
				nvim_lsp = "[LSP]",
				luasnip = "[LuaSnip]",
				nvim_lua = "[Lua]",
				latex_symbols = "[Latex]",
			})[entry.source.name]
			return vim_item
		end,
	},

	mapping = {
		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				--cmp.complete()
				cmp.select_next_item()
				--vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-n>', true, true, true), 'n')
			elseif check_back_space() then
				vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, true, true), 'n')
			elseif vim.fn['vsnip#available']() == 1 then
				vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>(vsnip-expand-or-jump)', true, true, true), '')
			else
				fallback()
			end
		end, {
		"i",
		"s",
		}),
		['<S-Tab>'] = function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif vim.fn['vsnip#available']() == 1 then
				vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>(vsnip-expand-or-jump)', true, true, true), '')
			else
				fallback()
			end
		end,
	},

	sources = {
		{ name = 'nvim_lua' },
		{ name = 'path' },
		{ name = 'buffer' },
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
	},
}

vim.opt.hidden = true
------------------set hidden

vim.opt.syntax = 'on'
------------------syntax on
vim.cmd [[
	colorscheme NeoSolarized
]]
vim.opt.background = 'dark'
--set background=dark
-- for when a terminal with true color support is used
vim.opt.termguicolors = true
--set termguicolors

-- swap file
vim.opt.backupdir = vim.fn.expand('~/.config/nvim/backup//')
vim.opt.directory = vim.fn.expand('~/.config/nvim/swap//')
vim.opt.undodir = vim.fn.expand('~/.config/nvim/undo//')
--set backupdir=~/.config/nvim/backup//
--set directory=~/.config/nvim/swap//
--set undodir=~/.config/nvim/undo//

-- tabs and spaces
-- number of visual spaces per TAB
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
--set tabstop=4
--set shiftwidth=4
--set noexpandtab

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.signcolumn = "yes"
--set nohlsearch
--set incsearch
--set signcolumn=yes

---- show > for tabs
--vim.opt.list = true
--set list

-- set numbers on
vim.opt.number = true
--set number

vim.cmd [[
	filetype plugin indent on
	autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
]]

-- i hate bells
vim.opt.visualbell = false
vim.opt.errorbells = false
--set novisualbell
--set noerrorbells

vim.opt.encoding = "utf-8"
--set encoding=utf-8

-- differences from vim to nvim
--set noautoindent
vim.opt.mouse = ""
vim.opt.smarttab = false
vim.opt.laststatus = 2
--set mouse=""
--set nosmarttab
--set laststatus=1
-- bottom line numbers in the corner
vim.opt.ruler = true
--set ruler
