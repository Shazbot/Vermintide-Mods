local mod = get_mod("Helpers")

--- Reset ult.
mod.reset_ult = function()
	local local_player_unit = Managers.player:local_player().player_unit
	local career_extension = ScriptUnit.has_extension(local_player_unit, "career_system")
	if career_extension then
		career_extension._cooldown = 0
	end
end

mod:command("ult", mod:localize("reset_ult_command_description"), mod.reset_ult)

--- Kill bots.
mod.kill_bots = function()
	mod:pcall(function()
		if EAC.state() ~= "untrusted" then
			local game_mode_manager = Managers.state.game_mode
			local round_started = game_mode_manager:is_round_started()

			if round_started then
				mod:echo("Bots may only be killed at the start of the map.")
				return
			end
		end

		for _, bot in ipairs( Managers.player:bots() ) do
			if bot.player_unit then
				local status_ext = ScriptUnit.extension(bot.player_unit, "status_system")
				if status_ext and not status_ext:is_ready_for_assisted_respawn() then
					status_ext:set_dead(true)
				end
			end
		end
	end)
end

mod:command("killbots", mod:localize("kill_bots_command_description"), function() mod.kill_bots() end)

--- Pause.
mod.do_pause = function()
	if not Managers.player.is_server then
		mod:echo(mod:localize("not_server"))
		return
	end

	if Managers.state.debug.time_paused then
		Managers.state.debug:set_time_scale(Managers.state.debug.time_scale_index)
		mod:echo(mod:localize("game_unpaused"))
	else
		Managers.state.debug:set_time_paused()
		mod:echo(mod:localize("game_paused"))
	end
end

mod:command("pause", mod:localize("pause_command_description"), function() mod.do_pause() end)

--- Win/Fail/Restart level.
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

mod:command("bot_toggle",
"Toggle bots on/off for current level."
	.."\nUse to spawn bots in inn."
	.."\nInn bots can lead to a rare nav crash.",
function()
	mod:pcall(function()
		local level_settings = LevelHelper:current_level_settings()
		level_settings.no_bots_allowed = not level_settings.no_bots_allowed
	end)
end)

mod:command("invincible_toggle",
"Toggle player and bot invincibility.",
function()
	mod:pcall(function()
		script_data.player_invincible = not script_data.player_invincible
	end)
end)

mod:command("inn_dmg",
"Enables taking damage in the inn.",
function()
	mod:pcall(function()
		DamageUtils.is_in_inn = false
	end)
end)
