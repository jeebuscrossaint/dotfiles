{
  config,
  pkgs,
  ...
}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    profiles.default = {
      userSettings = {
        "editor.tabSize" = 8;
        "editor.insertSpaces" = true;
        "editor.detectIndentation" = true;
        "clangd.path" = "${pkgs.llvmPackages_20.clang-unwrapped}/bin/clangd";
        "git.autofetch" = true;
        "files.autoSave" = "afterDelay";
      };

      "enableUpdateCheck" = false;
      "enableExtensionUpdateCheck" = false;

      extensions = with pkgs.vscode-extensions; [
        github.copilot
        ms-python.python
        ms-python.vscode-pylance
         jnoortheen.nix-ide
        ms-vscode.hexeditor
        ms-vscode.anycode
        github.copilot-chat
      timonwong.shellcheck
          ms-vscode.cmake-tools
        ms-vscode.makefile-tools
        mechatroner.rainbow-csv
        james-yu.latex-workshop
        llvm-vs-code-extensions.vscode-clangd
        # nvidia.nsight-copilot
        # nvidia.nsight-vscode-extension
      ];
    };
  };
}
