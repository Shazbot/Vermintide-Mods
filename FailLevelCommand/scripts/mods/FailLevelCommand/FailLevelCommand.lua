local mod = get_mod("FailLevelCommand") -- luacheck: ignore get_mod

-- luacheck: globals Managers

mod.fail_level = function(self) -- luacheck: ignore self
	mod:pcall(function()
		if Managers.state.game_mode:level_key() == "inn_level" then
			mod:echo("Can't fail in the keep.")
			return
		end

		Managers.state.game_mode:fail_level()
	end)
end

mod:command("fail", mod:localize("fail_level_command_description"), function() mod:fail_level() end)