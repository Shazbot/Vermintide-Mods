local mod = get_mod("SpawnTweaks") -- luacheck: ignore get_mod

-- luacheck: globals math ConflictUtils unpack table

local tablex = require'pl.tablex'
local stringx = require'pl.stringx'

--- "table.pack" and "unpack" replacements that are more reliable with nil values.
local function pack2(...) return {n=select('#', ...), ...} end
local function unpack2(t) return unpack(t, 1, t.n) end

--- Event hordes size adjustment.
mod:hook("SpawnerSystem._try_spawn_breed", function (func, self, breed_name, spawn_list_per_breed, spawn_list, breed_limits, active_enemies, group_template)
	local num_to_spawn = spawn_list_per_breed[breed_name]
	if num_to_spawn ~= nil then
		local horde_size_ratio = mod:get(mod.SETTING_NAMES.EVENT_HORDE_SIZE) / 100
		num_to_spawn = math.round(num_to_spawn * horde_size_ratio)
		spawn_list_per_breed[breed_name] = num_to_spawn
	end
	return func(self, breed_name, spawn_list_per_breed, spawn_list, breed_limits, active_enemies, group_template)
end)

--- Timed hordes size adjustment.
mod:hook("HordeSpawner.compose_horde_spawn_list", function (func, self, composition_type)
	local original_random_interval = ConflictUtils.random_interval
	ConflictUtils.random_interval = function (numbers)
		local result = original_random_interval(numbers)
		if result then
			local horde_size_ratio = mod:get(mod.SETTING_NAMES.HORDE_SIZE) / 100
			result = math.round(result * horde_size_ratio)

			-- so in compose_horde_spawn_list we have "for start,start+result,1 do" which will run once for result 0
			-- and as a result we get 1 slave in every horde
			if result == 0 then
				result = -1
			end
		end

		return result
	end

	local packed_return = pack2(func(self, composition_type))

	ConflictUtils.random_interval = original_random_interval

	return unpack2(packed_return)
end)

--- Fix for an assert crash for missing next queued breed when downsizing hordes.
mod:hook("HordeSpawner.spawn_unit", function (func, self, hidden_spawn, breed_name, goal_pos, horde, ...)
	if breed_name == nil then
		return
	end

	return func(self, hidden_spawn, breed_name, goal_pos, horde, ...)
end)

--- Disable ambients.
mod:hook("AIInterestPointSystem.spawn_interest_points", function (func, ...)
	if mod:get(mod.SETTING_NAMES.DISABLE_AMBIENTS) then
		return
	end

	return func(...)
end)

--- Disable boss doors.
mod:hook("DoorSystem.update", function(func, self, context, t)
	if mod:get(mod.SETTING_NAMES.NO_BOSS_DOOR) and self.is_server then
		for map_section, _ in pairs(table.clone(self._active_groups)) do
			self:open_boss_doors(map_section)
			self._active_groups[map_section] = nil
		end
	end
	return func(self, context, t)
end)

mod.boss_events = {
	"boss_event_chaos_troll",
	"boss_event_chaos_spawn",
	"boss_event_storm_fiend",
	"boss_event_rat_ogre"
}
--- Disable boss event.
mod:hook("TerrorEventMixer.run_functions.spawn", function (func, event, element, ...)
	if mod:get(mod.SETTING_NAMES.DISABLE_BOSSES) and tablex.find(mod.boss_events, event.name) then
		return true
	end

	if mod:get(mod.SETTING_NAMES.DISABLE_FIXED_EVENT_SPECIALS) and stringx.count(event.name, "_event_specials_") > 0 then
		return true
	end

	return func(event, element, ...)
end)

--- Disable patrols.
mod:hook("TerrorEventMixer.run_functions.spawn_patrol", function (func, event, element, t, dt)
	if mod:get(mod.SETTING_NAMES.DISABLE_PATROLS) then
		return true
	end

	return func(event, element, t, dt)
end)

--- Disable roaming patrols.
mod:hook("TerrorEventMixer.run_functions.roaming_patrol", function (func, event, element, t, dt)
	if mod:get(mod.SETTING_NAMES.DISABLE_ROAMING_PATROLS) then
		return true
	end

	return func(event, element, t, dt)
end)

local breeds_specials = {
	"skaven_gutter_runner",
	"skaven_pack_master",
	"skaven_ratling_gunner",
	"skaven_poison_wind_globadier",
	"chaos_vortex_sorcerer",
	"chaos_corruptor_sorcerer",
	"skaven_warpfire_thrower"
}
--- Disable timed specials.
mod:hook("ConflictDirector.spawn_queued_unit", function(func, self, breed, boxed_spawn_pos, boxed_spawn_rot, spawn_category, spawn_animation, spawn_type, optional_data, group_data, unit_data)
	if mod:get(mod.SETTING_NAMES.DISABLE_TIMED_SPECIALS) and tablex.find(breeds_specials, breed.name) then
		return
	end

	return func(self, breed, boxed_spawn_pos, boxed_spawn_rot, spawn_category, spawn_animation, spawn_type, optional_data, group_data, unit_data)
end)

--- Callbacks ---
mod.on_disabled = function(is_first_call) -- luacheck: ignore is_first_call
	mod:disable_all_hooks()
end

mod.on_enabled = function(is_first_call) -- luacheck: ignore is_first_call
	mod:enable_all_hooks()
end