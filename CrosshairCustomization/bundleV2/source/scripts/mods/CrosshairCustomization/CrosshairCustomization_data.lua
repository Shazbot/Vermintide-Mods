local mod = get_mod("CrosshairCustomization") -- luacheck: ignore get_mod

--- Enums ---
mod.COLOR_INDEX = {
    DEFAULT = 1,
    RED = 2,
    GREEN = 3,
    CUSTOM = 4
}

mod.COLORS = {
	[mod.COLOR_INDEX.DEFAULT] = {255, 255, 255, 255},
	[mod.COLOR_INDEX.RED] = {255, 255, 0, 0},
	[mod.COLOR_INDEX.GREEN] = {255, 0, 255, 0},
	DEFAULT = {255, 255, 255, 255},
	RED = {255, 255, 0, 0},
	GREEN = {255, 0, 255, 0},
}

mod.SETTING_NAMES = {
    COLOR = "color",
    ENLARGE = "enlarge",
    DOT = "dot",
    DOT_TOGGLE_HOTKEY = "dot_toggle_hotkey",
    NO_MELEE_DOT = "no_melee_dot",
    CUSTOM_RED = "custom_red",
    CUSTOM_GREEN = "custom_green",
    CUSTOM_BLUE = "custom_blue",
    NO_RANGE_MARKERS = "no_range_markers",
    NO_LINE_MARKERS = "no_line_markers"
}
---! Enums ---

local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
}
mod_data.options_widgets = {
   {
		["setting_name"] = mod.SETTING_NAMES.COLOR,
		["widget_type"] = "dropdown",
		["text"] = mod:localize("color"),
		["tooltip"] = mod:localize("color_tooltip"),
		["options"] = {
				{text = mod:localize("default"), value = mod.COLOR_INDEX.DEFAULT},
				{text = mod:localize("red"), value = mod.COLOR_INDEX.RED},
				{text = mod:localize("green"), value = mod.COLOR_INDEX.GREEN},
				{text = mod:localize("custom"), value = mod.COLOR_INDEX.CUSTOM},
	    },
		["default_value"] = mod.COLOR_INDEX.DEFAULT,
		["sub_widgets"] = {
		    {
				["show_widget_condition"] = { mod.COLOR_INDEX.CUSTOM },
				["setting_name"] = mod.SETTING_NAMES.CUSTOM_RED,
				["widget_type"] = "numeric",
				["text"] = mod:localize("red"),
				["tooltip"] = mod:localize("custom_red_tooltip"),
				["range"] = {0, 255},
				["default_value"] = 255,
			},
			{
				["show_widget_condition"] = { mod.COLOR_INDEX.CUSTOM },
				["setting_name"] = mod.SETTING_NAMES.CUSTOM_GREEN,
				["widget_type"] = "numeric",
				["text"] = mod:localize("green"),
				["tooltip"] = mod:localize("custom_green_tooltip"),
				["range"] = {0, 255},
				["default_value"] = 255,
			},
			{
				["show_widget_condition"] = { mod.COLOR_INDEX.CUSTOM },
				["setting_name"] = mod.SETTING_NAMES.CUSTOM_BLUE,
				["widget_type"] = "numeric",
				["text"] = mod:localize("blue"),
				["tooltip"] = mod:localize("custom_blue_tooltip"),
				["range"] = {0, 255},
				["default_value"] = 255,
			},
		},
	},
	{
		["setting_name"] = mod.SETTING_NAMES.ENLARGE,
		["widget_type"] = "numeric",
		["text"] = mod:localize("enlarge"),
		["tooltip"] = mod:localize("enlarge_tooltip"),
		["range"] = {0, 300},
		["unit_text"] = "%",
	    ["default_value"] = 100,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.DOT,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("dot"),
		["tooltip"] = mod:localize("dot_tooltip"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.DOT_TOGGLE_HOTKEY,
		["widget_type"] = "keybind",
		["text"] = mod:localize("dot_toggle_hotkey"),
		["tooltip"] = mod:localize("dot_toggle_hotkey_tooltip"),
		["default_value"] = {},
		["action"] = "dot_toggle"
	},
	{
		["setting_name"] = mod.SETTING_NAMES.NO_MELEE_DOT,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("no_melee_dot"),
		["tooltip"] = mod:localize("no_melee_dot_tooltip"),
		["default_value"] = false
	},
	{
		["setting_name"] = mod.SETTING_NAMES.NO_LINE_MARKERS,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("no_line_markers"),
		["tooltip"] = mod:localize("no_line_markers_tooltip"),
		["default_value"] = false
	},
	{
		["setting_name"] = mod.SETTING_NAMES.NO_RANGE_MARKERS,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("no_range_markers"),
		["tooltip"] = mod:localize("no_range_markers_tooltip"),
		["default_value"] = false
	},
}

return mod_data