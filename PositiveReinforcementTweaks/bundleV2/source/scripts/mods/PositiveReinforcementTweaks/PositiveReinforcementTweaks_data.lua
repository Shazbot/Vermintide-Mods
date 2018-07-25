local mod = get_mod("PositiveReinforcementTweaks") -- luacheck: ignore get_mod

local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = false,
}

mod.SETTING_NAMES = {
	VERTICAL_ALIGNMENT = "vertical_alignment",
	HORIZONTAL_ALIGNMENT = "horizontal_alignment",
	SHOW_DURATION = "show_duration",
	OFFSET_X = "offset_x",
	OFFSET_Y = "offset_y",
}

mod.ALIGNMENTS = {
	TOP = 1,
	BOTTOM = 2,
	LEFT = 3,
	RIGHT = 4,
	CENTER = 5,
}

mod.ALIGNMENTS_LOOKUP = {
	"top",
	"bottom",
	"left",
	"right",
	"center",
}

mod_data.options_widgets = {
	{
		["setting_name"] = mod.SETTING_NAMES.VERTICAL_ALIGNMENT,
		["widget_type"] = "dropdown",
		["text"] = mod:localize("vertical_alignment"),
		["tooltip"] = mod:localize("vertical_alignment_tooltip"),
		["options"] = {
			{ text = mod:localize("top"), value = mod.ALIGNMENTS.TOP }, --1
			{ text = mod:localize("bottom"), value = mod.ALIGNMENTS.BOTTOM }, --2
			{ text = mod:localize("center"), value = mod.ALIGNMENTS.CENTER }, --1
		},
		["default_value"] = mod.ALIGNMENTS.TOP,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.HORIZONTAL_ALIGNMENT,
		["widget_type"] = "dropdown",
		["text"] = mod:localize("horizontal_alignment"),
		["tooltip"] = mod:localize("horizontal_alignment_tooltip"),
		["options"] = {
			{ text = mod:localize("right"), value = mod.ALIGNMENTS.RIGHT }, --1
			{ text = mod:localize("left"), value = mod.ALIGNMENTS.LEFT }, --2
			{ text = mod:localize("center"), value = mod.ALIGNMENTS.CENTER }, --3
		},
		["default_value"] = mod.ALIGNMENTS.RIGHT,
	},
	{
		["show_widget_condition"] = {3},
		["setting_name"] = mod.SETTING_NAMES.SHOW_DURATION,
		["widget_type"] = "numeric",
		["text"] = mod:localize("show_duration"),
		["tooltip"] = mod:localize("show_duration_tooltip"),
		["range"] = {0, 20},
		["unit_text"] = "sec",
		["default_value"] = 4,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.OFFSET_X,
		["widget_type"] = "numeric",
		["text"] = mod:localize("offset_x"),
		["tooltip"] = mod:localize("offset_x_tooltip"),
		["range"] = {-2000, 2000},
		["unit_text"] = "px",
	    ["default_value"] = 0,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.OFFSET_Y,
		["widget_type"] = "numeric",
		["text"] = mod:localize("offset_y"),
		["tooltip"] = mod:localize("offset_y_tooltip"),
		["range"] = {-2000, 2000},
		["unit_text"] = "px",
	    ["default_value"] = 0,
	},
}

return mod_data