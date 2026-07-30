return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        list = {
          selection = {
            preselect = false,
            auto_insert = false,
          },
        },
        menu = {
          auto_show = true,
        },
      },
      -- Merged on top of LazyVim's `preset = "enter"`, so anything not listed
      -- here (<C-space>, <C-e>, <C-n>/<C-p>, <C-y>, arrows) keeps its default.
      keymap = {
        -- Cycle the menu with Tab/S-Tab. Commands are tried in order and the
        -- first one that applies wins, so when the menu is closed these still
        -- jump between snippet placeholders, and outside a snippet "fallback"
        -- gives a literal tab / indent.
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        -- select_and_accept (not plain accept) so this still works when nothing
        -- is explicitly selected -- preselect is off, so the list often has no
        -- active item until Tab is pressed.
        ["<C-CR>"] = { "select_and_accept", "fallback" },
        ["<CR>"] = { "fallback" },
        ["<S-Space>"] = { "show", "show_documentation", "hide_documentation" },
      },
    },
  },
}
