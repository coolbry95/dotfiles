local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- needs to be before lazy.setup
vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require("lazy").setup({
	{
		'nvim-telescope/telescope.nvim',
		tag = '0.1.6',
		dependencies = {
			'nvim-lua/popup.nvim',
			'nvim-lua/plenary.nvim',
			'nvim-telescope/telescope-fzy-native.nvim',
		}
	},

	{
		"L3MON4D3/LuaSnip",
		-- follow latest release.
		version = "v2.*",
	},

	{
		'hrsh7th/nvim-cmp',
		dependencies = {
			-- Install snippet engine (This example installs [hrsh7th/vim-vsnip](https://github.com/hrsh7th/vim-vsnip))
			'hrsh7th/vim-vsnip',
			-- Install the buffer completion source
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-nvim-lua',
			'ray-x/cmp-treesitter',
		}
	},

	{
		'nvim-telescope/telescope.nvim',
		dependencies = {
			'nvim-lua/popup.nvim',
			'nvim-lua/plenary.nvim',
			'nvim-telescope/telescope-fzy-native.nvim',
		}
	},

	{
		"folke/which-key.nvim",
		config = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
			require("which-key").setup {
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			}
		end
	},

	'neovim/nvim-lspconfig',

	{ 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },

	'overcache/NeoSolarized',
	'ishan9299/nvim-solarized-lua',
	--'Tsuzat/NeoSolarized.nvim', -- TODO: Try this one out
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

vim.lsp.enable({
	'gopls',
	'pylsp',
	'rust_analyzer',
})

vim.lsp.config('rust-analyzer', {
	capabilities = capabilities,
})

vim.lsp.config('pylsp', {
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
	settings = {
		pylsp = {
			plugins = {
				ruff = {
					enabled = true,
					extendSelect = { "I" },
					format = { "I" },
					--extendIgnore = {"E501"},
				},
				pylsp_mypy = { enabled = false },
			},
		},
	},
	single_file_support = true,
	capabilities = capabilities,
})

vim.lsp.config('gopls', {
	settings = {
		gopls = {
			gofumpt = true,
			usePlaceholders = true,
			staticcheck = true,
		},
	},
	capabilities = capabilities,
})

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

	--vim.lsp.buf.formatting_sync(nil, timeoutms)
	vim.lsp.buf.format({ async = false })
end

require 'nvim-treesitter.configs'.setup {
	ensure_installed = "all",
	highlight = {
		enable = true, -- false will disable the whole extension
	},
}

--"autocmd BufWritePre *.go lua goimports(100000)
--vim.cmd [[ autocmd BufWritePre *.go lua vim.lsp.buf.formatting_sync(nil, 1000) ]]
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.go",
	callback = function(args)
		--vim.lsp.buf.formatting_sync(nil, 1000)
		vim.lsp.buf.format({ async = false })
	end,
	desc = "auto format go files",
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
	  -- TODO: this is broken because it expects params
	  -- https://github.com/golang/tools/blob/master/gopls/doc/vim.md#imports-and-formatting
    local params = vim.lsp.util.make_range_params()
    params.context = {only = {"source.organizeImports"}}
    -- buf_request_sync defaults to a 1000ms timeout. Depending on your
    -- machine and codebase, you may want longer. Add an additional
    -- argument after params if you find that you have to write the file
    -- twice for changes to be saved.
    -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
    vim.lsp.buf.format({async = false})
  end
})

--vim.api.nvim_create_autocmd("BufWritePre", {
--  pattern = "*.go",
--  callback = function()
--    local params = vim.lsp.util.make_range_params()
--    params.context = {only = {"source.organizeImports"}}
--    -- buf_request_sync defaults to a 1000ms timeout. Depending on your
--    -- machine and codebase, you may want longer. Add an additional
--    -- argument after params if you find that you have to write the file
--    -- twice for changes to be saved.
--    -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
--    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
--    for cid, res in pairs(result or {}) do
--      for _, r in pairs(res.result or {}) do
--        if r.edit then
--          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
--          vim.lsp.util.apply_workspace_edit(r.edit, enc)
--        end
--      end
--    end
--    vim.lsp.buf.format({async = false})
--  end
--})

function key_map(mode, key_map)
	for key, value in pairs(key_map) do
		vim.api.nvim_set_keymap(mode, key, '', {
			callback = value,
			noremap = true,
			silent = true,
		})
	end
end

lsp_n_key_map = {
	['<leader>K'] = vim.lsp.buf.code_action,
	['<leader>fo'] = function()
		vim.lsp.buf.format { async = true }
	end,
	['<leader>rn'] = vim.lsp.buf.rename,
	['gd'] = vim.lsp.buf.definition,
	['gD'] = vim.lsp.buf.declaration,
	['gi'] = vim.lsp.buf.implementation,
	['K'] = vim.lsp.buf.hover,
	['<C-]'] = vim.lsp.buf.implementation,
	['<C-k'] = vim.lsp.buf.signature_help,
	['<space>D'] = vim.lsp.buf.type_definition,
	['gr'] = vim.lsp.buf.references,
	['g0'] = vim.lsp.buf.document_symbol,
	['gW'] = vim.lsp.buf.workspace_symbol,
	['<leader>e'] = vim.diagnostic.open_float,
	['[d'] = vim.lsp.buf.goto_prev,
	[']d'] = vim.lsp.buf.goto_next,
	['<leader>q'] = vim.diagnostic.setloclist,
}

lsp_v_key_map = {
	--['<leader>K'] = vim.lsp.buf.code_action(vim.lsp.util.make_range_params()),
	['<leader>K'] = vim.lsp.buf.code_action,
}

key_map('n', lsp_n_key_map)
key_map('v', lsp_v_key_map)

-- this way versus key_map?
vim.keymap.set("x", "<leader>p", "\"_dP")
-- copy into system clipboard
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

require('telescope').setup {
	defaults = {
		file_sorter = require('telescope.sorters').get_fzy_sorter,

		mappings = {
			i = {
				["<C-x>"] = false,
				["<C-q>"] = require('telescope.actions').send_to_qflist + require('telescope.actions').open_qflist,
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

telescope_n_key_map = {
	['ff'] = require('telescope.builtin').find_files,
	['fg'] = require('telescope.builtin').live_grep,
	['fb'] = require('telescope.builtin').buffers,
	['fh'] = require('telescope.builtin').help_tags,
}

key_map('n', telescope_n_key_map)


local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local luasnip = require 'luasnip'
local cmp = require 'cmp'

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
		['<CR>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				if luasnip.expandable() then
					luasnip.expand()
				else
					cmp.confirm({
						select = true,
					})
				end
			else
				fallback()
			end
		end),

		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				--cmp.complete()
				cmp.select_next_item()
				--vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-n>', true, true, true), 'n')
				--elseif vim.fn['vsnip#available']() == 1 then
				--vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>(vsnip-expand-or-jump)', true, true, true), '')
			elseif luasnip.locally_jumpable(1) then
				luasnip.jump(1)
			elseif has_words_before() then
				vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, true, true), 'n')
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
			elseif luasnip.locally_jumpable(-1) then
				luasnip.jump(-1)
				--elseif vim.fn['vsnip#available']() == 1 then
				--	vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>(vsnip-expand-or-jump)', true, true, true), '')
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

--vim.cmd('colorscheme NeoSolarized')
vim.cmd('colorscheme solarized')
vim.opt.background = 'dark'
--set background=dark
-- for when a terminal with true color support is used
vim.opt.termguicolors = true
--set termguicolors

vim.opt.undofile = true
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

vim.api.nvim_create_autocmd('FileType', {
	pattern = { '*.yaml', '*.yml' },
	--command = 'setlocal ts=2 sts=2 sw=2 expandtab',
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.expandtab = true
	end,
})
--vim.cmd [[
--	filetype plugin indent on -- this is default in neovim
--	autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
--]]

-- default plus linematch:60
vim.opt.diffopt = "internal,filler,closeoff,linematch:60"

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
