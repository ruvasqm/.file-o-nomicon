local builtin = require('telescope.builtin')
local utils = require('telescope.utils')
local telescope = require("telescope")
pcall(telescope.load_extension, "fzf")
telescope.setup({
	defaults = {
		-- `hidden = true` is not supported in text grep commands.
	},
	pickers = {
		find_files = {
			-- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
			cwd = utils.buffer_dir(),
		},
    grep_string = {
			cwd = utils.buffer_dir(),
    },
    live_grep = {
			cwd = utils.buffer_dir(),
    },
	},
})

vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', function()
	builtin.live_grep({ })
end)

