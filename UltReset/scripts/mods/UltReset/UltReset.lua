local mod = get_mod("UltReset")

mod.reset_ult = function()
	local local_player_unit = Managers.player:local_player().player_unit
	local career_extension = ScriptUnit.has_extension(local_player_unit, "career_system")
	if career_extension then
		local abilities = career_extension._abilities

		for i = 1, career_extension._num_abilities, 1 do
			local ability = abilities[i]
			ability.cooldown = 0
		end
	end
end

mod:command("ult", mod:localize("ult_command_description"), mod.reset_ult)
