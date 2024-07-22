local lsp_zero = require('lsp-zero')
local cmp = require('cmp')

cmp.setup({
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		['<C-Space>'] = cmp.mapping.complete(),
	})
})

lsp_zero.on_attach(function(client, bufnr)
	-- see :help lsp-zero-keybindings
	-- to learn the available actions
	lsp_zero.default_keymaps({ buffer = bufnr })
end)

require('mason').setup({})
  require('mason-lspconfig').setup({
    -- Replace the language servers listed here 
    -- with the ones you want to install
    ensure_installed = {
	    'eslint',
	    'lua_ls',
	    'intelephense',
	    --'phpactor',
	    'html',
	    'cssls',
	    'tailwindcss',
	    'pylsp',
    },
    handlers = {
      lsp_zero.default_setup,
    },
  })

lsp_zero.setup()
