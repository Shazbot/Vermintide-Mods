local mod = get_mod("InfiniteAmmo") -- luacheck: ignore get_mod

-- luacheck: globals Managers Unit ScriptUnit

mod.on_disabled = function()
	mod.remove_buffs()
end

mod.update = function()
	if not mod.is_ready then
		return
	end

	if mod:is_enabled() then
		mod.refresh_buffs()
	else
		mod.remove_buffs()
	end
end

mod.on_game_state_changed = function(status, state)
	if status == "enter" and state == "StateIngame" then
		mod.is_ready = true
	end
end

mod.remove_buffs = function()
	local local_player_unit = Managers.player:local_player().player_unit
	if local_player_unit and Unit.alive(local_player_unit) then
		local buff_extension = ScriptUnit.has_extension(local_player_unit, "buff_system")
		if buff_extension and buff_extension:has_buff_type("twitch_no_overcharge_no_ammo_reloads") then
			local inf_ammo_buff = buff_extension:get_non_stacking_buff("twitch_no_overcharge_no_ammo_reloads")
			buff_extension:remove_buff(inf_ammo_buff.id)
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
