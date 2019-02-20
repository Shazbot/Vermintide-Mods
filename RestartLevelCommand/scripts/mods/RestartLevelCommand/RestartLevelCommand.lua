local mod = get_mod("RestartLevelCommand") -- luacheck: ignore get_mod

-- luacheck: globals Managers GameModeAdventure

mod.do_insta_fail = false

mod.restart_level = function()
	mod:pcall(function()
		if Managers.state.game_mode:level_key() == "inn_level" then
			mod:echo("Can't restart in the keep.")
			return
		end

		mod.do_insta_fail = true
		Managers.state.game_mode:fail_level()
	end)
end

mod:hook(GameModeAdventure, "evaluate_end_conditions", function(func, self, round_started, dt, t, ...)
	local restart = false
	if self.lost_condition_timer and mod.do_insta_fail then
		mod.do_insta_fail = false
		self.lost_condition_timer = t - 1
		restart = true
	end

	local ended, reason = func(self, round_started, dt, t, ...)

	if ended and restart then
		return ended, "reload"
	end

	return ended, reason
end)

mod:command("restart", mod:localize("restart_level_command_description"), function() mod.restart_level() end)
