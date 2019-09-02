local mod = get_mod("SpawnTweaks")

local pl = require'pl.import_into'()

mod.specials_mut = {}

mod.specials_mut.before_add_damage_network_player = function(damage_profile, target_index, power_level, hit_unit, attacker_unit, hit_zone_name, hit_position, attack_direction) -- luacheck: no unused
	if not mod.specials_mut.is_mut_enabled() then
		return
	end

	if damage_profile.default_target.attack_template == "shot_machinegun" then
		mod:pcall(function()
			local status_ext = ScriptUnit.has_extension(hit_unit, "status_system")
			if status_ext and not status_ext:is_disabled() then
				local to_player = attack_direction
				local hit_unit_pos = Unit.world_position(hit_unit, 0)
				local attacker_unit_pos = Unit.world_position(attacker_unit, 0)

				local dist = Vector3.length(hit_unit_pos - attacker_unit_pos)

				local push_velocity = Vector3.normalize(to_player) * 1/dist*10
				local player_locomotion = ScriptUnit.has_extension(hit_unit, "locomotion_system")
				if player_locomotion then
					player_locomotion:add_external_velocity(push_velocity)
				end
			end
		end)
	end
end
mod.dispatcher:on("before_add_damage_network_player",
function(event, ...) -- luacheck: no unused
	mod.specials_mut.on_mutator_toggled(...)
end)

mod:hook(BTRatlingGunnerShootAction, "enter",
function(func, self, unit, blackboard, t)
	func(self, unit, blackboard, t)
	blackboard.attack_pattern_data = table.clone(blackboard.attack_pattern_data)
	-- doubling these two:
	blackboard.attack_pattern_data.time_between_shots_at_start = 0.05
	blackboard.attack_pattern_data.time_between_shots_at_end = 0.02
end)

mod:hook(BTRatlingGunnerWindUpAction, "enter",
function(func, self, unit, blackboard, t)
	func(self, unit, blackboard, t)
	pcall(function()
		local data = blackboard.attack_pattern_data
		data.wind_up_timer = data.wind_up_timer / 2
		data.wind_up_time = data.wind_up_timer
	end)
end)

mod:hook(BTSkulkAroundAction, "enter",
function(func, self, unit, blackboard, t)
	local skulk_data = blackboard.skulk_data
	local override_attack_timer = false
	if skulk_data and not skulk_data.attack_timer then
		override_attack_timer = true
	end
	func(self, unit, blackboard, t)
	if override_attack_timer then
		skulk_data.attack_timer = t + math.random(0.5, 3)
	end
	blackboard.navigation_extension:set_max_speed(12)
end)

mod:hook(BTSkulkIdleAction, "enter",
function(func, self, unit, blackboard, t)
	local skulk_data = blackboard.skulk_data
	local override_attack_timer = false
	if skulk_data and not skulk_data.attack_timer then
		override_attack_timer = true
	end
	func(self, unit, blackboard, t)
	if override_attack_timer then
		skulk_data.attack_timer = t + math.random(0.5, 3)
	end
	blackboard.navigation_extension:set_max_speed(12)
end)

mod:hook(BTNinjaApproachAction, "run",
function(func, self, unit, blackboard, t, dt)
	blackboard.urgency_to_engage = 100
	return func(self, unit, blackboard, t, dt)
end)

mod:hook_safe(BTNinjaApproachAction, "enter",
function(self, unit, blackboard, t) -- luacheck: no unused
	blackboard.navigation_extension:set_max_speed(12)
end)


mod:hook_safe(BTTargetPouncedAction, "leave",
function(self, unit, blackboard, t, reason, destroy) -- luacheck: no unused
	blackboard.ninja_vanish = true
end)

mod:hook_safe(BTCrazyJumpAction, "leave",
function(self, unit, blackboard, t, reason, destroy) -- luacheck: no unused
	if reason == "aborted" or reason == "failed" then
		blackboard.ninja_vanish = true
	end
end)

mod:hook_safe(BTStaggerAction, "leave",
function(self, unit, blackboard, t, reason, destroy) -- luacheck: no unused
	blackboard.ninja_vanish = true
end)

--- Force globadier suicide.
mod:hook(BTConditions, "suicide_run",
function(func, blackboard)
	if blackboard.mod_force_suicide == nil then
		blackboard.mod_force_suicide = math.random(1, 10) < 3
	end
	return blackboard.mod_force_suicide or func(blackboard)
end)

