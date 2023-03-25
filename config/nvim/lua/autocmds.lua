local myAutoGroup = vim.api.nvim_create_augroup("myAutoGroup", { clear = true })

local keymap = require("utils").keymap
local cmd = require("utils").cmd
local autocmd = require("utils").autocmd

-- Format on Save
autocmd("BufWritePre", {
  callback = vim.lsp.buf.format,
  group = myAutoGroup,
  pattern = require("lang-config.treesitter.autoformat"),
})

-- This setting is based on my keyboard(Apple Magic Keyboard) layout
-- open help in right window
-- q to quit
-- <CR> to jump in
-- <HOME> <END> to jump previous / next
-- <PageUp> <PageDown> to move up and down
autocmd("BufEnter", {
  group = myAutoGroup,
  pattern = vim.fn.expand('$VIMRUNTIME') .. "/doc/*.txt",
  callback = function()
    cmd('wincmd L|vert resize 82')
    keymap('n', 'q', ":q<cr>", { silent = true, buffer = 0 })
    keymap("n", "<cr>", "<C-]>", { silent = true, buffer = 0 })
    keymap('n', '<HOME>', "<C-o>", { silent = true, buffer = 0 })
    keymap('n', '<END>', "<C-i>", { silent = true, buffer = 0 })
  end,
})

-- Enable Copy over SSH
-- vim.opt.clipboard = vim.opt.clipboard + 'unnamedplus',  <-- Enable Copy to Local System Clipboard Also
autocmd("TextYankPost", {
  group = myAutoGroup,
  pattern = "*",
  callback = function()
    cmd('OSCYankReg +')
  end,
})


-- 用o换行不要延续注释
autocmd("BufEnter", {
  group = myAutoGroup,
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions
        - "o" -- O and o, don't continue comments
        + "r" -- But do continue when pressing enter.
  end,
})


--Treesitter
-- autocmd("BufWritePost", {
--   group = myAutoGroup,
--   pattern = "*.lua",
--   callback = function()
--     if vim.fn.expand("<afile>") == "lua/lang-config/treesitter/parsers.lua" then
--       cmd("source lua/lang-config/treesitter/parsers.lua")
--       cmd("TSUpdate")
--     end
--   end,
-- })
