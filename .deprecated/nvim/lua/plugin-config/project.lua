-- nvim-tree 支持
vim.g.nvim_tree_respect_buf_cwd = 1

(require "project_nvim").setup({
  detection_methods = { "pattern" },
  patterns = { ".git", "Makefile", "package.json", "Cargo.toml", "README", "README.md" },
})