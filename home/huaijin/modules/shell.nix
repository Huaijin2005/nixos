{ config, pkgs, ... }:

{
  # ============================================================
  # Shell 配置 (home/huaijin/modules/shell.nix)
  # ============================================================
  # 管理 Zsh、Fish、Tmux 等 shell 工具的用户配置。
  # Zsh 是主 shell，使用 Zim 框架作为插件管理器。
  # Fish 是备用 shell，保留基本配置。
  # starship 配置文件已在 tools.nix 中通过 xdg.configFile 链接。
  # ============================================================

  # ============================================================
  # Zsh 配置
  # ============================================================
  programs.zsh = {
    enable = true; # 启用 home-manager 管理 Zsh

    # ----------------------------------------------------------
    # Zsh 选项（setopt）
    # ----------------------------------------------------------
    history = {
      ignoreAllDups = true; # 不记录重复的历史命令
    };
    # ponytail: home-manager 的 programs.zsh 没有 globdots 选项，
    # 在 initContent 中通过 source 的 setup 文件设置

    # ----------------------------------------------------------
    # Zsh 初始化脚本（~/.zshrc 顶部执行）
    # ----------------------------------------------------------
    initContent = ''
      # ============================================================
      # Zim 框架初始化
      # Zim 是一个轻量级的 Zsh 插件框架，替代 Oh My Zsh
      # 比起 Oh My Zsh 启动更快、配置更简洁
      # ============================================================

      # 设置 Zim 安装目录
      ZIM_HOME=''${ZDOTDIR:-$HOME}/.zim

      # 如果 zimfw.zsh 不存在，自动下载 Zim 框架
      if [[ ! -e ''${ZIM_HOME}/zimfw.zsh ]]; then
        if (( ''${+commands[curl]} )); then
          curl -fsSL --create-dirs -o ''${ZIM_HOME}/zimfw.zsh \
              https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
        else
          mkdir -p ''${ZIM_HOME} && wget -nv -O ''${ZIM_HOME}/zimfw.zsh \
              https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
        fi
      fi

      # 如果模块需要更新，自动安装
      if [[ ! ''${ZIM_HOME}/init.zsh -nt ''${ZIM_CONFIG_FILE:-''${ZDOTDIR:-$HOME}/.zimrc} ]]; then
        source ''${ZIM_HOME}/zimfw.zsh init
      fi

      # 加载 Zim 初始化脚本（包含所有模块）
      source ''${ZIM_HOME}/init.zsh

      # ============================================================
      # Zsh 基本设置
      # ============================================================
      # 语言环境
      export LANG=en_US.UTF-8
      export LANGUAGE=en_US.UTF-8

      # 设置编辑模式为 vi 键位
      bindkey -v

      # 从 WORDCHARS 中移除 / 字符
      # 这样在路径补全时，Alt+Backspace 会停在 / 处而非删除整个路径
      WORDCHARS=''${WORDCHARS//[\/]}

      # ============================================================
      # 加载自定义脚本（来自 dotfiles）
      # ============================================================
      # 函数定义（proxy_on, proxy_off 等）
      source ~/.zsh/function.zsh

      # 别名定义（ls -> eza, cd -> z, ssh -> kitten ssh 等）
      source ~/.zsh/alias.zsh

      # 工具链初始化（starship, zoxide, fnm, conda, yazi 等）
      source ~/.zsh/setup.zsh

      # 加载 SOPS 生成的 API key 文件（如果存在）
      # 此文件由 modules/sops.nix 的 templates."private-zsh" 自动生成
      # 模板默认输出到 /run/secrets/ 目录（sops-nix 默认行为）
      if [[ -f /run/secrets/private-zsh ]]; then
        source /run/secrets/private-zsh
      fi
    '';

    # ----------------------------------------------------------
    # Zsh 插件配置
    # ----------------------------------------------------------
    # Zim 模块列表（写入 ~/.zimrc）
    # 这些模块提供：Git 别名、输入增强、智能补全、语法高亮等
    zplug = {
      # ponytail: zplug 设置是占位的，实际插件由 Zim 的 .zimrc 管理
      enable = false;
    };

    # Zsh 自动建议：灰色显示历史命令建议，按 → 接受
    autosuggestion = {
      enable = true;
      highlight = "fg=242"; # 建议文字颜色：灰色
    };

    # Zsh 语法高亮：实时给命令上色（红色=错误命令，绿色=有效命令）
    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "main"
        "brackets"
      ]; # 启用主要高亮 + 括号匹配
    };

    # Zsh 历史子串搜索：输入时按 ↑ 搜索匹配的历史命令
    historySubstringSearch = {
      enable = true;
    };

    # ----------------------------------------------------------
    # Zsh session 变量（写入 ~/.zshrc）
    # ----------------------------------------------------------
    sessionVariables = {
      # starship 配置文件路径
      STARSHIP_CONFIG = "$HOME/.config/starship/starship.toml";
    };

    # ----------------------------------------------------------
    # Zsh 初始化附加脚本（~/.zshrc 最后执行）
    # ----------------------------------------------------------
    # initExtra = ''
    #   # ============================================================
    #   # starship 终端提示符初始化
    #   # 显示当前目录、Git 分支、语言版本等信息
    #   # ============================================================
    #   eval "$(starship init zsh)"

    #   # ============================================================
    #   # zoxide 智能跳转初始化
    #   # 替代 cd 命令，根据使用频率自动跳转
    #   # ============================================================
    #   eval "$(zoxide init zsh)"
    # '';
  };

  # ============================================================
  # Zim 配置文件 (~/.zimrc)
  # ============================================================
  # Zim 模块列表：决定哪些插件被加载
  home.file.".zimrc".text = ''
    # ============================================================
    # Zim 框架模块配置
    # 模块顺序很重要：后加载的模块可能覆盖前面的设置
    # ============================================================

    # 基础环境模块（环境变量、编辑器设置）
    environment

    # Git 模块（提供大量 Git 别名和函数）
    git

    # 输入增强（双击 .. 自动补全为 ../.. 等）
    input

    # 终端标题（自动设置终端窗口标题）
    termtitle

    # 实用工具模块
    utility

    # 持续时间提醒（长命令执行完毕后提示耗时）
    duration-info

    # Git 状态提示
    git-info

    # 目录路径缩短（~/very/long/path 显示为 ~/v/l/path）
    prompt-pwd

    # Zsh 补全增强
    zsh-completions
    completion

    # 语法高亮（实时给命令上色）
    fast-syntax-highlighting

    # 历史子串搜索（输入时按 ↑ 搜索历史）
    zsh-history-substring-search

    # 自动建议（灰色显示历史建议）
    zsh-autosuggestions

    # FZF Tab 补全（模糊搜索增强补全体验）
    fzf-tab
  '';

  # ============================================================
  # Fish Shell 配置（备用 shell）
  # ============================================================
  programs.fish = {
    enable = true;

    # Fish shell 初始化脚本
    interactiveShellInit = ''
      # ============================================================
      # starship 终端提示符
      # ============================================================
      starship init fish | source

      # ============================================================
      # 代理函数（注释形式保留，如需使用取消注释）
      # 在需要时终端执行 proxy_on 开启代理
      # ============================================================
      # function proxy_on
      #     set -gx http_proxy http://127.0.0.1:7897
      #     set -gx https_proxy http://127.0.0.1:7897
      #     set -gx all_proxy http://127.0.0.1:7897
      # end
      #
      # function proxy_off
      #     set -e http_proxy
      #     set -e https_proxy
      #     set -e all_proxy
      # end
    '';
  };

  # ============================================================
  # Tmux 终端复用器配置
  # ============================================================
  programs.tmux = {
    enable = true;

    # 终端类型：保证颜色和特性正常
    terminal = "tmux-256color";

    # 快捷键前缀（默认 Ctrl+b，这里保持不变）
    shortcut = "b";

    # Escape 输入等待时间（毫秒）：10ms 足够，太大会感觉延迟
    escapeTime = 10;

    # 历史记录行数
    historyLimit = 100000;

    # 启用鼠标支持（点击窗口、拖动分隔线、滚轮翻页）
    mouse = true;

    # Tmux 额外配置
    extraConfig = ''
      # ----------------------------------------------------------
      # 终端特性覆盖（RGB 颜色、剪贴板、焦点事件、超链接）
      # os.solarized 主题和其他现代插件需要这些特性
      # ----------------------------------------------------------
      set -as terminal-features ",xterm-kitty:RGB,clipboard,focus,hyperlinks"
      set -as terminal-features ",tmux-256color:RGB,clipboard,focus,hyperlinks"

      # ----------------------------------------------------------
      # OSC52 剪贴板支持
      # 允许程序通过 ANSI escape 序列直接访问系统剪贴板
      # ponytail: 简单开启即可，无需额外配置
      # ----------------------------------------------------------
      set -s allow-passthrough on
      set -as terminal-features ",*:clipboard"

      # ----------------------------------------------------------
      # 环境变量传递
      # 当 tmux 重新连接时，自动更新 SSH_AUTH_SOCK 等变量
      # ----------------------------------------------------------
      set -g update-environment "DISPLAY SSH_ASKPASS SSH_AUTH_SOCK SSH_AGENT_PID SSH_CONNECTION WINDOWID XAUTHORITY"

      # ----------------------------------------------------------
      # Vi 模式键位
      # ----------------------------------------------------------
      set -g mode-keys vi
    '';
  };

  # ============================================================
  # Zsh 自定义脚本文件
  # ============================================================
  # 这些文件在 ~/.zshrc 中被 source，内容由 dotfiles 直接链接
  home.file = {
    # 函数定义文件（proxy_on, proxy_off 等）
    ".zsh/function.zsh".source =
      config.lib.file.mkOutOfStoreSymlink /home/huaijin/dotfiles/shell/.zsh/function.zsh;

    # 别名定义文件（ls -> eza, cd -> z 等）
    ".zsh/alias.zsh".source =
      config.lib.file.mkOutOfStoreSymlink /home/huaijin/dotfiles/shell/.zsh/alias.zsh;

    # 工具链初始化（starship, zoxide, fnm, conda, yazi）
    ".zsh/setup.zsh".source =
      config.lib.file.mkOutOfStoreSymlink /home/huaijin/dotfiles/shell/.zsh/setup.zsh;
  };
}
