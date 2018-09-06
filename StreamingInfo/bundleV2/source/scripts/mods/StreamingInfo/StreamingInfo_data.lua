local mod = get_mod("StreamingInfo") -- luacheck: ignore get_mod

mod.SETTING_NAMES = {}

local mod_data = {
	name = "Streaming Info",
	description = mod:localize("mod_description"),
	is_togglable = true,
}

mod_data.options_widgets = {}

mod.add_option = function(setting_name, option_widget)
	mod.SETTING_NAMES[setting_name] = setting_name
	option_widget.setting_name = setting_name
	option_widget.text = mod:localize(setting_name)
	option_widget.tooltip = mod:localize(setting_name.."_T")
	table.insert(mod_data.options_widgets, option_widget)
end

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
	"FONT_SIZE",
	{
		["widget_type"] = "numeric",
		["range"] = {16, 40},
		["default_value"] = 18,
	}
)
mod.add_option(
	"SPACING",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 50},
		["default_value"] = 22,
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

return mod_data