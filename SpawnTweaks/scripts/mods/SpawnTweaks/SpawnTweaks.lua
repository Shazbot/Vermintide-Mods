local mod = get_mod("SpawnTweaks") -- luacheck: ignore get_mod

-- luacheck: globals math ConflictUtils unpack table BossSettings CurrentSpecialsSettings
-- luacheck: globals RecycleSettings CurrentPacing Breeds Unit DamageUtils Managers CurrentBossSettings
-- luacheck: globals HordeSpawner SpawnerSystem SpecialsPacing ConflictDirector TerrorEventMixer DoorSystem
-- luacheck: globals AIInterestPointSystem SpawnZoneBaker Pacing get_mod Application

local vmf = get_mod("VMF")

local pl = require'pl.import_into'()
local tablex = require'pl.tablex'
local stringx = require'pl.stringx'

--- "table.pack" and "unpack" replacements that are more reliable with nil values.
local function pack2(...) return {n=select('#', ...), ...} end
local function unpack2(t) return unpack(t, 1, t.n) end

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

	return result
end

mod.horde_compose_hooks = function (func, self, ...)
	if mod:get(mod.SETTING_NAMES.HORDES) == mod.HORDES.DEFAULT then
		return func(self, ...)
	end

	mod.original_random_interval = ConflictUtils.random_interval
	ConflictUtils.random_interval = mod.new_random_interval

	local return_val_1, return_val_2, return_val_3 = func(self, ...)

	ConflictUtils.random_interval = mod.original_random_interval

	return return_val_1, return_val_2, return_val_3
end

