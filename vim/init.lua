vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- neovim defaults this to `on`, but in order for rust autoindent settings to
-- be loaded, we must turn this off before loading packages.
vim.cmd.filetype({"indent", "off"})

---------------------------
-- setup package manager --
---------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-------------------
-- setup plugins --
-------------------

require("lazy").setup({
  -- fuzzy file search
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", enabled = vim.fn.executable "make" == 1, build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup()
      telescope.load_extension("fzf")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<C-p>", builtin.find_files, {})
      vim.keymap.set("n", "<C-g>", builtin.live_grep, {})
    end,
  },
  -- tab bar and status line
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "akinsho/bufferline.nvim", config = function() require("bufferline").setup() end },
  { "nvim-lualine/lualine.nvim", config = function() require("lualine").setup() end, event = "VeryLazy" },
  -- syntax
  {
    "nvim-treesitter/nvim-treesitter",
    build = function()
      pcall(require("nvim-treesitter.install").update({ with_sync = true }))
    end,
    config = function()
      require("nvim-treesitter.configs").setup({
        -- Add languages to be installed here that you want installed for treesitter
        ensure_installed = {
          "bash",
          "beancount",
          "c",
          "cpp",
          "css",
          "diff",
          "dockerfile",
          "git_config",
          "gitignore",
          "go",
          "gomod",
          "gosum",
          "hcl",
          "html",
          "javascript",
          "json",
          "latex",
          "lua",
          "make",
          "objc",
          "python",
          "ruby",
          "rust",
          "scss",
          "starlark",
          "terraform",
          "toml",
          "typescript",
          "vim",
          "yaml",
        },

        highlight = { enable = true },
        indent = { enable = true, disable = { "python" } },
      })
    end,
  },
  -- colorscheme
  {
    "projekt0n/github-nvim-theme",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      vim.opt.termguicolors = true

      require("github-theme").setup({
        -- disable all italics
        options = {
          styles = {
            comments = "NONE",
            keywords = "NONE",
          }
        }
      })

      vim.cmd("colorscheme github_dark_dimmed")
    end,
  },
  -- programming lang support
  { "fatih/vim-go", build = ":GoUpdateBinaries" },
  {
    "rust-lang/rust.vim",
    init = function()
      -- https://github.com/rust-lang/rust.vim#formatting-with-rustfmt
      vim.g.rustfmt_autosave = 1
    end,
  },
})

vim.cmd.syntax("on")
vim.cmd.filetype({"plugin", "indent", "on"})

-------------------------
-- trailing whitespace --
-------------------------

