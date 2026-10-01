-- 補完・定義ジャンプ・診断は Neovim 標準の LSP クライアントを使う。
if not vim.lsp.config or not vim.lsp.enable then
    vim.notify('LSP setup requires Neovim 0.11 or later.', vim.log.levels.WARN)
    return
end

vim.diagnostic.config({
    virtual_text = false,
    severity_sort = true,
})

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('dotfiles_lsp', { clear = true }),
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if not client then
            return
        end

        local function map(key, action, description)
            vim.keymap.set('n', key, action, { buffer = event.buf, desc = description })
        end

        if client.name == 'ruff' then
            -- 型や関数の説明は basedpyright に任せる。
            client.server_capabilities.hoverProvider = false
        end

        if client:supports_method('textDocument/definition') then
            map('gd', vim.lsp.buf.definition, 'Go to definition')
        end
        map('<leader>cd', vim.diagnostic.open_float, 'Show diagnostics')

        if client:supports_method('textDocument/completion') then
            -- "." 等に加え、識別子の入力でも候補を表示する。
            local triggers = client.server_capabilities.completionProvider.triggerCharacters or {}
            for character in ('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_'):gmatch('.') do
                if not vim.tbl_contains(triggers, character) then
                    table.insert(triggers, character)
                end
            end
            client.server_capabilities.completionProvider.triggerCharacters = triggers
            vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
        end

        if client:supports_method('textDocument/formatting') then
            map('<leader>cf', function()
                vim.lsp.buf.format({ bufnr = event.buf, id = client.id, timeout_ms = 3000 })
            end, 'Format buffer')
        end
    end,
})

for _, name in ipairs({ 'basedpyright', 'ruff' }) do
    local config = vim.lsp.config[name]
    if vim.fn.executable(config.cmd[1]) == 1 then
        vim.lsp.enable(name)
    else
        vim.notify(config.cmd[1] .. ' is missing; see docs/editors.md for setup.', vim.log.levels.WARN)
    end
end
