{ config, pkgs, ... }:

{
  # ============================================================
  # 工具软件配置 (home/huaijin/modules/tools.nix)
  # ============================================================
  # 各种命令行工具和开发辅助软件。
  # 编辑器（neovim）因为配置过于复杂，通过 config/neovim.nix 链接
  # dotfiles 中的完整配置目录，不做 nix 化处理。
  # ============================================================

  # 用户级软件包
  home.packages = with pkgs; [
    # ----------------------------------------------------------
    # 文件管理器
    # ----------------------------------------------------------
    yazi # 终端文件管理器（Rust 编写，异步 I/O，支持图片预览）

    # ----------------------------------------------------------
    # Git 工具
    # ----------------------------------------------------------
    lazygit # Git 的终端 UI（比命令行 git 更方便的交互界面）

    # ----------------------------------------------------------
    # 系统信息
    # ----------------------------------------------------------
    fastfetch # 系统信息展示（neofetch 的继任者，更活跃维护）

    # ----------------------------------------------------------
    # Shell 增强工具
    # ----------------------------------------------------------
    zoxide # 智能 cd 替代（根据使用频率跳转目录）
    eza # ls 替代（带图标、颜色、Git 状态）
    trash-cli # 安全删除（rm 替代，文件移入回收站而非永久删除）
    starship

    # ----------------------------------------------------------
    # 安全与密钥
    # ----------------------------------------------------------
    gnome-keyring # GNOME 密钥管理守护进程（SSH agent、密码存储）

    # ----------------------------------------------------------
    # 开发工具
    # ponytail: conda 和 fnm 的 nixpkgs 路径与原 setup.zsh 中的路径不同
    # （$HOME/miniconda3/bin/conda vs nix store）
    # 保留 setup.zsh 中的手动安装路径，等迁移完成后再统一
    # ----------------------------------------------------------
    # conda # Python 虚拟环境（nixpkgs 路径与 setup.zsh 不兼容）
    # fnm   # Node.js 版本管理器（同上）
    codex
    bubblewrap # codex 依赖

    # ----------------------------------------------------------
    # 截图工具
    # ----------------------------------------------------------
    grim # Wayland 截图工具
    slurp # Wayland 区域选择工具（配合 grim 使用）
  ];

  # ============================================================
  # 配置文件：从 dotfiles 链接
  # ============================================================
  # 以下配置直接引用 dotfiles 中的原始文件，不做 nix 化转换。
  # 如果后续需要声明式管理，可以改写为 nix 的 attrset 配置。

  # Yazi 文件管理器配置
  xdg.configFile = {
    # 主配置：显示隐藏文件
    "yazi/yazi.toml".source =
      config.lib.file.mkOutOfStoreSymlink /home/huaijin/dotfiles/tools/.config/yazi/yazi.toml;

    # LazyGit 配置：语言设为英文
    "lazygit/config.yml".source =
      config.lib.file.mkOutOfStoreSymlink /home/huaijin/dotfiles/tools/.config/lazygit/config.yml;

    # Fastfetch 系统信息展示配置
    "fastfetch/config.jsonc".source =
      config.lib.file.mkOutOfStoreSymlink /home/huaijin/dotfiles/shell/.config/fastfetch/config.jsonc;

    # Starship 终端提示符配置
    "starship/starship.toml".source =
      config.lib.file.mkOutOfStoreSymlink /home/huaijin/dotfiles/shell/.config/starship/starship.toml;
  };
}
