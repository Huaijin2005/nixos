{
  description = "NixOS Flake Configuration";

  inputs = {
    # NixOS 官方软件包仓库，使用 unstable 分支获取最新软件包
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager：声明式管理用户 home 目录配置
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # 与 nixpkgs 共享同一个版本，避免重复下载
    };

    # SOPS-Nix：加密敏感信息（API keys、密码等）的管理工具
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # DMS (Dank Material Shell)：Wayland 桌面面板/启动器/通知中心
    # 通过 home-manager 模块安装到用户级别
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      sops-nix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.nixos-vm = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/nixos-vm
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup"; # ← 自动备份同名文件到 .hm-backup
              # 让 DMS 的 home-manager 模块对所有用户可用
              # sharedModules 中的模块会与每个用户的 home-manager 配置自动合并
              sharedModules = [
                # DMS (Dank Material Shell) home-manager 模块
                # 提供 programs.dank-material-shell.* 配置选项
                inputs.dms.homeModules.dank-material-shell
                # 注意：不导入 inputs.dms.homeModules.niri
                # 该模块依赖 niri-flake 的 config.lib.niri.actions，
                # 我们使用 nixpkgs 的 programs.niri，不需要 niri-flake。
                # niri 的 config include 由我们手动管理
                # （在 config/niri.nix 中生成 config.kdl wrapper）
              ];
              users.huaijin = import ./home/huaijin;
            };
          }
        ];
      };
    };
}
