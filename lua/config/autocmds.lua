-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Git autosync for org notes
local org_sync_group = vim.api.nvim_create_augroup("OrgGitSync", { clear = true })

local org_dir = vim.fn.expand("~/org")

local function in_org_dir(path)
  local full = vim.fn.fnamemodify(path, ":p")
  -- normalize trailing slash for a clean prefix match
  return full:sub(1, #org_dir + 1) == (org_dir .. "/")
end

vim.api.nvim_create_autocmd("BufWritePost", {
  group = org_sync_group,
  pattern = "*.org",
  callback = function(args)
    if not in_org_dir(args.file) then
      return
    end

    local dir = vim.fn.fnamemodify(args.file, ":h")
    local file = vim.fn.fnamemodify(args.file, ":t")

    vim.system({ "git", "-C", dir, "add", file }, {}, function(add_res)
      if add_res.code ~= 0 then
        return
      end
      vim.system({ "git", "-C", dir, "commit", "-m", "autosync: " .. file }, {}, function(commit_res)
        if commit_res.code ~= 0 then
          return
        end -- nothing to commit is fine
        vim.system({ "git", "-C", dir, "push" }, {}, function(push_res)
          if push_res.code ~= 0 then
            vim.schedule(function()
              vim.notify("git push failed: " .. (push_res.stderr or ""), vim.log.levels.WARN)
            end)
          end
        end)
      end)
    end)
  end,
})

vim.api.nvim_create_autocmd("BufReadPre", {
  group = org_sync_group,
  pattern = "*.org",
  callback = function(args)
    if not in_org_dir(args.file) then
      return
    end

    local dir = vim.fn.fnamemodify(args.file, ":h")
    vim.system({ "git", "-C", dir, "pull", "--rebase" }, {}, function(res)
      if res.code ~= 0 then
        vim.schedule(function()
          vim.notify("git pull failed: " .. (res.stderr or ""), vim.log.levels.WARN)
        end)
      end
    end)
  end,
})
