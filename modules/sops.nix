{ config, ... }:

{
  # ============================================================
  # SOPS 密钥管理 (modules/sops.nix)
  # ============================================================
  # SOPS (Secrets OPerationS) 使用 age 加密存储敏感信息。
  # 当前配置了两种解密方式：
  #   1. SSH Host Key — 机器重启后自动解密（无需手动输入密码）
  #   2. 用户 age 密钥 — 手动 sops updatekeys 时使用
  # 加密规则定义在项目根目录的 .sops.yaml 中。
  # ============================================================

  sops = {
    # 默认的加密文件路径（相对于此模块文件的位置）
    # ponytail: 相对路径基于模块文件位置，不是项目根目录
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml"; # 使用 YAML 格式存储，方便编辑

    # 用于解密的 age 密钥路径
    # SSH host key 在首次启动 nixos-generate-config 时自动生成
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = {
      # ----------------------------------------------------------
      # GitHub Token
      # 用于 nix flake update 和 nix build 时认证 GitHub API
      # 在 GitHub Settings > Developer settings > Personal access tokens 生成
      # 只需要 read:public_repo 权限
      # ----------------------------------------------------------
      github_token = { };

      # ----------------------------------------------------------
      # DeepSeek API Key
      # 用于 Codex CLI / AI 编程工具
      # 在 platform.deepseek.com 获取
      # ----------------------------------------------------------
      deepseek_api_key = { };

      # # ----------------------------------------------------------
      # # HuggingFace Token
      # # 用于下载 HuggingFace 模型和数据集
      # # 在 huggingface.co/settings/tokens 生成（需要 READ 权限）
      # # ----------------------------------------------------------
      # hf_token = { };

      # # ----------------------------------------------------------
      # # MinerU API Key
      # # 用于 MinerU PDF 解析服务
      # # 在 mineru.net 获取
      # # ----------------------------------------------------------
      # mineru_api_key = { };
    };

    # ============================================================
    # 模板：将机密信息渲染为文件
    # ============================================================

    # nix-netrc 模板：为 root 和 wheel 组生成 GitHub 认证文件
    # 用途：
    #   - nix-daemon 拉取私有 flake 时使用（root）
    #   - nix flake update 时使用（wheel 组成员，如 huaijin）
    # 在 configuration.nix 中通过 nix.settings.netrc-file 引用
    templates."nix-netrc" = {
      content = ''
        machine github.com
          login oauth2
          password ${config.sops.placeholder.github_token}
        machine api.github.com
          login oauth2
          password ${config.sops.placeholder.github_token}
      '';
      owner = "root"; # nix-daemon rebuild 系统时使用
      group = "wheel"; # nix flake update 时需要
      mode = "0640"; # root 可写, wheel 组可读
    };

    # private.zsh 模板：生成 shell 环境变量文件
    # 包含各种 API key，在 zshrc 中通过 source 加载
    # ponytail: 写入 /etc 而非 ~/.zsh/ 是因为 sops-nix NixOS 模块
    # 无法直接写入用户 home 目录（权限问题）
    templates."private-zsh" = {
      content = ''
        # ============================================================
        # 私有环境变量（由 SOPS 自动生成，请勿手动编辑）
        # 来源：modules/sops.nix > sops.templates."private-zsh"
        # ============================================================
        export DEEPSEEK_API_KEY="${config.sops.placeholder.deepseek_api_key}"
      '';
      # export HF_TOKEN="${config.sops.placeholder.hf_token}"
      # export MINERU_API_KEY="${config.sops.placeholder.mineru_api_key}"
      owner = "root";
      group = "wheel";
      mode = "0640"; # 仅 wheel 组成员（如 huaijin）可读
    };
  };
}