-- highlight trailing whitespace
vim.cmd.highlight("ExtraWhitespace ctermbg=red guibg=red")
vim.cmd.match([[ExtraWhitespace /\s\+\%#\@<!$/]])

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  command = "highlight ExtraWhitespace ctermbg=red guibg=red",
})

-- strip trailing whitespace for all files (except markdown where trailing
-- whitespace is significant)
vim.api.nvim_create_augroup("strip_trailing_whitespace", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = "strip_trailing_whitespace",
  pattern = "*",
  command = [[if &ft!~?'markdown' | let l = line(".") | let c = col(".") | %s/\\s\\+$//e | call cursor(l, c)]],
})

--------------------------
-- convenience settings --
--------------------------

-- normal OS clipboard interaction
vim.opt.clipboard = "unnamedplus"

vim.opt.termencoding = "utf-8"
vim.opt.encoding = "utf-8"

-- hide buffers instead of closing them this. means that the current buffer can
-- be put to background without being written; and that marks and undo history
-- are preserved.
vim.opt.hidden = true

-- don't wrap lines
vim.opt.wrap = false
-- a tab is two spaces
vim.opt.tabstop = 2
-- expand tabs by default (overloadable per file type later)
vim.opt.expandtab = true
-- number of spaces to use for autoindenting
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
-- always show line numbers
vim.opt.number = true
vim.opt.autoread = true

-- change the mapleader from \ to ,
vim.g.mapleader = ","

-- Remap j and k to act as expected when used on long, wrapped, lines
vim.keymap.set("n", "j", "gj", { noremap = true })
vim.keymap.set("n", "k", "gk", { noremap = true })

-- when editing a file, always jump to the last known cursor position.
--
-- don't do it when the position is invalid or when inside an event handler
-- (happens when dropping a file on gvim).
vim.api.nvim_create_augroup("restore_cursor", { clear = true })
vim.api.nvim_create_autocmd("BufReadPost", {
  group = "restore_cursor",
  pattern = "*",
  command = [[if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif]],
})

-- save on lose focus, but don't complain if you can't
vim.api.nvim_create_augroup("save_on_lose_focus", { clear = true })
vim.api.nvim_create_autocmd("FocusLost", {
  group = "save_on_lose_focus",
  pattern = "*",
  command = "silent! wa",
})

---------------------
-- typo prevention --
---------------------

vim.keymap.set("n", ";", ":", { noremap = true })

-- allow `:W` to save, which can happen when typing fast
vim.cmd.cnoreabbrev({"W", "w"})

-- disable Ex mode
vim.cmd.map({"Q", "<Nop>"})

-- prevent saving filenames that beging with `:`, `;`, `"`, `'`, `[` or `]`.
-- these are common typos I make when typing the `:w` command quickly.
--
-- https://stackoverflow.com/a/6211489
vim.api.nvim_create_augroup("prevent_saving_typoed_names", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = "prevent_saving_typoed_names",
  pattern = "[:;\"'\\[\\]]*",
  command = "try | echoerr 'Forbidden file name: ' . expand('<afile>') | endtry",
})

--------------------------------
-- search and replace options --
--------------------------------

-- ignore case when searching
vim.opt.ignorecase = true
-- ignore case if search pattern is all lowercase, case-sensitive otherwise
vim.opt.smartcase = true
-- set show matching parenthesis
vim.opt.showmatch = true
-- highlight search terms
vim.opt.hlsearch = true
-- show search matches as you type
vim.opt.incsearch = true
-- search/replace "globally" (on a line) by default
vim.opt.gdefault = true

-- alias to disable highlighting from search matches
vim.keymap.set("n", "<leader><space>", ":noh<cr>", { noremap = true })

---------------------
-- display options --
---------------------

-- status lines
vim.opt.cursorline = true
vim.opt.laststatus = 2

-- change the terminal's title
vim.opt.title = true
-- don't beep
vim.opt.visualbell = true
-- don't beep
vim.opt.errorbells = false

-- show (partial) command in the last line of the screen. this also shows visual
-- selection info
vim.opt.showcmd = true

-- always display at least this many lines between the cursor line and the top
-- and bottom of the viewport
vim.opt.scrolloff = 5

--------------------------
-- file clutter options --
--------------------------

-- do not keep backup files, it's 70's style cluttering
vim.opt.backup = false
-- do not write out changes via backup files
vim.opt.writebackup = false
-- do not write annoying intermediate swap files
vim.opt.swapfile = false

-- enable using the mouse if terminal emulator supports it (xterm does)
vim.opt.mouse = "a"

-------------------
-- speed options --
-------------------

-- speed up the updatetime so gitgutter and friends are quicker
vim.opt.updatetime = 250

-- make the keyboard faaaaaaast
vim.opt.ttyfast = true

-- disable mode lines (security measure)
vim.opt.modeline = false

---------------------
-- persistent undo --
---------------------

vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand("$HOME/.local/state/nvim/undo")
-- use many levels of undo
vim.opt.undolevels = 1000
vim.opt.undoreload = 10000

-----------------------------------
-- programming language settings --
-----------------------------------

-- use tabs for golang
vim.api.nvim_create_augroup("golang_tabs", { clear = true })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = "golang_tabs",
  pattern = "*.go",
  command = "setlocal noexpandtab ts=4 sw=4 sts=4",
})

-- set gitconfig filetype for dotfiles
vim.api.nvim_create_augroup("detect_gitconfig", { clear = true })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = "detect_gitconfig",
  pattern = "*.gitconfig",
  command = "set ft=gitconfig",
})
