local mod = get_mod("TrueSoloQoL")

-- luacheck: globals LevelTransitionHandler

local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
}

mod:initialize_data(mod_data)

--- Callbacks ---
mod.on_disabled = function(is_first_call) -- luacheck: ignore is_first_call
	mod:disable_all_hooks()
end

mod.on_enabled = function(is_first_call) -- luacheck: ignore is_first_call
	mod:enable_all_hooks()
end

--- Mod Logic ---
--- Restart the level on mission failure.
--- Without it we'd transitions to the inn.
mod:hook("GameModeManager.server_update", function (func, self, dt, t)
	local round_started = self._round_started
	local ended, reason = self._game_mode:evaluate_end_conditions(round_started, dt, t)
	local original_set_next_level = LevelTransitionHandler.set_next_level
	if ended and reason == "lost" then
		LevelTransitionHandler.set_next_level = function(self, level_key) -- self is now LevelTransitionHandler
			return original_set_next_level(self, self:get_current_level_keys())
		end
	end
	func(self, dt, t)
	LevelTransitionHandler.set_next_level = original_set_next_level
end)

--- Track frame_index to know if it's bot UI. Player frame_index is nil.
mod:hook("UnitFrameUI._create_ui_elements", function (func, self, frame_index)
	self._frame_index = frame_index
	func(self, frame_index)
end)

--- Make sure bots UI doesn't reappear.
mod:hook("UnitFrameUI.update", function (func, self, ...)
	mod:pcall(function()
		if self._mod_stay_hidden then
			self:set_visible(false)
		end
	end)
	func(self, ...)
end)

--- Hook the kill_bots function of Killbots and add UI hiding code after we run /killbots.
local mod = get_mod("Killbots")
if mod then
	mod.original_kill_bots = mod.original_kill_bots or mod.kill_bots
	mod.kill_bots = function(self)
		mod:original_kill_bots()
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