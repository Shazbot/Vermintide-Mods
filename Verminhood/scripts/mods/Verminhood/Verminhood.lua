local mod = get_mod("Verminhood")

mod:hook(GenericHealthExtension, "add_damage", function(func, self, attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit, hit_react_type, is_critical_strike, added_dot)
	local self_unit = self.unit
	local breed = Unit.get_data(self_unit, "breed")

	if not self.is_server or not breed then
		return func(self, attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit, hit_react_type, is_critical_strike, added_dot)
	end

	mod:hook_disable(GenericHealthExtension, "add_damage")

	local dmg = damage_amount

	local position = Unit.world_position(self_unit, 0)
	local world = Managers.world:world("level_world")
	local physics_world = World.physics_world(world)
	local radius = mod:get(mod.SETTING_NAMES.RADIUS)
	local collision_filter = "filter_enemy_unit"
	local actors, num_actors = PhysicsWorld.immediate_overlap(physics_world, "shape", "sphere",
		"position", position, "size", radius, "collision_filter", collision_filter, "use_global_table")

	mod:pcall(function()
		local units_to_damage = {}
		for i = 1, num_actors, 1 do
			local hit_actor = actors[i]
			local hit_unit = Actor.unit(hit_actor)

			local unit_spawner = Managers.state.unit_spawner
			local unit_death_watch_list = unit_spawner.unit_death_watch_list

			local is_dead = false
			for ii = 1, unit_spawner.unit_death_watch_list_n, 1 do
				local death_data = unit_death_watch_list[ii]
				if death_data.unit == hit_unit then
					is_dead = true
					break
				end
			end
			if not is_dead then
				table.insert(units_to_damage, hit_unit)
			end
		end
		local actionable_units = #units_to_damage
		for _, unit in ipairs( units_to_damage ) do
			local health_ext = ScriptUnit.has_extension(unit, "health_system")
			if health_ext then
				health_ext:add_damage(unit, dmg/actionable_units, "full", "undefined",
					Unit.world_position(unit, 0), Vector3(0, 0, -1))
			end
		end
	end)

	mod:hook_enable(GenericHealthExtension, "add_damage")

	return
end)
