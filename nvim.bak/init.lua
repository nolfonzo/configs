vim.cmd("let g:netrw_liststyle = 3")
vim.g.mapleader = " "

local opt = vim.opt

opt.relativenumber = true
opt.number = true

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

opt.wrap = false

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

opt.cursorline = true

-- turn on termguicolors for tokyonight colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom



-- Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
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

require("lazy").setup("plugins")


vim.cmd("colorscheme catppuccin")

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

vim.keymap.set('', '<leader>mp',":MarkdownPreview<CR>")
vim.keymap.set('', '<leader>ms',":MarkdownPreviewStop<CR>")
vim.keymap.set('', '<leader>mt',":MarkdownPreviewToggle<CR>")

vim.keymap.set('', '<leader>to',":NvimTreeOpen<CR>")
vim.keymap.set('', '<leader>tc',":NvimTreeClose<CR>")
vim.keymap.set('', '<leader>tt',":NvimTreeToggle<CR>")
vim.keymap.set('', '<leader>tf',":NvimTreeFocus<CR>")
vim.keymap.set('', '<leader>tr',":NvimTreeRefresh<CR>")
vim.keymap.set('', '<leader>tff',":NvimTreeFindFile<CR>")
vim.keymap.set('', '<leader>tco',":NvimTreeCollapse<CR>")

vim.keymap.set('', '<leader>w',":WhichKey<CR>")

vim.keymap.set('', '<leader>-',":Oil<CR>")
