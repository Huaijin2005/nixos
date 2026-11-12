{ config, pkgs, ... }:

{
  # ============================================================
  # 虚拟机主机配置 (hosts/nixos-vm/configuration.nix)
  # ============================================================
  # 此文件定义 nixos-vm 这台机器的特定配置。
  # 通用配置（如 nix 设置、自由软件许可）已移至 modules/default.nix。

  imports = [
    # 硬件配置：由 nixos-generate-config 自动生成
    # 包含磁盘分区、文件系统、内核模块等
    ./hardware-configuration.nix
  ];

  # ============================================================
  # 引导加载器
  # ============================================================
  # systemd-boot：UEFI 系统的轻量引导管理器
  boot.loader.systemd-boot.enable = true;
  # 允许从操作系统修改 EFI 启动项（安装/更新引导管理器时使用）
  boot.loader.efi.canTouchEfiVariables = true;

  # ============================================================
  # 网络配置
  # ============================================================
  networking.hostName = "nixos"; # 主机名
  networking.networkmanager.enable = true; # 使用 NetworkManager 管理网络

  # ============================================================
  # 时区与本地化
  # ============================================================
  time.timeZone = "Asia/Shanghai"; # 上海时区 (UTC+8)

  # 系统默认语言环境
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # ----------------------------------------------------------
  # 中文输入法：Fcitx5 + Rime
  # ----------------------------------------------------------
  i18n.inputMethod = {
    type = "fcitx5"; # 使用 Fcitx5 输入法框架
    fcitx5 = {
      # 启用 Wayland 前端（niri 是 Wayland 合成器，必须启用此项）
      waylandFrontend = true;
      # 输入法插件列表
      addons = with pkgs; [
        fcitx5-rime # Rime 输入法引擎（中文）
        rime-ice # 开源简体中文词库（雾凇拼音）
        fcitx5-gtk # GTK 程序输入支持
        librime-lua # Rime Lua 脚本扩展（Rime Ice 依赖）
      ];
    };
  };

  # ============================================================
  # 键盘布局
  # ============================================================
  # X11 键盘布局（对 Wayland 无效，但保留以防 XWayland 应用需要）
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # ============================================================
  # Niri Wayland 合成器
  # ============================================================
  # Niri：滚动式平铺 Wayland 合成器
  # 详细配置（快捷键、动画、窗口规则）在 home-manager 中通过
  # home/huaijin/config/niri.nix 管理
  programs.niri.enable = true;

  # ============================================================
  # 显示管理器（图形登录界面）
  # ============================================================
  # DMS Greeter：基于 Dank Material Shell 的 Wayland 登录界面
  # 使用 niri 合成器渲染登录界面，与桌面环境风格统一
  services.displayManager.dms-greeter = {
    enable = true;
    # 指定登录界面用什么 Wayland 合成器渲染
    compositor.name = "niri";
    # 注意：dms-greeter 使用的 niri 实例独立于用户桌面的 niri，
    # 两者不会冲突
  };

  # ============================================================
  # PipeWire 音频服务
  # ============================================================
  # PipeWire 是现代的 Linux 音频/视频流服务，替代 PulseAudio 和 JACK
  # 几乎所有 Wayland 桌面环境都需要它
  services.pipewire = {
    enable = true;
    # ALSA 兼容层：让使用 ALSA 的老程序也能发声
    alsa.enable = true;
    # PulseAudio 兼容层：让使用 PulseAudio 的程序也能工作
    pulse.enable = true;
    # JACK 兼容层：专业音频程序（如 DAW）需要
    jack.enable = true;
  };

  # ============================================================
  # D-Bus 服务
  # ============================================================
  # gnome-keyring：密钥管理服务，SSH agent、密码存储等
  services.dbus.packages = with pkgs; [
    gnome-keyring
  ];

  # ============================================================
  # XDG 桌面门户 (Desktop Portal)
  # ============================================================
  # 桌面门户是 Wayland 应用与系统交互的桥梁：
  # 文件选择器、屏幕截图、屏幕录制等都需要它
  xdg.portal = {
    enable = true;
    # 默认门户后端（优先级从高到低）
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk # GTK 风格的文件选择器
    ];
    config = {
      niri = {
        # 屏幕录制/截图使用 GNOME 门户后端
        "org.freedesktop.impl.portal.ScreenCast" = "gnome";
        "org.freedesktop.impl.portal.Screenshot" = "gnome";
      };
    };
  };

  # ============================================================
  # 系统字体
  # ============================================================
  # 系统级别安装字体，保证所有用户都能使用
  # 用户级别的字体安装在 home/huaijin/modules/fonts.nix 中管理
  fonts.packages = with pkgs; [
    # 中文像素优化字体（屏幕阅读用）
    lxgw-wenkai-screen
    # 中文字体系列
    lxgw-wenkai
    lxgw-wenkai-tc
    # 思源系列：泛 CJK 字体（支持中日韩）
    source-han-serif # 衬线字体
    source-han-sans # 无衬线字体
    # Noto CJK 字体（Google 出品，覆盖中日韩）
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    # FiraCode Nerd Font：编程字体 + Nerd Font 图标补丁
    # 用于终端、代码编辑器和各类状态栏图标显示
    nerd-fonts.fira-code
  ];

  # ============================================================
  # Shell 支持
  # ============================================================
  # 系统级别启用 Zsh 和 Fish（使其可用作 login shell）
  # 详细的 Zsh 配置（zim、别名、函数）在 home/huaijin/modules/shell.nix 中
  programs.zsh.enable = true;
  programs.fish.enable = true;

  # ============================================================
  # 用户配置
  # ============================================================
  users.users.huaijin = {
    isNormalUser = true;
    description = "huaijin";
    extraGroups = [
      "networkmanager" # 管理网络连接
      "wheel" # sudo 权限
      "input" # 访问输入设备（键盘/鼠标）
      "audio" # 访问音频设备
      "video" # 访问视频设备（屏幕亮度等）
    ];
    shell = pkgs.fish; # 默认 shell 使用 Fish
  };

  # ============================================================
  # 系统级软件包
  # ============================================================
  # 系统全局安装的包（所有用户共享）
  # 大部分用户软件通过 home-manager 安装在 home/huaijin/default.nix
  environment.systemPackages = with pkgs; [
    # 包里不放东西，由 home-manager 管理
  ];

  # ============================================================
  # SSH 配置
  # ============================================================
  services.openssh = {
    enable = true;
    openFirewall = true; # 开放 22 端口
    settings = {
      PasswordAuthentication = false; # 禁止密码登录（仅密钥）
      PermitRootLogin = "no"; # 禁止 root 直接登录
    };
  };

  # SSH 客户端配置：GitHub 通过 443 端口连接（绕过部分网络限制）
  programs.ssh.extraConfig = ''
    Host github.com
      Hostname ssh.github.com
      Port 443
      User git
  '';

  # ============================================================
  # VS Code FHS 环境
  # ============================================================
  # nix-ld：允许 VS Code 运行非 Nix 编译的二进制文件
  # VS Code 的插件市场中有很多预编译的二进制文件需要它
  programs.nix-ld.enable = true;

  # ============================================================
  # Nix 设置
  # ============================================================
  # 注意：nix.settings.experimental-features 和 allowUnfree
  # 已移至 modules/default.nix（所有 host 共享）
  nix.settings = {
    # GitHub 认证：使用 SOPS 生成的 netrc 文件
    # 此文件由 modules/sops.nix 中的模板自动生成
    netrc-file = config.sops.templates."nix-netrc".path;
  };

  # ============================================================
  # 系统版本锁定
  # ============================================================
  # 不要手动修改此值！它用于确定 NixOS 的默认行为和兼容性
  # 初次安装时由 nixos-generate-config 自动生成
  system.stateVersion = "26.05";
}
