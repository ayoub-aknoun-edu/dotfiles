local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Telescope
map("n", "<leader>sb", "<cmd>Telescope buffers<cr>", { desc = "Search Buffers" })
map("n", "<leader>sk", "<cmd>Telescope keymaps<cr>", { desc = "Search Keymaps" })

-- Diagnostics
map("n", "<leader>xx", vim.diagnostic.setloclist, { desc = "Diagnostics to LocList" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })

-- Surround (you installed mini.surround; repeat here as reminders)
-- add: <leader>sa, delete: <leader>sd, replace: gsr, highlight: gsh

-- Quick save/quit
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- Terminal toggle (both variants depending on terminal)
map({ "n", "t" }, "<C-/>", "<cmd>ToggleTerm<cr>", { desc = "Toggle Terminal" })
map({ "n", "t" }, "<C-_>", "<cmd>ToggleTerm<cr>", { desc = "Toggle Terminal (alt)" })
