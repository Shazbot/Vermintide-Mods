local mod = get_mod("SpawnTweaks")

local pl = require'pl.import_into'()

mod.reverse_twins_data = {}

local data = mod.reverse_twins_data
data.breed_tier_list = {
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
		"chaos_warrior",
	},
	skaven_plague_monk = {
		"skaven_warpfire_thrower",
		"skaven_poison_wind_globadier",
	},
	skaven_warpfire_thrower = {
		"skaven_stormfiend",
	},
	chaos_raider = {
		"chaos_warrior",
		"chaos_warrior",
		"chaos_corruptor_sorcerer",
	},
	skaven_pack_master = {
		"skaven_rat_ogre",
	},
	skaven_ratling_gunner = {
		"skaven_stormfiend_boss",
	},
	chaos_warrior = {
		"chaos_troll",
		"chaos_spawn",
		"chaos_exalted_champion_norsca",
		"chaos_exalted_champion_warcamp",
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
	skaven_storm_vermin = {
		"skaven_rat_ogre",
		"skaven_stormfiend",
		"skaven_storm_vermin_warlord",
		"skaven_ratling_gunner",
	},
	skaven_storm_vermin_commander = {
		"skaven_pack_master",
		"skaven_gutter_runner",
		"skaven_ratling_gunner",
		"skaven_poison_wind_globadier",
	},
	skaven_storm_vermin_with_shield = {
		"skaven_rat_ogre",
		"skaven_stormfiend",
		"skaven_storm_vermin_warlord",
		"skaven_ratling_gunner",
	}
}
data.breed_tier_list.skaven_clan_rat_with_shield = data.breed_tier_list.skaven_clan_rat
data.breed_tier_list.chaos_marauder_with_shield = data.breed_tier_list.chaos_marauder

data.breed_tier_list_bomb_rats = table.clone(data.breed_tier_list)
table.insert(data.breed_tier_list_bomb_rats.skaven_clan_rat, "skaven_explosive_loot_rat")

