-- luacheck: globals LevelTransitionHandler get_mod
-- luacheck: globals ConflictDirector Breeds Managers WwiseWorld GameModeManager UnitFrameUI
-- luacheck: globals TerrorEventBlueprints NetworkLookup fassert ScriptUnit TutorialUI
-- luacheck: globals PlayerHud AreaIndicatorUI script_data UISettings GenericStatusExtension
-- luacheck: globals RespawnHandler

local mod = get_mod("TrueSoloQoL")

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
		local is_visible = self.data.level_text ~= "BOT"
		if self._mod_stay_hidden and self._is_visible ~= is_visible then
			self:set_visible(is_visible)
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
	for _, string in ipairs( { "ASSASSIN_WARNING_", "PACK_WARNING_" } ) do
		if pl.stringx.count(key, string) > 0 then
			key = pl.stringx.replace(key, string, "")
			key = pl.stringx.replace(key, "_DUPE", "")
			key = pl.stringx.replace(key, "_", " ")
			return key
		end
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

mod:hook(RespawnHandler, "update", function(func, self, dt, t, player_statuses)
	mod:pcall(function()
		if mod:get(mod.SETTING_NAMES.AUTO_KILL_BOTS) then
			local game_mode_manager = Managers.state.game_mode
			local round_started = game_mode_manager:is_round_started()

			if not round_started then
				local killbots_mod = get_mod("Killbots")
				if killbots_mod then
					killbots_mod:kill_bots()
				end
			end
		end

		if mod:get(mod.SETTING_NAMES.DONT_RESPAWN_BOTS) then
			for _, status in ipairs(player_statuses) do
				local peer_id = status.peer_id
				local local_player_id = status.local_player_id

				if peer_id or local_player_id then
					local player = Managers.player:player(peer_id, local_player_id)

					if status.health_state == "dead"
					and not status.ready_for_respawn
					and status.respawn_timer
					and status.respawn_timer < t
					and player.bot_player
					then
						status.respawn_timer = t + 1
					end
				end
			end
		end
	end)
	return func(self, dt, t, player_statuses)
end)

mod.get_num_alive_packmasters = function()
	return Managers.state.conflict:count_units_by_breed("skaven_pack_master")
end

mod.breed_notification_data = {
	skaven_gutter_runner = {
		num_alive_func = mod.get_num_alive_assassins,
		text_alone = "ASSASSIN_WARNING_ASS!",
		text_alone_dupe = "ASSASSIN_WARNING_ASS!_DUPE",
		text_multi = "ASSASSIN_WARNING_ASS_",
	},
	skaven_pack_master = {
		num_alive_func = mod.get_num_alive_packmasters,
		text_alone = "PACK_WARNING_PACK!",
		text_alone_dupe = "PACK_WARNING_PACK!_DUPE",
		text_multi = "PACK_WARNING_PACK_",
	},
}

mod:hook(AreaIndicatorUI, "update", function(func, self, dt)
	self.area_text_box.offset[2] = 0

	if mod:get(mod.SETTING_NAMES.ASSASSIN_TEXT_WARNING) then
		mod:pcall(function()
			self.area_text_box.style.text.text_color = { 255, 255, 255, 0}
			if mod.current_location then
				if mod.current_location == "ASSASSIN_WARNING_ASS_2" then
					self.area_text_box.style.text.text_color = { 255, 255, 0, 0 }
				end
				if pl.stringx.lfind(mod.current_location, "PACK_WARNING_") then
					self.area_text_box.offset[2] = -550
					self.area_text_box.style.text.text_color = { 255, 0, 255, 0}
				end
				if mod.current_location == "PACK_WARNING_PACK_2" then
					self.area_text_box.style.text.text_color = { 255, 255, 165, 0}
				end
			end
		end)
	end

	return func(self, dt)
end)

mod:hook(ConflictDirector, "spawn_queued_unit", function(func, self, breed, boxed_spawn_pos, boxed_spawn_rot, spawn_category, spawn_animation, spawn_type, optional_data, group_data, unit_data)
	local notification_data = mod.breed_notification_data[breed.name]
	if notification_data then
		if mod:get(mod.SETTING_NAMES.ASSASSIN_TEXT_WARNING) then
			UISettings.area_indicator.wait_time = 0
			mod:pcall(function()
				local player_unit = Managers.player:local_player().player_unit
				local player_hud_extension = ScriptUnit.extension(player_unit, "hud_system")
				if notification_data.num_alive_func() > 0 then
					player_hud_extension.current_location = notification_data.text_multi..(notification_data.num_alive_func()+1)
				else
					if player_hud_extension.current_location == notification_data.text_alone then
						player_hud_extension.current_location = notification_data.text_alone_dupe
					else
						player_hud_extension.current_location = notification_data.text_alone
					end
				end
				mod.current_location = player_hud_extension.current_location
			end)
		else
			UISettings.area_indicator.wait_time = 1
		end
	end

	return func(self, breed, boxed_spawn_pos, boxed_spawn_rot, spawn_category, spawn_animation, spawn_type, optional_data, group_data, unit_data)
end)

mod:dofile("scripts/mods/"..mod:get_name().."/keep_spawning_fix")
mod:dofile("scripts/mods/"..mod:get_name().."/assassin_hero_warning")
