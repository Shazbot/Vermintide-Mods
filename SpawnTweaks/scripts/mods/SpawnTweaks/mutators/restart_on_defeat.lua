local mod = get_mod("SpawnTweaks")

--- Restart the level on mission failure.
--- Without it we'd transitions to the inn.

mod.restart_on_defeat = {}
mod.restart_on_defeat.do_insta_fail = false
mod.restart_on_defeat.do_restart = false

-- CHECK
-- GameModeAdventure.evaluate_end_conditions = function (self, round_started, dt, t, mutator_handler)
mod:hook(GameModeAdventure, "evaluate_end_conditions", function(func, self, round_started, dt, t, ...)
	if not mod.restart_on_defeat.do_insta_fail
	and not mod.restart_on_defeat.do_restart
	and not mod:get(mod.SETTING_NAMES.RESTART_ON_DEFEAT)
	then
		return func(self, round_started, dt, t, ...)
	end

	if self.lost_condition_timer and mod.restart_on_defeat.do_insta_fail then
		mod.restart_on_defeat.do_insta_fail = false
		self.lost_condition_timer = t - 1
	end
	local ended, reason = func(self, round_started, dt, t, ...)

	if ended
	and reason == "lost"
	and not mod.restart_on_defeat.skip_restart
	and (
		mod:get(mod.SETTING_NAMES.RESTART_ON_DEFEAT)
		or mod.restart_on_defeat.do_restart
	)
	then
		mod.restart_on_defeat.do_restart = false
		return ended, "reload"
	end

	mod.restart_on_defeat.skip_restart = false

	return ended, reason
end)

mod.win_level = function()
	pcall(function()
		if DamageUtils.is_in_inn then
			mod:echo("Can't win in the keep.")
			return
		end

		mod.restart_on_defeat.do_insta_fail = true
		Managers.state.game_mode:complete_level()
	end)
end

mod.fail_level = function()
	pcall(function()
		if DamageUtils.is_in_inn then
			mod:echo("Can't fail in the keep.")
			return
		end

		mod.restart_on_defeat.do_insta_fail = true
		Managers.state.game_mode:fail_level()
	end)
end

mod.restart_level = function()
	pcall(function()
		if DamageUtils.is_in_inn then
			mod:echo("Can't restart in the keep.")
			return
		end

		mod.restart_on_defeat.do_restart = true
		mod.fail_level()
	end)
end

mod.fail_level_to_inn = function()
	mod:pcall(function()
		if DamageUtils.is_in_inn then
			mod:echo("Can't restart in the keep.")
			return
		end

		mod.restart_on_defeat.do_insta_fail = true
		mod.restart_on_defeat.skip_restart = true
		Managers.state.game_mode:fail_level()
	end)
end
mod:command("st_inn", "Fail and return to inn.", function() mod.fail_level_to_inn() end)

mod:command("st_win", "Win the level.",
	function()
		mod.win_level()
	end)
mod:command("st_lose", "Lose the level.",
	function()
		mod.fail_level()
	end)
mod:command("st_restart", "Restart the level.",
	function()
		mod.restart_level()
	end)
