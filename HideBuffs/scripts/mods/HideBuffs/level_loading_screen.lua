local mod = get_mod("HideBuffs")

--- Disable level intro audio.
mod:hook(StateLoading, "_trigger_sound_events", function(func, self, level_key)
	if mod:get(mod.SETTING_NAMES.DISABLE_LEVEL_INTRO_AUDIO) then
		return
	end

	return func(self, level_key)
end)

--- Disable loading screen tips.
mod:hook(LoadingView, "setup_tip_text", function(func, ...)
	if mod:get(mod.SETTING_NAMES.HIDE_LOADING_SCREEN_TIPS) then
		return
	end

	return func(...)
end)

--- Hide loading screen subtitles.
mod:hook(LoadingView, "create_ui_elements", function(func, ...)
	local definitions = local_require("scripts/ui/views/loading_view_definitions")

	if not mod.original_num_subtitle_rows then
		mod.original_num_subtitle_rows = definitions.NUM_SUBTITLE_ROWS
	end

	if mod:get(mod.SETTING_NAMES.HIDE_LOADING_SCREEN_SUBTITLES) then
		definitions.NUM_SUBTITLE_ROWS = 0
	else
		definitions.NUM_SUBTITLE_ROWS = mod.original_num_subtitle_rows
	end

	return func(...)
end)
