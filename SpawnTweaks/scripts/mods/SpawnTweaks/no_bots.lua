local mod = get_mod("SpawnTweaks")

--- We're changing script_data.cap_num_bots in mod.update in main script.
mod:hook_safe(mod, "update", function()
	script_data.cap_num_bots = (mod:is_enabled() and mod:get(mod.SETTING_NAMES.NO_BOTS)) and 0 or nil
end)

--- Fix for bug with mission not ending when bots are disabled.
mod:hook(SpawnManager, "all_players_disabled", function(func, self, ...)
	if not mod:is_enabled() or script_data.cap_num_bots ~= 0 then
		return func(self, ...)
	end

	-- fix the auto-fail on map start when with other people
	local game_mode_manager = Managers.state.game_mode
	if not game_mode_manager then
		return false
	end

	local round_started = game_mode_manager:is_round_started()
	if not round_started then
		for _, status in ipairs(self._player_statuses) do
			if status.spawn_state == "initial_spawning" then
				return false
			end
		end
	end

	for _, status in ipairs(self._player_statuses) do
		if status.health_state == "alive" and status.spawn_state == "spawned" then
			return false
		end
	end

	return true
end)
