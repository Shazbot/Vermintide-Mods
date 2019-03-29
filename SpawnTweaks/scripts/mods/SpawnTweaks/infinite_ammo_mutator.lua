local mod = get_mod("SpawnTweaks")

mod.infinite_ammo_mutator_on_disabled_func = function()
	if not mod.ingame_entered then
		return
	end

	mod.remove_buffs()
end
table.insert(mod.on_disabled_funcs, function() mod.infinite_ammo_mutator_on_disabled_func() end)

mod.infinite_ammo_mutator_update_func = function()
	if not mod.ingame_entered then
		return
	end

	if mod:get(mod.SETTING_NAMES.INFINITE_AMMO_MUTATOR) then
		mod.refresh_buffs()
	else
		mod.remove_buffs()
	end
end
table.insert(mod.update_funcs, function() mod.infinite_ammo_mutator_update_func() end)

mod.remove_buffs = function()
	if Managers.player:local_player() then
		local local_player_unit = Managers.player:local_player().player_unit
		if local_player_unit and Unit.alive(local_player_unit) then
			local buff_extension = ScriptUnit.has_extension(local_player_unit, "buff_system")
			if buff_extension and buff_extension:has_buff_type("twitch_no_overcharge_no_ammo_reloads") then
				local inf_ammo_buff = buff_extension:get_non_stacking_buff("twitch_no_overcharge_no_ammo_reloads")
				buff_extension:remove_buff(inf_ammo_buff.id)
			end
		end
	end

	if Managers.player.is_server then
		local players = Managers.player:human_and_bot_players()

		for _, player in pairs(players) do
			local unit = player.player_unit
			if Unit.alive(unit) then
				local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
				if buff_extension and buff_extension:has_buff_type("twitch_no_overcharge_no_ammo_reloads") then
					local inf_ammo_buff = buff_extension:get_non_stacking_buff("twitch_no_overcharge_no_ammo_reloads")
					buff_extension:remove_buff(inf_ammo_buff.id)
				end
			end
		end
	end
end

mod.refresh_buffs = function()
	if Managers.player:local_player() then
		local local_player_unit = Managers.player:local_player().player_unit
		if local_player_unit and Unit.alive(local_player_unit) then
			local buff_extension = ScriptUnit.has_extension(local_player_unit, "buff_system")
			if buff_extension then
				buff_extension:add_buff("twitch_no_overcharge_no_ammo_reloads")
			end
		end
	end

	if Managers.player.is_server then
		local players = Managers.player:human_and_bot_players()

		for _, player in pairs(players) do
			local unit = player.player_unit

			if Unit.alive(unit) then
				local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
				if buff_extension and not buff_extension:has_buff_type("twitch_no_overcharge_no_ammo_reloads") then
					local buff_system = Managers.state.entity:system("buff_system")
					local server_controlled = false
					buff_system:add_buff(unit, "twitch_no_overcharge_no_ammo_reloads", unit, server_controlled)
				end
			end
		end
	end
end
