local mod = get_mod("Gib")

local pl = require'pl.import_into'()

mod.SETTING_NAMES = {}

local mod_data = {
	name = "Gib",
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true,
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

mod.add_option(
	"STAGGER_MULTIPLIER",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 5000},
		["unit_text"] = "%",
	    ["default_value"] = 100,
	},
	"Stagger Multiplier",
	"Multiplies the force of non-kill stagger."
)
mod.add_option(
	"DEATH_PUSH_MULTIPLIER",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 1000},
	    ["default_value"] = 1,
	},
	"Death Stagger Value",
	"Set the value of stagger on kill. Default is 1 for slave rats, lower for elites."
)
mod.add_option(
	"GIB_PUSH_FORCE",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 1000},
	    ["default_value"] = 5,
	},
	"Gib Push Force",
	"Set the gib push force for body parts. Default is between 1-5."
	.."\nSets them all to this value."
	.."\nMay actually not do anything, but it should glancing at the code."
)
mod.add_option(
	"ALWAYS_DISMEMBER",
	{
		["widget_type"] = "checkbox",
	    ["default_value"] = false,
	},
	"Always Dismember",
	"Dismember on every attack. Can lead to some it's just a flesh wound enemies."
)
mod.add_option(
	"FORCE_DISMEMBER",
	{
		["widget_type"] = "checkbox",
	    ["default_value"] = false,
	},
	"Force Dismember",
	"Force a dismember on every kill."
)
mod.add_option(
	"ALWAYS_RAGDOLL",
	{
		["widget_type"] = "checkbox",
	    ["default_value"] = false,
	},
	"Always Ragdoll",
	"Ragdoll on every kill."
)

return mod_data
