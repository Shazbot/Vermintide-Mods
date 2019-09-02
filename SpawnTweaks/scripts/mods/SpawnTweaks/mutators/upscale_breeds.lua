local mod = get_mod("SpawnTweaks")

mod.upscale_breeds = {}
mod.upscale_breeds.breed_to_higher_breed = {
	chaos_fanatic = {
		"chaos_marauder",
		"chaos_marauder_with_shield",
	},
	chaos_marauder = {
		"chaos_berzerker",
		"chaos_raider",
	},
	chaos_berzerker = {
		"chaos_vortex_sorcerer",
		"chaos_warrior",
	},
	skaven_plague_monk = {
		"skaven_warpfire_thrower",
		"skaven_poison_wind_globadier",
	},
	chaos_raider = {
		"chaos_warrior",
	},
	skaven_slave = {
		"skaven_clan_rat",
		"skaven_clan_rat_with_shield",
	},
	skaven_clan_rat = {
		"skaven_plague_monk",
		"skaven_storm_vermin_commander",
		"skaven_storm_vermin",
		"skaven_storm_vermin_with_shield",
	},
	skaven_storm_vermin_commander = {
		"skaven_pack_master",
		"skaven_gutter_runner",
		"skaven_ratling_gunner",
		"skaven_poison_wind_globadier",
	},
}

mod.upscale_breeds.get_upscaled_breed = function(breed_name, upscale_chance)
	local breed_tier_list = mod.upscale_breeds.breed_to_higher_breed
	local upper_tier_breed_name = breed_tier_list[breed_name]

	if upscale_chance - math.random(100) < 0 then
		return
	end

	if type(upper_tier_breed_name) == "table" then
		upper_tier_breed_name = upper_tier_breed_name[math.random(#upper_tier_breed_name)]
	end

	return Breeds[upper_tier_breed_name]
end

-- CHECK
-- ConflictDirector._spawn_unit = function (self, breed, spawn_pos, spawn_rot, spawn_category, spawn_animation, spawn_type, optional_data, group_data, spawn_index)
mod:hook(ConflictDirector, "_spawn_unit", function(func, self, breed, spawn_pos, spawn_rot, spawn_category, spawn_animation, spawn_type, optional_data, group_data, spawn_index)
	if mod:get(mod.SETTING_NAMES.UPSCALE_BREEDS_MUTATOR) then
		local upscale_chance = mod:get(mod.SETTING_NAMES.UPSCALE_BREEDS_MUTATOR_CHANCE)
		while true do
			local new_breed = mod.upscale_breeds.get_upscaled_breed(breed.name, upscale_chance)
			if new_breed then
				breed = new_breed
				upscale_chance = mod:get(mod.SETTING_NAMES.UPSCALE_BREEDS_MUTATOR_SUCCESSIVE_CHANCE)
			else
				break
			end
		end
		spawn_animation = breed.default_spawn_animation
		if optional_data then
			optional_data.inventory_configuration_name = nil
		end
	end

	return func(self, breed, spawn_pos, spawn_rot, spawn_category, spawn_animation, spawn_type, optional_data, group_data, spawn_index)
end)
