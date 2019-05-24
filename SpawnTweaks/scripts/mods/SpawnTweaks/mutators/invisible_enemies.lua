local mod = get_mod("SpawnTweaks")

mod.invis_enemies_mut = {}

mod.invis_enemies_mut.invis_update = function()
	if not mod:get(mod.SETTING_NAMES.INVISIBLE_ENEMIES_MUTATOR) then
		return
	end

	local reverse = mod:get(mod.SETTING_NAMES.INVISIBLE_ENEMIES_MUTATOR_REVERSE)
	local hide_radious = mod:get(mod.SETTING_NAMES.INVISIBLE_ENEMIES_MUTATOR_DISTANCE)
	local hide_distance_sq = hide_radious^2
	local overlap_radious = (hide_radious+1)^2

	local show_weapon = mod:get(mod.SETTING_NAMES.INVISIBLE_ENEMIES_MUTATOR_SHOW_WEAPONS)

	mod:pcall(function()
		if Managers.state.network and Managers.player and Managers.player:local_player() then
			local local_player_unit = Managers.player:local_player().player_unit
			if not local_player_unit then
				return
			end

			local position_player = Unit.world_position(local_player_unit, 0)

			local world = Managers.world:world("level_world")
			if not world then
				return
			end

			local physics_world = World.physics_world(world)
			local radius = overlap_radious
			local collision_filter = "filter_enemy_unit"
			local actors, num_actors = PhysicsWorld.immediate_overlap(physics_world, "shape", "sphere",
				"position", position_player, "size", radius, "collision_filter", collision_filter)

			local Actor_unit = Actor.unit
			local Vector3_distance_squared = Vector3.distance_squared
			local Unit_set_unit_visibility = Unit.set_unit_visibility
			local Unit_world_position = Unit.world_position
			local ScriptUnit_has_extension = ScriptUnit.has_extension

			for i = 1, num_actors, 1 do
				local hit_actor = actors[i]
				local hit_unit = Actor_unit(hit_actor)
				local position = Unit_world_position(hit_unit, 0)
				local dist_sq = Vector3_distance_squared(position, position_player)

				local visible = dist_sq <= hide_distance_sq
				if reverse then
					visible = not visible
				end

				Unit_set_unit_visibility(hit_unit, visible)

				local weapon_visible = show_weapon or visible
				local item_extension = ScriptUnit_has_extension(hit_unit, "ai_inventory_system")
				if item_extension then
					for _, eq_unit in ipairs( item_extension.inventory_item_units ) do
						Unit_set_unit_visibility(eq_unit, weapon_visible)
					end
				end
			end
		end
	end)
end
mod.dispatcher:on("onModUpdate",
	function()
		mod.invis_enemies_mut.invis_update()
	end)
