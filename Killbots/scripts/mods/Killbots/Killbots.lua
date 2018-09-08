local mod = get_mod("Killbots") -- luacheck: ignore get_mod

-- luacheck: globals Managers ScriptUnit EAC

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