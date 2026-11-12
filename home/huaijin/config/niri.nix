{ config, pkgs, ... }:

{
  # ------------------------------------------------------------
  # Niri 主配置文件 (home/huaijin/config/niri.nix)
  # ------------------------------------------------------------
  # 生成两个文件：
  #   1. config.kdl — niri 入口配置，include 其他子文件
  #   2. hm.kdl     — niri 主配置内容（动画、窗口规则、输入等）
  #
  # DMS 的 niri 模块没有导入（它依赖 niri-flake），
  # 所以我们手动管理 config includes 结构。
  #
  # 原 DMS niri 模块会自动做 include 管理，现在我们手动模拟：
  #   config.kdl  ──include──> hm.kdl          (我们的主配置)
  #               ──include──> dms/colors.kdl  (DMS 颜色)
  #               ──include──> dms/layout.kdl  (DMS 布局)
  #               ──include──> dms/binds.kdl   (DMS 快捷键)
  #               ... 等
  # ------------------------------------------------------------

  xdg.configFile."niri/hm.kdl".text = ''
    # ------------------------------------------------------------
    # Niri 主配置 - 由 home-manager 生成
    # 来源：home/huaijin/config/niri.nix
    # 快捷键、颜色、布局、输出等 DMS 管理的设置在 dms/*.kdl
    # ------------------------------------------------------------

    # 禁用失败通知（避免反复弹出配置错误提示）
    config-notification {
        disable-failed
    }

    # ----------------------------------------------------------
    # 显示器配置
    # 注意：VM 中 DMS 会通过 dms/outputs.kdl 自动配置显示器
    # 以下为原笔记本配置（在 VM 中运行时此设置可能无效）
    # ----------------------------------------------------------
    /-output "eDP-1" {
        mode "1920x1080@120.030"
        scale 2
        transform "normal"
        position x=1280 y=0
    }

    # 禁用热角触发
    gestures {
        hot-corners {
            off
        }
    }

    # ----------------------------------------------------------
    # 输入设备配置
    # ----------------------------------------------------------
    input {
        keyboard {
            xkb {}
            repeat-delay 200    # 按下后 200ms 开始重复
            repeat-rate 40      # 每秒重复 40 次
            numlock             # 开机自动开启数字锁定
        }

        touchpad {
            tap                 # 点击即点击
            natural-scroll      # 自然滚动（Mac 风格）
        }

        mouse {}
        trackpoint {}

        # 鼠标跟随焦点：鼠标移到窗口上自动聚焦
        # max-scroll-amount="1%" 避免非整数缩放导致的无法切换聚焦
        focus-follows-mouse max-scroll-amount="1%"
    }

    # ----------------------------------------------------------
    # 布局配置
    # ----------------------------------------------------------
    layout {
        background-color "transparent"
        center-focused-column "never"       # 不居中当前列
        preset-column-widths {
            proportion 0.2
            proportion 0.33333
            proportion 0.4
            proportion 0.5
            proportion 0.6
            proportion 0.66667
            proportion 0.8
        }
        default-column-width { proportion 0.5; }
        border {
            off
            width 4
            active-color   "#707070"        # 中性灰（活动窗口）
            inactive-color "#d0d0d0"        # 浅灰（非活动窗口）
            urgent-color   "#cc4444"        # 柔和红色（紧急窗口）
        }
        shadow {
            softness 30
            spread 5
            offset x=0 y=5
            color "#0007"
        }
        struts {}
    }

    # Quickshell (DMS) 层级规则：允许 DMS 面板在背景中显示
    layer-rule {
        match namespace="^quickshell$"
        place-within-backdrop true
    }

    # 总览模式：不显示工作区阴影
    overview {
        workspace-shadow {
            off
        }
    }

    # 环境变量：告知应用当前桌面环境是 niri
    environment {
      XDG_CURRENT_DESKTOP "niri"
    }

    # 启动时跳过快捷键覆盖层显示
    hotkey-overlay {
        skip-at-startup
    }

    # 优先使用客户端自带装饰（CSD）而非服务端装饰
    prefer-no-csd

    # 截图保存路径
    screenshot-path "~/Pictures/Screenshots/Screenshot-%Y-%m-%d %H-%M-%S.png"

    # ----------------------------------------------------------
    # 动画配置（弹簧物理模拟）
    # ----------------------------------------------------------
    animations {
        # 工作区切换：快速回弹
        workspace-switch {
            spring damping-ratio=0.80 stiffness=523 epsilon=0.0001
        }
        # 窗口打开：指数渐出
        window-open {
            duration-ms 150
            curve "ease-out-expo"
        }
        # 窗口关闭：二次渐出
        window-close {
            duration-ms 150
            curve "ease-out-quad"
        }
        # 水平视图移动
        horizontal-view-movement {
            spring damping-ratio=0.85 stiffness=423 epsilon=0.0001
        }
        # 窗口移动
        window-movement {
            spring damping-ratio=0.75 stiffness=323 epsilon=0.0001
        }
        # 窗口大小调整
        window-resize {
            spring damping-ratio=0.85 stiffness=423 epsilon=0.0001
        }
        # 配置通知打开/关闭
        config-notification-open-close {
            spring damping-ratio=0.65 stiffness=923 epsilon=0.001
        }
        # 截图 UI 打开
        screenshot-ui-open {
            duration-ms 200
            curve "ease-out-quad"
        }
        # 总览模式打开/关闭
        overview-open-close {
            spring damping-ratio=0.85 stiffness=800 epsilon=0.0001
        }
    }

    # ----------------------------------------------------------
    # 背景模糊
    # ----------------------------------------------------------
    blur {
        passes 2            # 模糊迭代次数（越多越丝滑，越吃 GPU）
        offset 5.0          # 采样偏移乘数（越大模糊半径越大）
        noise 0.05          # 噪点覆盖（防止色带，增加毛玻璃质感）
        saturation 1.5      # 色彩饱和度（让模糊背景更鲜艳）
    }

    # ----------------------------------------------------------
    # 窗口规则
    # ----------------------------------------------------------
    # 默认窗口：模糊背景 + 95% 不透明度
    window-rule{
        background-effect {
            blur true
            xray false
        }
        opacity 0.95
    }

    # 特定应用：启用背景模糊 + 90% 不透明度
    window-rule {
        match app-id=r#"^com\.gitee\.gmg137\.NeteaseCloudMusicGtk4$"#
        match app-id=r#"^org\.wezfurlong\.wezterm$"#
        match app-id=r#"^kitty$"#
        match app-id=r#"^com\.mitchellh\.ghostty$"#
        background-effect {
            blur true
        }
        opacity 0.9
    }

    # WezTerm 初始 configure bug 临时修复
    window-rule {
        match app-id=r#"^org\.wezfurlong\.wezterm$"#
        default-column-width {}
    }

    # 终端窗口默认列宽
    window-rule {
        match app-id=r#"^kitty$"#
        match app-id=r#"^com\.mitchellh\.ghostty$"#
        default-column-width { proportion 0.4; }
    }

    # GNOME 应用：圆角裁剪
    window-rule {
        match app-id=r#"^org\.gnome\."#
        draw-border-with-background false
        geometry-corner-radius 12
        clip-to-geometry true
    }

    # 系统设置窗口：平铺显示
    window-rule {
        match app-id=r#"^gnome-control-center$"#
        match app-id=r#"^pavucontrol$"#
        match app-id=r#"^nm-connection-editor$"#
        default-column-width { proportion 0.5; }
        open-floating false
    }

    # 小型工具：悬浮显示
    window-rule {
        match app-id=r#"^gnome-calculator$"#
        match app-id=r#"^galculator$"#
        match app-id=r#"^blueman-manager$"#
        match app-id=r#"^org\.gnome\.Nautilus$"#
        match app-id=r#"^xdg-desktop-portal$"#
        open-floating true
    }

    # Steam 通知：右下角悬浮
    window-rule {
        match app-id=r#"^steam$"# title=r#"^notificationtoasts_\d+_desktop$"#
        default-floating-position x=10 y=10 relative-to="bottom-right"
        open-focused false
    }

    # 终端和应用：不绘制背景边框
    window-rule {
        match app-id=r#"^org\.wezfurlong\.wezterm$"#
        match app-id="Alacritty"
        match app-id="zen"
        match app-id="com.mitchellh.ghostty"
        match app-id="kitty"
        draw-border-with-background false
    }

    # 画中画/视频会议：悬浮显示
    window-rule {
        match app-id=r#"firefox$"# title="^Picture-in-Picture$"
        match app-id="zoom"
        open-floating true
    }

    # 即时通讯：悬浮显示
    window-rule{
        match app-id="QQ"
        match app-id="wechat"
        match title="微信"
        open-floating true
    }

    # DMS 窗口：默认悬浮
    window-rule {
        match app-id=r#"org.quickshell$"#
        open-floating true
    }

    # XDG Activation 调试选项
    debug {
        honor-xdg-activation-with-invalid-serial
    }

    # ----------------------------------------------------------
    # 最近窗口切换器（Alt+Tab）
    # 重写配置来禁用 Super+Tab（避免与 niri 总览快捷键冲突）
    # ----------------------------------------------------------
    recent-windows {
        binds {
            Alt+Tab         { next-window scope="output"; }
            Alt+Shift+Tab   { previous-window scope="output"; }
            Alt+grave       { next-window filter="app-id"; }
            Alt+Shift+grave { previous-window filter="app-id"; }
        }
    }
  '';

  # ------------------------------------------------------------
  # Niri 入口配置文件 (~/.config/niri/config.kdl)
  # ------------------------------------------------------------
  # 这是 niri 实际读取的文件。它 include 所有子配置文件：
  #   - hm.kdl：我们的主配置（动画、窗口规则、输入等）
  #   - dms/*.kdl：DMS 生成的子配置（颜色、快捷键、布局等）
  #
  # DMS 首次启动时会通过 dms setup 生成 dms/*.kdl 文件。
  # 在此之前，从 dotfiles 中复制一份初始化版本
  # （见下方 xdg.configFile."niri/dms" 链接）
  xdg.configFile."niri/config.kdl".text = ''
    # ------------------------------------------------------------
    # Niri 入口配置 - 由 home-manager 生成
    # 来源 home/huaijin/config/niri.nix
    # ------------------------------------------------------------
    # 此文件 include 所有子配置。
    # 如果你修改了 hm.kdl 以外的 niri 配置，
    # 请运行 nixos-rebuild switch 来更新此文件。
    # ------------------------------------------------------------

    # 主配置（动画、窗口规则、输入设备、模糊等）
    include "hm.kdl"

    # DMS 生成的子配置（由 dms setup 命令生成/更新）
    # 如果这些文件不存在，niri 会报错。运行 dms setup 来生成它们。
    include "dms/alttab.kdl"
    include "dms/binds.kdl"
    include "dms/colors.kdl"
    include "dms/layout.kdl"
    include "dms/outputs.kdl"
    include "dms/wpblur.kdl"
    include "dms/cursor.kdl"
    include "dms/windowrules.kdl"
  '';

  # ------------------------------------------------------------
  # DMS 初始 dms/*.kdl 文件
  # ------------------------------------------------------------
  # ponytail: 从 dotfiles 复制一份 dms/*.kdl 作为初始版本。
  # DMS 首次运行 dms setup 后会覆盖这些文件。
  # 这样做的好处是 niri 在首次启动时不会因为找不到 include 文件而报错。
  xdg.configFile."niri/dms".source =
    config.lib.file.mkOutOfStoreSymlink /home/huaijin/dotfiles/niri-dms/.config/niri/dms;
}
