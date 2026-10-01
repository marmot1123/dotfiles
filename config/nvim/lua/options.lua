local opt = vim.opt

-- 行番号
opt.number = true

-- タブとインデントの設定
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true

-- 検索設定
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true

-- 補完候補は自動選択せず、明示的に確定する。
opt.completeopt = { 'menu', 'menuone', 'noselect', 'popup' }
opt.signcolumn = 'yes'
