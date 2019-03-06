local mod = get_mod("InvisTeam")

mod.update = function()
	if Managers.state.network and Managers.player and Managers.player:local_player() then
		local local_player_unit = Managers.player:local_player().player_unit
		for _, player in pairs( Managers.player:human_and_bot_players() ) do
			local player_unit = player.player_unit

			if player_unit and player_unit ~= local_player_unit then
				local scale = nil
				if not local_player_unit or not mod:is_enabled() then
					scale = 1
				else
					local position = Unit.world_position(player_unit, 0)
					local position_player = Unit.world_position(local_player_unit, 0)
					if position and position_player then
						local dist = Vector3.distance(position, position_player)

						if dist > mod:get(mod.SETTING_NAMES.DISTANCE) then
							scale = 0
						else
							scale = 1
						end
					end
				end

				local new_scale_vector = Vector3(scale,scale,scale)
				if scale and not Vector3.equal(Unit.local_scale(player_unit, 0), new_scale_vector) then
					Unit.set_local_scale(player_unit, 1, new_scale_vector)
				end
			end
		end
	end
end
