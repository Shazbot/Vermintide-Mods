local mod = get_mod("ModdedProgression")

local vmf = get_mod("VMF")

mod:hook_safe(StatisticsUtil, "_register_completed_level_difficulty", function(_, level_id, _, difficulty_name)
	if difficulty_name ~= "hardest" then
		return
	end

	local dwons_mod = get_mod("is-dwons-on")
	if dwons_mod then
		local dw_enabled, ons_enabled = dwons_mod.get_status()
		local completions_lookup = {
			ONS_COMPLETION = ons_enabled,
			DW_COMPLETION = dw_enabled,
		}
		local flush_settings = false
		for completion_key, enabled in pairs( completions_lookup ) do
			if enabled then
				local completions = mod:get(completion_key) or {}
				completions[level_id] = true
				mod:set(completion_key, completions)
				flush_settings = true
			end
		end
		if flush_settings then
			vmf.save_unsaved_settings_to_file()
		end
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

		new_widget.content.ons = ons_completion[level_key]
		new_widget.content.dw = dw_completion[level_key]

		table.insert(self.mod_widgets, new_widget)
	end
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

	UIRenderer.end_pass(ui_renderer)
end)

mod.create_level_widget = function(scenegraph_id)
	local widget = {
		element = {}
	}
	local passes = {
		{
			pass_type = "texture",
			style_id = "frame",
			texture_id = "frame",
			content_check_function = function (content)
				return content.ons
			end

		},
		{
			pass_type = "texture",
			style_id = "icon",
			texture_id = "icon",
			content_check_function = function (content)
				return content.dw
			end
		},
	}
	local content = {
		frame = "achievement_banner",
		icon = "end_screen_banner_victory",
		ons = false,
		dw = false,
	}
	local style = {
		frame = {
			vertical_alignment = "center",
			horizontal_alignment = "center",
			texture_size = {
				164,
				125
			},
			offset = {
				0,-90,50
			},
			color = {
				255,
				220,20,60
			}
		},
		icon = {
			vertical_alignment = "center",
			horizontal_alignment = "center",
			texture_size = {
				680/5,
				240/5,
			},
			offset = {
				0,-88,51
			},
			color = {
				255,
				255,255,255
			}
		},
	}
	widget.element.passes = passes
	widget.content = content
	widget.style = style
	widget.offset = {0,0,0}
	widget.scenegraph_id = scenegraph_id

	return widget
end
