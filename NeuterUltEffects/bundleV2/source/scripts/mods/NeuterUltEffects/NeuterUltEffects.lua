local mod = get_mod("NeuterUltEffects") -- luacheck: ignore get_mod

-- luacheck: globals BuffFunctionTemplates MOOD_BLACKBOARD StateInGameRunning BuffExtension PlayerUnitFirstPerson

local pl = require'pl.import_into'()

--- Mod Logic ---
--- Skip huntsman fov malarkey.
BuffFunctionTemplates.functions.apply_huntsman_activated_ability = function (...) -- luacheck: ignore ...
	return
end

--- Stop mood activation for specific skills.
local moods_to_keep_disabled = pl.List({
	"skill_slayer",
	"skill_zealot",
	"skill_huntsman_surge",
	"skill_huntsman_stealth",
	"skill_ranger",
	"skill_shade",
})
mod:hook(StateInGameRunning, "update_mood", function (func, ...)
	moods_to_keep_disabled:foreach(function(skill_name)
		MOOD_BLACKBOARD[skill_name] = false
	end)
	if mod:get(mod.SETTING_NAMES.WOUNDED) then
		MOOD_BLACKBOARD["wounded"] = false
	end
	if mod:get(mod.SETTING_NAMES.KNOCKED_DOWN) then
		MOOD_BLACKBOARD["knocked_down"] = false
	end
	return func(...)
end)

--- Skip Bardin hearthbeat sound loop and his ult audio distortions that mess with specials audio.
local skip_these_hud_sound_events = pl.List({
	"Play_career_ability_bardin_slayer_loop",
	"Stop_career_ability_bardin_slayer_loop",
	-- "Play_career_ability_bardin_slayer_enter",
	-- "Play_career_ability_bardin_slayer_exit",
	-- "Play_career_ability_markus_huntsman_enter",
	-- "Play_career_ability_markus_huntsman_exit",
	"Play_career_ability_markus_huntsman_loop",
	"Stop_career_ability_markus_huntsman_loop",
	-- "Play_career_ability_kerillian_shade_enter",
	-- "Play_career_ability_kerillian_shade_exit",
	"Play_career_ability_kerillian_shade_loop",
	"Stop_career_ability_kerillian_shade_loop",
})
mod:hook(PlayerUnitFirstPerson, "play_hud_sound_event", function (func, self, event_name, ...)
	if skip_these_hud_sound_events:contains(event_name) then
		return
	end
	return func(self, event_name, ...)
end)

--- Skip huntsman, ranger, shade ult swirly screen effect.
local effects_to_disable = pl.List({
	"fx/screenspace_huntsman_skill_01",
	"fx/screenspace_huntsman_skill_02",
	"fx/screenspace_ranger_skill_01",
	"fx/screenspace_ranger_skill_02",
	"fx/screenspace_shade_skill_01",
	"fx/screenspace_shade_skill_02",
})
mod:hook(BuffExtension, "_play_screen_effect", function (func, self, effect)
	if effects_to_disable:contains(effect) then
		return
	end
	return func(self, effect)
end)