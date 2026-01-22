-- Create a function to handle the Enter key in Insert mode
--
-- local function handle_enter_key()
--   if vim.fn.pumvisible() == 1 then
--
--     -- If the popup menu is visible, do nothing or map to another key
--     return ""
--   else
--     -- If the popup menu is not visible, insert a newline
--     return vim.api.nvim_replace_termcodes("<CR>", true, true, true)
--   end
-- end
--
-- -- Map the Enter key in Insert mode to the handle_enter_key function
-- vim.api.nvim_set_keymap('i', '<CR>', 'v:lua.handle_enter_key()', {expr = true, noremap = true})
-- vim.keymap.set('n', '<CR>', 'm`o<Esc>')
-- vim.keymap.set('n', '<S-CR>', 'm`O<Esc>')
-- local dap = require 'mfussenegger/nvim-dap'

local mappings = {
    b = {
        name = "Buffer",
        k = { "<cmd>Bdelete<cr>", "Kill" },
        l = { "<cmd>buffers<cr>", "Buffers" },
        n = { "<cmd>bnext<cr>", "Next" },
        p = { "<cmd>bprevious<cr>", "Previous" },
        f = { "<cmd>Telescope buffers<cr>", "Buffers" },
    },
    g = {
        name = "Git",
        g = { "<cmd>Neogit<CR>", "Lazygit" },
        j = { "<cmd>lua require 'gitsigns'.next_hunk()<cr>", "Next Hunk" },
        k = { "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", "Prev Hunk" },
        l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
        p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk" },
        r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
        R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
        s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
        u = {
            "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
            "Undo Stage Hunk",
        },
        o = { "<cmd>Telescope git_status<cr>", "Open changed file" },
        b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
        c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
        d = {
            "<cmd>Gitsigns diffthis HEAD<cr>",
            "Diff",
        },
    },
    c = {
        name = "LSP",
        a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
        d = {
            "<cmd>Telescope lsp_document_diagnostics<cr>",
            "Document Diagnostics",
        },
        w = {
            "<cmd>Telescope lsp_workspace_diagnostics<cr>",
            "Workspace Diagnostics",
        },
        f = { "<cmd>lua require('conform').format()<cr>", "Format" },
        i = { "<cmd>LspInfo<cr>", "Info" },
        I = { "<cmd>LspInstallInfo<cr>", "Installer Info" },
        j = {
            "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>",
            "Next Diagnostic",
        },
        k = {
            "<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>",
            "Prev Diagnostic",
        },
        l = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
        O = {
            "<cmd>Outline<cr>",
            "Symbol Outline"
        },
        q = { "<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>", "Quickfix" },
        r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
        s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
        S = {
            "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
            "Workspace Symbols",
        },
    },
    ["e"] = { "<cmd>NvimTreeToggle<cr>", "Open Tree" },
    f = {
        name = "+Find",
        r = { "<cmd>Telescope oldfiles<cr>", "Recent Files" },
        f = { "<cmd>Telescope find_files<cr>", "Files" },
        s = { "<cmd>Telescope live_grep<cr>", "Strings" },
        b = { "<cmd>Telescope buffers<cr>", "Buffers" },
        h = { "<cmd>Telescope help_tags<cr>", "Help" },
        m = { "<cmd> Telescope file_browser", "File Browser" },
    },
    h = {
        name = "Harpoon",
        a = { function() require('harpoon'):list():add() end, "Add File" },
        m = { function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end, "Buffers" },
        n = { function() require("harpoon"):list():next() end, "Next" },
        p = { function() require("harpoon"):list():prev() end, "Previous" },
        -- f = { "<cmd>Telescope harpoon marks<cr>", "Buffers"},
        -- vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end)
        -- vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
        --
        -- vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
        -- vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
        -- vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
        -- vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)
        --
        -- -- Toggle previous & next buffers stored within Harpoon list
        -- vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
        -- vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
    },
    t = {
        name = "+Trouble",
        t = { "<cmd>TroubleToggle<cr>", "Toggle" },
        r = { "<cmd>Trouble lsp_references<cr>", "References" },
        D = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
        d = { "<cmd>Trouble document_diagnostics<cr>", "Diagnostics" },
        q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
        l = { "<cmd>Trouble loclist<cr>", "LocationList" },
        w = { "<cmd>Trouble workspace_diagnostics<cr>", "Workspace Diagnostics" },
    },
    w = {
        name = "Window",
        c = { "<c-w>c", "Close" },
        n = { "<c-w>h", "Left" },
        e = { "<c-w>j", "Down" },
        i = { "<c-w>k", "Up" },
        o = { "<c-w>l", "Right" },
        v = { "<cmd>vsp<cr>", "Vertical Split" },
        h = { "<cmd>sp<cr>", "Horizontal Split" },
    },
    q = {
        name = "+Session",
        s = { [[<cmd>lua require("persistence").load()<cr>]], "Restore Current Dir Session" },
        l = { [[<cmd>lua require("persistence").load({ last = true })<cr>]], "Restore Last Session" },
        d = { [[<cmd>lua require("persistence").stop()<cr>]], "Exit Current Session" },
    }
}
local opts = {
    mode = "n",     -- NORMAL mode
    prefix = "<leader>",
    buffer = nil,   -- Global mappings. Specify a buffer number for buffer local mappings
    silent = true,  -- use `silent` when creating keymaps
    noremap = true, -- use `noremap` when creating keymaps
    nowait = true,  -- use `nowait` when creating keymaps
}

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
vim.keymap.set('n', '<c-w>n', '<c-w>h')
vim.keymap.set('n', '<c-w>e', '<c-w>j')
vim.keymap.set('n', '<c-w>i', '<c-w>k')
vim.keymap.set('n', '<c-w>o', '<c-w>l')
-- document existing key chains
require('which-key').register(mappings, opts)
