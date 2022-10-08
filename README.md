# repos.nvim

repos.nvim is a simple Neovim plugin for per-repository settings.

## Installation

[vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'TymekDev/repos.nvim'
```

[packer](https://github.com/wbthomason/packer.nvim)

```lua
use "TymekDev/repos.nvim"
```

## Usage
I suggest configuring repos.nvim in `after/plugin` directory.
This way the callbacks can override settings declarations executed earlier.
```lua
require("repos").setup({
  remote = "origin", -- Remote used for matching callbacks against it
  callbacks = {},    -- Callbacks with keys to match against remote URL
})
```

Note: multiple `callbacks` can be executed for a single repository.

### Example
```lua
require("repos").setup({
  callbacks = {
    -- Runs on a single repository due to the specific key
    ["git@github.com:TymekDev/repos.nvim"] = function(root)
      print("Repository is located at: " .. root)
    end,
    -- Possibly runs on multiple repositories on different platforms (e.g. GitHub and GitLab)
    ["TymekDev/dotfiles"] = function(_)
      vim.opt.winwidth = 20
    end,
    -- Runs on any SSH repository
    ["git@"] = function(_)
      -- ...
    end,
  },
})
```
