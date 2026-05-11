vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.rustfmt_autosave = 1

-- neovim defaults this to `on`, but in order for rust autoindent settings to
-- be loaded, we must turn this off before loading packages.
vim.cmd.filetype({"indent", "off"})

-------------------
-- setup plugins --
-------------------

local github = function(repo)
  return "https://github.com/" .. repo
end

local plugins = {
  -- fuzzy file search
  github("nvim-lua/plenary.nvim"),
  github("nvim-telescope/telescope.nvim"),
  -- tab bar and status line
  github("nvim-tree/nvim-web-devicons"),
  github("akinsho/bufferline.nvim"),
  github("nvim-lualine/lualine.nvim"),
  -- colorscheme
  github("projekt0n/github-nvim-theme"),
  -- programming lang support
  github("hashivim/vim-terraform"),
  github("rust-lang/rust.vim"),
  github("vim-ruby/vim-ruby"),
}

if vim.fn.executable("make") == 1 then
  table.insert(plugins, {
    src = github("nvim-telescope/telescope-fzf-native.nvim"),
    data = { build = { "make" } },
  })
end

local pack_hooks_grp = vim.api.nvim_create_augroup("pack_hooks", { clear = true })
vim.api.nvim_create_autocmd("PackChanged", {
  group = pack_hooks_grp,
  callback = function(ev)
    if ev.data.kind ~= "install" and ev.data.kind ~= "update" then
      return
    end

    local build = ev.data.spec.data and ev.data.spec.data.build
    if build then
      local result = vim.system(build, { cwd = ev.data.path, text = true }):wait()
      if result.code ~= 0 then
        local output = result.stderr
        if output == "" then
          output = result.stdout
        end

        vim.schedule(function()
          vim.notify(
            string.format("Failed building %s:\n%s", ev.data.spec.name, output),
            vim.log.levels.ERROR
          )
        end)
      end
    end
  end,
})

vim.pack.add(plugins, { confirm = false, load = true })

local telescope = require("telescope")
telescope.setup()
pcall(telescope.load_extension, "fzf")

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", builtin.find_files, {})
vim.keymap.set("n", "<C-g>", builtin.live_grep, {})

require("bufferline").setup()
require("lualine").setup()

vim.opt.termguicolors = true

require("github-theme").setup({
  -- disable all italics
  options = {
    styles = {
      comments = "NONE",
      keywords = "NONE",
    },
  },
})

vim.cmd("colorscheme github_dark_dimmed")

vim.cmd("filetype plugin indent on")
vim.cmd("syntax on")

-------------------------
-- trailing whitespace --
-------------------------

-- highlight trailing whitespace
local trailing_ws_highlight_grp = vim.api.nvim_create_augroup("trailing_whitespace_highlight", { clear = true })

local function set_extra_whitespace_highlight()
  vim.api.nvim_set_hl(0, "ExtraWhitespace", {
    ctermbg = "red",
    bg = "red",
  })
end

set_extra_whitespace_highlight()

vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
  group = trailing_ws_highlight_grp,
  callback = function()
    if vim.w.extra_whitespace_match_id then
      return
    end

    vim.w.extra_whitespace_match_id = vim.fn.matchadd("ExtraWhitespace", [[\s\+\%#\@<!$]])
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  group = trailing_ws_highlight_grp,
  pattern = "*",
  callback = set_extra_whitespace_highlight,
})

-- strip trailing whitespace for all files except prose-ish formats where
-- trailing whitespace may be significant
local trailing_ws_excluded_filetypes = {
  markdown = true,
  ["markdown.mdx"] = true,
  gitcommit = true,
  mail = true,
  mutt = true,
}

local function is_normal_file_buffer(buf)
  return vim.bo[buf].buftype == "" and vim.bo[buf].modifiable
end

local strip_trailing_ws_grp = vim.api.nvim_create_augroup("strip_trailing_whitespace", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = strip_trailing_ws_grp,
  pattern = "*",
  callback = function(args)
    if not is_normal_file_buffer(args.buf) then
      return
    end

    if trailing_ws_excluded_filetypes[vim.bo[args.buf].filetype] then
      return
    end

    local view = vim.fn.winsaveview()
    vim.cmd([[keepjumps keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

--------------------------
-- convenience settings --
--------------------------

-- normal OS clipboard interaction
vim.opt.clipboard = "unnamedplus"

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
local restore_cursor_grp = vim.api.nvim_create_augroup("restore_cursor", { clear = true })
vim.api.nvim_create_autocmd("BufReadPost", {
  group = restore_cursor_grp,
  pattern = "*",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)

    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- save on lose focus, but don't complain if you can't
local save_on_lose_focus_grp = vim.api.nvim_create_augroup("save_on_lose_focus", { clear = true })
vim.api.nvim_create_autocmd("FocusLost", {
  group = save_on_lose_focus_grp,
  pattern = "*",
  callback = function()
    pcall(vim.cmd.wall)
  end,
})

---------------------
-- typo prevention --
---------------------

vim.keymap.set("n", ";", ":", { noremap = true })

-- allow `:W` to save, which can happen when typing fast
vim.cmd.cnoreabbrev({"W", "w"})

-- disable Ex mode
vim.cmd.map({"Q", "<Nop>"})

-- prevent saving filenames that begin with `:`, `;`, `"`, `'`, `[` or `]`.
-- these are common typos I make when typing the `:w` command quickly.
local prevent_typos_grp = vim.api.nvim_create_augroup("prevent_saving_typoed_names", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = prevent_typos_grp,
  pattern = "[:;\"'\\[\\]]*",
  callback = function(args)
    error("Forbidden file name: " .. args.file)
  end,
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
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"
-- use many levels of undo
vim.opt.undolevels = 1000
vim.opt.undoreload = 10000

-----------------------------------
-- programming language settings --
-----------------------------------

-- use tabs for golang
local golang_tabs_grp = vim.api.nvim_create_augroup("golang_tabs", { clear = true })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = golang_tabs_grp,
  pattern = "*.go",
  callback = function()
    vim.bo.expandtab = false
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
  end,
})

-- format Go buffers with gofmt before writing them to disk
local gofmt_on_save_grp = vim.api.nvim_create_augroup("gofmt_on_save", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = gofmt_on_save_grp,
  pattern = "*.go",
  callback = function(args)
    if not is_normal_file_buffer(args.buf) then
      return
    end

    if vim.fn.executable("gofmt") ~= 1 then
      return
    end

    local buf = args.buf
    local view = vim.fn.winsaveview()
    local input = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
    if vim.bo[buf].endofline then
      input = input .. "\n"
    end

    local result = vim.system({ "gofmt" }, { stdin = input, text = true }):wait()
    if result.code ~= 0 then
      local output = result.stderr
      if output == "" then
        output = result.stdout
      end
      error(string.format("gofmt failed:\n%s", vim.trim(output)))
    end

    local formatted = vim.split(result.stdout, "\n", { plain = true })
    if formatted[#formatted] == "" then
      table.remove(formatted, #formatted)
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, formatted)
    vim.fn.winrestview(view)
  end,
})

-- set gitconfig filetype for dotfiles
local detect_gitconfig_grp = vim.api.nvim_create_augroup("detect_gitconfig", { clear = true })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = detect_gitconfig_grp,
  pattern = "*.gitconfig",
  callback = function()
    vim.bo.filetype = "gitconfig"
  end,
})

-- set bash filetype for brewfiles
local detect_brewfile_grp = vim.api.nvim_create_augroup("detect_brewfile", { clear = true })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = detect_brewfile_grp,
  pattern = {
    "Brewfile",
    "Brewfile.*",
  },
  callback = function()
    vim.bo.filetype = "bash"
  end,
})

-- set toml filetype for telegraf config
local detect_telegraf_toml_grp = vim.api.nvim_create_augroup("detect_telegraf_toml", { clear = true })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = detect_telegraf_toml_grp,
  pattern = "telegraf.conf",
  callback = function()
    vim.bo.filetype = "toml"
  end,
})
