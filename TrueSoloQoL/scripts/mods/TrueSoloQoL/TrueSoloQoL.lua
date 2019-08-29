local mod = get_mod("TrueSoloQoL")

local pl = require'pl.import_into'()

fassert(pl, "True Solo QoL Tweaks must be lower than Penlight Lua Libraries in your launcher's load order.")

--- Restart the level on mission failure.
--- Without it we'd transitions to the inn.
mod:hook(GameModeAdventure, "evaluate_end_conditions", function(func, self, round_started, dt, t, ...)
	if mod:get(mod.SETTING_NAMES.DONT_RESTART) then
		mod.do_insta_fail = false
		mod.skip_restart = false
		return func(self, round_started, dt, t, ...)
	end

	if self.lost_condition_timer and mod.do_insta_fail then
		mod.do_insta_fail = false
		self.lost_condition_timer = t - 1
	end
	local ended, reason = func(self, round_started, dt, t, ...)

	if ended and mod.skip_restart then
		mod.skip_restart = false
		return ended, reason
	end

	if ended and reason == "lost" then
		return ended, "reload"
	end

	return ended, reason
end)

mod.fail_level_to_inn = function()
	mod:pcall(function()
		if Managers.state.game_mode:level_key() == "inn_level" then
			mod:echo("Can't restart in the keep.")
			return
		end

		mod.do_insta_fail = true
		mod.skip_restart = true
		Managers.state.game_mode:fail_level()
	end)
end
mod:command("inn", "Fail and return to inn.", function() mod.fail_level_to_inn() end)

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

mod.unit_frames_handler = nil
mod:hook_safe(UnitFramesHandler, "init", function(self)
	mod.unit_frames_handler = self
end)

mod.update = function()
	--- Hook the kill_bots function of Killbots and add UI hiding code after we run /killbots.
	local killbots_mod = get_mod("Killbots")
	if killbots_mod and not killbots_mod.original_kill_bots then
		killbots_mod.original_kill_bots = killbots_mod.original_kill_bots or killbots_mod.kill_bots
		killbots_mod.kill_bots = function(self)
			killbots_mod:original_kill_bots()
			mod:pcall(function()
				local unit_frames_handler = mod.unit_frames_handler
				if unit_frames_handler then
					for _, unit_frame in ipairs( unit_frames_handler._unit_frames ) do
						local unit_frame_ui = unit_frame.widget
						if unit_frame_ui._frame_index
						  and unit_frame_ui._is_visible
						  and unit_frame_ui.data.level_text == "BOT" then
							unit_frame_ui:set_visible(false)
							unit_frame_ui._mod_stay_hidden = true
						end
					end
				end
			end)
		end
	end
end

--- Disable the bots.
mod:hook(GameModeAdventure, "_handle_bots",
function(func, self, ...)
	local original_cap_num_bots = script_data.cap_num_bots

	if mod:get(mod.SETTING_NAMES.AUTO_KILL_BOTS) then
		script_data.cap_num_bots = 0
	end

	func(self, ...)

	script_data.cap_num_bots = original_cap_num_bots
end)

--- Prevent a crash with disabled bots.
mod:hook(AdventureSpawning, "force_update_spawn_positions", function(func, ...)
	if not mod:get(mod.SETTING_NAMES.AUTO_KILL_BOTS) then
		return func(...)
	end

	pcall(func, ...)
end)

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

mod:hook(ConflictDirector, "spawn_queued_unit", function(func, self, breed, ...)
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

	return func(self, breed, ...)
end)

--- Disable the purple explosion effect.
mod:hook(AiUtils, "generic_mutator_explosion", function(func, killed_unit, blackboard, explosion_template_name)
	if mod:get(mod.SETTING_NAMES.DISABLE_MUTATOR_EXPLOSIONS)
	and (
		explosion_template_name == "generic_mutator_explosion"
		or explosion_template_name == "generic_mutator_explosion_medium"
		or explosion_template_name == "generic_mutator_explosion_large"
	)
	then
		return
	end

	return func(killed_unit, blackboard, explosion_template_name)
end)

