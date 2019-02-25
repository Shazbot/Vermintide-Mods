local mod = get_mod("SpawnTweaks")

local pl = require'pl.import_into'()
local tablex = require'pl.tablex'
local stringx = require'pl.stringx'

fassert(pl, "Spawn Tweaks must be lower than Penlight Lua Libraries in your launcher's load order.")

--- Don't play horde warning sound when hordes disabled.
mod:hook(HordeSpawner, "play_sound", function(func, ...)
	if mod:get(mod.SETTING_NAMES.HORDES) == mod.HORDES.DISABLE then
		return
	end

	return func(...)
end)

--- Event hordes size adjustment.
mod:hook(SpawnerSystem, "_try_spawn_breed", function (func, self, breed_name, spawn_list_per_breed, spawn_list, breed_limits, active_enemies, group_template)
	if mod:get(mod.SETTING_NAMES.HORDES) == mod.HORDES.DEFAULT then
		return func(self, breed_name, spawn_list_per_breed, spawn_list, breed_limits, active_enemies, group_template)
	end

	local num_to_spawn = spawn_list_per_breed[breed_name]
	if num_to_spawn ~= nil then
		local horde_size_ratio = mod:get(mod.SETTING_NAMES.EVENT_HORDE_SIZE) / 100
		if mod:get(mod.SETTING_NAMES.HORDES) == mod.HORDES.DISABLE then
			horde_size_ratio = 0
		end
		num_to_spawn = math.round(num_to_spawn * horde_size_ratio)
		spawn_list_per_breed[breed_name] = num_to_spawn
	end

	return func(self, breed_name, spawn_list_per_breed, spawn_list, breed_limits, active_enemies, group_template)
end)

mod.original_random_interval = nil
mod.latest_random_interval_result = nil
mod.new_random_interval = function (numbers)
	local result = mod.original_random_interval(numbers)
	if result then
		local horde_size_ratio = mod:get(mod.SETTING_NAMES.HORDE_SIZE) / 100
		if mod:get(mod.SETTING_NAMES.HORDES) == mod.HORDES.DISABLE then
			horde_size_ratio = 0
		end
		result = math.round(result * horde_size_ratio)

		-- so in compose_horde_spawn_list we have "for start,start+result,1 do" which will run once for result 0
		-- and as a result we get 1 slave in every horde
		if result == 0 then
			result = -1
		end
	end

	mod.latest_random_interval_result = result

	return result
end

mod.horde_compose_hook = function (func, self, variant, ...)
	if mod:get(mod.SETTING_NAMES.HORDES) == mod.HORDES.DEFAULT then
		return func(self, variant, ...)
	end

	mod.original_random_interval = ConflictUtils.random_interval
	ConflictUtils.random_interval = mod.new_random_interval

	local return_val_1, return_val_2, return_val_3 = func(self, variant, ...)

	ConflictUtils.random_interval = mod.original_random_interval

	if mod:get(mod.SETTING_NAMES.HORDE_TYPES) == mod.HORDE_TYPES.CUSTOM
	or mod:get(mod.SETTING_NAMES.HORDE_TYPES) == mod.HORDE_TYPES.SKAVEN
	  and mod:get(mod.SETTING_NAMES.SKAVEN_HORDE_TOGGLE_GROUP)
	or mod:get(mod.SETTING_NAMES.HORDE_TYPES) == mod.HORDE_TYPES.CHAOS
	  and mod:get(mod.SETTING_NAMES.CHAOS_HORDE_TOGGLE_GROUP)
	then
		if not variant.breeds then
			variant.breeds = {}
			variant.name = "custom variant"
			variant.must_use_hidden_spawners = true
		end
		variant.breeds = {}

		local horde_setting_name = "custom_horde"
		if mod:get(mod.SETTING_NAMES.HORDE_TYPES) == mod.HORDE_TYPES.SKAVEN then
			horde_setting_name = "skaven_horde"
		end
		if mod:get(mod.SETTING_NAMES.HORDE_TYPES) == mod.HORDE_TYPES.CHAOS
		and pl.stringx.lfind(CurrentHordeSettings.name, "chaos") then
			horde_setting_name = "chaos_horde"
		end

		local total = 0
		for breed_name, _ in pairs( mod.all_breeds ) do
			total = total + mod:get(breed_name.."_"..horde_setting_name.."_weight")
		end

		for breed_name, _ in pairs( mod.all_breeds ) do
			local weight = mod:get(breed_name.."_"..horde_setting_name.."_weight")
			if weight > 0 then
				table.insert(variant.breeds, breed_name)
				table.insert(variant.breeds, math.round(weight/total * mod.latest_random_interval_result))
			end
		end

		return_val_1, return_val_2, return_val_3 = func(self, variant, ...)
	end

	return return_val_1, return_val_2, return_val_3
