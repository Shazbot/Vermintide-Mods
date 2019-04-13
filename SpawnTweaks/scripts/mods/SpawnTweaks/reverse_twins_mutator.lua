local mod = get_mod("SpawnTweaks")

local pl = require'pl.import_into'()

local data = {}
data.breed_tier_list = {
	chaos_fanatic = { "chaos_marauder", "chaos_marauder_with_shield", },
	skaven_plague_monk = { "skaven_warpfire_thrower", "skaven_poison_wind_globadier", },
	chaos_marauder = { "chaos_berzerker", "chaos_raider", },
	chaos_berzerker = {
		"chaos_vortex_sorcerer",
		"chaos_warrior",
		"chaos_warrior",
	},
	skaven_storm_vermin_commander = {
		"skaven_pack_master",
		"skaven_gutter_runner",
		"skaven_ratling_gunner",
	},
	skaven_warpfire_thrower = "skaven_stormfiend",
	chaos_raider = {
		"chaos_warrior",
		"chaos_warrior",
		"chaos_corruptor_sorcerer",
	},
	skaven_pack_master = {
		nil, nil, nil, nil,
		"skaven_rat_ogre",
	},
	skaven_ratling_gunner = {
		nil, nil, nil, nil,
		"skaven_stormfiend_boss",
	},
	chaos_warrior = {
		nil, nil, nil, nil,
		"chaos_troll",
		"chaos_spawn",
	},
	skaven_slave = {
		"skaven_clan_rat",
		"skaven_clan_rat_with_shield",
	},
	skaven_clan_rat = {
		"skaven_plague_monk",
		"skaven_explosive_loot_rat",
		"skaven_storm_vermin_commander",
		"skaven_storm_vermin",
		"skaven_storm_vermin_with_shield",
	},
	skaven_storm_vermin = {
		nil, nil, nil, nil,
		"skaven_rat_ogre",
		"skaven_stormfiend",
	},
	skaven_storm_vermin_with_shield = {
		nil, nil, nil, nil,
		"skaven_rat_ogre",
		"skaven_stormfiend",
	}
}

data.breed_explosion_templates = {
	skaven_storm_vermin_commander = "generic_mutator_explosion_medium",
	chaos_raider = "generic_mutator_explosion_medium",
	chaos_exalted_champion_warcamp = "generic_mutator_explosion_medium",
	skaven_plague_monk = "generic_mutator_explosion_medium",
	skaven_storm_vermin_warlord = "generic_mutator_explosion_medium",
	skaven_grey_seer = "generic_mutator_explosion_medium",
	chaos_exalted_champion_norsca = "generic_mutator_explosion_medium",
	chaos_spawn_exalted_champion_norsca = "generic_mutator_explosion_large",
	skaven_stormfiend = "generic_mutator_explosion_large",
	chaos_exalted_sorcerer = "generic_mutator_explosion_medium",
	chaos_warrior = "generic_mutator_explosion_medium",
	skaven_rat_ogre = "generic_mutator_explosion_large",
	chaos_troll = "generic_mutator_explosion_large",
	chaos_spawn = "generic_mutator_explosion_large",
	skaven_stormfiend_boss = "generic_mutator_explosion_large",
	skaven_storm_vermin = "generic_mutator_explosion_medium",
	skaven_storm_vermin_with_shield = "generic_mutator_explosion_medium"
}
data.cb_enemy_spawned_function = function (unit, breed)
	local blackboard = BLACKBOARDS[unit]

	if not breed.special then
		blackboard.spawn_type = "horde"
		blackboard.spawning_finished = true
	end
end

data.spawn_queue = {}
data.spawn_delay = 0.25

mod:hook_safe(MutatorHandler, "update", function(self, dt, t)
	if not mod:get(mod.SETTING_NAMES.REVERSE_TWINS_MUTATOR) then
		return
	end

	local spawn_queue = data.spawn_queue
	local delete_index = nil

	for i = 1, #spawn_queue, 1 do
		local spawn_queue_entry = spawn_queue[i]

		if spawn_queue_entry.spawn_at_t < t then
			local breed = spawn_queue_entry.breed
			local position_box = spawn_queue_entry.position_box
			local rotation_box = spawn_queue_entry.rotation_box
			local spawn_category = "mutator"
			local optional_data = {
				spawned_func = data.cb_enemy_spawned_function
			}

			Managers.state.conflict:spawn_queued_unit(breed, position_box, rotation_box, spawn_category, nil, nil, optional_data)

			delete_index = i

			break
		end
	end

	if delete_index then
		table.remove(spawn_queue, delete_index)
	end
end)

mod:hook_safe(MutatorHandler, "ai_killed", function(self, killed_unit, killer_unit, death_data)
	if not mod:get(mod.SETTING_NAMES.REVERSE_TWINS_MUTATOR) then
		return
	end

	local breed_tier_list = data.breed_tier_list
	local breed_explosion_templates = data.breed_explosion_templates
	local blackboard = BLACKBOARDS[killed_unit]
	local breed = blackboard.breed
	local breed_name = breed.name
	local lower_tier_breed_name = breed_tier_list[breed_name]

	local spawn_chance = mod:get(mod.SETTING_NAMES.REVERSE_TWINS_MUTATOR_CHANCE) or 76
	if spawn_chance + 1 - math.random(100) < 0 then
		return
	end

	if type(lower_tier_breed_name) == "table" then
		lower_tier_breed_name = lower_tier_breed_name[math.random(#lower_tier_breed_name)]
	end

	local position = POSITION_LOOKUP[killed_unit]
	local nav_world = Managers.state.entity:system("ai_system"):nav_world()
	local spawn_queue = data.spawn_queue
	local conflict_director = Managers.state.conflict

	if position and lower_tier_breed_name then
		local rotation = Unit.local_rotation(killed_unit, 0)
		local right = Quaternion.right(rotation) * 0.5
		local lower_tier_breed = Breeds[lower_tier_breed_name]
		local explosion_template_name = breed_explosion_templates[breed_name] or "generic_mutator_explosion"

		AiUtils.generic_mutator_explosion(killed_unit, blackboard, explosion_template_name)

		local position_1 = position + right
		local projected_start_pos_1 = LocomotionUtils.pos_on_mesh(nav_world, position_1, 1, 1)

		if not projected_start_pos_1 then
			local p = GwNavQueries.inside_position_from_outside_position(nav_world, position_1, 6, 6, 8, 0.5)

			if p then
				projected_start_pos_1 = p
			end
		end

		local t = Managers.time:time("game")
		local spawn_at_t = t + data.spawn_delay

		if projected_start_pos_1 then
			local spawn_queue_entry = {
				breed = lower_tier_breed,
				rotation_box = QuaternionBox(rotation),
				spawn_at_t = spawn_at_t,
				position_box = Vector3Box(projected_start_pos_1)
			}
			spawn_queue[#spawn_queue + 1] = spawn_queue_entry
		end

		local unit_spawner = Managers.state.unit_spawner

		if not unit_spawner:is_marked_for_deletion(killed_unit) then
			local froze_unit_successfully = conflict_director.breed_freezer:try_mark_unit_for_freeze(breed, killed_unit)

			if not froze_unit_successfully then
				unit_spawner:mark_for_deletion(killed_unit)

				if death_data then
					death_data.remove = true
				end
			end
		end

		blackboard.about_to_be_destroyed = true
	end
end)
