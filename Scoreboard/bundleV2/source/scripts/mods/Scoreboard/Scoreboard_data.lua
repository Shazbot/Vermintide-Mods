-- luacheck: ignore get_mod
local mod = get_mod("Scoreboard")

local pl = require'pl.import_into'()

mod.SETTING_NAMES = {}

local mod_data = {
	name = "Scoreboard Tweaks",
	description = mod:localize("mod_description"),
	allow_rehooking = true,
}

mod_data.options_widgets = pl.List()
mod.localizations = mod.localizations or pl.Map()

mod.add_option = function(setting_name, option_widget, en_text, en_tooltip)
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
	mod_data.options_widgets:append(option_widget)
end

mod.add_option(
	"EXCLUDE_SELF_DMG_FROM_DMG_TAKEN",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Substract Self Dmg From Damage Taken",
	"Substract self-inflicted damage from damage taken."
)

return mod_data