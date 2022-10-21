local M = {}

local config = {}
local defaults = {
  remote = "origin", -- Remote used for matching callbacks against it
  plain = true,      -- Perform plain text matching (true) or regex matching (false)
  callbacks = {},    -- Callbacks with keys to match against remote URL
}

local function is_valid_worktree(path)
  if path:find("fatal: not a git repository") ~= nil then
    return false
  elseif path:find("fatal: this operation must be run in a work tree") ~= nil then
    return false
  end

  return true
end

function M.run()
  local msg = ""
  if vim.tbl_count(config) == 0 or config.callbacks == nil then
    msg = "repos.nvim is not configured. Run setup() function first."
  elseif vim.tbl_count(config.callbacks) == 0 then
    msg = "repos.nvim does not have any callback registered. Use setup() function to define them."
  end
  if msg ~= "" then
    vim.notify(msg, vim.log.levels.ERROR)
    return
  end

  local root = vim.fn.system({ "git", "rev-parse", "--show-toplevel" })
  if not is_valid_worktree(root) then
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

function M.setup(_config)
  config = vim.tbl_deep_extend("keep", _config or {}, defaults)
  M.run()
end

return M
