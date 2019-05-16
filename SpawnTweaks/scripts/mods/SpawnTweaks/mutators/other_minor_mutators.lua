local mod = get_mod("SpawnTweaks")

local pl = require'pl.import_into'()

--- WHITE HP MULTIPLIER ---
--- Get whether heal_type gives green/permanent HP.
mod.is_permanent_heal = function(heal_type)
	return heal_type == "healing_draught" or heal_type == "bandage" or heal_type == "bandage_trinket" or heal_type == "buff_shared_medpack" or heal_type == "career_passive" or heal_type == "health_regen" or heal_type == "debug"
end
mod:hook(DamageUtils, "heal_network", function(func, healed_unit, healer_unit, heal_amount, heal_type)
	local player_white_hp_gain_multiplier = mod:get(mod.SETTING_NAMES.PLAYER_WHITE_HP_GAIN_MULTIPLIER)
	if player_white_hp_gain_multiplier == mod.setting_defaults[mod.SETTING_NAMES.PLAYER_WHITE_HP_GAIN_MULTIPLIER] then
		return func(healed_unit, healer_unit, heal_amount, heal_type)
	end

	if not mod.is_permanent_heal(heal_type) then
		heal_amount = heal_amount * player_white_hp_gain_multiplier/100
	end
	return func(healed_unit, healer_unit, heal_amount, heal_type)
end)


mod:hook(PlayerUnitHealthExtension, "health_degen_settings", function(func, ...)
	local degen_amount, degen_delay, degen_start = func(...)
	if not mod.is_setting_at_default(mod.SETTING_NAMES.WHITE_HP_DEGEN_AMOUNT) then
		degen_amount = mod:get(mod.SETTING_NAMES.WHITE_HP_DEGEN_AMOUNT)
	end
	if not mod.is_setting_at_default(mod.SETTING_NAMES.WHITE_HP_DEGEN_DELAY) then
		degen_delay = mod:get(mod.SETTING_NAMES.WHITE_HP_DEGEN_DELAY)
	end
	if not mod.is_setting_at_default(mod.SETTING_NAMES.WHITE_HP_DEGEN_START) then
		degen_start = mod:get(mod.SETTING_NAMES.WHITE_HP_DEGEN_START)
	end
	return degen_amount, degen_delay, degen_start
end)

--- Disable ult cd on player striking and getting hit.
mod:hook(CareerExtension, "extensions_ready", function(func, self, world, unit)
	local disable_ult_cd_on_strike = mod:get(mod.SETTING_NAMES.DISABLE_ULT_CD_ON_STRIKE)
	local disable_ult_cd_on_getting_hit = mod:get(mod.SETTING_NAMES.DISABLE_ULT_CD_ON_GETTING_HIT)
	if not disable_ult_cd_on_strike and not disable_ult_cd_on_getting_hit then
		return func(self, world, unit)
	end

	local passive_ability_data = self._career_data.passive_ability
	local buffs = passive_ability_data.buffs

	local buffs_temp = table.clone(buffs)
	if disable_ult_cd_on_strike then
		buffs = pl.tablex.filter(buffs,
			function(buff_name)
				return not string.find(buff_name, "ability_cooldown_on_hit")
			end)
	end
	if disable_ult_cd_on_getting_hit then
		buffs = pl.tablex.filter(buffs,
			function(buff_name)
				return not string.find(buff_name, "ability_cooldown_on_damage_taken")
			end)
	end

	passive_ability_data.buffs = buffs

	func(self, world, unit)

	passive_ability_data.buffs = buffs_temp
end)
