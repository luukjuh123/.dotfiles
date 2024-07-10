-- ~/.config/nvim/lua/plugins/init.lua

return {
  -- Example of other plugins...
  {
      "neovim/nvim-lspconfig",
      config = function()
          local lspconfig = require('lspconfig')
          -- Pyright setup
          lspconfig.pyright.setup{}
          -- Add other LSP servers here if needed
      end
  },
  -- Add other plugins as needed
}
