local mod = get_mod("SpawnTweaks")

mod.green_hp_mut = {}

local function _add_player_damaged_telemetry(unit, damage_type, damage_source)
	local player_manager = Managers.player
	local owner = player_manager:owner(unit)

	if owner then
		local local_player = owner.local_player
		local is_bot = owner.bot_player
		local network_manager = Managers.state.network
		local is_server = network_manager.is_server

		if (is_bot and is_server) or local_player then
			local position = POSITION_LOOKUP[unit]

			Managers.telemetry.events:player_damaged(owner, damage_type, damage_source, position)
		end
	end
end

mod.green_hp_mut.FORCED_PERMANENT_DAMAGE_TYPES = {}

mod:hook(PlayerUnitHealthExtension, "add_damage", function(func, self, attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit, hit_react_type, is_critical_strike, added_dot)
	local white_hp_to_green_hp_ratio = mod:get(mod.SETTING_NAMES.WHITE_HP_TO_GREEN_HP)/100
	if damage_type == "temporary_health_degen"
	and white_hp_to_green_hp_ratio > 0
	then
		self:add_heal(self.unit, damage_amount*white_hp_to_green_hp_ratio, nil, "health_regen")
	end

	if not mod:get(mod.SETTING_NAMES.LOSE_GREEN_HP_MUTATOR) then
		return func(self, attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit, hit_react_type, is_critical_strike, added_dot)
	end

	if DamageUtils.is_in_inn then
		return
	end

	local status_extension = self.status_extension

	if status_extension:is_ready_for_assisted_respawn() then
		return
	end

	local breed = Unit.get_data(attacker_unit, "breed")

	if breed and breed.boss then
		local owner_player = Managers.player:owner(self.unit)

		if owner_player and owner_player.local_player and not owner_player.bot_player then
			Managers.state.event:trigger("show_boss_health_bar", attacker_unit)
		end
	end

	fassert(damage_type, "No damage_type!")

	local unit = self.unit
	local damage_table = self:_add_to_damage_history_buffer(unit, attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit, hit_react_type, is_critical_strike)

	if damage_type ~= "temporary_health_degen" then
		StatisticsUtil.register_damage(unit, damage_table, self.statistics_db)
	end

	self._recent_damage_type = damage_type
	self._recent_hit_react_type = hit_react_type
	local controller_features_manager = Managers.state.controller_features

	if controller_features_manager then
		local player = self.player

		if player.local_player and damage_amount > 0 and damage_type ~= "temporary_health_degen" then
			controller_features_manager:add_effect("hit_rumble", {
				damage_amount = damage_amount,
				unit = unit
			})
		end
	end

	_add_player_damaged_telemetry(unit, damage_type, damage_source_name or "n/a")

	local buff_extension = ScriptUnit.extension(unit, "buff_system")

	buff_extension:trigger_procs("on_damage_taken", attacker_unit, damage_amount, damage_type)

	local ai_inventory_extension = ScriptUnit.has_extension(attacker_unit, "ai_inventory_system")

	if ai_inventory_extension then
		ai_inventory_extension:play_hit_sound(unit, damage_type)
	end

	if ScriptUnit.has_extension(attacker_unit, "hud_system") then
		DamageUtils.handle_hit_indication(attacker_unit, unit, damage_amount, hit_zone_name, added_dot)
	end

	if self.player.local_player and (buff_extension:has_buff_type("bardin_ironbreaker_activated_ability") or buff_extension:has_buff_type("bardin_ironbreaker_activated_ability_duration")) then
		local first_person_extension = ScriptUnit.extension(unit, "first_person_system")

		first_person_extension:play_hud_sound_event("Play_career_ability_bardin_ironbreaker_hit")
	end

	if self.is_server and not self.is_invincible and not script_data.player_invincible then
		local game = self.game
		local game_object_id = self.health_game_object_id

		if game and game_object_id then
			local force_permanent_damage = mod.green_hp_mut.FORCED_PERMANENT_DAMAGE_TYPES[damage_type]
			local current_health = GameSession.game_object_field(game, game_object_id, "current_health")
			local current_temporary_health = GameSession.game_object_field(game, game_object_id, "current_temporary_health")
			local permanent_damage_amount, temporary_damage_amount = nil

			if force_permanent_damage then
				permanent_damage_amount = (current_health < damage_amount and current_health) or damage_amount
				temporary_damage_amount = (current_health < damage_amount and damage_amount - current_health) or 0
			else
				permanent_damage_amount = (current_temporary_health < damage_amount and damage_amount - current_temporary_health) or 0
				temporary_damage_amount = (current_temporary_health < damage_amount and current_temporary_health) or damage_amount

				if permanent_damage_amount == 0 then
					local forced_permanent_dmg = temporary_damage_amount * mod:get(mod.SETTING_NAMES.LOSE_GREEN_HP_MUTATOR_CHANCE)/100
					if current_health >= forced_permanent_dmg then
						permanent_damage_amount = math.min(current_health, forced_permanent_dmg)
						temporary_damage_amount = temporary_damage_amount - forced_permanent_dmg
					end
				end
			end

			local new_health = (current_health < permanent_damage_amount and 0) or current_health - permanent_damage_amount

			GameSession.set_game_object_field(game, game_object_id, "current_health", new_health)

			local new_temporary_health = (current_temporary_health < temporary_damage_amount and 0) or current_temporary_health - temporary_damage_amount

			GameSession.set_game_object_field(game, game_object_id, "current_temporary_health", new_temporary_health)

			local is_dead = new_health + new_temporary_health <= 0 and (self.state ~= "alive" or not status_extension:has_wounds_remaining())

			if is_dead and self.state ~= "dead" then
				local death_system = Managers.state.entity:system("death_system")

				death_system:kill_unit(unit, damage_table)
			end

			local unit_id = self.unit_storage:go_id(unit)
			local attacker_unit_id, attacker_is_level_unit = self.network_manager:game_object_or_level_id(attacker_unit)
			local hit_zone_id = NetworkLookup.hit_zones[hit_zone_name]
			local damage_type_id = NetworkLookup.damage_types[damage_type]
			local damage_source_id = NetworkLookup.damage_sources[damage_source_name or "n/a"]
			local hit_ragdoll_actor_id = NetworkLookup.hit_ragdoll_actors[hit_ragdoll_actor or "n/a"]
			local hit_react_type_id = NetworkLookup.hit_react_types[hit_react_type or "light"]
			is_critical_strike = is_critical_strike or false
			added_dot = added_dot or false

			self.network_transmit:send_rpc_clients("rpc_add_damage", unit_id, false, attacker_unit_id, attacker_is_level_unit, damage_amount, hit_zone_id, damage_type_id, hit_position, damage_direction, damage_source_id, hit_ragdoll_actor_id, hit_react_type_id, is_dead, is_critical_strike, added_dot)
		end
	end
end)
