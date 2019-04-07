local mod = get_mod("SpawnTweaks")

for _, health_ext_obj in ipairs( { GenericHealthExtension, RatOgreHealthExtension } ) do
	mod:hook(health_ext_obj, "add_damage", function(func, self, attacker_unit, damage_amount, hit_zone_name, damage_type, ...)
		local self_unit = self.unit
		local breed = Unit.get_data(self_unit, "breed")

		local verminhood_mode = mod:get(mod.SETTING_NAMES.VERMINHOOD_MUTATOR)
		if not self.is_server
		or not breed
		or verminhood_mode == mod.VERMINHOOD_MODES.DISABLED
		then
			return func(self, attacker_unit, damage_amount, hit_zone_name, damage_type, ...)
		end

		mod:hook_disable(health_ext_obj, "add_damage")

		local dmg = damage_amount

		local position = Unit.world_position(self_unit, 0)
		local world = Managers.world:world("level_world")
		local physics_world = World.physics_world(world)
		local radius = mod:get(mod.SETTING_NAMES.VERMINHOOD_RADIUS) or 10
		local collision_filter = "filter_enemy_unit"
		local actors, num_actors = PhysicsWorld.immediate_overlap(physics_world, "shape", "sphere",
			"position", position, "size", radius, "collision_filter", collision_filter)

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

			if verminhood_mode == mod.VERMINHOOD_MODES.SPLIT then
				local actionable_units = #units_to_damage
				for _, unit in ipairs( units_to_damage ) do
					local health_ext = ScriptUnit.has_extension(unit, "health_system")
					if health_ext then
						health_ext:add_damage(unit, dmg/actionable_units, "full", "undefined",
							Unit.world_position(unit, 0), Vector3(0, 0, -1))
					end
				end
			elseif verminhood_mode == mod.VERMINHOOD_MODES.POOL then
				local health_extensions = {}
				local hp_sum = 0
				for i, unit in ipairs( units_to_damage ) do
					local health_ext = ScriptUnit.has_extension(unit, "health_system")
					if health_ext then
						health_extensions[i] = health_ext
						hp_sum = hp_sum + health_ext:current_health()
					end
				end
				for i, unit in ipairs( units_to_damage ) do
					local health_ext = health_extensions[i]
					local hp_ratio = health_ext:current_health()/hp_sum
					health_ext:add_damage(unit, dmg*hp_ratio, "full", "undefined",
						Unit.world_position(unit, 0), Vector3(0, 0, -1))

					-- mod:echo("sum "..hp_sum)
					-- mod:echo("ratio "..hp_ratio)
					-- mod:echo("dmg "..dmg)
					-- mod:echo(dmg*hp_ratio)
					-- mod:echo("====")
				end
			end
		end)

		mod:hook_enable(health_ext_obj, "add_damage")

		return
	end)
end
