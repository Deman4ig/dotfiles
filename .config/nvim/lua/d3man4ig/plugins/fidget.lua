return {
  'j-hui/fidget.nvim',
  enabled = true,
  event = 'VeryLazy',
  opts = {
    notification = {
      override_vim_notify = true,
      window = {
        x_padding = 0,
        y_padding = 0,
        winblend = 100,
        normal_hl = 'Comment',
      },
    },
  },
}
