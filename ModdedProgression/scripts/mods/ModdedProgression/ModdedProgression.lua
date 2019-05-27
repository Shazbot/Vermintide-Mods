local mod = get_mod("ModdedProgression")

local pl = require'pl.import_into'()

local vmf = get_mod("VMF")

mod:hook_safe(StatisticsUtil, "_register_completed_level_difficulty", function(_, level_id, _, difficulty_name)
	if mod.map_start_time then
		mod.map_time = Managers.time:time("game") - mod.map_start_time
		if mod.map_time < 60 then
			return
		end
	end

	local flush_settings = false

	local true_solo = false
	if Managers.player.is_server then
		local players = Managers.player:human_and_bot_players()
		if #pl.Map(players):keys() == 1 then
			true_solo = true
		end
	end

	local dw_enabled, ons_enabled = false, false
	local dwons_mod = get_mod("is-dwons-on")
	if dwons_mod then
		dw_enabled, ons_enabled = dwons_mod.get_status()
	end

	local completions_lookup = {
		ONS_COMPLETION = ons_enabled,
		DW_COMPLETION = dw_enabled,
		DWONS_COMPLETION = dw_enabled and ons_enabled,
	}

	local difficulty_done_lookup = {
		ONS_DIFFICULTY = ons_enabled,
		DW_DIFFICULTY = dw_enabled,
		DWONS_DIFFICULTY = dw_enabled and ons_enabled,
		TS_DIFFICULTY = true_solo,
	}

	local difficulty_index = pl.tablex.find(DefaultDifficulties, difficulty_name)
	if difficulty_index then
		for completion_key, enabled in pairs( difficulty_done_lookup ) do
			if enabled then
				local completions = mod:get(completion_key) or {}
				if completions[level_id] then
					local done_difficulty_index = pl.tablex.find(DefaultDifficulties, completions[level_id])
					if done_difficulty_index and done_difficulty_index > difficulty_index then
						completions[level_id] = difficulty_name
					end
				else
					completions[level_id] = difficulty_name
				end
				mod:set(completion_key, completions)
				flush_settings = true
			end
		end
	end

	if difficulty_name == "hardest" then
		for completion_key, enabled in pairs( completions_lookup ) do
			if enabled then
				local completions = mod:get(completion_key) or {}
				completions[level_id] = true
				mod:set(completion_key, completions)
				flush_settings = true
			end
		end

		if mod.map_start_time then
			mod.map_time = Managers.time:time("game") - mod.map_start_time
			if mod.map_time >= 60 then
				local map_times = mod:get("MAP_TIMES") or {}
				map_times[level_id] = map_times[level_id] or {}
				map_times[level_id] =
					pl.List(map_times[level_id])
					:append(mod.map_time)
					:sorted()
					:slice(1,10)
				mod:set("MAP_TIMES", map_times)
				flush_settings = true
			end
		end
	end

	mod.map_start_time = nil

	if flush_settings then
		vmf.save_unsaved_settings_to_file()
	end
end)

mod:hook_safe(StartGameWindowMissionSelection, "_present_acts", function(self)
	self.mod_widgets = {}
	for _, widget in ipairs( self._active_node_widgets ) do
		local new_widget = UIWidget.init(mod.create_level_widget(widget.scenegraph_id))
		new_widget.offset = table.clone(widget.offset)

		local level_key = widget.content.level_key

		local ons_completion = mod:get("ONS_COMPLETION") or {}
		local dw_completion = mod:get("DW_COMPLETION") or {}
		local dwons_completion = mod:get("DWONS_COMPLETION") or {}

		new_widget.content.ons = ons_completion[level_key]
		new_widget.content.dw = dw_completion[level_key]
		new_widget.content.dwons = dwons_completion[level_key]

		table.insert(self.mod_widgets, new_widget)
	end
end)

mod.get_map_time = function(level_id)
	local map_times = mod:get("MAP_TIMES") or {}

	local map_time = "00:00"

	if map_times[level_id] and map_times[level_id][1] then
		local total_secs = map_times[level_id][1]
		local mins = math.floor(total_secs/60)
		local secs = math.round(total_secs % 60)
		map_time = mins..":"..secs
	end

	return map_time
end

mod:hook(StartGameWindowMissionSelection, "update", function(func, self, dt, t)
	mod:pcall(function()
		self._widgets_by_name.selected_level.offset[1] = 0
		self._widgets_by_name.selected_level.offset[2] = 210
		self._widgets_by_name.selected_level.offset[3] = 50

		if not self.mod_progression_text then
			self.mod_progression_text = UIWidget.init(UIWidgets.create_simple_text("", "description_text", nil, nil, mod.description_text_style))
			self.mod_progression_text.offset[2] = 270
		end

		local level_id = self._selected_level_id or ""

		local modded_muts_names = pl.List{
			"Onslaught",
			"Deathwish",
			"DwOns",
			"True Solo",
		}

		local modded_mut_to_difficutly_done_setting_lookup = pl.Map{
			Onslaught = "ONS_DIFFICULTY",
			Deathwish = "DW_DIFFICULTY",
			DwOns = "DWONS_DIFFICULTY",
			["True Solo"] = "TS_DIFFICULTY",
		}

		local modded_mut_to_done_on_hardest_lookup = pl.Map{
			Onslaught = mod:get("ONS_COMPLETION") or {},
			Deathwish = mod:get("DW_COMPLETION") or {},
			DwOns = mod:get("DWONS_COMPLETION") or {},
		}

		local info_out = {}
		modded_muts_names:foreach(function(modded_mut_name)
			local done_on_difficulty_setting = modded_mut_to_difficutly_done_setting_lookup[modded_mut_name]
			local done_on_difficulty = mod:get(done_on_difficulty_setting) or {}

			local done_difficulty = done_on_difficulty[level_id]
			if modded_mut_to_done_on_hardest_lookup[modded_mut_name]
			and modded_mut_to_done_on_hardest_lookup[modded_mut_name][level_id] then
				info_out[modded_mut_name] = "Yes"
			elseif not done_difficulty then
				info_out[modded_mut_name] = "No"
			elseif done_difficulty == "hardest" then
				info_out[modded_mut_name] = "Yes"
			else
				info_out[modded_mut_name] = Localize(DifficultySettings[done_difficulty].display_name)
			end
		end)

		self.mod_progression_text.content.text =
			modded_muts_names:map(function(modded_mut)
				return string.format("%s: %s", modded_mut, info_out[modded_mut])
			end)
			:insert(1, "Time: "..mod.get_map_time(level_id))
			:join("\n")
	end)

	return func(self, dt, t)
end)

mod:hook_safe(StartGameWindowMissionSelection, "draw", function(self, dt)
	local ui_renderer = self.ui_renderer
	local ui_scenegraph = self.ui_scenegraph
	local input_service = self.parent:window_input_service()

	UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, self.render_settings)

	if self.mod_widgets then
		for i = 1, #self.mod_widgets, 1 do
			local widget = self.mod_widgets[i]

			UIRenderer.draw_widget(ui_renderer, widget)
		end
	end

	if self.mod_progression_text then
		UIRenderer.draw_widget(ui_renderer, self.mod_progression_text)
	end

	UIRenderer.end_pass(ui_renderer)
end)

mod:dofile("scripts/mods/"..mod:get_name().."/widget_definitions")
mod:dofile("scripts/mods/"..mod:get_name().."/map_timer")
