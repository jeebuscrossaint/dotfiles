{
  config,
  pkgs,
  ...
}:

{
	programs.vscode = {
		enable = true;
		package = pkgs.code-cursor;
		
		profiles.default = {
			userSettings = {
				"editor.tabSize" = 8;
				"editor.insertSpaces" = true;
				"editor.detectIndentation" = true;
			};
			
			"enableUpdateCheck" = false;
			"enableExtensionUpdateCheck" = false;
			
			extensions = with pkgs.vscode-extensions; [
				github.copilot
				ms-python.python
				ms-vscode.cpptools
				jnoortheen.nix-ide
				ms-vscode.hexeditor
				github.copilot-chat
				tamasfe.even-better-toml
				timonwong.shellcheck
				ms-vscode.powershell
				ms-vscode.cmake-tools
				bmalehorn.vscode-fish
				rust-lang.rust-analyzer
				ms-vscode.makefile-tools
				mechatroner.rainbow-csv
				james-yu.latex-workshop
				ms-vscode-remote.vscode-remote-extensionpack
				llvm-vs-code-extensions.vscode-clangd
			];
		};
	};
}