--- When running to explode use distance from player 1 instead of 2
--- to start exploding.
-- CHECK
-- PerceptionUtils.pick_closest_target = function (ai_unit, blackboard, breed)
mod:hook(PerceptionUtils, "pick_closest_target",
function(func, ai_unit, blackboard, breed)
	local closest_enemy, closest_dist = func(ai_unit, blackboard, breed)
	if closest_dist < 2 and closest_dist > 1 then
		closest_dist = 2.1
	end
	return closest_enemy, closest_dist
end)
mod:hook_disable(PerceptionUtils, "pick_closest_target")

mod:hook(BTSuicideRunAction.StateMove, "update",
function(func, self, dt, t)
	mod:hook_enable(PerceptionUtils, "pick_closest_target")
	local ret = func(self, dt, t)
	mod:hook_disable(PerceptionUtils, "pick_closest_target")
	return ret
end)

mod:hook_safe(BTSuicideRunAction.StateMove, "on_enter",
function(self, params)
	local blackboard = params.blackboard
	if blackboard.mod_force_suicide then
		self.explode_timer = 18
	end
end)

local hitzone_primary_armor_categories = {
	head = {
		attack = 6,
		impact = 2
	},
	neck = {
		attack = 6,
		impact = 2
	}
}
local hitzone_primary_armor_categories_warpfire_thrower = {
	head = {
		attack = 6,
		impact = 2
	},
	neck = {
		attack = 6,
		impact = 2
	},
	aux = {
		attack = 6,
		impact = 2
	}
}
local hitzone_multiplier_types_warpfire_thrower  = {
	head = "headshot",
	aux = "protected_weakspot",
}
local ignore_staggers = {
	true,
	true,
	true,
	true,
	true,
	true
}

mod.specials_mut.breeds_overrides = {
	skaven_ratling_gunner = {
		hitzone_primary_armor_categories = table.clone(hitzone_primary_armor_categories),
		armor_category = 2,
		primary_armor_category = 6,
		run_speed = 8,
		walk_speed = 6,
	},
	chaos_vortex_sorcerer = {
		hitzone_primary_armor_categories = table.clone(hitzone_primary_armor_categories),
		armor_category = 2,
		primary_armor_category = 6,
	},
	skaven_poison_wind_globadier = {
		armor_category = 2,
		run_speed = 5,
		walk_speed = 4,
	},
	skaven_warpfire_thrower = {
		hitzone_primary_armor_categories = table.clone(hitzone_primary_armor_categories_warpfire_thrower),
		hitzone_multiplier_types = table.clone(hitzone_multiplier_types_warpfire_thrower),
		armor_category = 2,
		primary_armor_category = 6,
		run_speed = 5,
		walk_speed = 4,
	}
}
local breeds_overrides = mod.specials_mut.breeds_overrides

mod.specials_mut.breed_actions_overrides = {
	skaven_ratling_gunner = {
		shoot_ratling_gun = {
			ignore_staggers = table.clone(ignore_staggers)
		}
	},
	skaven_poison_wind_globadier = {
		advance_towards_players = {
			time_until_first_throw = {
				0,
				1
			},
			throw_at_distance = {
				5,
				40
			},
			range = 60,
		},
		throw_poison_globe = {
			barrage_count = 8,
			time_between_throws = {
				8,
				1
			},
		},
	},
	skaven_pack_master = {
		skulk = {
			ignore_staggers = table.clone(ignore_staggers)
		},
		follow = {
			ignore_staggers = table.clone(ignore_staggers)
		},
	},
	chaos_corruptor_sorcerer = {
		grab_attack = {
			ignore_staggers = table.clone(ignore_staggers)
		},
	},
	skaven_warpfire_thrower = {
		shoot_warpfire_thrower = {
			ignore_staggers = table.clone(ignore_staggers)
		},
	},
}
local breed_actions_overrides = mod.specials_mut.breed_actions_overrides

