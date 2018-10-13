local mod = get_mod("NeuterUltEffects")

mod.get_rpc_trigger_dialogue_event_data = function(action_career_object)
	local self = action_career_object

	local unit = self._owner_unit
	local go_id = NetworkUnit.game_object_id(unit)
	local event_id = NetworkLookup.dialogue_events["activate_ability"]

	local event_data = FrameTable.alloc_table()

	local event_data_array_temp_types = FrameTable.alloc_table()
	local event_data_array_temp = FrameTable.alloc_table()
	local event_data_array_temp_n = table.table_to_array(event_data, event_data_array_temp)

	for i = 1, event_data_array_temp_n, 1 do
		local value = event_data_array_temp[i]

		if type(value) == "number" then
			assert(value % 1 == 0, "Tried to pass non-integer value to dialogue event")
			assert(value >= 0, "Tried to send a dialogue data number smaller than zero")

			event_data_array_temp[i] = value + 1
			event_data_array_temp_types[i] = true
		else
			local value_id = NetworkLookup.dialogue_event_data_names[value]
			event_data_array_temp[i] = value_id
			event_data_array_temp_types[i] = false
		end

	end

	return go_id, event_id, event_data_array_temp, event_data_array_temp_types
end

mod:hook(DialogueSystem, "rpc_play_dialogue_event", function(func, self, sender, go_id, is_level_unit, dialogue_id, dialogue_index)
	if mod:get(mod.SETTING_NAMES.ONLY_DISABLE_OWN_LINES) then
		return func(self, sender, go_id, is_level_unit, dialogue_id, dialogue_index)
	end

	local dialogue_name = NetworkLookup.dialogues[dialogue_id]
	if string.find(dialogue_name, "special_ability_") then
		local unit = Managers.state.unit_storage:unit(go_id)
		if unit then
			local career_extension = ScriptUnit.has_extension(unit, "career_system")
			if career_extension then
				if mod:get(career_extension._career_name.."_vo") then
					return
				end
			end
		end
	end

	return func(self, sender, go_id, is_level_unit, dialogue_id, dialogue_index)
end)

mod.get_vo_hook = function(career_name)
	return
		function(func, self, ...)
			if mod:get(career_name.."_vo") then
				local network_manager = Managers.state.network
				if self._is_server then
					local go_id, event_id, event_data_array_temp, event_data_array_temp_types =
							mod.get_rpc_trigger_dialogue_event_data(self)
					network_manager.network_transmit:send_rpc_clients("rpc_trigger_dialogue_event",
							go_id, event_id, event_data_array_temp, event_data_array_temp_types)
				else
					local go_id, event_id, event_data_array_temp, event_data_array_temp_types =
							mod.get_rpc_trigger_dialogue_event_data(self)
					network_manager.network_transmit:send_rpc_server("rpc_trigger_dialogue_event",
							go_id, event_id, event_data_array_temp, event_data_array_temp_types)
				end

				return
			end

			return func(self, ...)
		end
end

local career_name_to_action_object = {
	bw_scholar = ActionCareerBWScholar,
	wh_bountyhunter = ActionCareerWHBountyhunter,
	dr_ranger = ActionCareerDRRanger,
	we_waywatcher = ActionCareerWEWaywatcher,
}

mod:pcall(function()
	for career_key, career in pairs( CareerSettings ) do
		if career.activated_ability.ability_class
		and career_key ~= "empire_soldier_tutorial"
		then
			mod:hook(career.activated_ability.ability_class, "_play_vo",
					mod.get_vo_hook(career.display_name))
		end
	end
	for career_name, action_career_object in pairs( career_name_to_action_object ) do
		mod:hook(action_career_object, "_play_vo", mod.get_vo_hook(career_name))
	end
end)