end

mod.blob_horde_compose_hook = function (func, self, variant, ...)
	if mod:get(mod.SETTING_NAMES.HORDES) == mod.HORDES.DEFAULT then
		return func(self, variant, ...)
	end

	-- if mod:get(mod.SETTING_NAMES.HORDE_TYPES) == mod.HORDE_TYPES.CUSTOM then
	-- 	mod.horde_compose_hook(func, self, variant, ...)
	-- end

	mod.original_random_interval = ConflictUtils.random_interval
	ConflictUtils.random_interval = mod.new_random_interval

	local return_val_1, return_val_2, return_val_3 = func(self, variant, ...)

	ConflictUtils.random_interval = mod.original_random_interval

	return return_val_1, return_val_2, return_val_3
end

--- Timed hordes size adjustment.
mod:hook(HordeSpawner, "compose_horde_spawn_list", mod.horde_compose_hook)
mod:hook(HordeSpawner, "compose_blob_horde_spawn_list", mod.blob_horde_compose_hook)

--- Fix for an assert crash for missing next queued breed when downsizing hordes.
mod:hook(HordeSpawner, "spawn_unit", function (func, self, hidden_spawn, breed_name, ...)
	if breed_name == nil then
		return
	end

	return func(self, hidden_spawn, breed_name, ...)
end)

--- Disable ambients.
mod:hook(AIInterestPointSystem, "spawn_interest_points", function (func, ...)
	if mod:get(mod.SETTING_NAMES.AMBIENTS) == mod.AMBIENTS.DISABLE then
		return
	end

	return func(...)
end)

--- Disable boss doors.
mod:hook(DoorSystem, "update", function(func, self, context, t)
	if mod:get(mod.SETTING_NAMES.BOSSES) == mod.BOSSES.DISABLE
	or (
		mod:get(mod.SETTING_NAMES.BOSSES) == mod.BOSSES.CUSTOMIZE and
		mod:get(mod.SETTING_NAMES.NO_BOSS_DOOR) and self.is_server
	) then
		for map_section, _ in pairs(table.clone(self._active_groups)) do
			self:open_boss_doors(map_section)
			self._active_groups[map_section] = nil
		end
	end

	return func(self, context, t)
end)

--- Disable patrols.
mod:hook(TerrorEventMixer.run_functions, "spawn_patrol", function (func, event, element, t, dt)
	if mod:get(mod.SETTING_NAMES.DISABLE_PATROLS) then
		return true
	end

	return func(event, element, t, dt)
end)

