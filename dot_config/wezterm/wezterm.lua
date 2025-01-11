local wezterm = require 'wezterm'
local config = wezterm.config_builder();

config.initial_cols = 120;

if string.find(wezterm.target_triple, "darwin") then
    config.initial_rows = 30;
else
    config.initial_rows = 24;
end

config.color_scheme = 'Catppuccin Mocha';

if string.find(wezterm.target_triple, 'windows') then
    config.default_prog = { 'powershell.exe' }
    config.launch_menu = {
        {
            label = "PowerShell",
            args = { "powershell.exe", "-nol" },
        },
        {
            label = "Cygwin",
            args = { "D:\\cygwin\\bin\\zsh.exe", "--login" }
        },
        {
            label = "msys2 - ucrt64",
            args = { "cmd.exe", "/k", "D:/msys2/msys2_shell.cmd -defterm -here -no-start -ucrt64 -shell zsh"}
        }
    }
    config.font = wezterm.font_with_fallback {
        'JetBrains Mono',
        'Microsoft YaHei'
    }
end

return config
