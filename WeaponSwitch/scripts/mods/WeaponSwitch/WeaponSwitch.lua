local mod = get_mod("WeaponSwitch")

-- luacheck: globals CharacterStateHelper ScriptUnit Profiler Managers DamageProfileTemplates BackendUtils
-- luacheck: globals Development ActionUtils table InventorySettings

local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
}

mod:initialize_data(mod_data)

--- Callbacks ---
mod.on_disabled = function(is_first_call) -- luacheck: ignore is_first_call
	mod:disable_all_hooks()
end

mod.on_enabled = function(is_first_call) -- luacheck: ignore is_first_call
	mod:enable_all_hooks()
end

--- Mod Logic ---
local function validate_action(unit, action_name, sub_action_name, action_settings, input_extension, inventory_extension, only_check_condition, ammo_extension)
	local input_id = action_settings.input_override or action_name
	local skip_hold = action_settings.do_not_validate_with_hold
	local hold_input = not skip_hold and action_settings.hold_input
	local wield_input = CharacterStateHelper.wield_input(input_extension, inventory_extension, input_id)
	local buffered_input = input_extension:get_buffer(input_id)
	local action_input = input_extension:get(input_id)
	local action_hold_input = hold_input and input_extension:get(hold_input)
	local allow_toggle = action_settings.allow_hold_toggle and input_extension.toggle_alternate_attack
	local hold_or_toggle_input = (allow_toggle and action_input) or (not allow_toggle and (action_input or action_hold_input))

	if only_check_condition or wield_input or buffered_input or hold_or_toggle_input then
		local condition_func = action_settings.condition_func
		local condition_passed = nil

		if condition_func then
			condition_passed = condition_func(unit, input_extension, ammo_extension)
		else
			condition_passed = true
		end

		if condition_passed then
			if not wield_input and not action_settings.keep_buffer then
				input_extension:reset_input_buffer()
			end

			return action_name, sub_action_name
		end
	end

	return
end

