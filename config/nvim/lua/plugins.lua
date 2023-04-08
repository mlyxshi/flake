return {
  --Dependency
  'kyazdani42/nvim-web-devicons',
  'nvim-lua/plenary.nvim',

  --Theme
  {
    "folke/tokyonight.nvim",
    config = function()
      vim.cmd([[colorscheme tokyonight]])
    end
  },

  --Treesitter
  "nvim-treesitter/nvim-treesitter",

  --UI
  'nvim-lualine/lualine.nvim',
  'kyazdani42/nvim-tree.lua',
  'akinsho/bufferline.nvim',
  'famiu/bufdelete.nvim',
  { 'j-hui/fidget.nvim', config = true },
  'lewis6991/gitsigns.nvim',
  'akinsho/toggleterm.nvim',
  {
    'folke/which-key.nvim',
    config = {
      plugins = {
        presets = {
          operators = false, -- disable help for operators like d, y, ... and registers them for motion / text object completion
        }
      }
    }
  },

  --Telescope/Dashboard
  'nvim-telescope/telescope.nvim',
  'nvim-telescope/telescope-ui-select.nvim',
  'goolord/alpha-nvim',
  'ahmedkhalf/project.nvim',

  --fzf
  'ibhagwan/fzf-lua',

  --LSP
  'neovim/nvim-lspconfig',
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  'onsails/lspkind-nvim',

  --Snip
  'L3MON4D3/LuaSnip',
  'saadparwaiz1/cmp_luasnip',

  --Language Enhancement
  'folke/neodev.nvim',

  --Code
  'windwp/nvim-autopairs',
  'lukas-reineke/indent-blankline.nvim',
  'mvllow/modes.nvim',
  { 'numToStr/Comment.nvim', config = true },

  --Enhancement
  'ojroques/nvim-osc52',
}
