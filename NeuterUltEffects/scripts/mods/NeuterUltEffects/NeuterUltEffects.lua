local mod = get_mod("NeuterUltEffects") -- luacheck: ignore get_mod

-- luacheck: globals BuffFunctionTemplates MOOD_BLACKBOARD StateInGameRunning BuffExtension PlayerUnitFirstPerson

local pl = require'pl.import_into'()

--- Skip huntsman fov malarkey.
mod:hook(BuffFunctionTemplates.functions, "apply_huntsman_activated_ability", function(func, ...)
	if mod:get(mod.SETTING_NAMES["HUNTSMAN_VISUAL"]) then
		return
	end

	return func(...)
end)

--- Stop mood activation for specific skills.
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
	return func(...)
end)

--- Skip audio distortions.
local name_to_event = {
	SLAYER = { "Play_career_ability_bardin_slayer_loop", "Stop_career_ability_bardin_slayer_loop" },
	HUNTSMAN = { "Play_career_ability_markus_huntsman_loop", "Stop_career_ability_markus_huntsman_loop" },
	SHADE = { "Play_career_ability_kerillian_shade_loop", "Stop_career_ability_kerillian_shade_loop" },
	RANGER = { "Play_career_ability_bardin_ranger_loop", "Stop_career_ability_bardin_ranger_loop" },
	ZEALOT = { "Play_career_ability_victor_zealot_loop", "Stop_career_ability_victor_zealot_loop" },
}
mod:hook(PlayerUnitFirstPerson, "play_hud_sound_event", function (func, self, event_name, ...)
	for name, event_names in pairs( name_to_event ) do
		if mod:get(mod.SETTING_NAMES[name.."_AUDIO"]) then
			for _, ult_event_name in ipairs( event_names ) do
				if ult_event_name == event_name then
					return
				end
			end
		end
	end
	return func(self, event_name, ...)
end)

--- Skip huntsman, ranger, shade ult swirly screen effect.
local name_to_fx = {
	HUNTSMAN = { "fx/screenspace_huntsman_skill_01", "fx/screenspace_huntsman_skill_02" },
	SHADE = { "fx/screenspace_shade_skill_01", "fx/screenspace_shade_skill_02" },
	RANGER = { "fx/screenspace_ranger_skill_01", "fx/screenspace_ranger_skill_02" },
}
mod:hook(BuffExtension, "_play_screen_effect", function (func, self, effect)
	for name, fxs in pairs( name_to_fx ) do
		if mod:get(mod.SETTING_NAMES[name.."_VISUAL"]) then
			for _, fx in ipairs( fxs ) do
				if fx == effect then
					return
				end
			end
		end
	end
	return func(self, effect)
end)