local mod = get_mod("NeuterUltEffects")

local pl = require'pl.import_into'()

fassert(pl, "Neuter Ult Effects must be lower than Penlight Lua Libraries in your launcher's load order.")

--- Disable blood splatters.
mod:hook(World, "create_particles", function(func, world, particle_name, ...)
	if mod:get(mod.SETTING_NAMES.BLOOD_SPLATTER)
	and (
			particle_name == "fx/screenspace_blood_drops"
			or particle_name == "fx/screenspace_blood_drops_heavy"
		)
	then
		return
	end

	if mod:get(mod.SETTING_NAMES.DISABLE_DAMAGE_TAKEN_FLASH)
	and particle_name == "fx/screenspace_damage_indicator"
	then
		return
	end

	return func(world, particle_name, ...)
end)

local overcharge_events = {
	["Play_weapon_staff_overcharge"] = true,
	["Play_weapon_drakegun_overcharge"] = true,
	["Play_weapon_life_staff_overcharge"] = true,
}

--- Mute wizard overcharge noise.
mod:hook(WwiseWorld, "trigger_event", function(func, wwise_world, sound_event, ...)
	if overcharge_events[sound_event]
	and mod:get(mod.SETTING_NAMES.MUTE_OVERCHARGE_NOISE) then
		return
	end

	if sound_event == "hud_ping_enemy"
	and mod:get(mod.SETTING_NAMES.MUTE_ENEMY_PING) then
		return
	end

	if sound_event == "Play_wpn_steam_minigun_pump_damage"
	and mod:get(mod.SETTING_NAMES.MUTE_CRANK_GUN_MAX_RELOAD) then
		return
	end

	return func(wwise_world, sound_event, ...)
end)

--- Skip huntsman fov malarkey.
mod:hook(BuffFunctionTemplates.functions, "apply_huntsman_activated_ability", function(func, ...)
	if mod:get(mod.SETTING_NAMES["HUNTSMAN_VISUAL"]) then
		return
	end

	return func(...)
end)

--- Stop moods from getting activated.
local name_to_mood = {
	SLAYER = "skill_slayer",
	ZEALOT = "skill_zealot",
	RANGER = "skill_ranger",
	SHADE = "skill_shade",
}
mod:hook(StateInGameRunning, "update_mood", function (func, ...)
	for name, mood in pairs( name_to_mood ) do
		if mod:get(mod.SETTING_NAMES[name.."_VISUAL"]) then
			MOOD_BLACKBOARD[mood] = false
		end
	end
	if mod:get(mod.SETTING_NAMES["HUNTSMAN_VISUAL"]) then
		MOOD_BLACKBOARD["skill_huntsman_surge"] = false
		MOOD_BLACKBOARD["skill_huntsman_stealth"] = false
	end

	if mod:get(mod.SETTING_NAMES.WOUNDED) then
		MOOD_BLACKBOARD["wounded"] = false
	end
	if mod:get(mod.SETTING_NAMES.KNOCKED_DOWN) then
		MOOD_BLACKBOARD["knocked_down"] = false
	end

	if mod:get(mod.SETTING_NAMES.HEALING) then
		MOOD_BLACKBOARD["heal_medikit"] = false
	end

	return func(...)
end)

--- Skip ult audio distortions.
--- Skip potions audio.
mod.name_to_event = {
	SLAYER_AUDIO = { "Play_career_ability_bardin_slayer_loop", "Stop_career_ability_bardin_slayer_loop" },
	HUNTSMAN_AUDIO = { "Play_career_ability_markus_huntsman_loop", "Stop_career_ability_markus_huntsman_loop" },
	SHADE_AUDIO = { "Play_career_ability_kerillian_shade_loop", "Stop_career_ability_kerillian_shade_loop" },
	RANGER_AUDIO = { "Play_career_ability_bardin_ranger_loop", "Stop_career_ability_bardin_ranger_loop" },
	ZEALOT_AUDIO = { "Play_career_ability_victor_zealot_loop", "Stop_career_ability_victor_zealot_loop" },
}
mod.pot_to_event = {
	STR_POT_AUDIO = "hud_gameplay_stance_smiter_activate",
	SPEED_POT_AUDIO = "hud_gameplay_stance_ninjafencer_activate",
	CDR_POT_AUDIO = "hud_gameplay_stance_ninjafencer_activate",
}
mod.crank_gun_firing_sound_events = {
	["Play_player_engineer_shooting_burst"] = true,
	["Play_player_engineer_shooting_armor_piercing"] = true,
}
mod:hook(PlayerUnitFirstPerson, "play_hud_sound_event", function (func, self, event_name, ...)
	-- ults
	for name, event_names in pairs( mod.name_to_event ) do
		if mod:get(mod.SETTING_NAMES[name]) then
			for _, ult_event_name in ipairs( event_names ) do
				if ult_event_name == event_name then
					return
				end
			end
		end
	end

	-- potions
	for name, pot_event in pairs( mod.pot_to_event ) do
		if mod:get(mod.SETTING_NAMES[name]) and event_name == pot_event then
			return
		end
	end

	if mod.crank_gun_firing_sound_events[event_name] and mod:get(mod.SETTING_NAMES.MUTE_CRANK_GUN_SHOOTING) then
		return
	end

	return func(self, event_name, ...)
end)

--- Skip huntsman, ranger, shade ult swirly screen effect.
--- Skip potions visuals.
mod.ult_name_to_fx = {
	HUNTSMAN_VISUAL = { "fx/screenspace_huntsman_skill_01", "fx/screenspace_huntsman_skill_02" },
	SHADE_VISUAL = { "fx/screenspace_shade_skill_01", "fx/screenspace_shade_skill_02" },
	RANGER_VISUAL = { "fx/screenspace_ranger_skill_01", "fx/screenspace_ranger_skill_02" },
	IRONBREAKER_VISUAL = { "fx/screenspace_potion_03" },
}
mod.pot_name_to_fx = {
	STR_POT_VISUAL = "fx/screenspace_potion_01",
	SPEED_POT_VISUAL = "fx/screenspace_potion_02",
	CDR_POT_VISUAL = "fx/screenspace_potion_02",
}
mod:hook(BuffExtension, "_play_screen_effect", function (func, self, effect)
	-- ults
	for name, fxs in pairs( mod.ult_name_to_fx ) do
		if mod:get(mod.SETTING_NAMES[name]) then
			for _, fx in ipairs( fxs ) do
				if fx == effect then
					return
				end
			end
		end
	end

	if effect == "fx/thornsister_avatar_screenspace" and mod:get(mod.SETTING_NAMES.HIDE_SIS_RADIANCE_ENTER) then
		return
	end

	if effect == "fx/thornsister_avatar_screenspace_loop" and mod:get(mod.SETTING_NAMES.HIDE_SIS_RADIANCE_LOOP) then
		return
	end

	-- potions
	for name, pot_fx in pairs( mod.pot_name_to_fx ) do
		if mod:get(mod.SETTING_NAMES[name]) and effect == pot_fx then
			return
		end
	end

	return func(self, effect)
end)

mod:dofile("scripts/mods/"..mod:get_name().."/no_potion_glow")
mod:dofile("scripts/mods/"..mod:get_name().."/no_ult_vo")
mod:dofile("scripts/mods/"..mod:get_name().."/overcharge")
