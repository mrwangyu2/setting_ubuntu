-- 初始化 packer
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'  -- Packer 管理器本身

  -- 安装 bufferline 插件
  use {
    'akinsho/bufferline.nvim',
    tag = "v3.*",  -- 使用最新的v3版本
    requires = 'nvim-tree/nvim-web-devicons', -- 图标支持
    config = function()
      require("bufferline").setup {
        options = {
          numbers = "both", -- 显示缓冲区编号
          close_command = "bdelete! %d", -- 关闭缓冲区命令
          right_mouse_command = "bdelete! %d", -- 右键关闭缓冲区命令
          left_mouse_command = "buffer %d", -- 左键切换缓冲区命令
          middle_mouse_command = nil, -- 中键命令
          indicator = {
            icon = '▎', -- 图标
            style = 'icon',
          },
          buffer_close_icon = '',
          modified_icon = '●',
          close_icon = '',
          left_trunc_marker = '',
          right_trunc_marker = '',
          max_name_length = 18,
          max_prefix_length = 15, -- 缓冲区名称前缀最大长度
          tab_size = 18,
          diagnostics = "nvim_lsp", -- 启用LSP诊断信息
          diagnostics_update_in_insert = false,
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              highlight = "Directory",
              text_align = "left",
            }
          },
          show_buffer_icons = true, -- 显示缓冲区图标
          show_buffer_close_icons = true, -- 显示缓冲区关闭图标
          show_close_icon = true, -- 显示关闭图标
          show_tab_indicators = true, -- 显示标签指示器
          persist_buffer_sort = true, -- 持续缓冲区排序
          separator_style = "thin", -- 分隔符样式
          enforce_regular_tabs = false,
          always_show_bufferline = true,
          sort_by = 'id', -- 排序方式
        }
      }
    end
  }

  -- 其他插件
end)

