local wezterm = require 'wezterm'
local config = wezterm.config_builder();

config.initial_cols = 120;

if string.find(wezterm.target_triple, "darwin") then
    config.initial_rows = 30;
else
    config.initial_rows = 24;
end

config.keys = {};
config.color_scheme = 'Catppuccin Mocha';

local chinese_font_fallback;

function detect_os(search_string)
    return string.find(wezterm.target_triple, search_string) ~= nil;
end

local is_linux = detect_os('linux');
local is_mac = detect_os('darwin');
local is_windows = detect_os('windows');

if is_linux then
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

    chinese_font_fallback = "Noto Sans CJK SC";
end

if is_windows then
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
    chinese_font_fallback = "Microsoft YaHei";
end

if not is_mac then
    -- Use ctrl c and ctrl v for copying and pasting on non-macs
    table.insert(config.keys, {
        key = 'c',
        mods = 'CTRL',
        action = wezterm.action_callback(function(window, pane)
            selection_text = window:get_selection_text_for_pane(pane)
            is_selection_active = string.len(selection_text) ~= 0
            if is_selection_active then
                window:perform_action(wezterm.action.CopyTo('ClipboardAndPrimarySelection'), pane)
            else
                window:perform_action(wezterm.action.SendKey{ key='c', mods='CTRL' }, pane)
            end
        end),
    });
    table.insert(config.keys, { key = 'v', mods = 'CTRL', action = wezterm.action.PasteFrom 'Clipboard' });
end

config.font = wezterm.font_with_fallback {
    'JetBrains Mono',
    chinese_font_fallback
}

-- Reduce scroll height
config.mouse_bindings = {
{
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = 'NONE',
    action = wezterm.action.ScrollByLine(-7),
},
{
    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods = 'NONE',
    action = wezterm.action.ScrollByLine(7),
},
}

return config
