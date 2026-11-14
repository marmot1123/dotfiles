{ config, pkgs, ... }:
{
  # 初回導入時の互換性基準。更新に合わせて機械的に変更しない。
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
  xdg.enable = true;

  home.packages = with pkgs; [
    git
    git-lfs
    gh
    fish
    fzf
    fd
    ripgrep
    # 管理ツールだけを Nix で固定し、言語本体と依存はプロジェクト側で選ぶ。
    fnm
    # 実行時は fnm が選んだ Node.js を使う。
    (pnpm.override { withNode = false; })
    uv
    rustup
  ];

  home.sessionVariables.LANG = "en_US.UTF-8";

  # 書き込み可能な fish_variables や旧版用の移行処理は配置しない。
  xdg.configFile = {
    "fish/config.fish".text = builtins.readFile ../config/fish/config.fish + ''

      # 共通 CLI は Home Manager のプロファイルを優先する。
      fish_add_path --path --prepend --move "${config.home.profileDirectory}/bin"
      set --global fish_key_bindings fish_default_key_bindings

      # PATH の準備後に、シェルごとの Node.js 環境を作る。
      if status is-interactive; and command --query fnm
          fnm env --use-on-cd --shell fish | source
      end
    '';
    "fish/conf.d/fish_frozen_theme.fish".source = ../config/fish/conf.d/fish_frozen_theme.fish;
    "fish/functions/fish_prompt.fish".source = ../config/fish/functions/fish_prompt.fish;
    "fish/functions/fish_user_key_bindings.fish".source = ../config/fish/functions/fish_user_key_bindings.fish;
    "git/config".source = ../config/git/config;
  };

  home.file = {
    ".vimrc".source = ../.vimrc;
    ".gitignore_global".source = ../config/git/ignore;
  };
}
