from .window_management import (
    collect_all_windows,
    rofi_choose_between,
    rofi_choose_between_dict_by_value,
    rofi_choose_between_dict,
)

window_management = {
    collect_all_windows,
    rofi_choose_between,
    rofi_choose_between_dict,
    rofi_choose_between_dict_by_value,
}

__all__ = ["window_management"]
