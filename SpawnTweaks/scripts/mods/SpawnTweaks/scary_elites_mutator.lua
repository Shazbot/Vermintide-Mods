local mod = get_mod("SpawnTweaks")

local pl = require'pl.import_into'()

mod.elite_breeds = pl.List{
	"chaos_warrior",
	"skaven_storm_vermin_commander",
	"chaos_raider",
	"skaven_storm_vermin",
	"chaos_berzerker",
	"skaven_storm_vermin_with_shield",
	"skaven_plague_monk",
}

mod:hook(DamageUtils, "stagger_ai", function(func, t, damage_profile, target_index, power_level, target_unit, ...)
	if not mod:get(mod.SETTING_NAMES.SCARY_ELITES_MUTATOR) then
		return func(t, damage_profile, target_index, power_level, target_unit, ...)
	end

	if target_unit and AiUtils.unit_alive(target_unit) then
		local breed = AiUtils.unit_breed(target_unit)
		if breed then
			local breed_name = breed.name
			if mod.elite_breeds:contains(breed_name) then
				return
			end
		end
	end

	return func(t, damage_profile, target_index, power_level, target_unit, ...)
end)

mod:hook(WeaponSystem, "rpc_attack_hit", function(func, self, sender, damage_source_id, attacker_unit_id, hit_unit_id, ...)
	if not mod:get(mod.SETTING_NAMES.SCARY_ELITES_MUTATOR) then
		return func(self, sender, damage_source_id, attacker_unit_id, hit_unit_id, ...)
	end

	local hit_unit = self.unit_storage:unit(hit_unit_id)
	local blackboard = BLACKBOARDS[hit_unit]
	if not blackboard or not blackboard.breed then
		return func(self, sender, damage_source_id, attacker_unit_id, hit_unit_id, ...)
	end

	local unbreakable_shield_temp = blackboard.breed.unbreakable_shield
	blackboard.breed.unbreakable_shield = false

	func(self, sender, damage_source_id, attacker_unit_id, hit_unit_id, ...)

	blackboard.breed.unbreakable_shield = unbreakable_shield_temp
end)
