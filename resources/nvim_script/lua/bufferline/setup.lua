require('bufferline').setup {
  options = {
    mode = "buffers", -- 设定 buffer 显示模式
    numbers = "ordinal", -- 在 buffer 标签上显示数字
    diagnostics = "nvim_lsp", -- 显示 LSP 诊断信息
    separator_style = "slant", -- 设置分隔符样式为倾斜风格
    show_buffer_icons = false,   -- 开启文件类型图标显示
    show_buffer_close_icons = true, -- 是否显示关闭图标
    show_close_icon = false, -- 是否显示总的关闭图标
    enforce_regular_tabs = false, -- 禁用等宽标签
    always_show_bufferline = true, -- 一直显示 bufferline
    offsets = {
      {
        filetype = "NvimTree",
        text = "File Explorer",
        highlight = "Directory",
        text_align = "left",
      }
    },
    -- 自定义图标设置
    custom_areas = {
      right = function()
        local result = {}
        local error = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
        local warning = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
        if #error ~= 0 then
          table.insert(result, { text = "  " .. #error, guifg = "#EC5241" })
        end
        if #warning ~= 0 then
          table.insert(result, { text = "  " .. #warning, guifg = "#EFB839" })
        end
        return result
      end,
    },
    -- 自定义颜色配置
    highlights = {
      fill = {
        guifg = '#ffffff',
        guibg = '#2e3440',
      },
      background = {
        guifg = '#81a1c1',
        guibg = '#3b4252',
      },
      buffer_selected = {
        guifg = '#88c0d0',
        guibg = '#434c5e',
        gui = "bold",
      },
      -- 你还可以为其他部分自定义颜色
    },

  }
}

