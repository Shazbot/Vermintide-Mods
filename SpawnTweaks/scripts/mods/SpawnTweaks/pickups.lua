local mod = get_mod("SpawnTweaks")

local pl = require'pl.import_into'()

mod.build_enabled_map_pickups = function()
	mod.enabled_map_pickups =
		pl.List(mod.map_pickups)
		:filter(function(pickup_name) return not mod:get(mod.SETTING_NAMES["MAP_PICKUPS_DISABLE_"..pickup_name]) end)
end

mod.build_enabled_map_pickups()

mod:hook(mod, "on_setting_changed", function(func, setting_name)
	mod.build_enabled_map_pickups()

	return func(setting_name)
end)


mod:hook(Pickups.special.loot_die, "can_spawn_func", function(func, params, is_debug_spawn)
	if not params then
		return true
	end

	return func(params, is_debug_spawn)
end)

mod:hook(AiBreedSnippets, "reward_boss_kill_loot", function(func, unit, blackboard)
	if not mod:get(mod.SETTING_NAMES["MAP_PICKUPS_DISABLE_loot_die"]) then
		return func(unit, blackboard)
	end

	if not mod:get(mod.SETTING_NAMES.MAP_PICKUPS_REPLACE_DISABLED) or #mod.enabled_map_pickups == 0 then
		return
	end

	local nav_world = blackboard.nav_world
	local position = POSITION_LOOKUP[unit]
	local below = 1
	local above = 1
	local is_on_navmesh, altitude = GwNavQueries.triangle_from_position(nav_world, position, above, below)

	local wanted_drop_position
	if is_on_navmesh then
		wanted_drop_position = Vector3.copy(position)
		wanted_drop_position.z = altitude
	else
		local horizontal_limit = 2
		local distance_from_nav_border = 0.05
		wanted_drop_position = GwNavQueries.inside_position_from_outside_position(nav_world, position, above, below, horizontal_limit, distance_from_nav_border)
	end

	wanted_drop_position = wanted_drop_position or position
	local offset = Vector3(0, 0, 0.6)

	local pickup_name = mod.enabled_map_pickups[math.random(#mod.enabled_map_pickups)]

	local spawn_method = "rpc_spawn_pickup_with_physics"
	if pickup_name == "all_ammo" then
		spawn_method = "rpc_spawn_pickup"
	end

	Managers.state.network.network_transmit:send_rpc_server(
		spawn_method,
		NetworkLookup.pickup_names[pickup_name],
		wanted_drop_position + offset,
		Quaternion.identity(),
		NetworkLookup.pickup_spawn_types['dropped']
	)

	blackboard.rewarded_boss_loot = true
end)

mod:hook(AiBreedSnippets, "drop_loot", function(func, num_die, pos, ...)
	if not mod:get(mod.SETTING_NAMES["MAP_PICKUPS_DISABLE_loot_die"]) then
		return func(num_die, pos, ...)
	end

	if not mod:get(mod.SETTING_NAMES.MAP_PICKUPS_REPLACE_DISABLED) or #mod.enabled_map_pickups == 0 then
		return
	end

	local pickup_name = mod.enabled_map_pickups[math.random(#mod.enabled_map_pickups)]

	local spawn_method = "rpc_spawn_pickup_with_physics"
	if pickup_name == "all_ammo" then
		spawn_method = "rpc_spawn_pickup"
	end

	Managers.state.network.network_transmit:send_rpc_server(
		spawn_method,
		NetworkLookup.pickup_names[pickup_name],
		pos,
		Quaternion.identity(),
		NetworkLookup.pickup_spawn_types['dropped']
	)
end)

-- CHECK
-- PickupSystem._spawn_pickup = function (self, pickup_settings, pickup_name, position, rotation, with_physics, spawn_type, owner_peer_id, spawn_limit)
mod:hook(PickupSystem, "_spawn_pickup", function(func, self, pickup_settings, pickup_name, ...)
	if mod:get(mod.SETTING_NAMES["MAP_PICKUPS_DISABLE_"..pickup_name]) then
		if mod:get(mod.SETTING_NAMES.MAP_PICKUPS_REPLACE_DISABLED) and #mod.enabled_map_pickups > 0 then
			local new_pickup_name = mod.enabled_map_pickups[math.random(#mod.enabled_map_pickups)]
			local new_pickup_settings = AllPickups[new_pickup_name]
			return func(self, new_pickup_settings, new_pickup_name, ...)
		end

		return
	end

	return func(self, pickup_settings, pickup_name, ...)
end)
