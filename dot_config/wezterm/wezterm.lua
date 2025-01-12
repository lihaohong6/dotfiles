local wezterm = require 'wezterm'
local config = wezterm.config_builder();

config.initial_cols = 120;

if string.find(wezterm.target_triple, "darwin") then
    config.initial_rows = 30;
else
    config.initial_rows = 24;
end

config.color_scheme = 'Catppuccin Mocha';

if string.find(wezterm.target_triple, 'linux') then
    wezterm.on("setup-panes", function(window, pane)
        local top_pane = pane:split{ direction = 'Top'};
        local bottom_left_pane = pane:split{ direction = 'Left'};
        local top_right_pane = top_pane:split{ direcion = 'Right'};
      
        -- Run commands in each pane
        window:perform_action(wezterm.action.SendString("dstat -pcmrd\n"), top_right_pane)
        window:perform_action(wezterm.action.SendString("htop\n"), top_pane)
        -- window:perform_action(wezterm.action.SendString("ls\n"), bottom_left_pane)
        window:perform_action(wezterm.action.SendString("musicfox\n"), pane)
    end)

    config.keys = {
        {key="S", mods="CTRL|SHIFT", action=wezterm.action.EmitEvent("setup-panes")},
    }
end

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
