local function add_missing_imports()
  if vim.fn.exists ':TSTools' then
    vim.notify 'Adding missing imports'
    vim.cmd 'TSToolsAddMissingImports'
    vim.notify 'Removing unused imports'
    vim.cmd 'TSToolsRemoveUnusedImports'
  else
    vim.notify 'TSTools are not loaded'
  end
end

local function run_eslint()
  vim.notify 'Running ESLint fix'
  vim.lsp.buf.format()
  vim.cmd 'write'
end

-- vim.keymap.set('n', '<leader>pv', vim.cmd.Ex, { desc = 'Open netrw' })
vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
vim.keymap.set('n', '<leader>pv', '<CMD>Oil --float<CR>', { desc = 'Open parent directory' })
vim.keymap.set('i', '<C-c>', '<Esc>')

-- gitsigns
vim.keymap.set('n', '<leader>clb', '<CMD>Gitsigns toggle_current_line_blame<CR>')
vim.keymap.set('n', '<leader>hp', '<CMD>Gitsigns prev_hunk<CR>')
vim.keymap.set('n', '<leader>hn', '<CMD>Gitsigns next_hunk<CR>')
vim.keymap.set('n', '<leader>hr', '<CMD>Gitsigns reset_hunk<CR>')

-- lsp keymaps
vim.keymap.set('n', '<leader>lef', run_eslint, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>mi', add_missing_imports)

vim.keymap.set('n', '<leader>lth', function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, {})

-- yank/paste to/from system clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]])
vim.keymap.set({ 'n', 'v' }, '<leader>p', [["+p]])
