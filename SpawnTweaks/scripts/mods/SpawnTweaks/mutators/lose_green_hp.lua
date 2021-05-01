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

-- CHECK
-- PlayerUnitHealthExtension.add_damage = function (self, attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, source_attacker_unit, hit_react_type, is_critical_strike, added_dot, first_hit, total_hits, backstab_multiplier)
mod:hook(PlayerUnitHealthExtension, "add_damage", function(func, self, attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, source_attacker_unit, hit_react_type, is_critical_strike, added_dot, first_hit, total_hits, backstab_multiplier)
	local white_hp_to_green_hp_ratio = mod:get(mod.SETTING_NAMES.WHITE_HP_TO_GREEN_HP)/100
	if damage_type == "temporary_health_degen"
	and white_hp_to_green_hp_ratio > 0
	then
		self:add_heal(self.unit, damage_amount*white_hp_to_green_hp_ratio, nil, "health_regen")
	end

	if not mod:get(mod.SETTING_NAMES.LOSE_GREEN_HP_MUTATOR) then
		return func(self, attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, source_attacker_unit, hit_react_type, is_critical_strike, added_dot, first_hit, total_hits, backstab_multiplier)
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

		QuestSettings.handle_bastard_block(self.unit, attacker_unit, false)
	end

	if damage_source_name == "ground_impact" and not breed.is_hero then
		return
	end

	fassert(damage_type, "No damage_type!")

	local unit = self.unit
	local damage_table = self:_add_to_damage_history_buffer(unit, attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, source_attacker_unit, hit_react_type, is_critical_strike)

	if damage_amount == nil then
		Crashify.print_exception("HealthSystem", "damage_amount is nil in PlayerUnitHealthExtension:add_damage()")
	end

	if damage_type ~= "temporary_health_degen" and damage_type ~= "knockdown_bleed" then
		StatisticsUtil.register_damage(unit, damage_table, self.statistics_db)
	end

	self:save_kill_feed_data(attacker_unit, damage_table, hit_zone_name, damage_type, damage_source_name, source_attacker_unit)

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

	if Script.type_name(damage_amount) == "number" and damage_type ~= "temporary_health_degen" and damage_source_name ~= "temporary_health_degen" then
		local player = Managers.player:owner(unit)
		local position = POSITION_LOOKUP[unit]

		Managers.telemetry.events:player_damaged(player, damage_type, damage_source_name or "n/a", damage_amount, position)

		local attacker_player = Managers.player:owner(attacker_unit)

		if not DEDICATED_SERVER and attacker_player then
			local local_player = Managers.player:local_player()

			if attacker_player:unique_id() == local_player:unique_id() then
				local attacker_position = POSITION_LOOKUP[attacker_unit]
				local target_breed = Unit.get_data(unit, "breed")

				Managers.telemetry.events:local_player_damaged_player(attacker_player, target_breed.name, damage_amount, attacker_position, position)
			end
		end
	end

	local buff_extension = ScriptUnit.extension(unit, "buff_system")

	if damage_amount > 0 and damage_source_name ~= "temporary_health_degen" then
		buff_extension:trigger_procs("on_damage_taken", attacker_unit, damage_amount, damage_type)
	end

	local min_health = (buff_extension:has_buff_perk("ignore_death") and 1) or 0

	if damage_source_name ~= "dot_debuff" and damage_type ~= "temporary_health_degen" and damage_type ~= "overcharge" then
		local ai_inventory_extension = ScriptUnit.has_extension(attacker_unit, "ai_inventory_system")

		if ai_inventory_extension then
			ai_inventory_extension:play_hit_sound(unit, damage_type)
		end

		if self.player.local_player and (buff_extension:has_buff_type("bardin_ironbreaker_activated_ability") or buff_extension:has_buff_type("bardin_ironbreaker_activated_ability_taunt_range_and_duration")) then
			local first_person_extension = ScriptUnit.extension(unit, "first_person_system")

			first_person_extension:play_hud_sound_event("Play_career_ability_bardin_ironbreaker_hit")
		end
	end

	if ScriptUnit.has_extension(attacker_unit, "hud_system") then
		DamageUtils.handle_hit_indication(attacker_unit, unit, damage_amount, hit_zone_name, added_dot)
	end

	local weave_manager = Managers.weave

	if weave_manager:get_active_weave() and self.is_server and damage_amount > 0 then
		weave_manager:player_damaged(damage_amount)
	end

	if self.is_server and not self:get_is_invincible() and not script_data.player_invincible then
		local game = self.game
		local game_object_id = self.health_game_object_id

		if game and game_object_id then
			local force_permanent_damage = FORCED_PERMANENT_DAMAGE_TYPES[damage_type]
			local current_health = GameSession.game_object_field(game, game_object_id, "current_health")
			local current_temporary_health = GameSession.game_object_field(game, game_object_id, "current_temporary_health")
			local permanent_damage_amount, temporary_damage_amount = nil
			local total_health = current_health + current_temporary_health
			local modified_damage_amount = (damage_amount >= total_health and total_health - min_health) or damage_amount

			if force_permanent_damage then
				permanent_damage_amount = (current_health < modified_damage_amount and current_health) or modified_damage_amount
				temporary_damage_amount = (current_health < modified_damage_amount and modified_damage_amount - current_health) or 0
			else
				permanent_damage_amount = (current_temporary_health < modified_damage_amount and modified_damage_amount - current_temporary_health) or 0
				temporary_damage_amount = (current_temporary_health < modified_damage_amount and current_temporary_health) or modified_damage_amount

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
			local source_attacker_unit_id = self.network_manager:unit_game_object_id(source_attacker_unit) or attacker_unit_id
			local hit_zone_id = NetworkLookup.hit_zones[hit_zone_name]
			local damage_type_id = NetworkLookup.damage_types[damage_type]
			local damage_source_id = NetworkLookup.damage_sources[damage_source_name or "n/a"]
			local hit_ragdoll_actor_id = NetworkLookup.hit_ragdoll_actors[hit_ragdoll_actor or "n/a"]
			local hit_react_type_id = NetworkLookup.hit_react_types[hit_react_type or "light"]
			is_critical_strike = is_critical_strike or false
			added_dot = added_dot or false
			first_hit = first_hit or false
			total_hits = total_hits or 1
			backstab_multiplier = backstab_multiplier or 1

			self.network_transmit:send_rpc_clients("rpc_add_damage", unit_id, false, attacker_unit_id, attacker_is_level_unit, source_attacker_unit_id, damage_amount, hit_zone_id, damage_type_id, hit_position, damage_direction, damage_source_id, hit_ragdoll_actor_id, hit_react_type_id, is_dead, is_critical_strike, added_dot, first_hit, total_hits, backstab_multiplier)
		end
	end
end)
