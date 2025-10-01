local function modify_hl(highlight, opts)
  local ok, current = pcall(vim.api.nvim_get_hl, 0, { name = highlight })
  if not ok then
    vim.notify('Failed to get highlight ' .. highlight, vim.log.levels.ERROR)
    return
  end

  local new_hl = vim.tbl_extend('force', current, opts)

  pcall(vim.api.nvim_set_hl, 0, highlight, new_hl)
end

function Get_hl_hex(name, option)
  if type(name) ~= 'string' or (option ~= 'fg' and option ~= 'bg') then
    error "Invalid arguments. Usage: highlight(name: string, option: 'fg' | 'bg')"
  end
  local hl = vim.api.nvim_get_hl(0, { name = name })
  local color = hl[option]
  if not color then
    print('No ' .. option .. ' color found for highlight group: ' .. name)
    return nil
  end
  local hex_color = string.format('#%06x', color)
  return hex_color
end

vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
  group = vim.api.nvim_create_augroup('Color', {}),
  pattern = '*',
  callback = function()
    modify_hl('CursorLine', { link = 'None' })
    modify_hl('WinSeparator', { link = 'FloatBorder' })
    modify_hl('DiagnosticUnnecessary', { underline = true })

    modify_hl('FlashLabel', { bg = Get_hl_hex('PreProc', 'fg'), fg = Get_hl_hex('FloatBorder', 'bg') })
    modify_hl('FlashBackdrop', { link = 'SignColumn' })

    modify_hl('NeoTreeCursorLine', { link = 'CursorColumn' })
    modify_hl('NeoTreeDirectoryIcon', { link = 'Function' })
    modify_hl('NeoTreeDirectoryName', { link = 'Function' })

    modify_hl('NeoTreeGitUnstaged', { link = 'Changed' })
    modify_hl('NeoTreeGitModified', { link = 'Changed' })

    modify_hl('NeoTreeGitUntracked', { link = 'Added' })
    modify_hl('NeoTreeGitRenamed', { link = 'Added' })
    modify_hl('NeoTreeGitConflict', { link = 'Removed' })
  end,
})

-- local lint_progress = function()
--   local linters = require('lint').get_running()
--   if #linters == 0 then
--     return ''
--   end
--   return ' ' .. table.concat(linters, ', ')
-- end

return {
  'nvim-lualine/lualine.nvim',
  config = function()
    local colors = {
      white = Get_hl_hex('PreProc', 'fg'),
      red = Get_hl_hex('Constant', 'fg'),
      green = Get_hl_hex('Character', 'fg'),
      blue = Get_hl_hex('@property', 'fg'),
      yellow = Get_hl_hex('Function', 'fg'),
      grey = Get_hl_hex('Comment', 'fg'),
      dark = Get_hl_hex('StatusLineNc', 'bg'),
    }

    require('lualine').setup {
      options = {
        theme = {
          normal = {
            a = { bg = colors.dark, fg = colors.white, gui = 'bold' },
            b = { bg = colors.dark, fg = colors.white },
            c = { bg = colors.dark, fg = colors.white },
          },
          insert = {
            a = { bg = colors.dark, fg = colors.blue, gui = 'bold' },
            b = { bg = colors.dark, fg = colors.blue },
            c = { bg = colors.dark, fg = colors.blue },
          },
          visual = {
            a = { bg = colors.dark, fg = colors.red, gui = 'bold' },
            b = { bg = colors.dark, fg = colors.red },
            c = { bg = colors.dark, fg = colors.red },
          },
          replace = {
            a = { bg = colors.dark, fg = colors.green, gui = 'bold' },
            b = { bg = colors.dark, fg = colors.green },
            c = { bg = colors.dark, fg = colors.green },
          },
          command = {
            a = { bg = colors.dark, fg = colors.yellow, gui = 'bold' },
            b = { bg = colors.dark, fg = colors.yellow },
            c = { bg = colors.dark, fg = colors.yellow },
          },
          inactive = {
            a = { bg = colors.dark, fg = colors.gray, gui = 'bold' },
            b = { bg = colors.dark, fg = colors.gray },
            c = { bg = colors.dark, fg = colors.gray },
          },
        },
        icons_enabled = true,
        globalstatus = true,
        disabled_filetypes = {
          'alpha',
        },

        component_separators = { left = '─', right = '─' },
        section_separators = { left = '─', right = '─' },
      },
      sections = {
        lualine_a = {
          {
            symbols = { modified = ' ', readonly = ' ', unnamed = 'No name', newfile = 'New file' },
            'filename',
          },
        },
        lualine_b = {
          { 'branch', icon = { '', align = 'left' } },
        },
        lualine_c = {
          { 'diff', symbols = { added = '+', modified = '~', removed = '-' } },
        },
        lualine_x = {
          'location',
        },
        lualine_y = {
          'progress',
        },
        lualine_z = {
          { 'filetype', colored = false, icon = { align = 'right' } },
        },
      },
      extensions = {
        'nvim-tree',
        'mason',
        'lazy',
        'fzf',
      },
    }
  end,
}
