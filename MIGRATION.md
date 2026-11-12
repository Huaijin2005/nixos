# NixOS 迁移进度文档

## 概述

从 CachyOS dotfiles 迁移到 NixOS，基于现有 `home/huaijin` 和 `host/nixos-vm` 配置进行模块化扩展。

- **目标环境**：QEMU/KVM 虚拟机
- **桌面环境**：niri + DMS (Dank Material Shell)
- **迁移日期**：2026-07-07

## 目录结构变化

```
修改前：
home/huaijin/
└── default.nix              (21 行)

修改后：
home/huaijin/
├── default.nix              (重写，约 80 行)
├── config/
│   ├── niri.nix             (新增，约 230 行)
│   ├── neovim.nix           (新增，约 20 行)
│   ├── fcitx5.nix           (新增，约 45 行)
│   └── gtk.nix              (新增，约 70 行)
└── modules/
    ├── dms.nix              (新增，约 160 行)
    ├── shell.nix            (新增，约 180 行)
    ├── terminal.nix         (新增，约 140 行)
    ├── fonts.nix            (新增，约 55 行)
    └── tools.nix            (新增，约 60 行)
```

## 完成状态

### ✅ Phase 1: 系统级配置 (已完成)

| 文件 | 状态 | 说明 |
|------|------|------|
| `flake.nix` | ✅ | 添加 DMS input (`github:AvengeMedia/DankMaterialShell/stable`) |
| `modules/default.nix` | ✅ | 提取共享 NixOS 配置 (nix flakes + allowUnfree) |
| `modules/sops.nix` | ✅ | 新增 deepseek_api_key, hf_token, mineru_api_key + private-zsh 模板 |
| `hosts/nixos-vm/configuration.nix` | ✅ | 新增 niri/pipewire/fcitx5/fonts/xdg-portal 等系统级配置 |

### ✅ Phase 2: Home Manager 子模块 (已完成)

| 文件 | 状态 | 说明 |
|------|------|------|
| `home/huaijin/modules/dms.nix` | ✅ | DMS 安装 (systemd 启动) + 主题/动画/剪贴板设置 |
| `home/huaijin/modules/shell.nix` | ✅ | Zsh(Zim) + Fish + Tmux + Starship + 代理(注释) |
| `home/huaijin/modules/terminal.nix` | ✅ | Kitty (nix 化) + Ghostty/WezTerm (直接文件管理) |
| `home/huaijin/modules/fonts.nix` | ✅ | 字体包 + fontconfig 首选顺序 (FiraCode NF 替代 CodeNewRoman) |
| `home/huaijin/modules/tools.nix` | ✅ | yazi/lazygit/fastfetch/eza/zoxide + conda/fnm(注释) |

### ✅ Phase 3: 复杂配置链接 (已完成)

| 文件 | 状态 | 说明 |
|------|------|------|
| `home/huaijin/config/niri.nix` | ✅ | niri hm.kdl + config.kdl wrapper + dms/* 初始文件 |
| `home/huaijin/config/neovim.nix` | ✅ | neovim + LazyVim 配置目录链接 |
| `home/huaijin/config/fcitx5.nix` | ✅ | Rime 自定义 YAML + Catppuccin 主题 |
| `home/huaijin/config/gtk.nix` | ✅ | Tokyonight GTK 主题 + Catppuccin 光标 + GTK 设置 |

### ✅ Phase 4: 入口文件更新 (已完成)

| 文件 | 状态 | 说明 |
|------|------|------|
| `home/huaijin/default.nix` | ✅ | 导入所有新增子模块和配置链接 |

### ✅ Phase 5: 验证 (已完成)

| 任务 | 状态 | 说明 |
|------|------|------|
| 更新 `flake.lock` | ✅ | 已执行 `nix flake lock --update-input dms` |
| `nixos-rebuild dry-build` | ✅ | 构建验证通过 (0 errors, 2 deprecation warnings) |
| 构建包数量 | — | 251 个 derivations 需要构建, 466 路径从缓存获取 |

---

## 注意事项 / 待办项

### 🔴 部署前必做

1. **DMS 首次启动**：首次登录后运行 `dms setup` 来生成/更新 `dms/*.kdl` 文件
2. **SOPS 密钥更新**：`secrets/secrets.yaml` 需要重新加密，添加 deepseek_api_key/hf_token/mineru_api_key
3. **private-zsh 模板**：SOPS 模板输出到 `/run/secrets/private-zsh`，由 shell.nix 自动 source；需要将 .sops.yaml 中的对应 age 密钥配置好

### 🟡 已知问题

1. **DMS niri 模块未使用**：`inputs.dms.homeModules.niri` 依赖 `niri-flake` 的 `config.lib.niri.actions`，我们使用 nixpkgs 的 `programs.niri`，因此手动管理 niri 的 config includes
2. **deprecation 警告**：`programs.zsh.initExtraBeforeCompInit` 和 `initExtra` 在 home-manager 2.0 中已废弃，应使用 `initContent` + `mkOrder` (非阻塞)
3. **conda/fnm**：nixpkgs 中的 conda 路径与 dotfiles setup.zsh 中的路径不同，暂时注释掉，由 setup.zsh 手动管理

### 🟢 已知限制

1. **VM 中 blur 不可用**：niri 的 blur 需要 GPU 加速，VM 中可设 `WLR_RENDERER=pixman` 使用软件渲染
2. **Tela-circle-Dark 图标**：nixpkgs 中无此图标主题，GTK 设置中指向了它但实际使用系统默认图标
3. **FiraMono Nerd Font**：nixpkgs 中只有 `nerd-fonts.fira-code`，无单独的 FiraMono Nerd Font
4. **lxgw-wenkai-mono**：nixpkgs 中无此包，使用 lxgw-wenkai-screen 替代

---

## 文件清单（代码行数）

| 文件 | 行数 | 类型 |
|------|------|------|
| `flake.nix` | ~62 | 修改 |
| `modules/default.nix` | ~35 | 修改 |
| `modules/sops.nix` | ~97 | 修改 |
| `hosts/nixos-vm/configuration.nix` | ~226 | 修改 |
| `home/huaijin/default.nix` | ~80 | 修改 |
| `home/huaijin/modules/dms.nix` | ~160 | 新增 |
| `home/huaijin/modules/shell.nix` | ~180 | 新增 |
| `home/huaijin/modules/terminal.nix` | ~140 | 新增 |
| `home/huaijin/modules/fonts.nix` | ~55 | 新增 |
| `home/huaijin/modules/tools.nix` | ~60 | 新增 |
| `home/huaijin/config/niri.nix` | ~230 | 新增 |
| `home/huaijin/config/neovim.nix` | ~20 | 新增 |
| `home/huaijin/config/fcitx5.nix` | ~45 | 新增 |
| `home/huaijin/config/gtk.nix` | ~70 | 新增 |
| **总计** | **~1460** | **15 文件** |
