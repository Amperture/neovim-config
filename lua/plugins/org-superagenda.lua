return {
  "hamidi-dev/org-super-agenda.nvim",
  dependencies = {
    "nvim-orgmode/orgmode", -- required
    { "lukas-reineke/headlines.nvim", config = true }, -- optional nicety
  },
  config = function()
    require("org-super-agenda").setup({
      -- Where to look for .org files
      org_files = { "/home/amp/org/refile.org" },
      org_directories = { "/home/amp/org/" }, -- recurse for *.org
      exclude_files = {},
      exclude_directories = {},

      -- TODO states + their quick filter keymaps and highlighting
      -- Optional: add `shortcut` field to override the default key (first letter)
      todo_states = {
        {
          name = "TODO",
          keymap = "ot",
          color = "#FF5555",
          strike_through = false,
          fields = { "filename", "todo", "headline", "priority", "date", "tags" },
        },
        {
          name = "PROGRESS",
          keymap = "op",
          color = "#FFAA00",
          strike_through = false,
          fields = { "filename", "todo", "headline", "priority", "date", "tags" },
        },
        {
          name = "WAITING",
          keymap = "ow",
          color = "#BD93F9",
          strike_through = false,
          fields = { "filename", "todo", "headline", "priority", "date", "tags" },
        },
        {
          name = "DONE",
          keymap = "od",
          color = "#50FA7B",
          strike_through = true,
          fields = { "filename", "todo", "headline", "priority", "date", "tags" },
        },
      },

      -- Agenda keymaps (inline comments explain each)
      keymaps = {
        filter_reset = "oa", -- reset all filters
        toggle_other = "oo", -- toggle catch-all "Other" section
        filter = "of", -- live filter (exact text)
        filter_fuzzy = "oz", -- live filter (fuzzy)
        filter_query = "oq", -- advanced query input
        undo = "u", -- undo last change
        reschedule = "cs", -- set/change SCHEDULED
        set_deadline = "cd", -- set/change DEADLINE
        cycle_todo = "t", -- cycle TODO state
        set_state = "s", -- set state directly (st, sd, etc.) or show menu
        reload = "r", -- refresh agenda
        refile = "R", -- refile via Telescope/org-telescope
        hide_item = "x", -- hide current item
        preview = "K", -- preview headline content
        clock_in = "I", -- clock in on current headline
        clock_out = "O", -- clock out active clock
        clock_cancel = "X", -- cancel active clock
        clock_goto = "gI", -- jump to active/recent clocked task
        reset_hidden = "gX", -- clear hidden list
        fold_all = "zM", -- collapse all groups
        unfold_all = "zR", -- expand all groups
        toggle_duplicates = "D", -- duplicate items may appear in multiple groups
        cycle_view = "ov", -- switch view (classic/compact)
        bulk_mark = "m", -- toggle mark on current item (● indicator)
        bulk_unmark_all = "M", -- clear all marks
        bulk_reselect = "gv", -- reselect last marks
        bulk_action = "B", -- run action on all marked items
        open_view = "V", -- open custom view picker
      },

      -- Window/appearance
      window = {
        width = 0.8,
        height = 0.7,
        border = "rounded",
        title = "Org Super Agenda",
        title_pos = "center",
        margin_left = 0,
        margin_right = 0,
        fullscreen_border = "none", -- border style when using fullscreen
      },

      -- Group definitions (order matters; first match wins unless allow_duplicates=true)
      groups = {
        {
          name = "📅 Today",
          matcher = function(i)
            return i.scheduled and i.scheduled:is_today()
          end,
          sort = { by = "scheduled_time", order = "asc" },
        },
        {
          name = "🗓️ Tomorrow",
          matcher = function(i)
            return i.scheduled and i.scheduled:days_from_today() == 1
          end,
          sort = { by = "scheduled_time", order = "asc" },
        },
        {
          name = "☠️ Deadlines",
          matcher = function(i)
            return i.deadline and i.todo_state ~= "DONE" and not i:has_tag("personal")
          end,
          sort = { by = "deadline", order = "asc" },
        },
        {
          name = "⭐ Important",
          matcher = function(i)
            return i.priority == "A" and (i.deadline or i.scheduled)
          end,
          sort = { by = "date_nearest", order = "asc" },
        },
        {
          name = "⏳ Overdue",
          matcher = function(i)
            return i.todo_state ~= "DONE"
              and ((i.deadline and i.deadline:is_past()) or (i.scheduled and i.scheduled:is_past()))
          end,
          sort = { by = "date_nearest", order = "asc" },
        },
        {
          name = "🏠 Personal",
          matcher = function(i)
            return i:has_tag("personal")
          end,
        },
        {
          name = "💼 Work",
          matcher = function(i)
            return i:has_tag("work")
          end,
        },
        {
          name = "📆 Upcoming",
          matcher = function(i)
            local days = require("org-super-agenda.config").get().upcoming_days or 10
            local d1 = i.deadline and i.deadline:days_from_today()
            local d2 = i.scheduled and i.scheduled:days_from_today()
            return (d1 and d1 >= 0 and d1 <= days) or (d2 and d2 >= 0 and d2 <= days)
          end,
          sort = { by = "date_nearest", order = "asc" },
        },
      },

      -- Defaults & behavior
      upcoming_days = 10,
      hide_empty_groups = false, -- drop blank sections
      keep_order = false, -- keep original org order (rarely useful)
      allow_duplicates = false, -- if true, an item can live in multiple groups
      group_format = "* %s", -- group header format
      other_group_name = "Other",
      show_other_group = true, -- show catch-all section
      show_tags = true, -- draw tags on the right
      show_filename = true, -- include [filename]
      heading_max_length = 70,
      persist_hidden = false, -- keep hidden items across reopen
      view_mode = "classic", -- 'classic' | 'compact'

      classic = {
        heading_order = { "filename", "todo", "priority", "headline" },
        short_date_labels = false,
        inline_dates = true,
      },
      compact = { filename_min_width = 10, label_min_width = 12 },

      -- Global fallback sort for groups that omit `sort`
      group_sort = { by = "date_nearest", order = "asc" },

      -- Popup mode: auto-detected when launched via the tmux script (ORG_SUPER_AGENDA_POPUP=1).
      -- Override only if you use a different popup mechanism.
      popup_mode = {
        enabled = vim.env.ORG_SUPER_AGENDA_POPUP == "0",
        hide_command = "tmux detach-client",
      },

      debug = true,

      -- Custom views: reusable named views with pre-configured filters
      custom_views = {
        -- work_week = {
        --   name = "Work This Week",
        --   keymap = "<leader>ow",
        --   filter = "tag:work sched>=0 sched<7 -is:done",
        -- },
      },
    })
  end,
}
