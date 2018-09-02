local mod = get_mod("TrueSoloQoL") -- luacheck: ignore get_mod

-- luacheck: globals LevelTransitionHandler get_mod
-- luacheck: globals ConflictDirector Breeds Managers WwiseWorld GameModeManager UnitFrameUI
-- luacheck: globals TerrorEventBlueprints NetworkLookup fassert ScriptUnit TutorialUI
-- luacheck: globals PlayerHud AreaIndicatorUI script_data UISettings

local pl = require'pl.import_into'()

fassert(pl, "True Solo QoL Tweaks must be lower than Penlight Lua Libraries in your launcher's load order.")

--- Restart the level on mission failure.
--- Without it we'd transitions to the inn.
mod:hook(GameModeManager, "server_update", function (func, self, dt, t)
	local original_evaluate_end_conditions = self._game_mode.evaluate_end_conditions
	self._game_mode.evaluate_end_conditions = function(...)
		local ended, reason = original_evaluate_end_conditions(...)
		if ended and reason == "lost" then
			return ended, "reload"
		end
		return ended, reason
	end

	func(self, dt, t)

	self._game_mode.evaluate_end_conditions = original_evaluate_end_conditions
end)

--- Track frame_index to know if it's bot UI. Player frame_index is nil.
mod:hook(UnitFrameUI, "_create_ui_elements", function (func, self, frame_index)
	self._frame_index = frame_index
	func(self, frame_index)
end)

--- Make sure bots UI doesn't reappear.
mod:hook(UnitFrameUI, "update", function (func, self, ...)
	mod:pcall(function()
		if self._mod_stay_hidden then
			self:set_visible(self.data.level_text ~= "BOT")
		end
	end)
	func(self, ...)
end)

mod.update = function()
	--- Hook the kill_bots function of Killbots and add UI hiding code after we run /killbots.
	local killbots_mod = get_mod("Killbots")
	if killbots_mod and not killbots_mod.original_kill_bots then
		killbots_mod.original_kill_bots = killbots_mod.original_kill_bots or killbots_mod.kill_bots
		killbots_mod.kill_bots = function(self)
			killbots_mod:original_kill_bots()
			mod:pcall(function()
				local unit_frames_handler = rawget(_G, "unit_frames_handler")
				for _, unit_frame in ipairs( unit_frames_handler._unit_frames ) do
					local unit_frame_ui = unit_frame.widget
					if unit_frame_ui._frame_index
					  and unit_frame_ui._is_visible
					  and unit_frame_ui.data.level_text == "BOT" then
						unit_frame_ui:set_visible(false)
						unit_frame_ui._mod_stay_hidden = true
					end
				end
			end)
		end
	end
end

mod:hook("Localize", function(func, key)
	if pl.stringx.count(key, "ASSASSIN_WARNING_") > 0 then
		key = pl.stringx.replace(key, "ASSASSIN_WARNING_", "")
		key = pl.stringx.replace(key, "_DUPE", "")
		key = pl.stringx.replace(key, "_", " ")
		return key
	end
	return func(key)
end)

mod.get_num_alive_assassins = function()
	return Managers.state.conflict:count_units_by_breed("skaven_gutter_runner")
end

mod:hook(PlayerHud, "set_current_location", function(func, self, location)
	if mod:get(mod.SETTING_NAMES.ASSASSIN_TEXT_WARNING) then
		return
	end
	return func(self, location)
end)

mod:hook(AreaIndicatorUI, "update", function(func, self, dt)
	if mod:get(mod.SETTING_NAMES.ASSASSIN_TEXT_WARNING) then
		mod:pcall(function()
			self.area_text_box.style.text.text_color[2] = 255
			self.area_text_box.style.text.text_color[3] = 0
			self.area_text_box.style.text.text_color[4] = 0
		end)
	end
	return func(self, dt)
end)

mod:hook(ConflictDirector, "spawn_queued_unit", function(func, self, breed, boxed_spawn_pos, boxed_spawn_rot, spawn_category, spawn_animation, spawn_type, optional_data, group_data, unit_data)
	-- local assassin_spawn_option = mod:get(mod.SETTING_NAMES.ASSASSIN_STINGER_FIX)

	-- if assassin_spawn_option == mod.ASSASSIN_SOUND_OPTIONS.DEFAULT then
	-- 	Breeds.skaven_gutter_runner.special_spawn_stinger = "enemy_gutterrunner_stinger"
	-- else
	-- 	Breeds.skaven_gutter_runner.special_spawn_stinger = nil
	-- end

	if breed.name == "skaven_gutter_runner" then
		if mod:get(mod.SETTING_NAMES.ASSASSIN_TEXT_WARNING) then
			UISettings.area_indicator.wait_time = 0
			local player_unit = Managers.player:local_player().player_unit
			local player_hud_extension = ScriptUnit.extension(player_unit, "hud_system")
			if mod.get_num_alive_assassins() > 0 then
				player_hud_extension.current_location = "ASSASSIN_WARNING_ASS_"..(mod.get_num_alive_assassins()+1)
			else
				if player_hud_extension.current_location == "ASSASSIN_WARNING_ASS!" then
					player_hud_extension.current_location = "ASSASSIN_WARNING_ASS!_DUPE"
				else
					player_hud_extension.current_location = "ASSASSIN_WARNING_ASS!"
				end
			end
		else
			UISettings.area_indicator.wait_time = 1
		end

		-- local wwise_world = Managers.world:wwise_world(self._world)
		-- if assassin_spawn_option == mod.ASSASSIN_SOUND_OPTIONS.FIXED then
		-- 	WwiseWorld.trigger_event(wwise_world, "enemy_gutterrunner_stinger")
		-- elseif assassin_spawn_option == mod.ASSASSIN_SOUND_OPTIONS.KRENCH then
		-- 	Managers.state.network.network_transmit:send_rpc_all("rpc_server_audio_event", NetworkLookup.sound_events["Play_hud_matchmaking_countdown"])
		-- 	self._mod_times_to_play_sound = self._mod_times_to_play_sound or {}
		-- 	table.insert(self._mod_times_to_play_sound, self._time + 1)
		-- 	table.insert(self._mod_times_to_play_sound, self._time + 2)
		-- end
	end

	return func(self, breed, boxed_spawn_pos, boxed_spawn_rot, spawn_category, spawn_animation, spawn_type, optional_data, group_data, unit_data)
end)

-- mod:hook(ConflictDirector, "update", function(func, self, dt, t)
-- 	self._mod_times_to_play_sound = self._mod_times_to_play_sound or {}
-- 	for _, time in ipairs( self._mod_times_to_play_sound ) do
-- 		if time < t then
-- 			Managers.state.network.network_transmit:send_rpc_all("rpc_server_audio_event", NetworkLookup.sound_events["Play_hud_matchmaking_countdown"])
-- 		end
-- 	end
-- 	for i=#self._mod_times_to_play_sound, 1, -1 do
-- 	    if self._mod_times_to_play_sound[i] < t then
-- 	        table.remove(self._mod_times_to_play_sound, i)
-- 	    end
-- 	end
-- 	return func(self, dt, t)
-- end)