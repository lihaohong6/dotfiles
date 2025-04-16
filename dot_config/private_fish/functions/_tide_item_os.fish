function _tide_item_os
    _tide_detect_os | read -g --line tide_os_icon tide_os_color tide_os_bg_color
    _tide_print_item os $tide_os_icon
end
