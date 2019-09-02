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
