local nvim_tree = require "nvim-tree"

local list_keys = require('keybindings').nvimTreeList
nvim_tree.setup({
  git = {
    enable = false,
  },
  -- project plugin 需要这样设置
  update_cwd = true,
  update_focused_file = {
    enable = true,
    update_cwd = true,
  },
  -- 隐藏 .文件 和 node_modules 文件夹
  filters = {
    --dotfiles = true,
    custom = { 'node_modules' },
  },
  view = {
    -- 宽度
    width = 30,
    side = 'left',
    hide_root_folder = false,
    -- 自定义列表中快捷键
    mappings = {
      custom_only = false,
      list = list_keys,
    },
    -- 不显示行数
    number = false,
    relativenumber = false,
    -- 显示图标
    signcolumn = 'yes',
  },
  actions = {
    open_file = {
      -- 首次打开大小适配
      resize_window = true,
      -- 打开文件时关闭
      quit_on_open = true,
    },
  },

  system_open = {
    cmd = 'open',
  },
})