--- Timed hordes size adjustment.
mod:hook(HordeSpawner, "compose_horde_spawn_list", mod.horde_compose_hooks)
mod:hook(HordeSpawner, "compose_blob_horde_spawn_list", mod.horde_compose_hooks)

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
mod:hook(ConflictDirector, "spawn_queued_unit", function(func, self, breed, boxed_spawn_pos, boxed_spawn_rot, spawn_category, spawn_animation, spawn_type, optional_data, group_data, unit_data)
	if mod:get(mod.SETTING_NAMES.SPECIALS) == mod.SPECIALS.DISABLE and tablex.find(breeds_specials, breed.name) then
		return
	end

	if mod:get(mod.SETTING_NAMES.DISABLE_FIXED_SPAWNS) and spawn_category == "raw_spawner" then
		return
	end

	if mod:get(mod.SETTING_NAMES.AMBIENTS) == mod.AMBIENTS.CUSTOMIZE then
		if mod:get(mod.SETTING_NAMES.MORE_AMBIENT_ELITES) then
			if not spawn_type then
				if breed.name == "skaven_clan_rat" then
					breed = ({Breeds["skaven_plague_monk"], Breeds["skaven_storm_vermin_commander"], Breeds["skaven_storm_vermin_with_shield"]})[math.random(1,6)] or breed
				elseif breed.name == "chaos_marauder" then
					breed = ({Breeds["chaos_raider"], Breeds["chaos_fanatic"], Breeds["chaos_warrior"]})[math.random(1,6)] or breed
				end
			end
		end
	end

	return func(self, breed, boxed_spawn_pos, boxed_spawn_rot, spawn_category, spawn_animation, spawn_type, optional_data, group_data, unit_data)
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
mod:hook(SpecialsPacing.setup_functions, "specials_by_slots", function(func, t, slots, method_data)
	if mod:get(mod.SETTING_NAMES.SPECIALS) ~= mod.SPECIALS.CUSTOMIZE then
		return func(t, slots, method_data)
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

	func(t, slots, new_method_data)

	CurrentSpecialsSettings = original_specials_settings
end)

mod.get_num_alive_bosses = function()
	return #Managers.state.conflict:alive_bosses()
end

--- Change max of same special; replace special with a random boss.
mod:hook(SpecialsPacing.select_breed_functions, "get_random_breed", function(func, slots, breeds, method_data)
	if mod:get(mod.SETTING_NAMES.BOSSES) == mod.BOSSES.CUSTOMIZE
	and mod.get_num_alive_bosses() == 0
	and math.random(100) <= mod:get(mod.SETTING_NAMES.SPECIAL_TO_BOSS_CHANCE) then
		return mod.bosses[math.random(#mod.bosses)]
	end

	if mod:get(mod.SETTING_NAMES.SPECIALS) ~= mod.SPECIALS.CUSTOMIZE then
		return func(slots, breeds, method_data)
	end

	local only_enabled_breeds = tablex.keys(mod.specials_breeds)
		:filter(function(breed_name) return not mod:get(breed_name.."_toggle") end)

	local new_method_data = tablex.deepcopy(method_data)
	new_method_data.max_of_same = mod:get(mod.SETTING_NAMES.MAX_SAME_SPECIALS)

	if #only_enabled_breeds == 1 then
		new_method_data.max_of_same = mod:get(mod.SETTING_NAMES.MAX_SPECIALS)
	end

	return func(slots, only_enabled_breeds, new_method_data)
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

	if mod:get(mod.SETTING_NAMES.SPECIALS) == mod.SPECIALS.CUSTOMIZE
	and mod:get(mod.SETTING_NAMES.SPECIALS_NO_THREAT_DELAY) then
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

--- Specials always enabled.
mod:hook(TerrorEventMixer.init_functions, "control_specials", function(func, event, element, t)
	if mod:get(mod.SETTING_NAMES.SPECIALS) == mod.SPECIALS.CUSTOMIZE
	and mod:get(mod.SETTING_NAMES.ALWAYS_SPECIALS) then
		element.enable = true
	end

	return func(event, element, t)
end)

--- Specials always enabled.
mod:hook(SpecialsPacing, "update", function(func, self, t, alive_specials, specials_population, player_positions)
	if mod:get(mod.SETTING_NAMES.SPECIALS) == mod.SPECIALS.CUSTOMIZE then
		if mod:get(mod.SETTING_NAMES.ALWAYS_SPECIALS) then
			specials_population = 1
		end
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

mod.no_empty_events = {
	"event_boss",
	-- "event_patrol"
}

mod:hook_safe(ConflictDirector, "set_updated_settings", function(self, conflict_settings_name) -- luacheck: ignore self conflict_settings_name
	if mod:is_enabled() then
		CurrentBossSettings = tablex.deepcopy(CurrentBossSettings)

		if mod:get(mod.SETTING_NAMES.NO_EMPTY_EVENTS) then
			if CurrentBossSettings.boss_events then
				CurrentBossSettings.boss_events.events = mod.no_empty_events
				CurrentBossSettings.boss_events.max_events_of_this_kind = {}
			end
		end

		if mod:get(mod.SETTING_NAMES.MAX_ONE_BOSS) then
			if CurrentBossSettings.boss_events then
				CurrentBossSettings.boss_events.max_events_of_this_kind.event_boss = 1
			end
		end
	end
end)

--- Presets ---
mod.save_preset = function(preset_name)
	mod:pcall(function()
		if not preset_name then
			mod:echo("Preset needs a name:")
			mod:echo("/save_preset name")
			return
		end

		local mods_settings = Application.user_setting("mods_settings")
		if mods_settings then
			local mod_settings = mods_settings[mod:get_name()]
			if mod_settings then
				local presets = mod:get("presets") or {}
				local cloned_settings = table.clone(mod_settings)
				cloned_settings.presets = nil
				presets[preset_name] = cloned_settings
				mod:set("presets", presets)

				vmf.save_unsaved_settings_to_file()
				mod:echo("Saved preset "..preset_name)
			end
		end
	end)
end

mod.load_preset = function(preset_name)
	mod:pcall(function()
		if not preset_name then
			local presets = pl.Map(mod:get("presets"))
			if not presets or presets:len() == 0 then
				mod:echo("No presets to load! Save a new one with /save_preset")
				return
			end

			mod:echo("Available presets:\n"..presets:keys():join("\n"))
			mod:echo("Load using: /load_preset name")
			return
		end

		local presets = mod:get("presets")
		if presets then
			local preset = presets[preset_name]
			if not preset then
				mod:echo("Preset with that name doesn't exist!")
				return
			end

			for setting_name, setting_value in pairs( preset ) do
				mod:set(setting_name, setting_value, true)
			end

			mod:echo("Loaded preset "..preset_name.."!")
		end
	end)
end

mod.delete_preset = function(preset_name)
	mod:pcall(function()
		if not preset_name then
			mod:echo("Need a name of preset to delete: /delete_preset name")
			return
		end

		local presets = mod:get("presets")
		if presets then
			local preset = presets[preset_name]
			if not preset then
				mod:echo("Preset with that name doesn't exist!")
				return
			end

			presets[preset_name] = nil
			mod:set("presets", presets)
			vmf.save_unsaved_settings_to_file()

			mod:echo("Deleted preset "..preset_name.."!")
		end
	end)
end

mod.reset_breed_dmg = function()
	for breed_name, _ in pairs(mod.all_breeds) do
		mod:set(breed_name.."_dmg_toggle", 100)
	end
	vmf.save_unsaved_settings_to_file()
end

mod:command("save_preset", mod:localize("save_preset_command_description"), mod.save_preset)
mod:command("load_preset", mod:localize("load_preset_command_description"), mod.load_preset)
mod:command("delete_preset", mod:localize("delete_preset_command_description"), mod.delete_preset)
mod:command("reset_breed_dmg", mod:localize("reset_breed_dmg_description"), mod.reset_breed_dmg)
