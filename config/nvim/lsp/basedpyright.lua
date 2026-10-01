return {
    cmd = { 'basedpyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = { { 'pyproject.toml', 'pyrightconfig.json', '.venv' }, '.git' },
    settings = {
        basedpyright = {
            disableOrganizeImports = true,
            analysis = {
                -- プロジェクト側の指定があれば、そちらを優先する。
                typeCheckingMode = 'standard',
                autoFormatStrings = false,
            },
        },
    },
}
