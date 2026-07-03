return {
  -- add gruvbox
  {
    "ellisonleao/gruvbox.nvim",
    opts = {
      transparent_mode = "true",
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },

  -- add oldschool
  {
    "L-Colombo/oldschool.nvim",
    config = true,
    -- to override palette colors:
    opts = {
      black = "None",
    },
  },

  {
    "scottmckendry/cyberdream.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      require("cyberdream").setup({
        style = "deep",
        transparent = true,
        terminal_colors = false,
      })
      require("cyberdream").load()
    end,
    -- to override palette colors:
    -- opts = {
    --  <color> = "<hex value>",
    -- }
  },

  {
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
      require("onedark").setup({
        style = "deep",
        transparent = true,
        term_colors = true,
      })
      require("onedark").load()
    end,
    -- to override palette colors:
    -- opts = {
    --  <color> = "<hex value>",
    -- }
  },
  { "sainnhe/everforest" },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "oldschool",
    },
  },
}
