local wezterm = require 'wezterm'
local config = wezterm.config_builder();
config.initial_cols = 120;
config.initial_rows = 30;
config.color_scheme = "Catppuccin Mocha";
return config
