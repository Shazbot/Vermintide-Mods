-- luacheck: globals get_mod BTSpawningAction Managers DialogueSystem ScriptUnit
-- luacheck: globals DialogueLookup

local mod = get_mod("TrueSoloQoL")

mod.breed_name_to_dialogue_lookup = {
	skaven_gutter_runner = "_gameplay_hearing_a_gutter_runner",
	skaven_pack_master = "_gameplay_seeing_a_skaven_slaver",
}

mod:hook_safe(BTSpawningAction, "enter", function(self, unit, blackboard, t)
	if not mod:get(mod.SETTING_NAMES.ASSASSIN_HERO_WARNING) then
		return
	end

	local dialogue = mod.breed_name_to_dialogue_lookup[blackboard.breed.name]
	if dialogue then
		Managers.state.entity:system("dialogue_system"):force_play_hero_warning(dialogue)
	end
end)

mod:hook(DialogueSystem, "_update_currently_playing_dialogues", function(func, self, dt)
	if not mod:get(mod.SETTING_NAMES.ASSASSIN_HERO_WARNING) then
		return func(self, dt)
	end

	pcall(func, self, dt)
end)

mod.profile_name_to_short_name = {
	empire_soldier = "pes",
	witch_hunter = "pwh",
	bright_wizard = "pbw",
	dwarf_ranger = "pdr",
	wood_elf = "pwe",
}

-- dialogue_part is e.g. _gameplay_hearing_a_gutter_runner, missing short_name in front(pes, pdr etc.)
DialogueSystem.force_play_hero_warning = function(self, dialogue_part)
	mod:pcall(function()
		if not self.is_server then
			return
		end

		local unit = Managers.player:local_player().player_unit
		local profile_name = ScriptUnit.extension(unit, "dialogue_system").context.player_profile
		local short_name = mod.profile_name_to_short_name[profile_name]
		local dialogue_key = short_name..dialogue_part
		if self.dialogues[dialogue_key] then
			local dialogue_id = DialogueLookup[dialogue_key]
			local network_manager = Managers.state.network

			local go_id, is_level_unit = network_manager:game_object_or_level_id(unit)
			local num_lines = self.dialogues[dialogue_key].sound_events_n
			local line_index = math.random(num_lines)
			self:rpc_interrupt_dialogue_event(nil, go_id, is_level_unit)
			self:rpc_play_dialogue_event(nil, go_id, is_level_unit, dialogue_id, line_index)
		end
	end)
end