--- Disable level intro audio.
mod:hook(StateLoading, "_trigger_sound_events", function(func, self, level_key)
	if mod:get(mod.SETTING_NAMES.DISABLE_LEVEL_INTRO_AUDIO) then
		return
	end

	return func(self, level_key)
end)

mod:hook_safe(MoodHandler, "apply_environment_variables", function(self, shading_env)
  if mod:get(mod.SETTING_NAMES.DISABLE_FOG) then
		ShadingEnvironment.set_scalar(shading_env, "fog_enabled", 0)
	end
	if mod:get(mod.SETTING_NAMES.DISABLE_SUN_SHADOWS) then
		ShadingEnvironment.set_scalar(shading_env, "sun_shadows_enabled", 0)
	end
end)

--- Disable ult voice line from local player.
mod.get_vo_hook = function(career_name) -- luacheck: ignore career_name
	return
		function(func, self, ...)
			if mod:get(mod.SETTING_NAMES.DISABLE_ULT_VOICE_LINE) then
				return
			end

			return func(self, ...)
		end
end

local career_name_to_action_object = {
	bw_scholar = ActionCareerBWScholar,
	wh_bountyhunter = ActionCareerWHBountyhunter,
	dr_ranger = ActionCareerDRRanger,
	we_waywatcher = ActionCareerWEWaywatcher,
}

mod:pcall(function()
	for career_key, career in pairs( CareerSettings ) do
		if career.activated_ability.ability_class
		and career_key ~= "empire_soldier_tutorial"
		then
			mod:hook(career.activated_ability.ability_class, "_play_vo",
					mod.get_vo_hook(career.display_name))
		end
	end
	for career_name, action_career_object in pairs( career_name_to_action_object ) do
		mod:hook(action_career_object, "_play_vo", mod.get_vo_hook(career_name))
	end
end)

script_data.unlock_all_levels = true

mod.start_dlc_level = function()
	mod:pcall(function()
		local vote_data = {
			private_game = true,
			quick_game = false,
			strict_matchmaking = false,
			always_host = true,
			game_mode = "event",
			level_key = "plaza",
			difficulty = DefaultDifficulties[4]
		}

		local local_player_unit = Managers.player:local_player().player_unit
		local interaction_player = Managers.player:owner(local_player_unit)

		Managers.state.voting:request_vote("game_settings_vote", vote_data, interaction_player.peer_id)
	end)
end

mod:command("dlc", mod:localize("dlc_level_command_description"), function() mod.start_dlc_level() end)

mod:dofile("scripts/mods/"..mod:get_name().."/assassin_hero_warning")
mod:dofile("scripts/mods/"..mod:get_name().."/draw_boss_sphere")

mod.on_game_state_changed = function(status, state)
	if state == "StateIngame" then
		if status == "exit" and mod.line_object then
			local world = Managers.world:world("level_world")
			World.destroy_line_object(world, mod.line_object)
			mod.line_object = nil
		end
	end
end

mod.on_disabled = function()
	if mod:get(mod.SETTING_NAMES.SHOW_BOSS_PATH_PROGRESS) then
		local streaming_info = get_mod("StreamingInfo")
		if streaming_info then
			streaming_info.perm_external_lines["BOSS_PATH_PROGRESS"] = nil
		end
	end
end

mod.on_setting_changed = function(setting_name)
	if setting_name == mod.SETTING_NAMES.SHOW_BOSS_PATH_PROGRESS
	and not mod:get(mod.SETTING_NAMES.SHOW_BOSS_PATH_PROGRESS) then
		local streaming_info = get_mod("StreamingInfo")
		if streaming_info then
			streaming_info.perm_external_lines["BOSS_PATH_PROGRESS"] = nil
		end
	end
end
