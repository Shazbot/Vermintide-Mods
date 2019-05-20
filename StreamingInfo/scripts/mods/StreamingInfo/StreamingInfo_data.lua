local mod = get_mod("StreamingInfo")

local pl = require'pl.import_into'()

mod.SETTING_NAMES = {}

local mod_data = {
	name = "Streaming Info",
	description = mod:localize("mod_description"),
	is_togglable = true,
}

mod_data.options_widgets = pl.List()
mod.localizations = mod.localizations or pl.Map()

mod.add_option = function(setting_name, option_widget, en_text, en_tooltip, group, index)
	mod.SETTING_NAMES[setting_name] = setting_name
	option_widget.setting_name = setting_name
	if en_text then
		mod.localizations[setting_name] = {
			en = en_text
		}
	end
	if en_tooltip then
		mod.localizations[setting_name.."_T"] = {
			en = en_tooltip
		}
	end
	option_widget.text = mod:localize(setting_name)
	option_widget.tooltip = mod:localize(setting_name.."_T")
	option_widget.sub_widgets = {}
	if not group then
		index = index or #mod_data.options_widgets + 1
		mod_data.options_widgets:insert(index, option_widget)
	else
		index = index or #group + 1
		table.insert(group, index, option_widget)
	end

	return option_widget.sub_widgets
end

local additional_lines_subs = mod.add_option(
	"ADDITIONAL_LINES_GROUP",
	{
		["widget_type"] = "group",
	},
	"Show Additional Info",
	"Add additional lines."
)
mod.add_option(
	"ONS_DW_INFO_TEMP",
	{
		["widget_type"] = "checkbox",
	  ["default_value"] = true,
	},
	"Onslaught And Deathwish Temp",
	"Auto-add lines for Onslaught and Deathwish to temporary lines."
		.."\nThis requires the DwOns QoL mod to work.",
	additional_lines_subs
)
mod.add_option(
	"ONS_DW_INFO",
	{
		["widget_type"] = "checkbox",
	  ["default_value"] = false,
	},
	"Onslaught And Deathwish",
	"Auto-add lines for Onslaught and Deathwish to permanent lines."
		.."\nThis requires the DwOns QoL mod to work.",
	additional_lines_subs
)

mod.add_option(
	"MUTATORS_INFO_TEMP",
	{
		["widget_type"] = "checkbox",
	  ["default_value"] = true,
	},
	"Active FS Mutators Temp",
	"Auto-add lines for active Fatshark mutators to temporary lines.",
	additional_lines_subs
)
mod.add_option(
	"MUTATORS_INFO",
	{
		["widget_type"] = "checkbox",
	  ["default_value"] = false,
	},
	"Active FS Mutators",
	"Auto-add lines for active Fatshark mutators to permanent lines.",
	additional_lines_subs
)

mod.add_option(
	"RED",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 255},
		["default_value"] = 255,
	}
)
mod.add_option(
	"GREEN",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 255},
		["default_value"] = 255,
	}
)
mod.add_option(
	"BLUE",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 255},
		["default_value"] = 255,
	}
)
mod.add_option(
	"BG_OPACITY",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 255},
		["default_value"] = 100,
	},
	"Opacity",
	"Background opacity."
)
mod.add_option(
	"FONT_SIZE",
	{
		["widget_type"] = "numeric",
		["range"] = {10, 40},
		["default_value"] = 24,
	}
)
mod.add_option(
	"LINE_SPACING",
	{
		["widget_type"] = "numeric",
		["range"] = {-50, 50},
		["unit_text"] = "px",
		["default_value"] = -2,
	}
)
mod.add_option(
	"OFFSET_X",
	{
		["widget_type"] = "numeric",
		["range"] = {-10, 3500},
		["unit_text"] = "px",
		["default_value"] = 0,
	}
)
mod.add_option(
	"OFFSET_Y",
	{
		["widget_type"] = "numeric",
		["range"] = {-3500, 30},
		["unit_text"] = "px",
		["default_value"] = 0,
	}
)

local perm_info_subs = mod.add_option(
	"PERM_INFO_GROUP",
	{
		["widget_type"] = "group",
	},
	"Permanent Info",
	"Setting related to permanent lines set with /info."
)
mod.add_option(
	"PERM_RED",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 255},
		["default_value"] = 255,
	},
	nil,
	nil,
	perm_info_subs
)
mod.add_option(
	"PERM_GREEN",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 255},
		["default_value"] = 255,
	},
	nil,
	nil,
	perm_info_subs
)
mod.add_option(
	"PERM_BLUE",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 255},
		["default_value"] = 255,
	},
	nil,
	nil,
	perm_info_subs
)
mod.add_option(
	"PERM_BG_OPACITY",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 255},
		["default_value"] = 100,
	},
	"Perm Opacity",
	"Background opacity.",
	perm_info_subs
)
mod.add_option(
	"PERM_FONT_SIZE",
	{
		["widget_type"] = "numeric",
		["range"] = {10, 40},
		["default_value"] = 24,
	},
	nil,
	nil,
	perm_info_subs
)
mod.add_option(
	"PERM_LINE_SPACING",
	{
		["widget_type"] = "numeric",
		["range"] = {-50, 50},
		["unit_text"] = "px",
		["default_value"] = -2,
	},
	nil,
	nil,
	perm_info_subs
)
mod.add_option(
	"PERM_OFFSET_X",
	{
		["widget_type"] = "numeric",
		["range"] = {-10, 3500},
		["unit_text"] = "px",
		["default_value"] = 500,
	},
	nil,
	nil,
	perm_info_subs
)
mod.add_option(
	"PERM_OFFSET_Y",
	{
		["widget_type"] = "numeric",
		["range"] = {-3500, 30},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	nil,
	nil,
	perm_info_subs
)

return mod_data
