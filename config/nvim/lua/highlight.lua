local M = {}

-- 更新・新しい Mac での導入時にも同じ一覧を使う。
M.parsers = {
    'python',
    'markdown',
    'markdown_inline',
    'html',
    'css',
    'json',
    'yaml',
    'toml',
    'lua',
    'bash',
    'rust',
    'latex',
}

require('nvim-treesitter').setup({
    install_dir = vim.fn.stdpath('data') .. '/site',
})
vim.treesitter.language.register('latex', { 'tex', 'plaintex' })

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('dotfiles_highlight', { clear = true }),
    pattern = {
        'python', 'markdown', 'html', 'css', 'json',
        'yaml', 'toml', 'lua', 'sh', 'rust', 'tex', 'plaintex',
    },
    callback = function(event)
        local lang = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
        -- パーサー未導入時は標準の構文色付けで編集を続けられる。
        if lang and vim.treesitter.language.add(lang) then
            vim.treesitter.start(event.buf, lang)
        end
    end,
})

return M
