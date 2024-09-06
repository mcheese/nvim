-------------------------------------------------------------------------------
-- Bootstrap lazy.nvim

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-------------------------------------------------------------------------------
-- plugins

require("lazy").setup({
  spec = {
    { 'maxmx03/solarized.nvim' },
    { 'olimorris/onedarkpro.nvim' },
    { 'nvim-tree/nvim-tree.lua', dependencies = { "nvim-tree/nvim-web-devicons" } },
    { 'ojroques/nvim-hardline' },
    { 'VonHeikemen/lsp-zero.nvim', branch = 'v4.x' },
    { 'williamboman/mason.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },
    { 'neovim/nvim-lspconfig' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/nvim-cmp' },
    { 'nvim-treesitter/nvim-treesitter' },
    --{ 'epwalsh/obsidian.nvim', dependencies = { "nvim-lua/plenary.nvim" } },
    { 'nvim-telescope/telescope.nvim', dependencies = { 'nvim-lua/plenary.nvim' } },
  },

  checker = { enabled = true },
})

require("nvim-tree").setup {}
require("hardline").setup {}
require("nvim-treesitter.configs").setup {
  ensure_installed = { "c", "lua", "vim", "vimdoc", "zig" },
  highlight = { enable = true },
  additional_vim_regex_highlighting = false,
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<leader>v", -- set to `false` to disable one of the mappings
      node_incremental = "<C-k>",
      scope_incremental = "<C-l>",
      node_decremental = "<C-j>",
    },
  },
}
require("onedarkpro").setup {
  options = {
    cursorline = true,
    highlight_inactive_windows = true,
  }
}

--require("obsidian").setup {
--    workspaces = {
--      {
--        name = "notes",
--        path = "~/notes",
--      },
--    },
--    mappings = {
--        ["<leader>g"] = {
--      action = function()
--        return require("obsidian").util.gf_passthrough()
--      end,
--      opts = { noremap = false, expr = true, buffer = true },
--    },
--    -- Smart action depending on context, either follow link or toggle checkbox.
--    ["<leader><leader>"] = {
--      action = function()
--        return require("obsidian").util.smart_action()
--      end,
--      opts = { buffer = true, expr = true },
--    }
--    }
--}

local lsp_zero = require('lsp-zero')

local lsp_attach = function(client, bufnr)
  local opts = { buffer = bufnr }

  vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
  vim.keymap.set('n', '<leader>t', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
  vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
  vim.keymap.set('n', '<leader>g', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
  vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
  vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
  vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
  vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
  vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
  vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
  vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
  vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
end

lsp_zero.extend_lspconfig({
  sign_text = true,
  lsp_attach = lsp_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities()
})

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = { 'clangd', 'rust_analyzer', 'lua_ls', 'pyright', 'powershell_es', 'bashls', 'zls', },
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
  }
})

local cmp = require('cmp')

cmp.setup({
  sources = {
    { name = 'nvim_lsp' },
  },
  snippet = {
    expand = function(args)
      -- You need Neovim v0.10 to use vim.snippet
      vim.snippet.expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = function()
      if cmp.visible() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
      else
        cmp.complete()
      end
    end,
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
      else
        fallback()
      end
    end,
  }),
})

-------------------------------------------------------------------------------
-- bindings

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.keymap.set('i', 'jk', '<ESC>')
vim.keymap.set('i', 'Jk', '<ESC>') -- cant figure out a better way...
vim.keymap.set('i', 'JK', '<ESC>')
vim.keymap.set('i', 'kj', '<ESC>')
vim.keymap.set('i', 'Kj', '<ESC>')
vim.keymap.set('i', 'KJ', '<ESC>')
vim.keymap.set('n', '<leader>n', ':set relativenumber! number!<CR>', { silent = true })
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')
vim.keymap.set('n', '<leader>j', '<C-W><C-J>')
vim.keymap.set('n', '<leader>k', '<C-W><C-K>')
vim.keymap.set('n', '<leader>h', '<C-W><C-H>')
vim.keymap.set('n', '<leader>l', '<C-W><C-L>')
vim.keymap.set('n', '<leader>i', ':tabprevious<CR>')
vim.keymap.set('n', '<leader>o', ':tabnext<CR>')
vim.keymap.set('n', '<ESC>', ':noh<CR><ESC>', { silent = true }) -- clear highlight on ESC
-- telescope
vim.keymap.set('n', '<leader>ff', "<cmd>Telescope find_files<CR>")
vim.keymap.set('n', '<leader>fg', "<cmd>Telescope live_grep<CR>")
vim.keymap.set('n', '<leader>fb', "<cmd>Telescope buffers<CR>")
vim.keymap.set('n', '<leader>fh', "<cmd>Telescope help_tags<CR>")



-------------------------------------------------------------------------------
-- settings

vim.wo.number = true
vim.wo.relativenumber = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.encoding = 'utf-8'
vim.opt.listchars = { tab = '»·', trail = '·', nbsp = '·' }
vim.opt.list = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.cursorline = true
vim.opt.scrolloff = 5
vim.opt.termguicolors = true
vim.opt.background = 'dark'
vim.cmd.colorscheme 'onedark'


