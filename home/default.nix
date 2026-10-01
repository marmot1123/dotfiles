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
  ];

  home.sessionVariables.LANG = "en_US.UTF-8";

  # 書き込み可能な fish_variables や旧版用の移行処理は配置しない。
  xdg.configFile = {
    "fish/config.fish".text = builtins.readFile ../config/fish/config.fish + ''

      # 共通 CLI は Home Manager のプロファイルを優先する。
      fish_add_path --path --prepend --move "${config.home.profileDirectory}/bin"
      set --global fish_key_bindings fish_default_key_bindings
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
