local mod = get_mod("FailLevelCommand") -- luacheck: ignore get_mod

-- luacheck: globals Managers GameModeAdventure

mod.do_insta_fail = false

mod.fail_level = function()
	mod:pcall(function()
		if Managers.state.game_mode:level_key() == "inn_level" then
			mod:echo("Can't fail in the keep.")
			return
		end

		mod.do_insta_fail = true
		Managers.state.game_mode:fail_level()
	end)
end

mod:hook(GameModeAdventure, "evaluate_end_conditions", function(func, self, round_started, dt, t, ...)
	if self.lost_condition_timer and mod.do_insta_fail then
		mod.do_insta_fail = false
		self.lost_condition_timer = t - 1
	end
	local ended, reason = func(self, round_started, dt, t, ...)

	if ended and mod.do_restart then
		mod.do_restart = false
		return ended, "reload"
	end

	return ended, reason
end)

mod.win_level = function()
	mod:pcall(function()
		if Managers.state.game_mode:level_key() == "inn_level" then
			mod:echo("Can't win in the keep.")
			return
		end

		mod.do_insta_fail = true
		Managers.state.game_mode:complete_level()
	end)
end

mod.restart_level = function()
	mod:pcall(function()
		if Managers.state.game_mode:level_key() == "inn_level" then
			mod:echo("Can't restart in the keep.")
			return
		end

		mod.do_insta_fail = true
		mod.do_restart = true
		Managers.state.game_mode:fail_level()
	end)
end

mod:command("fail", mod:localize("fail_level_command_description"), function() mod.fail_level() end)
mod:command("win", mod:localize("win_level_command_description"), function() mod.win_level() end)
mod:command("restart", mod:localize("restart_level_command_description"), function() mod.restart_level() end)
