local mod = get_mod("SpawnTweaks")

mod.invis_mut = {}

mod.invis_mut.invis_update = function()
	if not mod:get(mod.SETTING_NAMES.INVISIBLE_TEAMMATES_MUTATOR) then
		return
	end

	local reverse = mod:get(mod.SETTING_NAMES.INVISIBLE_TEAMMATES_MUTATOR_REVERSE)
	local hide_distance_sq = mod:get(mod.SETTING_NAMES.INVISIBLE_TEAMMATES_MUTATOR_DISTANCE)^2
	if Managers.state.network and Managers.player and Managers.player:local_player() then
		local local_player_unit = Managers.player:local_player().player_unit
		local position_player = nil
		if local_player_unit then
			position_player = Unit.world_position(local_player_unit, 0)
		end
		for _, player in pairs( Managers.player:human_and_bot_players() ) do
			local player_unit = player.player_unit

			if player_unit and player_unit ~= local_player_unit then
				local scale = 1
				if not local_player_unit or not mod:is_enabled() then
					scale = 1
				else
					local position = Unit.world_position(player_unit, 0)
					if position and position_player then
						local dist_sq = Vector3.distance_squared(position, position_player)

						if dist_sq > hide_distance_sq then
							scale = reverse and 1 or 0
						else
							scale = reverse and 0 or 1
						end
					end
				end

				local new_scale_vector = Vector3(scale, scale, scale)
				if not Vector3.equal(Unit.local_scale(player_unit, 0), new_scale_vector) then
					Unit.set_local_scale(player_unit, 0, new_scale_vector)
				end
			end
		end
	end
end
mod.dispatcher:on("onModUpdate",
	function()
		mod.invis_mut.invis_update()
	end)
