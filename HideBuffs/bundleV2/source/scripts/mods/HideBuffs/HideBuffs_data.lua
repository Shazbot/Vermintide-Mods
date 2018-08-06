local mod = get_mod("HideBuffs") -- luacheck: ignore get_mod

mod.SETTING_NAMES = {
	VICTOR_BOUNTYHUNTER_PASSIVE_INFINITE_AMMO_BUFF = "victor_bountyhunter_passive_infinite_ammo_buff",
	GRIMOIRE_HEALTH_DEBUFF = "grimoire_health_debuff",
	MARKUS_HUNTSMAN_PASSIVE_CRIT_AURA_BUFF = "markus_huntsman_passive_crit_aura_buff",
	MARKUS_KNIGHT_PASSIVE_DEFENCE_AURA = "markus_knight_passive_defence_aura",
	KERILLIAN_WAYWATCHER_PASSIVE = "kerillian_waywatcher_passive",
	KERILLIAN_MAIDENGUARD_PASSIVE_STAMINA_REGEN_BUFF = "kerillian_maidenguard_passive_stamina_regen_buff",
}

-- Everything here is optional. You can remove unused parts.
local mod_data = {
	name = "Hide Buffs",
	description = mod:localize("mod_description"),
	is_togglable = true,
}
mod_data.options_widgets = {
	{
		["setting_name"] = mod.SETTING_NAMES.VICTOR_BOUNTYHUNTER_PASSIVE_INFINITE_AMMO_BUFF,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("victor_bountyhunter_passive_infinite_ammo_buff"),
		["tooltip"] = mod:localize("victor_bountyhunter_passive_infinite_ammo_buff_tooltip"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.GRIMOIRE_HEALTH_DEBUFF,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("grimoire_health_debuff"),
		["tooltip"] = mod:localize("grimoire_health_debuff_tooltip"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.MARKUS_HUNTSMAN_PASSIVE_CRIT_AURA_BUFF,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("markus_huntsman_passive_crit_aura_buff"),
		["tooltip"] = mod:localize("markus_huntsman_passive_crit_aura_buff_tooltip"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.MARKUS_KNIGHT_PASSIVE_DEFENCE_AURA,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("markus_knight_passive_defence_aura"),
		["tooltip"] = mod:localize("markus_knight_passive_defence_aura_tooltip"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.KERILLIAN_WAYWATCHER_PASSIVE,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("kerillian_waywatcher_passive"),
		["tooltip"] = mod:localize("kerillian_waywatcher_passive_tooltip"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.KERILLIAN_MAIDENGUARD_PASSIVE_STAMINA_REGEN_BUFF ,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("kerillian_maidenguard_passive_stamina_regen_buff"),
		["tooltip"] = mod:localize("kerillian_maidenguard_passive_stamina_regen_buff_tooltip"),
		["default_value"] = false,
	},
}

return mod_data