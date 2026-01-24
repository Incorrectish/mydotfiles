-- LSP and Mason configuration

local on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then desc = 'LSP: ' .. desc end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  local builtin = require('telescope.builtin')

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  nmap('gd', builtin.lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', builtin.lsp_references, '[G]oto [R]eferences')
  nmap('gI', builtin.lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', builtin.lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', builtin.lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', builtin.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('J', vim.lsp.buf.signature_help, 'Signature Documentation')
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- Mason setup (order matters)
require('mason').setup()
require('mason-lspconfig').setup()

-- Server configurations
local servers = {
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Setup servers via mason-lspconfig
require('mason-lspconfig').setup {
  ensure_installed = vim.tbl_keys(servers),
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = servers[server_name],
        filetypes = (servers[server_name] or {}).filetypes,
      }
    end,
  },
}

-- Enable inlay hints
vim.lsp.inlay_hint.enable()
