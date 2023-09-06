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
	use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

	use 'overcache/NeoSolarized'
	use 'ishan9299/nvim-solarized-lua'


end)

vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local lspconfig = require 'lspconfig'

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

lspconfig.rust_analyzer.setup {
  capabilities = capabilities,
  settings = {},
 }

lspconfig.lua_ls.setup {
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = runtime_path,
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file('', true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

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
	settings = {
		pylsp = {
			plugins = {
				pylsp_mypy = { enabled = true },
				isort = { enabled = true },
				black = { enabled = true },
			},
		},
	},
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
	ensure_installed = "all",
	highlight = {
		enable = true,              -- false will disable the whole extension
	},
}

--"autocmd BufWritePre *.go lua goimports(100000)
--vim.cmd [[ autocmd BufWritePre *.go lua vim.lsp.buf.formatting_sync(nil, 1000) ]]
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.go",
    callback = function(args)
		vim.lsp.buf.formatting_sync(nil, 1000)
    end,
    desc = "auto format go files",
})

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
	['<leader>fo'] = vim.lsp.buf.format,
	['<leader>rn'] = vim.lsp.buf.rename,
	['gd'] = vim.lsp.buf.definition,
	['K'] = vim.lsp.buf.hover,
	['<C-]'] = vim.lsp.buf.implementation,
	['<C-k'] = vim.lsp.buf.signature_help,
	--['gD'] = vim.lsp.buf.type_definition,
	['gr'] = vim.lsp.buf.references,
	['g0'] = vim.lsp.buf.document_symbol,
	['gW'] = vim.lsp.buf.workspace_symbol,
	['gD'] = vim.lsp.buf.declaration, -- keymap used twice
	['<leader>e'] = vim.lsp.buf.show_line_diagnostics,
	['[d'] = vim.lsp.buf.goto_prev,
	[']d'] = vim.lsp.buf.goto_next,
	['<leader>q'] = vim.lsp.buf.set_loclist,
}

lsp_v_key_map = {
	['<leader>K'] = vim.lsp.buf.range_code_action,
}

key_map('n', lsp_n_key_map)
key_map('v', lsp_v_key_map)

-- this way versus key_map?
vim.keymap.set("x", "<leader>p", "\"_dP")
-- copy into system clipboard
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")


--vim.api.nvim_set_keymap('n', '<Space>K',  [[<Cmd>lua vim.lsp.buf.code_action()<CR>]], { noremap = true, silent = true })
--vim.api.nvim_set_keymap('v', '<Space>K',  [[<Cmd>lua vim.lsp.buf.range_code_action()<CR>]], { noremap = true, silent = true })
--vim.api.nvim_set_keymap('n', '<Space>f',  [[<Cmd>lua vim.lsp.buf.formatting()<CR>]], { noremap = true, silent = true })
--vim.api.nvim_set_keymap('n', '<Space>rn',  [[<Cmd>lua vim.lsp.buf.rename()<CR>]], { noremap = true, silent = true })
--vim.api.nvim_set_keymap('n', 'gd',  [[<Cmd>lua vim.lsp.buf.definition()<CR>]], { noremap = true, silent = true })
--vim.api.nvim_set_keymap('n', 'K',  [[<Cmd>lua vim.lsp.buf.hover()<CR>]], { noremap = true, silent = true })
--vim.api.nvim_set_keymap('n', '<C-]',  [[<Cmd>lua vim.lsp.buf.implementation()<CR>]], { noremap = true, silent = true })
--vim.api.nvim_set_keymap('n', '<C-k',  [[<Cmd>lua vim.lsp.buf.signature_help()<CR>]], { noremap = true, silent = true })
--vim.api.nvim_set_keymap('n', 'gD',  [[<Cmd>lua vim.lsp.buf.type_definition()<CR>]], { noremap = true, silent = true })
--vim.api.nvim_set_keymap('n', 'gr',  [[<Cmd>lua vim.lsp.buf.references()<CR>]], { noremap = true, silent = true })
--vim.api.nvim_set_keymap('n', 'g0',  [[<Cmd>lua vim.lsp.buf.document_symbol()<CR>]], { noremap = true, silent = true })
--vim.api.nvim_set_keymap('n', 'gW',  [[<Cmd>lua vim.lsp.buf.workspace_symbol()<CR>]], { noremap = true, silent = true })
----vim.api.nvim_set_keymap('n', 'gD',  [[<Cmd>lua vim.lsp.buf.declaration()<CR>]], { noremap = true, silent = true }) -- this is used twice
--vim.api.nvim_set_keymap('n', '<Space>e',  [[<Cmd>lua vim.lsp.buf.show_line_diagnostics()<CR>]], { noremap = true, silent = true })
--vim.api.nvim_set_keymap('n', '[d',  [[<Cmd>lua vim.lsp.buf.goto_prev()<CR>]], { noremap = true, silent = true })
--vim.api.nvim_set_keymap('n', ']d',  [[<Cmd>lua vim.lsp.buf.goto_next()<CR>]], { noremap = true, silent = true })
--vim.api.nvim_set_keymap('n', '<Space>q',  [[<Cmd>lua vim.lsp.buf.set_loclist()<CR>]], { noremap = true, silent = true })

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
--vim.api.nvim_set_keymap('n', 'ff',  [[<Cmd>lua require('telescope.builtin').find_files()<CR>]], { noremap = true, silent = false })
--vim.api.nvim_set_keymap('n', 'fg',  [[<Cmd>lua require('telescope.builtin').live_grep()<CR>]], { noremap = true, silent = false })
--vim.api.nvim_set_keymap('n', 'fb',  [[<Cmd>lua require('telescope.builtin').buffers()<CR>]], { noremap = true, silent = false })
--vim.api.nvim_set_keymap('n', 'fh',  [[<Cmd>lua require('telescope.builtin').help_tags()<CR>]], { noremap = true, silent = false })


local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local cmp = require'cmp'

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
			elseif has_words_before() then
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
