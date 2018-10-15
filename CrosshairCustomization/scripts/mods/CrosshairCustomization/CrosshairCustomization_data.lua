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
    NO_LINE_MARKERS = "no_line_markers",
    NO_RANGED_DOT = "NO_RANGED_DOT",
    NO_MELEE_HIT_MARKERS = "NO_MELEE_HIT_MARKERS",
    NO_RANGED_HIT_MARKERS = "NO_RANGED_HIT_MARKERS",
    FORCE_MELEE_CROSSHAIR_GROUP = "FORCE_MELEE_CROSSHAIR_GROUP",
    MELEE_CROSSHAIR_PITCH = "MELEE_CROSSHAIR_PITCH",
    MELEE_CROSSHAIR_YAW = "MELEE_CROSSHAIR_YAW",
    ONLY_LOWER_MARKERS = "ONLY_LOWER_MARKERS",
    FORCE_MELEE_CROSSHAIR_NO_DOT = "FORCE_MELEE_CROSSHAIR_NO_DOT",
    HIT_MARKERS_COLOR_GROUP = "HIT_MARKERS_COLOR_GROUP",
    HIT_MARKERS_BLUE = "HIT_MARKERS_BLUE",
    HIT_MARKERS_GREEN = "HIT_MARKERS_GREEN",
    HIT_MARKERS_RED = "HIT_MARKERS_RED",
    HIT_MARKERS_SIZE = "HIT_MARKERS_SIZE",
    HIT_MARKERS_ALPHA = "HIT_MARKERS_ALPHA",
    HIT_MARKERS_GROUP = "HIT_MARKERS_GROUP",
    HIT_MARKERS_DURATION = "HIT_MARKERS_DURATION",
    HIT_MARKERS_CRITICAL_COLOR_GROUP = "HIT_MARKERS_CRITICAL_COLOR_GROUP",
    HIT_MARKERS_CRITICAL_RED = "HIT_MARKERS_CRITICAL_RED",
    HIT_MARKERS_CRITICAL_GREEN = "HIT_MARKERS_CRITICAL_GREEN",
    HIT_MARKERS_CRITICAL_BLUE = "HIT_MARKERS_CRITICAL_BLUE",
}
---! Enums ---

