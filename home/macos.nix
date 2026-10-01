{ config, ... }:
{
  # 新 Mac の短いアカウント名が異なる場合は、適用前にここだけ変更する。
  home.username = "motoki";
  home.homeDirectory = "/Users/${config.home.username}";

  home.file = {
    ".zshrc".source = ../.zshrc;
    ".zprofile".text = builtins.readFile ../.zprofile + ''

      # Apple の zsh を維持し、Home Manager の環境を読み込む。
      if [[ -r "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh" ]]; then
        source "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
      fi
      if [[ -d "${config.home.profileDirectory}/bin" ]]; then
        path=("${config.home.profileDirectory}/bin" $path)
      fi
    '';
    ".ssh/config".source = ../config/ssh/config;
  };

  xdg.configFile."ghostty/config.ghostty".source = ../config/ghostty/config.ghostty;
}
