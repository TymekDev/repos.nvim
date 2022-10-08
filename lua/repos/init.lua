local M = {}

local defaults = {
  remote = "origin",
  callbacks = {},
}

M.setup = function(config)
  config = vim.tbl_deep_extend("keep", config or {}, defaults)
  if vim.tbl_count(config.callbacks) == 0 then
    return
  end

  local root = vim.fn.system({ "git", "rev-parse", "--show-toplevel" })
  if root:find("fatal: not a git repository") ~= nil then
    return
  end

  vim.fn.jobstart({ "git", "remote", "get-url", config.remote }, {
    on_stdout = function(_, data)
      if data[1] == "" then
        return
      end
      for key, callback in pairs(config.callbacks) do
        if data[1]:find(key) ~= nil then
          callback(root:gsub("\n$", ""))
        end
      end
    end,
    stdout_buffered = true,
  })
end

return M
