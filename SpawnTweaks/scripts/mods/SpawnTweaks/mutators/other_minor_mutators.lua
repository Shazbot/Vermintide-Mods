local mod = get_mod("SpawnTweaks")

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

	if not mod.is_permanent_heal() then
		heal_amount = heal_amount * player_white_hp_gain_multiplier/100
	end
	return func(healed_unit, healer_unit, heal_amount, heal_type)
end)
