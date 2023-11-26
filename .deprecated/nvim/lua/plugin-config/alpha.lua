local alpha = require "alpha"
local dashboard = require 'alpha.themes.dashboard'

dashboard.section.header.val = {
  [[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗]],
  [[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║]],
  [[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║]],
  [[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
  [[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║]],
  [[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
  [[                                                   ]],
  [[                                                   ]],
}
dashboard.section.buttons.val = {
  dashboard.button("p", "Projects", ":Telescope projects<CR>"),
  dashboard.button("h", "History files", ":Telescope oldfiles<CR>"),
  dashboard.button("e", "Edit Projects ", ":edit ~/.local/share/nvim/project_nvim/project_history<CR>"),
}

dashboard.section.footer.val = "NixOS-Neovim"

alpha.setup(dashboard.config)
