local mod = get_mod("UltReset") -- luacheck: ignore get_mod

-- luacheck: globals Managers ScriptUnit

mod.reset_ult = function()
	local local_player_unit = Managers.player:local_player().player_unit
	local career_extension = ScriptUnit.has_extension(local_player_unit, "career_system")
	if career_extension then
		career_extension._cooldown = 0
	end
end

mod:command("ult", mod:localize("ult_command_description"), mod.reset_ult)