local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = false,
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
		["setting_name"] = mod.SETTING_NAMES.NO_RANGED_DOT,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("NO_RANGED_DOT"),
		["tooltip"] = mod:localize("NO_RANGED_DOT_T"),
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
	{
		["setting_name"] = mod.SETTING_NAMES.FORCE_MELEE_CROSSHAIR_GROUP,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("FORCE_MELEE_CROSSHAIR_GROUP"),
		["tooltip"] = mod:localize("FORCE_MELEE_CROSSHAIR_GROUP_T"),
		["default_value"] = false,
		["sub_widgets"] = {
			{
				["setting_name"] = mod.SETTING_NAMES.MELEE_CROSSHAIR_YAW,
				["widget_type"] = "numeric",
				["text"] = mod:localize("MELEE_CROSSHAIR_YAW"),
				["tooltip"] = mod:localize("MELEE_CROSSHAIR_YAW_T"),
				["range"] = {0, 100},
				["default_value"] = 0,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.MELEE_CROSSHAIR_PITCH,
				["widget_type"] = "numeric",
				["text"] = mod:localize("MELEE_CROSSHAIR_PITCH"),
				["tooltip"] = mod:localize("MELEE_CROSSHAIR_PITCH_T"),
				["range"] = {0, 100},
				["default_value"] = 0,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.FORCE_MELEE_CROSSHAIR_NO_DOT,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("FORCE_MELEE_CROSSHAIR_NO_DOT"),
				["tooltip"] = mod:localize("FORCE_MELEE_CROSSHAIR_NO_DOT_T"),
				["default_value"] = false,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.ONLY_LOWER_MARKERS,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("ONLY_LOWER_MARKERS"),
				["tooltip"] = mod:localize("ONLY_LOWER_MARKERS_T"),
				["default_value"] = false,
			},
		},
	},
	{
		["setting_name"] = mod.SETTING_NAMES.HIT_MARKERS_GROUP,
		["widget_type"] = "group",
		["text"] = mod:localize("HIT_MARKERS_GROUP"),
		["sub_widgets"] = {
			{
				["setting_name"] = mod.SETTING_NAMES.NO_MELEE_HIT_MARKERS,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("NO_MELEE_HIT_MARKERS"),
				["tooltip"] = mod:localize("NO_MELEE_HIT_MARKERS_T"),
				["default_value"] = false
			},
			{
				["setting_name"] = mod.SETTING_NAMES.NO_RANGED_HIT_MARKERS,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("NO_RANGED_HIT_MARKERS"),
				["tooltip"] = mod:localize("NO_RANGED_HIT_MARKERS_T"),
				["default_value"] = false
			},
			{
				["setting_name"] = mod.SETTING_NAMES.HIT_MARKERS_COLOR_GROUP,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("HIT_MARKERS_COLOR_GROUP"),
				["tooltip"] = mod:localize("HIT_MARKERS_COLOR_GROUP_T"),
				["default_value"] = false,
				["sub_widgets"] = {
				    {
						["setting_name"] = mod.SETTING_NAMES.HIT_MARKERS_RED,
						["widget_type"] = "numeric",
						["text"] = mod:localize("red"),
						["tooltip"] = mod:localize("custom_red_tooltip"),
						["range"] = {0, 255},
						["default_value"] = 255,
					},
					{
						["setting_name"] = mod.SETTING_NAMES.HIT_MARKERS_GREEN,
						["widget_type"] = "numeric",
						["text"] = mod:localize("green"),
						["tooltip"] = mod:localize("custom_green_tooltip"),
						["range"] = {0, 255},
						["default_value"] = 255,
					},
					{
						["setting_name"] = mod.SETTING_NAMES.HIT_MARKERS_BLUE,
						["widget_type"] = "numeric",
						["text"] = mod:localize("blue"),
						["tooltip"] = mod:localize("custom_blue_tooltip"),
						["range"] = {0, 255},
						["default_value"] = 255,
					},
				},
			},
			{
				["setting_name"] = mod.SETTING_NAMES.HIT_MARKERS_CRITICAL_COLOR_GROUP,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("HIT_MARKERS_CRITICAL_COLOR_GROUP"),
				["tooltip"] = mod:localize("HIT_MARKERS_CRITICAL_COLOR_GROUP_T"),
				["default_value"] = false,
				["sub_widgets"] = {
				    {
						["setting_name"] = mod.SETTING_NAMES.HIT_MARKERS_CRITICAL_RED,
						["widget_type"] = "numeric",
						["text"] = mod:localize("red"),
						["tooltip"] = mod:localize("custom_red_tooltip"),
						["range"] = {0, 255},
						["default_value"] = 255,
					},
					{
						["setting_name"] = mod.SETTING_NAMES.HIT_MARKERS_CRITICAL_GREEN,
						["widget_type"] = "numeric",
						["text"] = mod:localize("green"),
						["tooltip"] = mod:localize("custom_green_tooltip"),
						["range"] = {0, 255},
						["default_value"] = 255,
					},
					{
						["setting_name"] = mod.SETTING_NAMES.HIT_MARKERS_CRITICAL_BLUE,
						["widget_type"] = "numeric",
						["text"] = mod:localize("blue"),
						["tooltip"] = mod:localize("custom_blue_tooltip"),
						["range"] = {0, 255},
						["default_value"] = 255,
					},
				},
			},
			{
				["setting_name"] = mod.SETTING_NAMES.HIT_MARKERS_SIZE,
				["widget_type"] = "numeric",
				["text"] = mod:localize("HIT_MARKERS_SIZE"),
				["tooltip"] = mod:localize("HIT_MARKERS_SIZE_T"),
				["range"] = {0, 30},
				["unit_text"] = "px",
				["default_value"] = 10,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.HIT_MARKERS_ALPHA,
				["widget_type"] = "numeric",
				["text"] = mod:localize("HIT_MARKERS_ALPHA"),
				["tooltip"] = mod:localize("HIT_MARKERS_ALPHA_T"),
				["range"] = {0, 255},
				["default_value"] = 255,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.HIT_MARKERS_DURATION,
				["widget_type"] = "numeric",
				["text"] = mod:localize("HIT_MARKERS_DURATION"),
				["tooltip"] = mod:localize("HIT_MARKERS_DURATION_T"),
				["range"] = {0, 1},
				["decimals_number"] = 1,
				["default_value"] = 0.6,
			},
		},
	},
}

return mod_data