data.boss_breeds = pl.List{
	"skaven_rat_ogre",
	"skaven_stormfiend",
	"skaven_stormfiend_boss",
	"skaven_storm_vermin_warlord",
	"chaos_troll",
	"chaos_spawn",
	"chaos_exalted_champion_norsca",
	"chaos_exalted_champion_warcamp",
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

mod:hook_safe(MutatorHandler, "update", function(self, dt, t) -- luacheck: no unused
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

mod:hook_safe(MutatorHandler, "ai_killed", function(self, killed_unit, killer_unit, death_data) -- luacheck: no unused
	if not mod:get(mod.SETTING_NAMES.REVERSE_TWINS_MUTATOR) then
		return
	end

	local breed_tier_list = data.breed_tier_list
	if mod:get(mod.SETTING_NAMES.REVERSE_TWINS_MUTATOR_BOMB_RATS) then
		breed_tier_list = data.breed_tier_list_bomb_rats
	end
	local breed_explosion_templates = data.breed_explosion_templates
	local blackboard = BLACKBOARDS[killed_unit]
	local breed = blackboard.breed
	local breed_name = breed.name
	local lower_tier_breed_name = breed_tier_list[breed_name]

	local spawn_chance = mod:get(mod.SETTING_NAMES.REVERSE_TWINS_MUTATOR_CHANCE) or 50
	if spawn_chance - math.random(100) < 0 then
		return
	end

	if type(lower_tier_breed_name) == "table" then
		lower_tier_breed_name = lower_tier_breed_name[math.random(#lower_tier_breed_name)]
	end

	if lower_tier_breed_name and data.boss_breeds:contains(lower_tier_breed_name) then
		local boss_spawn_chance = mod:get(mod.SETTING_NAMES.REVERSE_TWINS_MUTATOR_BOSS_CHANCE) or 50
		if lower_tier_breed_name == "skaven_stormfiend" then
			boss_spawn_chance = math.round(boss_spawn_chance*0.85)
		end
		if boss_spawn_chance - math.random(100) < 0 then
			return
		end
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

mod.is_boss_spawning_state_disabled = function()
	return mod:get(mod.SETTING_NAMES.LORDS_ARENT_DEFENSIVE)
		or mod:get(mod.SETTING_NAMES.REVERSE_TWINS_MUTATOR)
end

mod:hook(BTConditions, "should_be_defensive", function(func, blackboard)
	if mod.is_boss_spawning_state_disabled() then
		return false
	end

	return func(blackboard)
end)

--- Crash prevention hooks from Creature Spawner by Aussiemon.
-- Prevent Spinemanglr summon crash #1
mod:hook(BTEnterHooks, "warlord_defensive_on_enter", function (func, unit, blackboard, ...)
	return blackboard.spawn_allies_positions and func(unit, blackboard, ...)
end)

-- Prevent Spinemanglr summon crash #2
mod:hook(BTSpawnAllies, "enter", function (func, self, unit, blackboard, ...)
	if blackboard.has_call_position or blackboard.override_spawn_allies_call_position then
		return func(self, unit, blackboard, ...)
	end

	local action = self._tree_node.action_data
	local find_spawn_points = action.find_spawn_points

	-- If we need to find spawn points, run the function early to see if it returns
	if find_spawn_points then
		local spawn_data = {
			end_time = math.huge
		}
		blackboard.spawning_allies = blackboard.spawning_allies or spawn_data

		local call_position = BTSpawnAllies.find_spawn_point(unit, blackboard, action, spawn_data)
		if call_position then
			return func(self, unit, blackboard, ...)
		else
			blackboard.spawning_allies = nil
		end
	else
		return func(self, unit, blackboard, ...)
	end
end)

-- Prevent Spinemanglr summon crash #3
mod:hook(BTSpawnAllies, "run", function (func, self, unit, blackboard, ...)
	return (blackboard.spawning_allies and func(self, unit, blackboard, ...)) or "done"
end)

-- Prevent Spinemanglr summon crash #4
mod:hook(BTSpawnAllies, "leave", function (func, self, unit, blackboard, ...)
	return (blackboard.action and func(self, unit, blackboard, ...))
end)

-- Prevent Spinemanglr summon crash #5
mod:hook(BTSpawnAllies, "find_spawn_point", function (func, unit, blackboard, action, data, override_spawn_group, ...)
	local spawn_group = override_spawn_group or action.optional_go_to_spawn or action.spawn_group
	local spawner_system = Managers.state.entity:system("spawner_system")
	local spawners_raw = spawner_system._id_lookup[spawn_group]

	if not spawners_raw and action.use_fallback_spawners then
		spawners_raw = spawner_system._enabled_spawners
	end

	-- Use original function if raw spawners exist in this level
	return spawners_raw and func(unit, blackboard, action, data, override_spawn_group, ...)
end)

-- Prevent missing blackboard value crash
--- Modified logic to return 0 if pcall fails.
mod:hook(Utility, "get_action_utility", function(func, breed_action, action_name, blackboard, from_draw_ai_behavior)
	local total_utility = 0
	pcall(function()
		total_utility = func(breed_action, action_name, blackboard, from_draw_ai_behavior)
	end)
	return total_utility
end)

mod:hook_safe(Breeds["skaven_stormfiend_boss"], "run_on_spawn", function(unit)
	if mod.is_boss_spawning_state_disabled() then
		local health_extension = ScriptUnit.extension(unit, "health_system")
		health_extension.is_invincible = false
	end
end)

--- Leech skip skulk on spawn.
mod:hook(BTChaosSorcererPlagueSkulkAction, "enter", function(func, self, unit, blackboard, t)
	if not mod:get(mod.SETTING_NAMES.REVERSE_TWINS_MUTATOR) then
		return func(self, unit, blackboard, t)
	end

	local action = self._tree_node.action_data
	local initial_skulk_time_temp = table.clone(action.initial_skulk_time)
	action.initial_skulk_time = { 0,0 }

	func(self, unit, blackboard, t)

	action.initial_skulk_time = initial_skulk_time_temp
end)

--- Load some breed packages on map start.
mod.reverse_twins_data.breeds_to_auto_load = {
	"chaos_exalted_champion_warcamp",
	"skaven_storm_vermin_warlord",
	"skaven_storm_vermin_champion",
	"skaven_stormfiend_boss",
}
mod.dispatcher:on("onStateIngameEntered",
function()
	if not mod:get(mod.SETTING_NAMES.REVERSE_TWINS_MUTATOR) then
		return
	end

	if not Managers.player.is_server then
		return
	end

	local enemy_package_loader = Managers.state.game_mode.level_transition_handler.enemy_package_loader

	for _, breed_name in ipairs( mod.reverse_twins_data.breeds_to_auto_load ) do
		if not enemy_package_loader.breed_processed[breed_name] then
			local ignore_breed_limits = true

			if not enemy_package_loader._breed_category_lookup[breed_name] then
					local breed_list = table.clone(mod.reverse_twins_data.breeds_to_auto_load)
					enemy_package_loader:_create_breed_category_lookup(breed_list, "spawn_tweaks_reverse_twins", math.huge)
			end

			enemy_package_loader:request_breed(breed_name, ignore_breed_limits)
		end
	end
end)

mod.handle_reverse_twins_toggle = function()
	if mod:get(mod.SETTING_NAMES.REVERSE_TWINS_MUTATOR) then
		UtilityConsiderations.stormfiend_boss_charge.distance_to_target.max_value = 5
	else
		UtilityConsiderations.stormfiend_boss_charge.distance_to_target.max_value = 20
	end
end

mod.dispatcher:on("onModDisabled",
	function()
		UtilityConsiderations.stormfiend_boss_charge.distance_to_target.max_value = 20
	end)
mod.dispatcher:on("onModEnabled",
	function()
		mod.handle_reverse_twins_toggle()
	end)
mod.dispatcher:on("reverseTwinsToggled",
	function()
		mod.handle_reverse_twins_toggle()
	end)

-- Gatekeeper tweaks.
mod:hook(BTTransformAction, "enter", function(func, self, unit, blackboard, t)
	if not mod:get(mod.SETTING_NAMES.REVERSE_TWINS_MUTATOR) then
		return func(self, unit, blackboard, t)
	end

	mod:pcall(function()
		local health_extension = ScriptUnit.has_extension(unit, "health_system")
		if health_extension then
			local damage = 0
			health_extension:set_current_damage(damage)
			local network_manager = Managers.state.network
			local go_id, is_level_unit = network_manager:game_object_or_level_id(unit)
			local state = NetworkLookup.health_statuses[health_extension.state]
			Managers.state.network.network_transmit:send_rpc_clients("rpc_sync_damage_taken", go_id, is_level_unit, false, damage, state)
		end
	end)

	return func(self, unit, blackboard, t)
end)

mod:hook(Breeds.chaos_exalted_champion_norsca, "run_on_update", function(func, unit, blackboard, t, dt)
	if not mod:get(mod.SETTING_NAMES.REVERSE_TWINS_MUTATOR) then
		return func(unit, blackboard, t, dt)
	end

	local blackboard_phase = blackboard.current_phase

	func(unit, blackboard, t, dt)

	local hp = ScriptUnit.extension(blackboard.unit, "health_system"):current_health_percent()
	if blackboard_phase == 1
	and blackboard.current_phase == 2
	and hp > 0.33 then
		blackboard.current_phase = 1
	end
end)
