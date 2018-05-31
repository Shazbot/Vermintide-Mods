local mod = get_mod("CustomHUD") -- luacheck: ignore get_mod

local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = false,
}

mod.SETTING_NAMES = {
	CUSTOM_HUD_METHOD = "custom_hud_method",
    HP_BAR_SIZE_METHOD = "hp_bar_size_method",
    HP_BAR_SIZE_SCALE_BY = "event_horde_size",
    PARTY_UI_ORIENTATION = "party_ui_orientation",
    PLAYER_UI_OFFSET = "player_ui_offset",
    AMMO_BAR_OFFSET_X = "ammo_bar_offset_x",
    AMMO_BAR_OFFSET_Y = "ammo_bar_offset_y",
    BUFFS_DIRECTION = "buffs_direction",
    BUFFS_OFFSET_X = "buffs_offset_x",
}

mod.CUSTOM_HUD_METHODS = {
	DEFAULT = 1,
	V1 = 2,
	CUSTOM = 3,
}

mod.HP_BAR_SIZE_METHODS = {
	DEFAULT = 1,
	FIXED = 2,
	CUSTOM = 3,
}

mod.ORIENTATIONS = {
	HORIZONTAL = 1,
	VERTICAL = 2,
}

mod.DIRECTIONS = {
	RIGHT = 1,
	LEFT = 2,
}

mod_data.options_widgets = {
	{
		["setting_name"] = mod.SETTING_NAMES.CUSTOM_HUD_METHOD,
		["widget_type"] = "dropdown",
		["text"] = mod:localize("custom_hud_method"),
		["tooltip"] = mod:localize("custom_hud_method_tooltip"),
		["options"] = {
			{text = mod:localize("custom_hud_method_default"), value = mod.CUSTOM_HUD_METHODS.DEFAULT},
			{text =  mod:localize("custom_hud_method_v1"), value = mod.CUSTOM_HUD_METHODS.V1},
			{text =  mod:localize("custom_hud_method_custom"), value = mod.CUSTOM_HUD_METHODS.CUSTOM},
		},
		["default_value"] = mod.CUSTOM_HUD_METHODS.DEFAULT,
		["sub_widgets"] = {
			{
				["show_widget_condition"] = {mod.CUSTOM_HUD_METHODS.CUSTOM},
				["setting_name"] = mod.SETTING_NAMES.HP_BAR_SIZE_METHOD,
				["widget_type"] = "dropdown",
				["text"] = mod:localize("hp_bar_size_method"),
				["tooltip"] = mod:localize("hp_bar_size_method_tooltip"),
				["options"] = {
					{text =  mod:localize("hp_bar_method_default"), value = mod.HP_BAR_SIZE_METHODS.DEFAULT},
					{text =  mod:localize("hp_bar_method_fixed"), value = mod.HP_BAR_SIZE_METHODS.FIXED},
					{text =  mod:localize("hp_bar_method_custom"), value = mod.HP_BAR_SIZE_METHODS.CUSTOM},
				},
				["default_value"] = mod.HP_BAR_SIZE_METHODS.DEFAULT,
				["sub_widgets"] = {
					{
						["show_widget_condition"] = {
							mod.HP_BAR_SIZE_METHODS.FIXED,
							mod.HP_BAR_SIZE_METHODS.CUSTOM,
						},
						["setting_name"] = mod.SETTING_NAMES.HP_BAR_SIZE_SCALE_BY,
						["widget_type"] = "numeric",
						["text"] = mod:localize("hp_bar_size_scale_by"),
						["tooltip"] = mod:localize("hp_bar_size_scale_by_tooltip"),
						["range"] = {0, 300},
						["unit_text"] = "%",
					    ["default_value"] = 100,
					},
				},
			},
			{
				["show_widget_condition"] = {mod.CUSTOM_HUD_METHODS.CUSTOM},
				["setting_name"] = mod.SETTING_NAMES.PARTY_UI_ORIENTATION,
				["widget_type"] = "dropdown",
				["text"] = mod:localize("party_ui_orientation"),
				["tooltip"] = mod:localize("party_ui_orientation_tooltip"),
				["options"] = {
					{text =  mod:localize("party_ui_orientation_vertical"), value = mod.ORIENTATIONS.VERTICAL},
					{text =  mod:localize("party_ui_orientation_horizontal"), value = mod.ORIENTATIONS.HORIZONTAL},
				},
				["default_value"] = mod.ORIENTATIONS.VERTICAL,
			},
			{
				["show_widget_condition"] = {mod.CUSTOM_HUD_METHODS.CUSTOM},
				["setting_name"] = mod.SETTING_NAMES.PLAYER_UI_OFFSET,
				["widget_type"] = "numeric",
				["text"] = mod:localize("player_ui_offset"),
				["tooltip"] = mod:localize("player_ui_offset_tooltip"),
				["range"] = {-2000, 2000},
				["unit_text"] = "px",
			    ["default_value"] = 0,
			},
			{
				["show_widget_condition"] = {mod.CUSTOM_HUD_METHODS.CUSTOM},
				["setting_name"] = mod.SETTING_NAMES.AMMO_BAR_OFFSET_X,
				["widget_type"] = "numeric",
				["text"] = mod:localize("ammo_bar_offset_x"),
				["tooltip"] = mod:localize("ammo_bar_offset_x_tooltip"),
				["range"] = {-2000, 2000},
				["unit_text"] = "px",
			    ["default_value"] = 0,
			},
			{
				["show_widget_condition"] = {mod.CUSTOM_HUD_METHODS.CUSTOM},
				["setting_name"] = mod.SETTING_NAMES.AMMO_BAR_OFFSET_Y,
				["widget_type"] = "numeric",
				["text"] = mod:localize("ammo_bar_offset_y"),
				["tooltip"] = mod:localize("ammo_bar_offset_y_tooltip"),
				["range"] = {-2000, 2000},
				["unit_text"] = "px",
			    ["default_value"] = 0,
			},
			{
				["show_widget_condition"] = {mod.CUSTOM_HUD_METHODS.CUSTOM},
				["setting_name"] = mod.SETTING_NAMES.BUFFS_DIRECTION,
				["widget_type"] = "dropdown",
				["text"] = mod:localize("buffs_direction"),
				["tooltip"] = mod:localize("buffs_direction_tooltip"),
				["options"] = {
					{text =  mod:localize("buffs_direction_right"), value = mod.DIRECTIONS.RIGHT},
					{text =  mod:localize("buffs_direction_left"), value = mod.DIRECTIONS.LEFT},
				},
				["default_value"] = mod.ORIENTATIONS.RIGHT,
			},
			{
				["show_widget_condition"] = {mod.CUSTOM_HUD_METHODS.CUSTOM},
				["setting_name"] = mod.SETTING_NAMES.BUFFS_OFFSET_X,
				["widget_type"] = "numeric",
				["text"] = mod:localize("buffs_offset_x"),
				["tooltip"] = mod:localize("buffs_offset_x_tooltip"),
				["range"] = {-2000, 2000},
				["unit_text"] = "px",
			    ["default_value"] = 0,
			},
		},
	},
}

return mod_data