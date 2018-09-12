local mod = get_mod("GiveWeapon") -- luacheck: ignore get_mod

mod.SETTING_NAMES = {
	NO_SKINS = "NO_SKINS",
}

local mod_data = {
	name = "Give Weapon",
	description = mod:localize("mod_description"),
}
mod_data.options_widgets = {
	{
		["setting_name"] = mod.SETTING_NAMES.NO_SKINS,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("NO_SKINS"),
		["tooltip"] = mod:localize("NO_SKINS_T"),
		["default_value"] = false,
	},
}

return mod_data