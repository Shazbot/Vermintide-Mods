local mod = get_mod("SpawnTweaks") -- luacheck: ignore get_mod

-- luacheck: globals math ConflictUtils unpack table BossSettings CurrentSpecialsSettings

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
mod:hook("HordeSpawner.spawn_unit", function (func, self, hidden_spawn, breed_name, ...)
	if breed_name == nil then
		return
	end

	return func(self, hidden_spawn, breed_name, ...)
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

--- Specials cooldowns.
mod:hook("SpecialsPacing.specials_by_slots", function(func, self, t, specials_settings, method_data, slots, spawn_queue)
	local new_method_data = tablex.deepcopy(method_data)
	new_method_data.spawn_cooldown = {
		mod:get(mod.SETTING_NAMES.SPAWN_COOLDOWN_MIN),
		mod:get(mod.SETTING_NAMES.SPAWN_COOLDOWN_MAX)
	}

	local original_specials_settings = tablex.deepcopy(CurrentSpecialsSettings)
	CurrentSpecialsSettings.max_specials = mod:get(mod.SETTING_NAMES.MAX_SPECIALS)

	func(self, t, specials_settings, new_method_data, slots, spawn_queue)

	CurrentSpecialsSettings = original_specials_settings
end)

--- Specials spawn delay from start of the level.
mod:hook("SpecialsPacing.setup_functions.specials_by_slots", function(func, t, slots, method_data)
	local new_method_data = tablex.deepcopy(method_data)
	new_method_data.after_safe_zone_delay = {
		mod:get(mod.SETTING_NAMES.SAFE_ZONE_DELAY_MIN),
		mod:get(mod.SETTING_NAMES.SAFE_ZONE_DELAY_MAX)
	}
	func(t, slots, new_method_data)
end)

--- Change max of same special.
mod:hook("SpecialsPacing.select_breed_functions.get_random_breed", function(func, slots, breeds, method_data)
	local new_method_data = tablex.deepcopy(method_data)
	new_method_data.max_of_same = mod:get(mod.SETTING_NAMES.MAX_SAME_SPECIALS)
	return func(slots, breeds, new_method_data)
end)

--- Double bosses.
mod.bosses = {
	"skaven_stormfiend",
	"skaven_rat_ogre",
	"chaos_troll",
	"chaos_spawn"
}
mod:hook("TerrorEventMixer.run_functions.spawn", function (func, event, element, ...)
	if not mod:get(mod.SETTING_NAMES.DOUBLE_BOSSES) then
		return func(event, element, ...)
	end

	if stringx.count(event.name, "boss_event") > 0
	  and stringx.count(event.name, "patrol") == 0 then
		local new_element = tablex.deepcopy(element)
		local bosses_no_duplicate = tablex.deepcopy(mod.bosses)
		local duplicate_index = tablex.find(bosses_no_duplicate, element.breed_name)
		if duplicate_index then
			table.remove(bosses_no_duplicate, duplicate_index)
		end
		new_element.breed_name = bosses_no_duplicate[math.random(#bosses_no_duplicate)]
		if event.data.group_data then
			event.data.group_data.size = 2
		end
		func(event, new_element, ...)
	end

	return func(event, element, ...)
end)

--- Threat and intensity tweaking.
mod:hook("ConflictDirector.calculate_threat_value", function(func, self)
	func(self)

	self.threat_value = self.threat_value * mod:get(mod.SETTING_NAMES.THREAT_MULTIPLIER)
	local threat_value = self.threat_value

	self.delay_horde = self.delay_horde_threat_value < threat_value
	self.delay_mini_patrol = self.delay_mini_patrol_threat_value < threat_value
	self.delay_specials = self.delay_specials_threat_value < threat_value
end)

--- Callbacks ---
mod.on_disabled = function(is_first_call) -- luacheck: ignore is_first_call
	mod:disable_all_hooks()

	mod.on_setting_changed(mod.SETTING_NAMES.NO_EMPTY_EVENTS)
end

mod.on_enabled = function(is_first_call) -- luacheck: ignore is_first_call
	mod:enable_all_hooks()

	mod.on_setting_changed(mod.SETTING_NAMES.NO_EMPTY_EVENTS)
end

mod.update = function()
	mod:pcall(function()
		local boss_settings_backup = mod:persistent_table("backups").BossSettings
		if BossSettings and not boss_settings_backup then
			mod:persistent_table("backups").BossSettings = tablex.deepcopy(BossSettings)
		end
	end)
end

mod.no_empty_events = {
	"event_boss",
	-- "event_patrol"
}

mod.on_setting_changed = function(setting_name)
	local boss_settings_backup = mod:persistent_table("backups").BossSettings
	if setting_name == mod.SETTING_NAMES.NO_EMPTY_EVENTS and boss_settings_backup then
		if mod:is_enabled() and mod:get(mod.SETTING_NAMES.NO_EMPTY_EVENTS) then
			for _, boss_setting in pairs( BossSettings ) do
				if boss_setting.boss_events and boss_setting.boss_events.events then
					boss_setting.boss_events.events = mod.no_empty_events
					boss_setting.boss_events.max_events_of_this_kind = {}
				end
			end
		else
			if mod:persistent_table("backups").BossSettings then
				BossSettings = tablex.deepcopy(mod:persistent_table("backups").BossSettings)
			end
		end
	end
end