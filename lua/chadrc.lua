-- This file needs to have the same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@class ChadrcConfig
local M = {}

M.base46 = {
  theme = "onedark",
  -- Optional highlight overrides:
  -- hl_override = {
  --   Comment = { italic = true },
  --   ["@comment"] = { italic = true },
  -- },
}

-- (Other NVChad options such as nvdash, ui etc. can be here)

------------------------------------
-- Options, UI, Plugins, Mappings --
------------------------------------
-- If you already have an options.lua, load it
-- Otherwise, define options directly here.

-- We'll configure our LSP servers next.

-------------------------
-- Custom LSP Config   --
-------------------------
local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
if lspconfig_ok then
  -- Example: existing tsserver configuration
  lspconfig.tsserver.setup {
    filetypes = {
      "javascript", "javascriptreact", "javascript.jsx",
      "typescript", "typescriptreact", "typescript.tsx",
    },
    on_attach = function(client, bufnr)
      if client.name == "tsserver" then
        client.server_capabilities.documentFormattingProvider = true -- Enable formatting
      end
      
      -- Format on save
      if client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          callback = function() vim.lsp.buf.format({ async = false }) end,
        })
      end

      local opts = { noremap = true, silent = true }
      vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    end,
  }

  -- Emmet LSP configuration as before
  lspconfig.emmet_ls.setup {
    filetypes = {
      "html", "css",
      "javascript", "javascriptreact",
      "typescript", "typescriptreact",
      "jsx", "tsx",
    },
    init_options = {
      html = {
        options = {
          ["bem.enabled"] = true,
        },
      },
    },
  }

  -- Add Tailwind CSS language server for Tailwind autocompletion
  lspconfig.tailwindcss.setup {
    filetypes = {
      "html", "css",
      "javascript", "javascriptreact",
      "typescript", "typescriptreact",
      "jsx", "tsx",
      "svelte", "vue", "astro" -- add others if needed
    },
    settings = {
      tailwindCSS = {
        experimental = { classRegex = {
          "tw`([^`]*)", 
          'tw\\("([^")]*)"',
          "tw\\([^)]*\\)",
          "tw={\"([^\"}]*)",
          "tw={`([^`}]*)"
        } },
        classAttributes = { "class", "className", "classList", "ngClass" },
      },
    },
    on_attach = function(client, bufnr)
      -- (Optional) you can add specific key mappings or settings for Tailwind
      local opts = { noremap = true, silent = true }
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ct", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    end,
  }
else
  print("LSPConfig not found!")
end

-------------------------
-- NVChad Plugin Config--
-------------------------
M.plugins = {
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
    ft = { "html", "javascriptreact", "typescriptreact", "jsx", "tsx" },
  },
}

-------------------------
-- End of Config       --
-------------------------
return M

