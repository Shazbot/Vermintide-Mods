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
mod.dispatcher:on("before_add_damage_network_player", function(event, ...) mod.specials_mut.on_mutator_toggled(...) end) -- luacheck: no unused

mod:hook(BTRatlingGunnerShootAction, "enter", function(func, self, unit, blackboard, t)
	func(self, unit, blackboard, t)
	blackboard.attack_pattern_data = table.clone(blackboard.attack_pattern_data)
	-- doubling these two:
	blackboard.attack_pattern_data.time_between_shots_at_start = 0.05
	blackboard.attack_pattern_data.time_between_shots_at_end = 0.02
end)

mod:hook(BTRatlingGunnerWindUpAction, "enter", function(func, self, unit, blackboard, t)
	func(self, unit, blackboard, t)
	pcall(function()
		local data = blackboard.attack_pattern_data
		data.wind_up_timer = data.wind_up_timer / 2
		data.wind_up_time = data.wind_up_timer
	end)
end)

mod:hook(BTSkulkAroundAction, "enter", function(func, self, unit, blackboard, t)
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

mod:hook(BTSkulkIdleAction, "enter", function(func, self, unit, blackboard, t)
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

mod:hook(BTNinjaApproachAction, "run", function(func, self, unit, blackboard, t, dt)
	blackboard.urgency_to_engage = 100
	return func(self, unit, blackboard, t, dt)
end)

mod:hook_safe(BTNinjaApproachAction, "enter", function(self, unit, blackboard, t) -- luacheck: no unused
	blackboard.navigation_extension:set_max_speed(12)
end)


mod:hook_safe(BTTargetPouncedAction, "leave", function(self, unit, blackboard, t, reason, destroy) -- luacheck: no unused
	blackboard.ninja_vanish = true
end)

mod:hook_safe(BTCrazyJumpAction, "leave", function(self, unit, blackboard, t, reason, destroy) -- luacheck: no unused
	if reason == "aborted" or reason == "failed" then
		blackboard.ninja_vanish = true
	end
end)

mod:hook_safe(BTStaggerAction, "leave", function(self, unit, blackboard, t, reason, destroy) -- luacheck: no unused
	blackboard.ninja_vanish = true
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
		run_speed = 10,
		walk_speed = 6,
	},
	chaos_vortex_sorcerer = {
		hitzone_primary_armor_categories = table.clone(hitzone_primary_armor_categories),
		armor_category = 2,
		primary_armor_category = 6,
	},
	skaven_poison_wind_globadier = {
		run_speed = 10,
		walk_speed = 5,
	},
	skaven_warpfire_thrower = {
		run_speed = 9,
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
}
local breed_actions_overrides = mod.specials_mut.breed_actions_overrides

mod.specials_mut.enable_mut = function()
	Breeds = pl.tablex.merge(Breeds, table.clone(breeds_overrides), true)
	BreedActions = pl.tablex.merge(BreedActions, table.clone(breed_actions_overrides), true)

	mod:hook_enable(BTRatlingGunnerShootAction, "enter")
	mod:hook_enable(BTRatlingGunnerWindUpAction, "enter")
	mod:hook_enable(BTSkulkAroundAction, "enter")
	mod:hook_enable(BTSkulkIdleAction, "enter")
	mod:hook_enable(BTNinjaApproachAction, "run")
	mod:hook_enable(BTNinjaApproachAction, "enter")
	mod:hook_enable(BTTargetPouncedAction, "leave")
	mod:hook_enable(BTCrazyJumpAction, "leave")
	mod:hook_enable(BTStaggerAction, "leave")
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
end

mod.specials_mut.disable_mut = function()
	Breeds = pl.tablex.merge(Breeds, table.clone(mod.persistent.specials_mut.breeds_backups), true)
	BreedActions = pl.tablex.merge(BreedActions, table.clone(mod.persistent.specials_mut.breed_actions_backups), true)

	mod.specials_mut.disable_hooks()
end

mod.specials_mut.is_mut_enabled = function()
	return mod:get(mod.SETTING_NAMES.JUICED_SPECIALS_MUTATOR)
end

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
mod.dispatcher:on("juicedSpecialsToggled", function(...) mod.specials_mut.on_mutator_toggled(...) end)

mod.dispatcher:on("onModDisabled", function()
	mod.specials_mut.disable_hooks()
end)
mod.dispatcher:on("onModEnabled", function()
	mod.specials_mut.on_mutator_toggled()
end)

mod.specials_mut.disable_hooks()