local weapon_action_interrupt_damage_types = {
	cutting_berserker = true,
	cutting = true
}
local interupting_action_data = {}
mod:hook("CharacterStateHelper.update_weapon_actions",
function (func, t, unit, input_extension, inventory_extension, health_extension) -- luacheck: ignore func

	local item_data, right_hand_weapon_extension, left_hand_weapon_extension = CharacterStateHelper.get_item_data_and_weapon_extensions(inventory_extension)

	table.clear(interupting_action_data)

	if not item_data then

		return
	end

	local new_action, new_sub_action, current_action_settings, current_action_extension, current_action_hand = nil
	current_action_settings, current_action_extension, current_action_hand = CharacterStateHelper.get_current_action_data(left_hand_weapon_extension, right_hand_weapon_extension)
	local item_template = BackendUtils.get_item_template(item_data)
	local recent_damage_type, recent_hit_react_type = health_extension:recently_damaged()
	local status_extension = ScriptUnit.extension(unit, "status_system")
	local buff_extension = ScriptUnit.extension(unit, "buff_system")
	local uninterruptible_heavy = false

	if current_action_settings then
		local damage_profile = current_action_settings.damage_profile
		uninterruptible_heavy = damage_profile and DamageProfileTemplates[damage_profile].charge_value == "heavy_attack" and buff_extension:has_buff_perk("uninterruptible_heavy")
	end

	local can_interrupt, reloading = nil
	local player = Managers.player:owner(unit)
	local is_bot_player = player and player.bot_player

	if recent_damage_type and weapon_action_interrupt_damage_types[recent_damage_type] then
		local ammo_extension = (left_hand_weapon_extension and left_hand_weapon_extension.ammo_extension) or (right_hand_weapon_extension and right_hand_weapon_extension.ammo_extension)

		if ammo_extension then
			if left_hand_weapon_extension and left_hand_weapon_extension.ammo_extension then
				reloading = left_hand_weapon_extension.ammo_extension:is_reloading()
			end

			if right_hand_weapon_extension and right_hand_weapon_extension.ammo_extension then
				reloading = right_hand_weapon_extension.ammo_extension:is_reloading()
			end
		end

		if (current_action_settings and current_action_settings.uninterruptible) or script_data.uninterruptible or reloading or is_bot_player or buff_extension:has_buff_perk("uninterruptible") or uninterruptible_heavy then
			can_interrupt = false
		elseif recent_damage_type == "cutting_berserker" then
			can_interrupt = true
		else
			can_interrupt = status_extension:hitreact_interrupt()
		end

		if can_interrupt and not status_extension:is_disabled() then
			local has_reduced_hit_react_buff = buff_extension:has_buff_perk("reduced_hit_react")

			if has_reduced_hit_react_buff then
				recent_hit_react_type = "light"
			end

			if current_action_settings then
				current_action_extension:stop_action("interrupted")
			end

			local first_person_extension = ScriptUnit.extension(unit, "first_person_system")

			CharacterStateHelper.play_animation_event(unit, "hit_reaction")

			if recent_hit_react_type == "medium" then
				first_person_extension:play_hud_sound_event("enemy_hit_medium")
			elseif recent_hit_react_type == "heavy" then
				first_person_extension:play_hud_sound_event("enemy_hit_heavy")
			end

			if not Development.parameter("attract_mode") then
				if recent_damage_type == "cutting_berserker" then
					status_extension:set_hit_react_type(recent_hit_react_type)
					status_extension:set_pushed_no_cooldown(true, t)
				else
					status_extension:set_hit_react_type(recent_hit_react_type)
					status_extension:set_pushed(true, t)
				end
			end

			return
		end
	end

	local next_action_init_data = nil

	if current_action_settings then
		new_action, new_sub_action = CharacterStateHelper._get_chain_action_data(item_template, current_action_extension, current_action_settings, input_extension, inventory_extension, unit, t)

		if not new_action then
			if current_action_settings.allow_hold_toggle and input_extension.toggle_alternate_attack then
				local input_id = current_action_settings.lookup_data.action_name

				if input_id and input_extension:get(input_id, true) and current_action_extension:can_stop_hold_action(t) then
					current_action_extension:stop_action("hold_input_released")
				end
			else
				local input_id = current_action_settings.hold_input

				if input_id and not input_extension:get(input_id) and current_action_extension:can_stop_hold_action(t) then
					current_action_extension:stop_action("hold_input_released")
				end
			end
		end
	elseif item_template.next_action then
		local action_data = item_template.next_action
		next_action_init_data = action_data.action_init_data
		local action_name = action_data.action
		local only_check_condition = true
		local sub_actions = item_template.actions[action_name]

		for sub_action_name, action_settings in pairs(sub_actions) do
			if sub_action_name ~= "default" and action_settings.condition_func then
				new_action, new_sub_action = validate_action(unit, action_name, sub_action_name, action_settings, input_extension, inventory_extension, only_check_condition)

				if new_action and new_sub_action then
					break
				end
			end
		end

		if not new_action then
			local action_settings = item_template.actions[action_name].default
			new_action, new_sub_action = validate_action(unit, action_name, "default", action_settings, input_extension, inventory_extension, only_check_condition)
		end

		item_template.next_action = nil
	else
		local ammo_extension = (left_hand_weapon_extension and left_hand_weapon_extension.ammo_extension) or (right_hand_weapon_extension and right_hand_weapon_extension.ammo_extension)

		local action_wield_action_name = "action_wield"
		if item_template and item_template.actions[action_wield_action_name] then
			local action_settings = item_template.actions[action_wield_action_name].default
			new_action, new_sub_action = validate_action(unit, action_wield_action_name, "default", action_settings, input_extension, inventory_extension, false, ammo_extension)
		end

		if not new_action then
			local action_reload_action_name = "weapon_reload"
			if (
					item_template
					and item_template.actions[action_reload_action_name]
					and item_template.actions[action_reload_action_name]["default"]
					and (
							input_extension:get("weapon_reload", false)
							or input_extension:get("weapon_reload_hold", false)
						)
				) then
				new_action = action_reload_action_name
				new_sub_action = "default"
			end
		end

		if not new_action then
			for action_name, sub_actions in pairs(item_template.actions) do
				for sub_action_name, action_settings in pairs(sub_actions) do
					if sub_action_name ~= "default" and action_settings.condition_func then
						new_action, new_sub_action = validate_action(unit, action_name, sub_action_name, action_settings, input_extension, inventory_extension, false, ammo_extension)

						if new_action and new_sub_action then
							break
						end
					end
				end

				if not new_action then
					local action_settings = item_template.actions[action_name].default
					new_action, new_sub_action = validate_action(unit, action_name, "default", action_settings, input_extension, inventory_extension, false, ammo_extension)
				end

				if new_action then
					break
				end
			end
		end
	end

	if new_action and new_sub_action then
		local career_ext = ScriptUnit.extension(unit, "career_system")
		local power_level = career_ext:get_career_power_level()
		local actions = item_template.actions
		local new_action_settings = actions[new_action][new_sub_action]
		local weapon_action_hand = new_action_settings.weapon_action_hand or "right"
		interupting_action_data.new_action = new_action
		interupting_action_data.new_sub_action = new_sub_action

		if weapon_action_hand == "both" then
			assert(left_hand_weapon_extension and right_hand_weapon_extension, "tried to start a dual wield weapon action without both a left and right hand wielded unit")

			if current_action_hand == "left" then
				left_hand_weapon_extension:stop_action("new_interupting_action", interupting_action_data)
			elseif current_action_hand == "right" then
				right_hand_weapon_extension:stop_action("new_interupting_action", interupting_action_data)
			elseif current_action_hand == "both" then
				left_hand_weapon_extension:stop_action("new_interupting_action", interupting_action_data)
				right_hand_weapon_extension:stop_action("new_interupting_action", interupting_action_data)
			end

			local left_action_init_data = (next_action_init_data and table.merge(next_action_init_data, {
				action_hand = "left"
			})) or {
				action_hand = "left"
			}
			local right_action_init_data = (next_action_init_data and table.merge(next_action_init_data, {
				action_hand = "right"
			})) or {
				action_hand = "right"
			}

			left_hand_weapon_extension:start_action(new_action, new_sub_action, item_template.actions, t, power_level, left_action_init_data)
			right_hand_weapon_extension:start_action(new_action, new_sub_action, item_template.actions, t, power_level, right_action_init_data)

			return
		end

		if weapon_action_hand == "either" then
			if right_hand_weapon_extension then
				weapon_action_hand = "right"
			else
				weapon_action_hand = "left"
			end
		end

		if weapon_action_hand == "left" then
			assert(left_hand_weapon_extension, "tried to start a left hand weapon action without a left hand wielded unit")

			if current_action_hand == "right" then
				right_hand_weapon_extension:stop_action("new_interupting_action", interupting_action_data)
			elseif current_action_hand == "both" then
				left_hand_weapon_extension:stop_action("new_interupting_action", interupting_action_data)
				right_hand_weapon_extension:stop_action("new_interupting_action", interupting_action_data)
			end

			left_hand_weapon_extension:start_action(new_action, new_sub_action, item_template.actions, t, power_level, next_action_init_data)

			return
		end

		assert(right_hand_weapon_extension, "tried to start a right hand weapon action without a right hand wielded unit")

		if current_action_hand == "left" then
			left_hand_weapon_extension:stop_action("new_interupting_action", interupting_action_data)
		elseif current_action_hand == "both" then
			left_hand_weapon_extension:stop_action("new_interupting_action", interupting_action_data)
			right_hand_weapon_extension:stop_action("new_interupting_action", interupting_action_data)
		end

		right_hand_weapon_extension:start_action(new_action, new_sub_action, item_template.actions, t, power_level, next_action_init_data)
	end
end)

