local mod = get_mod("WinLevelCommand") -- luacheck: ignore get_mod

-- luacheck: globals Managers

mod.win_level = function(self) -- luacheck: ignore self
	mod:pcall(function()
		if Managers.state.game_mode:level_key() == "inn_level" then
			mod:echo("Can't win in the keep.")
			return
		end

		Managers.state.game_mode:complete_level()
	end)
end

mod:command("win", mod:localize("win_level_command_description"), function() mod:win_level() end)