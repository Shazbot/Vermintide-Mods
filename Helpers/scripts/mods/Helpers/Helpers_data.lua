local mod = get_mod("Helpers")

local mod_data = {
	name = "Helpers Collection",
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true,
}

mod.SETTING_NAMES = {}
for _, setting_name in ipairs( {
	"ULT_RESET_HOTKEY",
	"KILL_BOTS_HOTKEY",
	"PAUSE_HOTKEY",
	"RESTART_LEVEL_HOTKEY",
	"WIN_LEVEL_HOTKEY",
	"FAIL_LEVEL_HOTKEY",
} ) do
	mod.SETTING_NAMES[setting_name] = setting_name
end

mod_data.options = {
	widgets = {
		{
		  setting_id = mod.SETTING_NAMES.ULT_RESET_HOTKEY,
		  type = "keybind",
		  keybind_trigger = "pressed",
		  keybind_type = "function_call",
		  function_name = "reset_ult",
		  default_value = {},
		},
		{
		  setting_id = mod.SETTING_NAMES.KILL_BOTS_HOTKEY,
		  type = "keybind",
		  keybind_trigger = "pressed",
		  keybind_type = "function_call",
		  function_name = "kill_bots",
		  default_value = {},
		},
		{
		  setting_id = mod.SETTING_NAMES.PAUSE_HOTKEY,
		  type = "keybind",
		  keybind_trigger = "pressed",
		  keybind_type = "function_call",
		  function_name = "do_pause",
		  default_value = {},
		},
		{
		  setting_id = mod.SETTING_NAMES.RESTART_LEVEL_HOTKEY,
		  type = "keybind",
		  keybind_trigger = "pressed",
		  keybind_type = "function_call",
		  function_name = "restart_level",
		  default_value = {},
		},
		{
		  setting_id = mod.SETTING_NAMES.WIN_LEVEL_HOTKEY,
		  type = "keybind",
		  keybind_trigger = "pressed",
		  keybind_type = "function_call",
		  function_name = "win_level",
		  default_value = {},
		},
		{
		  setting_id = mod.SETTING_NAMES.FAIL_LEVEL_HOTKEY,
		  type = "keybind",
		  keybind_trigger = "pressed",
		  keybind_type = "function_call",
		  function_name = "fail_level",
		  default_value = {},
		},
	},
}

return mod_data