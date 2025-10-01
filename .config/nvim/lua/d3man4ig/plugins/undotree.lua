-- some random settings
vim.g.undotree_SetFocusWhenToggle = true

-- keep undotree history for ever
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv 'HOME' .. '/.undodir'
vim.opt.undofile = true

return {
  'mbbill/undotree',
  vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle),
}
