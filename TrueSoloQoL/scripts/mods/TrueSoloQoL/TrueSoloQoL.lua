local mod = get_mod("TrueSoloQoL") -- luacheck: ignore get_mod

-- luacheck: globals LevelTransitionHandler get_mod

--- Mod Logic ---
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

--- Hook the kill_bots function of Killbots and add UI hiding code after we run /killbots.
local killbots_mod = get_mod("Killbots")
if killbots_mod then
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