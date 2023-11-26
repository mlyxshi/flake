--:help option_list 
--:help vim_diff.txt
local options = {
  number = true,

  splitbelow = true,
  splitright = true,

  --System Clipboard
  clipboard = vim.opt.clipboard + 'unnamedplus',

  writebackup = false,
  swapfile = false,

  -- RTFM :help tabstop
  -- Why default is 8? http://web.mit.edu/ghudson/info/linus-coding-standard
  -- Modern Indent is 2? https://google.github.io/styleguide/cppguide.html#Spaces_vs._Tabs
  tabstop = 2,
  shiftwidth = 2,
  expandtab = true,

  --Use TreeSitter Indent

  --Smart search
  ignorecase = true,
  smartcase = true,

  -- Global Statusline
  laststatus = 3,

  cmdheight = 0,

  termguicolors = true,
}


for k, v in pairs(options) do
  vim.opt[k] = v
end
