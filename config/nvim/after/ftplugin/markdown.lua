-- Markdown の記号を残し、折り返しは画面上だけで行う。
vim.opt_local.conceallevel = 0
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true

-- EditorConfig で textwidth が指定されても、入力中は改行を挿入しない。
-- 手動の gq とプロジェクトのインデント指定はそのまま利用できる。
vim.opt_local.formatoptions:remove({ 't', 'c', 'a' })

-- 同じバッファのファイルタイプを変えたときに設定を戻す。
vim.b.undo_ftplugin = (vim.b.undo_ftplugin or '')
    .. '\nsetlocal conceallevel< wrap< linebreak< breakindent< formatoptions<'
