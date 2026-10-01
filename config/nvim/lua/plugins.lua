-- Neovim 0.12 の標準パッケージ管理を使う。起動時の自動更新はしない。
if not vim.pack then
    vim.notify('Plugin setup requires Neovim 0.12 or later.', vim.log.levels.WARN)
    return
end

vim.pack.add({
    'https://github.com/ibhagwan/fzf-lua',
    'https://github.com/rebelot/kanagawa.nvim',
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
}, { confirm = false })

require('theme')
require('highlight')

local fzf = require('fzf-lua')
fzf.setup({
    -- Bizin Gothic 通常版で使える表示にする。
    file_icons = false,
    git_icons = false,
    color_icons = false,
    files = {
        fd_opts = '--color=never --hidden --type f --type l --exclude .git --exclude .venv --exclude __pycache__ --exclude node_modules',
    },
    grep = {
        rg_opts = '--column --line-number --no-heading --color=always --smart-case --hidden --glob !.git --glob !.venv --glob !__pycache__ --glob !node_modules --max-columns=4096 -e',
    },
})

vim.keymap.set('n', '<leader>ff', fzf.files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', fzf.live_grep, { desc = 'Search file contents' })
vim.keymap.set('n', '<leader>fb', fzf.buffers, { desc = 'Find open buffers' })
