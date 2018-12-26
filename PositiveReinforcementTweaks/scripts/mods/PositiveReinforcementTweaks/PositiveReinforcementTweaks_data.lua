local mod = get_mod("PositiveReinforcementTweaks")

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
	REVERSE_FLOW = "reverse_flow",
	BREEDS_GROUP = "BREEDS_GROUP",
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

mod.killfeed_breeds = {
	"skaven_storm_vermin",
	"skaven_storm_vermin_with_shield",
	"chaos_raider",
	"chaos_berzerker",
	"skaven_plague_monk",
	"chaos_warrior",
	"skaven_poison_wind_globadier",
	"skaven_ratling_gunner",
	"skaven_warpfire_thrower",
	"chaos_corruptor_sorcerer",
	"chaos_vortex_sorcerer",
	"skaven_loot_rat",
	"skaven_pack_master",
	"skaven_gutter_runner",
}

local breen_name_to_localized = {
	skaven_storm_vermin_with_shield = "Stormvermin with shield",
	chaos_corruptor_sorcerer = "Lifeleech Sorcerer",
}
mod:hook("Localize", function(func, id, ...)
	if breen_name_to_localized[id] then
		return breen_name_to_localized[id]
	end
	return func(id, ...)
end)

local killfeed_breed_widgets = {}
for _, breed_name in ipairs( mod.killfeed_breeds ) do
	mod.SETTING_NAMES[breed_name] = breed_name
	table.insert(killfeed_breed_widgets, {
		["setting_name"] = mod.SETTING_NAMES[breed_name],
		["widget_type"] = "checkbox",
		["text"] = Localize(breed_name),
		["tooltip"] = "Hide message for "..Localize(breed_name)..".",
		["default_value"] = false,
	})
end

mod:hook_disable("Localize")

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
		["setting_name"] = mod.SETTING_NAMES.REVERSE_FLOW,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("reverse_flow"),
		["tooltip"] = mod:localize("reverse_flow_tooltip"),
		["default_value"] = false,
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
	{
		["setting_name"] = mod.SETTING_NAMES.BREEDS_GROUP,
		["widget_type"] = "group",
		["text"] = mod:localize("BREEDS_GROUP"),
		["tooltip"] = mod:localize("BREEDS_GROUP_T"),
		["sub_widgets"] = killfeed_breed_widgets,
	},
}

return mod_data
