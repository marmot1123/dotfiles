-- 濃紺の背景と落ち着いた差し色。色はテーマの標準値を使う。
vim.opt.termguicolors = true
vim.opt.background = 'dark'

require('kanagawa').setup({
    theme = 'wave',
    transparent = false,
    commentStyle = { italic = false },
    keywordStyle = { italic = false },
})
vim.cmd.colorscheme('kanagawa-wave')
