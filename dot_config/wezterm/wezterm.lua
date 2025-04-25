local wezterm = require 'wezterm'
local background_loaded, backgrounds = pcall(require, 'backgrounds')
if not background_loaded then
    backgrounds = {};
end

local config = wezterm.config_builder();

config.keys = {};
config.color_scheme = 'Catppuccin Mocha';
config.enable_scroll_bar = true;

local chinese_font_fallback;

function detect_os(search_string)
    return string.find(wezterm.target_triple, search_string) ~= nil;
end

local is_linux = detect_os('linux');
local is_mac = detect_os('darwin');
local is_windows = detect_os('windows');
local hostname = wezterm.hostname();

config.initial_cols = 120;
if is_mac then
    config.initial_rows = 30;
else
    config.initial_rows = 24;
end

config.keys = {};

function fast_tab_navigation()
    for i=1,9 do
        table.insert(config.keys, {key=tostring(i), mods="ALT", action=wezterm.action.ActivateTab(i - 1)});
    end
    table.insert(config.keys, {key='t', mods="ALT", action=wezterm.action.SpawnTab 'DefaultDomain'});
end

if not is_mac then
    fast_tab_navigation()
end

if is_linux then
    wezterm.on("setup-panes", function(window, pane)
        local top_pane = pane:split{ direction = 'Top'};
        local bottom_left_pane = pane:split{ direction = 'Left', size = 0.6 };
        local top_right_pane = top_pane:split{ direcion = 'Right', size = 0.3 };
      
        -- Run commands in each pane
        window:perform_action(wezterm.action.SendString("dstat -cmd\n"), top_right_pane)
        window:perform_action(wezterm.action.SendString("htop\n"), top_pane)
        -- window:perform_action(wezterm.action.SendString("ls\n"), bottom_left_pane)
        window:perform_action(wezterm.action.SendString("musicfox\n"), pane)
    end)
    
    table.insert(config.keys, {key="S", mods="CTRL|SHIFT", action=wezterm.action.EmitEvent("setup-panes")});
    
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
        },
        {
            label = "wsl",
            args = { "powershell.exe", "wsl" }
        }
    }
    chinese_font_fallback = "Microsoft YaHei";
end

if is_mac then
    config.font_size = 15 
    table.insert(config.keys,{key="LeftArrow", mods="OPT", action=wezterm.action.SendString("\x1bb")});
    table.insert(config.keys,{key="RightArrow", mods="OPT", action=wezterm.action.SendString("\x1bf")});

    chinese_font_fallback = "Noto Sans SC";
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
                window:perform_action(wezterm.action.CopyTo('ClipboardAndPrimarySelection'), pane);
                window:perform_action(wezterm.action.ClearSelection, pane);
            else
                window:perform_action(wezterm.action.SendKey{ key='c', mods='CTRL' }, pane);
            end
        end),
    });
    table.insert(config.keys, { key = 'v', mods = 'CTRL', action = wezterm.action.PasteFrom 'Clipboard' });
end

if hostname == "tamako" then
    config.default_prog = "/usr/bin/fish";
end

config.font = wezterm.font_with_fallback {
    'JetBrains Mono',
    chinese_font_fallback
}

config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

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

-- random background
local bg_index = 0;
function random_background(index)
    if index == nil then
        index = math.random(1, #backgrounds);
        bg_index = index;
    end
    return {
        source = {
            File = backgrounds[index]
        },
        height = "Cover",
        vertical_align = "Middle",
        horizontal_align = "Center",
        hsb = {
            brightness = 0.05
        }
    };
end

if backgrounds and #backgrounds > 0 then
    local background = random_background();
    config.background = {background};
end

table.insert(config.keys, { key = 'b', mods = 'CTRL|SHIFT', action = wezterm.action_callback(function(window, pane)
    bg_index = bg_index + 1;
    if bg_index > #backgrounds then
        bg_index = 1;
    end
    local background = random_background(bg_index);
    window:set_config_overrides {
        background = {background};
    };
end) });

table.insert(config.keys, { key = 'g', mods = 'CTRL|SHIFT', action = wezterm.action_callback(function(window, pane)
    local background = random_background();
    window:set_config_overrides {
        background = {background};
    };
end) });

table.insert(config.keys, { key = 'h', mods = 'CTRL|SHIFT', action = wezterm.action_callback(function(window, pane)
    local overrides = window:get_config_overrides() or {};
    if overrides.background and #overrides.background == 0 then
        if overrides.color_scheme then
            overrides.color_scheme = nil;
            overrides.background = nil;
        else
            overrides.color_scheme = "";
        end
    else
        overrides.background = {};
    end
    window:set_config_overrides (overrides);
end)});

return config
