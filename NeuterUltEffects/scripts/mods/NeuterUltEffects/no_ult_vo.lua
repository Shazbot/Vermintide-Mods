local mod = get_mod("NeuterUltEffects")

--- Catch host requests to play ult lines.
mod:hook(DialogueSystem, "rpc_play_dialogue_event", function(func, self, sender, go_id, is_level_unit, dialogue_id, dialogue_index)
	local dialogue_name = NetworkLookup.dialogues[dialogue_id]
	if string.find(dialogue_name, "special_ability_")
	or string.find(dialogue_name, "activate_ability_") then
		local unit = Managers.state.unit_storage:unit(go_id)
		if unit then
			local career_extension = ScriptUnit.has_extension(unit, "career_system")
			if career_extension then
				if mod:get(career_extension._career_name.."_vo") then
					local player_unit = Managers.player:local_player().player_unit
					if not mod:get(mod.SETTING_NAMES.ONLY_DISABLE_OWN_LINES)
					or (
							mod:get(mod.SETTING_NAMES.ONLY_DISABLE_OWN_LINES)
							and unit == player_unit
						)
					then
						return
					end
				end
			end
		end
	end

	return func(self, sender, go_id, is_level_unit, dialogue_id, dialogue_index)
end)
