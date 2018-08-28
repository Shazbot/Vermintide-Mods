local mod = get_mod("Pause") -- luacheck: ignore get_mod

-- luacheck: globals Managers

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