--- Disable roaming patrols.
mod:hook(TerrorEventMixer.run_functions, "roaming_patrol", function (func, event, element, t, dt)
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
--- More ambient elites. Replaces trash ambients with elites.
--- trash spawn without a spawn_type == ambient trash
mod:hook(ConflictDirector, "spawn_queued_unit", function(func, self, breed, boxed_spawn_pos, boxed_spawn_rot, spawn_category, spawn_animation, spawn_type, ...)
	if mod:get(mod.SETTING_NAMES.SPECIALS) == mod.SPECIALS.DISABLE and tablex.find(breeds_specials, breed.name) then
		if not stringx.lfind(debug.traceback(), "CreatureSpawner") then
			return
		end
	end

	if mod:get(mod.SETTING_NAMES.DISABLE_FIXED_SPAWNS) and spawn_category == "raw_spawner" then
		return
	end

	if mod:get(mod.SETTING_NAMES.AMBIENTS) == mod.AMBIENTS.CUSTOMIZE
	and spawn_type == "roam"
	then
		if mod:get(mod.SETTING_NAMES.CUSTOM_AMBIENTS_TOGGLE_GROUP) then
			local total = 0
			for breed_name, _ in pairs( mod.all_breeds ) do
				total = total + mod:get(breed_name.."_ambient_weight")
			end

			local rnd = math.random(total)

			local count = 0
			for breed_name, _ in pairs( mod.all_breeds ) do
				count = count + mod:get(breed_name.."_ambient_weight")
				if count >= rnd then
					breed = Breeds[breed_name]
					break
				end
			end
		elseif mod:get(mod.SETTING_NAMES.MORE_AMBIENT_ELITES) then
			if not spawn_type then
				if breed.name == "skaven_clan_rat" then
					breed = ({Breeds["skaven_plague_monk"], Breeds["skaven_storm_vermin_commander"], Breeds["skaven_storm_vermin_with_shield"]})[math.random(1,6)] or breed
				elseif breed.name == "chaos_marauder" then
					breed = ({Breeds["chaos_raider"], Breeds["chaos_fanatic"], Breeds["chaos_warrior"]})[math.random(1,6)] or breed
				end
			end
		end
	end

	return func(self, breed, boxed_spawn_pos, boxed_spawn_rot, spawn_category, spawn_animation, spawn_type, ...)
end)

--- Specials cooldowns.
mod:hook(SpecialsPacing, "specials_by_slots", function(func, self, t, specials_settings, method_data, slots, spawn_queue)
	if mod:get(mod.SETTING_NAMES.SPECIALS) ~= mod.SPECIALS.CUSTOMIZE then
		return func(self, t, specials_settings, method_data, slots, spawn_queue)
	end

	local new_method_data = tablex.deepcopy(method_data)
	new_method_data.spawn_cooldown = {
		mod:get(mod.SETTING_NAMES.SPAWN_COOLDOWN_MIN),
		mod:get(mod.SETTING_NAMES.SPAWN_COOLDOWN_MAX)
	}

	func(self, t, specials_settings, new_method_data, slots, spawn_queue)
end)

--- Did we disable all the specials breeds through checkboxes?
mod.are_all_specials_disabled = function()
	return tablex.keys(mod.specials_breeds)
		:map(function(breed_name) return mod:get(breed_name.."_toggle") end)
		:reduce("and")
end

--- Specials spawn delay from start of the level.
mod:hook(SpecialsPacing.setup_functions, "specials_by_slots", function(func, t, slots, method_data, ...)
	if mod:get(mod.SETTING_NAMES.SPECIALS) ~= mod.SPECIALS.CUSTOMIZE then
		return func(t, slots, method_data, ...)
	end

	local new_method_data = tablex.deepcopy(method_data)
	new_method_data.after_safe_zone_delay = {
		mod:get(mod.SETTING_NAMES.SAFE_ZONE_DELAY_MIN),
		mod:get(mod.SETTING_NAMES.SAFE_ZONE_DELAY_MAX)
	}

	local original_specials_settings = tablex.deepcopy(CurrentSpecialsSettings)
	CurrentSpecialsSettings.max_specials = mod:get(mod.SETTING_NAMES.MAX_SPECIALS)

	if mod.are_all_specials_disabled() then
		CurrentSpecialsSettings.breeds = {}
	end

	func(t, slots, new_method_data, ...)

	CurrentSpecialsSettings = original_specials_settings
end)

mod.get_num_alive_bosses = function()
	return #Managers.state.conflict:alive_bosses()
end

--- Change max of same special; replace special with a random boss.
mod:hook(SpecialsPacing.select_breed_functions, "get_random_breed", function(func, slots, specials_settings, method_data, ...)
	local allow_replacing_specials_with_bosses =
		mod:get(mod.SETTING_NAMES.SPECIAL_TO_BOSS_CHANCE_ALLOW_BOSS_STACKING)
		or mod.get_num_alive_bosses() == 0

	if mod:get(mod.SETTING_NAMES.BOSSES) == mod.BOSSES.CUSTOMIZE
	and allow_replacing_specials_with_bosses
	and math.random(100) <= mod:get(mod.SETTING_NAMES.SPECIAL_TO_BOSS_CHANCE) then
		return mod.bosses[math.random(#mod.bosses)]
	end

	if mod:get(mod.SETTING_NAMES.SPECIALS) ~= mod.SPECIALS.CUSTOMIZE then
		return func(slots, specials_settings, method_data, ...)
	end

	local only_enabled_breeds = tablex.keys(mod.specials_breeds)
		:filter(function(breed_name) return not mod:get(breed_name.."_toggle") end)

	-- manually select special when they are weighted
	if mod:get(mod.SETTING_NAMES.SPECIALS_WEIGHTS_TOGGLE_GROUP) then
		local total = only_enabled_breeds:map(function(breed_name) return mod:get(breed_name.."_weight") end)
			:reduce(function(acc, breed_weight) return acc + breed_weight end)
		local rnd = math.random(total)
		local count = 0
		for _, breed_name in ipairs( only_enabled_breeds ) do
			count = count + mod:get(breed_name.."_weight")
			if count >= rnd then
				return breed_name
			end
		end
	end

	local new_method_data = tablex.deepcopy(method_data)
	new_method_data.max_of_same = mod:get(mod.SETTING_NAMES.MAX_SAME_SPECIALS)

	if #only_enabled_breeds == 1 then
		new_method_data.max_of_same = mod:get(mod.SETTING_NAMES.MAX_SPECIALS)
	end

	local new_specials_settings = tablex.deepcopy(method_data)
	new_specials_settings.breeds = only_enabled_breeds

	return func(slots, new_specials_settings, new_method_data, ...)
end)

--- Get boss breed names without disabled bosses
mod.get_filtered_boss_list = function()
	local pruned_bosses = mod.bosses:clone()
	if mod:get(mod.SETTING_NAMES.NO_TROLL) then
		pruned_bosses:remove_value("chaos_troll")
	end
	if mod:get(mod.SETTING_NAMES.NO_CHAOS_SPAWN) then
		pruned_bosses:remove_value("chaos_spawn")
	end
	if mod:get(mod.SETTING_NAMES.NO_STORMFIEND) then
		pruned_bosses:remove_value("skaven_stormfiend")
	end
	return pruned_bosses
end

--- Disable boss event and double bosses.
mod.boss_events = {
	"boss_event_chaos_troll",
	"boss_event_chaos_spawn",
	"boss_event_storm_fiend",
	"boss_event_rat_ogre"
}
mod.bosses = pl.List{
	"skaven_stormfiend",
	"skaven_rat_ogre",
	"chaos_troll",
	"chaos_spawn"
}
mod:hook(TerrorEventMixer.run_functions, "spawn", function (func, event, element, ...)
	if mod:get(mod.SETTING_NAMES.BOSSES) == mod.BOSSES.DISABLE and tablex.find(mod.boss_events, event.name) then
		return true
	end

	if mod:get(mod.SETTING_NAMES.DISABLE_FIXED_EVENT_SPECIALS) and stringx.count(event.name, "_event_specials_") > 0 then
		return true
	end

	if mod:get(mod.SETTING_NAMES.BOSSES) == mod.BOSSES.CUSTOMIZE then
		if stringx.count(event.name, "boss_event") > 0 and stringx.count(event.name, "patrol") == 0 then
			local pruned_bosses = mod.get_filtered_boss_list()
			if mod:get(mod.SETTING_NAMES.NO_TROLL) and element.breed_name == "chaos_troll"
			or mod:get(mod.SETTING_NAMES.NO_CHAOS_SPAWN) and element.breed_name == "chaos_spawn"
			or mod:get(mod.SETTING_NAMES.NO_STORMFIEND) and element.breed_name == "skaven_stormfiend" then
				element.breed_name = pruned_bosses[math.random(#pruned_bosses)]
			end

			if mod:get(mod.SETTING_NAMES.DOUBLE_BOSSES) then
				local new_element = tablex.deepcopy(element)
				local bosses_no_duplicate = tablex.deepcopy(pruned_bosses)
				local duplicate_index = tablex.find(bosses_no_duplicate, element.breed_name)
				if #bosses_no_duplicate > 1 and duplicate_index then
					table.remove(bosses_no_duplicate, duplicate_index)
				end
				new_element.breed_name = bosses_no_duplicate[math.random(#bosses_no_duplicate)]
				if event.data.group_data then
					event.data.group_data.size = 2
				end
				func(event, new_element, ...)
			end
		end
	end

	return func(event, element, ...)
end)

--- Threat and intensity tweaking.
mod:hook_safe(ConflictDirector, "calculate_threat_value", function(self)
	self.threat_value = self.threat_value * mod:get(mod.SETTING_NAMES.THREAT_MULTIPLIER)
	local threat_value = self.threat_value

	self.delay_horde = self.delay_horde_threat_value < threat_value
	self.delay_mini_patrol = self.delay_mini_patrol_threat_value < threat_value
	self.delay_specials = self.delay_specials_threat_value < threat_value

	if mod:get(mod.SETTING_NAMES.SPECIALS_NO_THREAT_DELAY) then
		self.delay_specials = false
	end
end)

mod:hook_safe(Pacing, "update", function(self, t, dt, alive_player_units) -- luacheck: ignore t dt

	local num_alive_player_units = #alive_player_units

	if num_alive_player_units == 0 then
		return
	end

	for k = 1, num_alive_player_units, 1 do
		self.player_intensity[k] = self.player_intensity[k] * mod:get(mod.SETTING_NAMES.THREAT_MULTIPLIER)
	end

	self.total_intensity = self.total_intensity * mod:get(mod.SETTING_NAMES.THREAT_MULTIPLIER)
end)

mod:hook(ConflictDirector, "update_horde_pacing", function(func, self, t, dt)
	if mod:get(mod.SETTING_NAMES.HORDES) ~= mod.HORDES.CUSTOMIZE then
		return func(self, t, dt)
	end

	local original_push_horde_if_num_alive_grunts_above = RecycleSettings.push_horde_if_num_alive_grunts_above
	RecycleSettings.push_horde_if_num_alive_grunts_above = mod:get(mod.SETTING_NAMES.HORDE_GRUNT_LIMIT)

	local original_horde_frequency = tablex.deepcopy(CurrentPacing.horde_frequency)
	CurrentPacing.horde_frequency = {
		mod:get(mod.SETTING_NAMES.HORDE_FREQUENCY_MIN),
		mod:get(mod.SETTING_NAMES.HORDE_FREQUENCY_MAX)
	}

	func(self, t, dt)

	CurrentPacing.horde_frequency = original_horde_frequency
	RecycleSettings.push_horde_if_num_alive_grunts_above = original_push_horde_if_num_alive_grunts_above
end)

mod:hook(ConflictDirector, "update", function(func, self, ...)
	if mod:get(mod.SETTING_NAMES.HORDES) ~= mod.HORDES.CUSTOMIZE then
		return func(self, ...)
	end

	local original_max_grunts = RecycleSettings.max_grunts
	local original_horde_startup_time = tablex.deepcopy(CurrentPacing.horde_startup_time)

	RecycleSettings.max_grunts = mod:get(mod.SETTING_NAMES.MAX_GRUNTS)
	CurrentPacing.horde_startup_time = {
		mod:get(mod.SETTING_NAMES.HORDE_STARTUP_MIN),
		mod:get(mod.SETTING_NAMES.HORDE_STARTUP_MAX)
	}

	func(self, ...)

	RecycleSettings.max_grunts = original_max_grunts
	CurrentPacing.horde_startup_time = original_horde_startup_time
end)

mod:hook(ConflictDirector, "horde_killed", function(func, self, ...)
	if mod:get(mod.SETTING_NAMES.HORDES) ~= mod.HORDES.CUSTOMIZE then
		return func(self, ...)
	end

	local original_horde_frequency = tablex.deepcopy(CurrentPacing.horde_frequency)
	CurrentPacing.horde_frequency = {
		mod:get(mod.SETTING_NAMES.HORDE_FREQUENCY_MIN),
		mod:get(mod.SETTING_NAMES.HORDE_FREQUENCY_MAX)
	}

	func(self, ...)

	CurrentPacing.horde_frequency = original_horde_frequency
end)

--- Change ambient density.
mod:hook(SpawnZoneBaker, "spawn_amount_rats", function(func, self, spawns, pack_sizes, pack_rotations, pack_types, zone_data_list, nodes, num_wanted_rats, pack_type, area, zone)
	if mod:get(mod.SETTING_NAMES.AMBIENTS) == mod.AMBIENTS.CUSTOMIZE then
		num_wanted_rats = math.round(num_wanted_rats * mod:get(mod.SETTING_NAMES.AMBIENTS_MULTIPLIER)/100)
	end

	return func(self, spawns, pack_sizes, pack_rotations, pack_types, zone_data_list, nodes, num_wanted_rats, pack_type, area, zone)
end)

mod:hook(ConflictDirector, "update_mini_patrol", function(func, self, ...)
	local temp_cp_mini_patrol = CurrentPacing.mini_patrol.only_spawn_below_intensity
	local temp_rc_max_grunts = RecycleSettings.max_grunts
	if mod:get(mod.SETTING_NAMES.AMBIENTS_NO_THREAT) then
		CurrentPacing.mini_patrol.only_spawn_below_intensity = math.huge
		RecycleSettings.max_grunts = math.huge
	end

	func(self, ...)

	CurrentPacing.mini_patrol.only_spawn_below_intensity = temp_cp_mini_patrol
	RecycleSettings.max_grunts = temp_rc_max_grunts
end)

--- Specials always enabled.
mod:hook(TerrorEventMixer.init_functions, "control_specials", function(func, event, element, t)
	if mod:get(mod.SETTING_NAMES.ALWAYS_SPECIALS) then
		element.enable = true
	end

	return func(event, element, t)
end)

--- Specials always enabled.
mod:hook(SpecialsPacing, "update", function(func, self, t, alive_specials, specials_population, player_positions)
	if mod:get(mod.SETTING_NAMES.ALWAYS_SPECIALS) then
		specials_population = 1
	end

	if mod:get(mod.SETTING_NAMES.SPECIALS) == mod.SPECIALS.CUSTOMIZE then
		if mod.are_all_specials_disabled() then
			return
		end
	end

	return func(self, t, alive_specials, specials_population, player_positions)
end)

--- Change damage dealt to bosses.
--- Only used as an intermediate hook inside DamageUtils.add_damage_network_player.
mod:hook(DamageUtils, "calculate_damage", function(func, damage_output, target_unit, ...)
	local dmg = func(damage_output, target_unit, ...)

	if target_unit then
		local breed = Unit.get_data(target_unit, "breed")
		if breed then
			if mod:get(mod.SETTING_NAMES.BREEDS_TOGGLE_GROUP)
			and mod:get(breed.name.."_dmg_toggle") ~= 100 then
				dmg = dmg * mod:get(breed.name.."_dmg_toggle") / 100
				return dmg
			end

			if mod.bosses:contains(breed.name)
			and mod:get(mod.SETTING_NAMES.BOSSES) == mod.BOSSES.CUSTOMIZE then
				dmg = dmg * mod:get(mod.SETTING_NAMES.BOSS_DMG_MULTIPLIER) / 100
				return dmg
			end

			if mod.lord_breeds:keys():contains(breed.name)
			and mod:get(mod.SETTING_NAMES.BOSSES) == mod.BOSSES.CUSTOMIZE then
				dmg = dmg * mod:get(mod.SETTING_NAMES.LORD_DMG_MULTIPLIER) / 100
				return dmg
			end
		end
	end

	return dmg
end)
mod:hook_disable(DamageUtils, "calculate_damage")

mod:hook(DamageUtils, "add_damage_network_player", function(func, ...)
	if mod:get(mod.SETTING_NAMES.BOSSES) ~= mod.BOSSES.CUSTOMIZE then
		return func(...)
	end

	mod:hook_enable(DamageUtils, "calculate_damage")

	func(...)

	mod:hook_disable(DamageUtils, "calculate_damage")
end)

mod.no_empty_events_bosses = {
	"event_boss",
}
mod.no_empty_events_patrols = {
	"event_patrol"
}
mod.no_empty_events_both = {
	"event_boss",
	"event_patrol",
}
mod.boss_events_lookup = {
	[mod.BOSS_EVENTS.ONLY_BOSSES] = mod.no_empty_events_bosses,
	[mod.BOSS_EVENTS.ONLY_PATROLS] = mod.no_empty_events_patrols,
	[mod.BOSS_EVENTS.BOTH] = mod.no_empty_events_both,
}

mod:hook_safe(ConflictDirector, "set_updated_settings", function(self, conflict_settings_name) -- luacheck: ignore self conflict_settings_name
	if mod:is_enabled() then
		CurrentBossSettings = tablex.deepcopy(CurrentBossSettings)

		if mod:get(mod.SETTING_NAMES.NO_EMPTY_EVENTS) then
			if CurrentBossSettings.boss_events then
				CurrentBossSettings.boss_events.events = table.clone(mod.boss_events_lookup[mod:get(mod.SETTING_NAMES.BOSS_EVENTS)])
				CurrentBossSettings.boss_events.max_events_of_this_kind = {}
			end
		end

		if mod:get(mod.SETTING_NAMES.MAX_ONE_BOSS) then
			if CurrentBossSettings.boss_events then
				CurrentBossSettings.boss_events.max_events_of_this_kind.event_boss = 1
			end
		end

		CurrentHordeSettings = tablex.deepcopy(CurrentHordeSettings)
		if mod:get(mod.SETTING_NAMES.HORDE_TYPES) == mod.HORDE_TYPES.SKAVEN then
			if pl.stringx.lfind(CurrentHordeSettings.name, "chaos_") then
				local new_horde_setting_name = pl.stringx.replace(CurrentHordeSettings.name, "chaos_", "", 1)
				if HordeSettings[new_horde_setting_name] then
					CurrentHordeSettings = HordeSettings[new_horde_setting_name]
				end
			end
		end
		if mod:get(mod.SETTING_NAMES.HORDE_TYPES) == mod.HORDE_TYPES.CHAOS then
			if not pl.stringx.lfind(CurrentHordeSettings.name, "chaos_") then
				local new_horde_setting_name = "chaos_"..CurrentHordeSettings.name
				if HordeSettings[new_horde_setting_name] then
					CurrentHordeSettings = HordeSettings[new_horde_setting_name]
				else
					if CurrentHordeSettings.name == "default" then
						new_horde_setting_name = "chaos"
					end
					if CurrentHordeSettings.name == "default_light" then
						new_horde_setting_name = "chaos_light"
					end
					if HordeSettings[new_horde_setting_name] then
						CurrentHordeSettings = HordeSettings[new_horde_setting_name]
					end
				end
			end
		end
	end
end)

--- Spawn hordes from both directions.
mod:hook(HordeSpawner, "find_good_vector_horde_pos", function(func, self, main_target_pos, distance, check_reachable)
	if mod:get(mod.SETTING_NAMES.HORDES) ~= mod.HORDES.CUSTOMIZE
	or not mod:get(mod.SETTING_NAMES.HORDES_BOTH_DIRECTIONS) then
		return func(self, main_target_pos, distance, check_reachable)
	end

	local success, horde_spawners, found_cover_points, epicenter_pos = func(self, main_target_pos, distance, check_reachable)

	local o_horde_spawners = nil
	local o_found_cover_points = nil

	if success then
		o_horde_spawners = table.clone(horde_spawners)
		o_found_cover_points = table.clone(found_cover_points)

		local new_epicenter_pos = self:get_point_on_main_path(main_target_pos, -distance, check_reachable)
		if new_epicenter_pos then
			local new_success, new_horde_spawners, new_found_cover_points = self:find_vector_horde_spawners(new_epicenter_pos, main_target_pos)

			if new_success then
				for _,horde_spawner in ipairs(new_horde_spawners) do
					table.insert(o_horde_spawners, horde_spawner)
				end
				for _,cover_point in ipairs(new_found_cover_points) do
					table.insert(o_found_cover_points, cover_point)
				end
			end
		end
	end

	return success, o_horde_spawners, o_found_cover_points, epicenter_pos
end)

--- Patrols start aggroed.
mod:hook(AIGroupTemplates.spline_patrol, "update", function(func, world, nav_world, group, ...)
	if not mod.are_bosses_customized()
	or not mod:get(mod.SETTING_NAMES.AGGRO_PATROLS) then
		return func(world, nav_world, group, ...)
	end

	local state = group.state
	if state == "patrolling" then
		group.target_units = table.clone(VALID_TARGETS_PLAYERS_AND_BOTS)
		group.has_targets = true
	end

	return func(world, nav_world, group, ...)
end)

--- Disable blob vector hordes.
mod:hook(HordeSpawner, "horde", function(func, self, horde_type, extra_data, no_fallback)
	if not mod.are_hordes_customized() then
		return func(self, horde_type, extra_data, no_fallback)
	end

	local temp_vector_blob_chance = CurrentHordeSettings.chance_of_vector_blob
	if mod:get(mod.SETTING_NAMES.DISABLE_BLOC_VECTOR_HORDE) then
		CurrentHordeSettings.chance_of_vector_blob = 0
	end

	func(self, horde_type, extra_data, no_fallback)

	CurrentHordeSettings.chance_of_vector_blob = temp_vector_blob_chance
end)

mod.are_hordes_customized = function()
	return mod:get(mod.SETTING_NAMES.HORDES) == mod.HORDES.CUSTOMIZE
end

mod.are_bosses_customized = function()
	return mod:get(mod.SETTING_NAMES.BOSSES) == mod.BOSSES.CUSTOMIZE
end

mod.reset_breed_dmg = function()
	for breed_name, _ in pairs(mod.all_breeds) do
		mod:set(breed_name.."_dmg_toggle", 100)
	end

	local vmf = get_mod("VMF")
	vmf.save_unsaved_settings_to_file()
end

mod.update = function()
end

mod.on_setting_changed = function(setting_name) -- luacheck: ignore setting_name
end

mod:command("reset_breed_dmg", mod:localize("reset_breed_dmg_description"), mod.reset_breed_dmg)

mod:dofile("scripts/mods/"..mod:get_name().."/presets")
mod:dofile("scripts/mods/"..mod:get_name().."/mutators")
mod:dofile("scripts/mods/"..mod:get_name().."/no_bots")
mod:dofile("scripts/mods/"..mod:get_name().."/pickups")

mod.on_disabled = function(init_call) -- luacheck: ignore init_call
	mod:hook_enable(mod, "update")
	mod:hook_enable(SpawnManager, "all_players_disabled")
end

UIResolutionScale = function()
	return 1
end