local empty_table = {}
local career_chain_action = {
	sub_action = "default",
	start_time = 0,
	action = "N/A",
	input = "action_career"
}
mod:hook("CharacterStateHelper._get_chain_action_data",
function (func, item_template, current_action_extension, current_action_settings, input_extension, inventory_extension, unit, t, is_bot_player)  -- luacheck: ignore func
	local done, _, new_action, new_sub_action, wield_input, send_buffer, clear_buffer = nil
	local career_extension = ScriptUnit.has_extension(unit, "career_system")

	if career_extension then
		local lookup_data = current_action_settings.lookup_data
		local current_action_name = lookup_data.action_name
		local activated_ability_data = career_extension:get_activated_ability_data()
		local action_name = activated_ability_data.action_name

		if action_name and action_name ~= current_action_name then
			local action_data = career_chain_action
			action_data.action = action_name
			_, new_action, new_sub_action, wield_input, send_buffer, clear_buffer = CharacterStateHelper._check_chain_action(wield_input, action_data, item_template, current_action_extension, input_extension, inventory_extension, unit, t)
		end
	end

	if not new_action then
		local chain_actions = current_action_settings.allowed_chain_actions or empty_table

		for i = 1, #chain_actions, 1 do
			local action_data = chain_actions[i]
			done, new_action, new_sub_action, wield_input, send_buffer, clear_buffer = CharacterStateHelper._check_chain_action(wield_input, action_data, item_template, current_action_extension, input_extension, inventory_extension, unit, t)

			if done then
				break
			end
		end
	end

	local item_data, right_hand_weapon_extension, left_hand_weapon_extension = CharacterStateHelper.get_item_data_and_weapon_extensions(inventory_extension)
	if right_hand_weapon_extension
	    and right_hand_weapon_extension.item_name then
	    -- EchoConsole("R: "..tostring(right_hand_weapon_extension.item_name))
	end

	if left_hand_weapon_extension
	    and left_hand_weapon_extension.item_name then
	    -- EchoConsole("L: "..tostring(left_hand_weapon_extension.item_name))
	end

	local chain_actions = current_action_settings.allowed_chain_actions or empty_table
	local item_data, right_hand_weapon_extension, left_hand_weapon_extension = CharacterStateHelper.get_item_data_and_weapon_extensions(inventory_extension)
	if right_hand_weapon_extension
	  and right_hand_weapon_extension.item_name
		-- and (string.find(right_hand_weapon_extension.item_name, "repeating_handgun") ~= nil
		-- or string.find(right_hand_weapon_extension.item_name, "rakegun") ~= nil
	  or
		left_hand_weapon_extension
		and left_hand_weapon_extension.item_name
		-- and (string.find(left_hand_weapon_extension.item_name, "hagbane") ~= nil
		-- or string.find(left_hand_weapon_extension.item_name, "trueflight") ~= nil)
	  then
		for i = 1, #chain_actions, 1 do
			local action_data = chain_actions[i]
			local input_id = action_data.input

			if input_id == "action_wield" then
				wield_input = CharacterStateHelper.wield_input(input_extension, inventory_extension, action_data.action)
				if wield_input then
					local sub_action = action_data.sub_action

					if not sub_action and action_data.first_possible_sub_action then
						local sub_actions = item_template.actions[action_data.action]

						for sub_action_name, data in pairs(sub_actions) do
							local condition_func = data.chain_condition_func

							if not condition_func or condition_func(unit) then
								sub_action = sub_action_name

								break
							end
						end
					end

					if sub_action then
						new_action = action_data.action
						new_sub_action = sub_action
						send_buffer = action_data.send_buffer
						clear_buffer = action_data.clear_buffer
					end
				end
			end
		end
	end

	if new_action then
		local action_settings = item_template.actions[new_action] and item_template.actions[new_action][new_sub_action]

		if clear_buffer or new_sub_action == "push" then
			input_extension:clear_input_buffer()
		elseif action_settings and not wield_input and not action_settings.keep_buffer and not send_buffer then
			input_extension:reset_input_buffer()
		end
	end

	return new_action, new_sub_action, wield_input
end)

mod:hook("CharacterStateHelper._check_chain_action",
function (func, wield_input, action_data, item_template, current_action_extension, input_extension, inventory_extension, unit, t)  -- luacheck: ignore func
	local new_action, new_sub_action, send_buffer, clear_buffer = nil
	local release_required = action_data.release_required
	local input_extra_requirement = true

	if release_required then
		input_extra_requirement = input_extension:released_input(release_required)
	end

	local hold_required = action_data.hold_required

	if hold_required then
		for index, hold_require in pairs(hold_required) do
			if input_extension:released_input(hold_require) then
				input_extra_requirement = false

				break
			end
		end
	end

	local input_id = action_data.input
	local softbutton_threshold = action_data.softbutton_threshold
	local input = nil
	local no_buffer = action_data.no_buffer
	local doubleclick_window = action_data.doubleclick_window
	local blocking_input = action_data.blocking_input
	local blocked = false

	local need_to_switch = CharacterStateHelper.get_buffered_input("wield_switch", input_extension)
	local slots_by_name = InventorySettings.slots_by_name
	local wieldable_slots = InventorySettings.slots_by_wield_input
	local equipment = inventory_extension:equipment()
	local wielded_slot_name = equipment.wielded_slot
	local current_slot = slots_by_name[wielded_slot_name]
	for index, slot in ipairs(wieldable_slots) do
		if slot ~= current_slot then
			local wield_input = slot.wield_input
			local name = slot.name

			if equipment.slots[name] and CharacterStateHelper.get_buffered_input(wield_input, input_extension) then
				need_to_switch = true
				break
			end
		end
	end

	if not need_to_switch then
		if blocking_input then
			blocked = input_extension:get(blocking_input)
		end

		if input_extra_requirement and not blocked then
			input = CharacterStateHelper.get_buffered_input(input_id, input_extension, no_buffer, doubleclick_window, softbutton_threshold)
		end
	end

	if not input then
		wield_input = CharacterStateHelper.wield_input(input_extension, inventory_extension, action_data.action)
		input = wield_input
	end

	if input or action_data.auto_chain then
		local select_chance = action_data.select_chance or 1
		local is_selected = math.random() <= select_chance
		local chain_action_available = current_action_extension:is_chain_action_available(action_data, t)

		if chain_action_available and is_selected then
			local sub_action = action_data.sub_action

			if not sub_action and action_data.first_possible_sub_action then
				local sub_actions = item_template.actions[action_data.action]

				for sub_action_name, data in pairs(sub_actions) do
					local condition_func = data.chain_condition_func

					if not condition_func or condition_func(unit) then
						sub_action = sub_action_name

						break
					end
				end
			end

			if action_data.blocker then
				return true, nil, nil, wield_input, nil, nil
			end

			if sub_action then
				new_action = action_data.action
				new_sub_action = sub_action
				local action_settings = item_template.actions[new_action] and item_template.actions[new_action][new_sub_action]
				local condition_func = action_settings and action_settings.chain_condition_func

				if not action_settings or (condition_func and not condition_func(unit, input_extension)) then
					new_action, new_sub_action = nil
				else
					send_buffer = action_data.send_buffer
					clear_buffer = action_data.clear_buffer

					return true, new_action, new_sub_action, wield_input, send_buffer, clear_buffer
				end
			end
		end
	end

	return false
end)