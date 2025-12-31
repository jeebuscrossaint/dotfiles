{
  config,
  pkgs,
  inputs,  # Make sure your flake passes inputs
  ...
}: 
let
  # Access the marketplace extensions
  marketplace = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;
in
{
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
        "leetcode.workspaceFolder" = "/home/amarnath/.leetcode";
        "leetcode.hint.configWebviewMarkdown" = false;
        "leetcode.defaultLanguage" = "cpp";
        "github.copilot.nextEditSuggestions.enabled" = false;
        "github.copilot.enable.*" = false;
        "github.copilot.enable.plaintext" = false;
        "github.copilot.enable.markdown" = false;
        "github.copilot.enable.scminput" = false;
      };
      "enableUpdateCheck" = false;
      "enableExtensionUpdateCheck" = false;
      extensions = with pkgs.vscode-extensions; [
        github.copilot
        github.copilot-chat
        ms-python.python
        ms-python.vscode-pylance
        jnoortheen.nix-ide
        ms-vscode.cmake-tools
        ms-vscode.makefile-tools
        llvm-vs-code-extensions.vscode-clangd  
       # Additional extensions from nixpkgs
        vadimcn.vscode-lldb  # codelldb
      ] ++ [
        # Extensions from marketplace (not in nixpkgs)
        marketplace.christian-kohler.path-intellisense
        marketplace.ms-python.debugpy  # python debugger
        marketplace.donjayamanne.python-environment-manager  # python env
        marketplace.leetcode.vscode-leetcode
        marketplace.tomoki1207.pdf  # vscode-pdf
        marketplace.myriad-dreamin.tinymist  # tinymist typst
        # marketplace.ocamllabs.ocaml-platform
        marketplace.codezombiech.gitignore  # gitignore
        marketplace.tboox.xmake-vscode
        marketplace.guyutongxue.cpp-reference
        marketplace.tchojnacki.cpp-compile
        marketplace.mkhl.direnv
      ];
    };
  };
}