mod.specials_mut.enable_mut = function()
	if not mod.persistent.juiced_specials_backups_done then
		return
	end

	for breed_name, breed_data in pairs( table.clone(breeds_overrides) ) do
		Breeds[breed_name] = pl.tablex.merge(Breeds[breed_name], breed_data, true)
	end

	for breed_name, actions in pairs( table.clone(breed_actions_overrides) ) do
		for action_name, action in pairs( actions ) do
			BreedActions[breed_name][action_name] =
				pl.tablex.merge(BreedActions[breed_name][action_name], action, true)
		end
	end

	mod:hook_enable(BTRatlingGunnerShootAction, "enter")
	mod:hook_enable(BTRatlingGunnerWindUpAction, "enter")
	mod:hook_enable(BTSkulkAroundAction, "enter")
	mod:hook_enable(BTSkulkIdleAction, "enter")
	mod:hook_enable(BTNinjaApproachAction, "run")
	mod:hook_enable(BTNinjaApproachAction, "enter")
	mod:hook_enable(BTTargetPouncedAction, "leave")
	mod:hook_enable(BTCrazyJumpAction, "leave")
	mod:hook_enable(BTStaggerAction, "leave")
	mod:hook_enable(BTConditions, "suicide_run")
	mod:hook_enable(BTSuicideRunAction.StateMove, "update")
	mod:hook_enable(BTSuicideRunAction.StateMove, "on_enter")
end

mod.specials_mut.disable_hooks = function()
	mod:hook_disable(BTRatlingGunnerShootAction, "enter")
	mod:hook_disable(BTRatlingGunnerWindUpAction, "enter")
	mod:hook_disable(BTSkulkAroundAction, "enter")
	mod:hook_disable(BTSkulkIdleAction, "enter")
	mod:hook_disable(BTNinjaApproachAction, "run")
	mod:hook_disable(BTNinjaApproachAction, "enter")
	mod:hook_disable(BTTargetPouncedAction, "leave")
	mod:hook_disable(BTCrazyJumpAction, "leave")
	mod:hook_disable(BTStaggerAction, "leave")
	mod:hook_disable(BTConditions, "suicide_run")
	mod:hook_disable(BTSuicideRunAction.StateMove, "update")
	mod:hook_disable(BTSuicideRunAction.StateMove, "on_enter")
end

mod.specials_mut.disable_mut = function()
	if not mod.persistent.juiced_specials_backups_done then
		return
	end

	Breeds = pl.tablex.merge(Breeds, table.clone(mod.persistent.specials_mut.breeds_backups), true)
	BreedActions = pl.tablex.merge(BreedActions, table.clone(mod.persistent.specials_mut.breed_actions_backups), true)

	mod.specials_mut.disable_hooks()
end

mod.specials_mut.is_mut_enabled = function()
	return mod:get(mod.SETTING_NAMES.JUICED_SPECIALS_MUTATOR)
end

mod.specials_mut.disabled_units = {}
mod:hook(ConflictDirector, "_post_spawn_unit", function(func, self, ai_unit, go_id, breed, ...)
	if not mod.specials_mut.is_mut_enabled() then
		return func(self, ai_unit, go_id, breed, ...)
	end

	if breed.name == "skaven_pack_master" then
		Unit.set_local_scale(ai_unit, 0, Vector3(0.85,0.85,0.85))
		Unit.disable_physics(ai_unit)
		table.insert(mod.specials_mut.disabled_units, ai_unit)
	end

	return func(self, ai_unit, go_id, breed, ...)
end)

mod.dispatcher:on(
	"onModUpdate",
	function()
		if not mod.specials_mut.is_mut_enabled() then
			return
		end

		for _, unit in ipairs( mod.specials_mut.disabled_units ) do
			Unit.enable_physics(unit)
		end
		mod.specials_mut.disabled_units = {}
	end)

mod.juiced_specials_update_func = function()
	if Breeds and not mod.persistent.juiced_specials_backups_done then
		mod.persistent.juiced_specials_backups_done = true
		mod.persistent.specials_mut = {}
		mod.persistent.specials_mut.breeds_backups = pl.tablex.merge(Breeds, breeds_overrides)
		mod.persistent.specials_mut.breed_actions_backups = pl.tablex.merge(BreedActions, breed_actions_overrides)

		-- Actually enable once we have the backups.
		if mod.specials_mut.is_mut_enabled() then
			mod.specials_mut.enable_mut()
		end
	end
end
table.insert(mod.update_funcs, function() mod.juiced_specials_update_func() end)

mod.specials_mut.on_mutator_toggled = function()
	if mod.specials_mut.is_mut_enabled() then
		mod.specials_mut.enable_mut()
	else
		mod.specials_mut.disable_mut()
	end
end

mod.dispatcher:on("juicedSpecialsToggled",
	function(...)
		mod.specials_mut.on_mutator_toggled(...)
	end)

mod.dispatcher:on("onModDisabled",
	function()
		mod.specials_mut.disable_hooks()
	end)
mod.dispatcher:on("onModEnabled",
	function()
		mod.specials_mut.on_mutator_toggled()
	end)

mod.specials_mut.disable_hooks()
