{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  nixConfig = {
    extra-trusted-public-keys = [
      "nixpkgs-terraform.cachix.org-1:8Sit092rIdAVENA3ZVeH9hzSiqI/jng6JiCrQ1Dmusw="
      "pepo.cachix.org-1:8sELuSHMV0vqHtuvnzKh3DCzb/+u+PtCY4Gl6V2blCg="
    ];
    extra-substituters = [
      "https://devenv.cachix.org"
      "https://nixpkgs-terraform.cachix.org"
      "https://pepo.cachix.org"
    ];
  };

  outputs =
    inputs@{
      self,
      flake-utils,
      nixpkgs,
    }:

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        # NOTE: nix-prefetch-url --type sha256 --unpack https://github.com/erlang/otp/archive/refs/tags/OTP-${VERSION}.zip
        # NOTE: nix-prefetch-url --type sha256 --unpack https://github.com/elixir-lang/elixir/archive/refs/tags/v${VERSION}.zip
        overlays = (
          self: super: {
            erlang = super.beam.interpreters.erlang_27.override {
              version = "27.0.1";
              sha256 = "YZWBLcpkm8B4sjoQO7I9ywXcmxXL+Dvq/JYsLsr7TO1=";
            };

            elixir = (super.beam.packagesWith (self.erlang)).elixir.override ({
              version = "1.17.2";
              sha256 = "8rb2f4CvJzio3QgoxvCv1iz8HooXze0tWUJ4Sc13dxg=";
            });

          }
        );
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlays ];
        };

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.elixir
            pkgs.erlang
          ];

          shellHook =
            let
              escript = ''
                Filepath = filename:join([
                  code:root_dir(),
                  "releases",
                  erlang:system_info(otp_release),
                  "OTP_VERSION"
                ]),
                {ok, Version} = file:read_file(Filepath),
                io:fwrite(Version),
                halt().
              '';
            in
            ''
              echo "🍎 Erlang OTP-$(erl -eval '${escript}' -noshell)"
              echo "💧 elixir-vsn: $(elixir --version | tail -n 1)"
            '';
        };
      }
    );
}