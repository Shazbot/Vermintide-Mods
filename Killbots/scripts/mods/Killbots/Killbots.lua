local mod = get_mod("Killbots")

-- luacheck: globals Managers ScriptUnit

mod.kill_bots = function(self) -- luacheck: ignore self
	mod:pcall(function()
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

mod:command("killbots", mod:localize("kill_bots_command_description"), function() mod:kill_bots() end)