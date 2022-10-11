local M = {}

local defaults = {
  remote = "origin", -- Remote used for matching callbacks against it
  plain = true,      -- Perform plain text matching (true) or regex matching (false)
  callbacks = {},    -- Callbacks with keys to match against remote URL
}

local function is_invalid_git_worktree(root)
  if root:find("fatal: not a git repository") ~= nil then
    return true
  elseif root:find("fatal: this operation must be run in a work tree") ~= nil then
    return true
  end

  return false
end

M.setup = function(config)
  config = vim.tbl_deep_extend("keep", config or {}, defaults)
  if vim.tbl_count(config.callbacks) == 0 then
    return
  end

  local root = vim.fn.system({ "git", "rev-parse", "--show-toplevel" })
  if is_invalid_git_worktree(root) then
    return
  end

  vim.fn.jobstart({ "git", "remote", "get-url", config.remote }, {
    on_stdout = function(_, data)
      if data[1] == "" then
        return
      end
      for key, callback in pairs(config.callbacks) do
        if data[1]:find(key, 1, config.plain) ~= nil then
          callback(root:gsub("\n$", ""))
        end
      end
    end,
    stdout_buffered = true,
  })
end

return M
