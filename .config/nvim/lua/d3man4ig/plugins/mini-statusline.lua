return {
  'echasnovski/mini.statusline',
  version = false,
  config = function()
    local custom_mode_names = {
      n = 'N',
      v = 'V',
      V = 'VL',
      [''] = 'VB', -- Visual block
      i = 'I',
      R = 'R',
      c = 'C',
      t = 'T',
      ['!'] = '!',
    }

    local function one_letter_mode()
      local mode = vim.fn.mode(1)
      -- Get mode name with a fallback
      local mode_name = custom_mode_names[mode] or mode

      -- Use a dynamic highlighting approach
      local mode_hl = 'MiniStatuslineModeNormal' -- Default to normal mode

      -- Dynamically set highlight based on mode
      if mode:find '^[vV]' then
        mode_hl = 'MiniStatuslineModeVisual'
      elseif mode:find '^[iI]' then
        mode_hl = 'MiniStatuslineModeInsert'
      elseif mode:find '^[rR]' then
        mode_hl = 'MiniStatuslineModeReplace'
      elseif mode:find '^[cC]' then
        mode_hl = 'MiniStatuslineModeCommand'
      end

      return mode_name, mode_hl
    end

    require('mini.statusline').setup {
      content = {
        active = function()
          local mode, mode_hl = one_letter_mode()
          local git = MiniStatusline.section_git { trunc_width = 75 }
          local diagnostics = MiniStatusline.section_diagnostics { trunc_width = 75 }
          local filename = MiniStatusline.section_filename { trunc_width = 140 }
          local location = MiniStatusline.section_location { trunc_width = 75 }

          return MiniStatusline.combine_groups {
            { hl = mode_hl, strings = { mode } },
            { hl = 'MiniStatuslineDevinfo', strings = { git } },
            { hl = 'MiniStatuslineFilename', strings = { filename } },
            '%<', -- Mark general truncate point
            { hl = 'MiniStatuslineFilename', strings = { diagnostics } },
            { hl = 'MiniStatuslineLocation', strings = { location } },
          }
        end,
        inactive = function()
          return nil
        end,
        -- inactive = function()
        --   local filename = MiniStatusline.section_filename { trunc_width = 140 }
        --   return MiniStatusline.combine_groups {
        --     { hl = 'MiniStatuslineFilename', strings = { filename } },
        --   }
        -- end,
      },
    }
  end,
}
