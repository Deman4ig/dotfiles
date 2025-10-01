vim.api.nvim_create_autocmd('LspAttach', {
  pattern = { '*.ts', '*.tsx', '*.js', '*.jsx' },
  callback = function()
    vim.keymap.set('n', '<leader>lai', function()
      vim.notify 'Adding missing imports...'
      vim.cmd 'TSToolsAddMissingImports'
    end, { desc = 'Add missing imports' })
  end,
})

return {
  'pmizio/typescript-tools.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
  opts = {},
  config = function()
    require('typescript-tools').setup {
      settings = {
        tsserver_file_preferences = {
          includeInlayParameterNameHints = 'all', -- 'none' | 'literals' | 'all'
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
    }
  end,
}
