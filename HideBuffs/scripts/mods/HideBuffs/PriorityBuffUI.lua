local mod = get_mod("HideBuffs")

local pl = require'pl.import_into'()

local definitions = local_require("scripts/mods/HideBuffs/buff_ui_definitions")
local scenegraph_definition = definitions.scenegraph_definition
scenegraph_definition = table.clone(scenegraph_definition)
scenegraph_definition.pivot = {
	vertical_alignment = "top",
	parent = "root",
	horizontal_alignment = "center",
	position = {
		0,
		-200,
		1
	},
	size = {
		0,
		0
	}
}
local ALIGNMENT_DURATION_TIME = 0.3
local MAX_NUMBER_OF_BUFFS = definitions.MAX_NUMBER_OF_BUFFS
local BUFF_SIZE = table.clone(definitions.BUFF_SIZE)
local BUFF_SPACING = definitions.BUFF_SPACING
PriorityBuffUI = class(PriorityBuffUI)

PriorityBuffUI.init = function (self, ingame_ui_context)
	self.ui_renderer = ingame_ui_context.ui_renderer
	self.ingame_ui = ingame_ui_context.ingame_ui
	self.input_manager = ingame_ui_context.input_manager
	self.peer_id = ingame_ui_context.peer_id
	self.player_manager = ingame_ui_context.player_manager
	self.ui_animations = {}
	self.is_in_inn = ingame_ui_context.is_in_inn
	self.render_settings = {
		alpha_multiplier = 1
	}

	self:_create_ui_elements()
end

PriorityBuffUI._create_ui_elements = function (self)
	self.ui_scenegraph = UISceneGraph.init_scenegraph(scenegraph_definition)
	local buff_widgets = {}
	local unused_buff_widgets = {}

	for i, definition in ipairs(definitions.buff_widget_definitions) do
		buff_widgets[i] = UIWidget.init(definition)
		unused_buff_widgets[i] = buff_widgets[i]
	end

	self._buff_widgets = buff_widgets
	self._unused_buff_widgets = unused_buff_widgets
	self._active_buffs = {}

	UIRenderer.clear_scenegraph_queue(self.ui_renderer)
	self:set_visible(true)
	self:set_dirty()

	local player = Managers.player:local_player(1)
	local player_unit = player.player_unit

	if player_unit then
		local career_extension = ScriptUnit.extension(player_unit, "career_system")
		local career_index = career_extension:career_index()
		self._current_career_index = career_index
	end
end

local sorted_buffs = {}
local widgets_to_remove = {}
local buffs_to_add = {}

PriorityBuffUI._sync_buffs = function (self)
	local debug_buffs = Development.parameter("debug_player_buffs")
	local t = Managers.time:time("game")
	local active_buffs = self._active_buffs
	local align_widgets = false
	local player = Managers.player:local_player(1)
	local player_unit = player.player_unit

	if player_unit then
		table.clear(buffs_to_add)

		local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
		local buffs = buff_extension:active_buffs()
		local num_buffs = #buffs

		for i = 1, #active_buffs, 1 do
			local data = active_buffs[i]
			data.widget.content.stack_count = 1
			data.verified = false
		end

		for i = 1, num_buffs, 1 do
			repeat
				local buff = buffs[i]
				local duration = buff.duration
				local start_time = buff.start_time
				local buff_template = buff.template
				if not buff_template then
					break
				end
				local handle_buff = debug_buffs or buff_template.icon ~= nil

				if handle_buff then
					local buff_name = buff_template.name
					local buff_id = buff.id
					local infinite = not duration
					local end_time = duration and start_time + duration
					local remaining_duration = end_time and math.max(end_time - t, 0)
					local verified = false

					for j = 1, #active_buffs, 1 do
						local data = active_buffs[j]

						if data.id == buff_id then
							if not end_time or end_time == data.end_time then
								data.verified = true
								verified = true
							end

							break
						end
					end

					if not verified and (infinite or remaining_duration > 0) then
						buffs_to_add[#buffs_to_add + 1] = buff_id
					end
				end
			until true
		end

		table.clear(widgets_to_remove)

		for i, data in ripairs(active_buffs) do
			if not data.verified then
				widgets_to_remove[#widgets_to_remove + 1] = i
			end
		end

		for i = 1, #widgets_to_remove, 1 do
			local index = widgets_to_remove[i]

			self:_remove_buff(index)

			align_widgets = true
		end

		for i, buff in ipairs(buffs) do
			local duration = buff.duration
			local start_time = buff.start_time
			local buff_template = buff.template
			if not buff_template then
					break
				end
			local handle_buff = debug_buffs or buff_template.icon ~= nil

			if handle_buff then
				for _, id in ipairs(buffs_to_add) do
					if id == buff.id then
						local infinite = not duration
						local end_time = duration and start_time + duration
						local added = self:_add_buff(buff, infinite, end_time)

						if added then
							align_widgets = true
						end
					end
				end
			end
		end

		if align_widgets then
			self:_align_widgets()
		end
	end
end

PriorityBuffUI._add_buff = function (self, buff, infinite, end_time)
	if not mod:get(mod.SETTING_NAMES.SECOND_BUFF_BAR) then
		return false
	end

	local is_priority_buff = false

	if mod.bm.is_priority_buff(buff.buff_type)
	then
		is_priority_buff = true
	end

	for setting_name, buff_names in pairs( mod.priority_buff_setting_name_to_buff_name ) do
		for _, buff_name in ipairs( buff_names ) do
			if buff_name == buff.buff_type then
				if mod:get(setting_name) then
					is_priority_buff = true
					break
				end
			end
		end
	end

	if not is_priority_buff then
		return false
	end

	local buff_template = buff.template
	local dormant = buff_template.dormant
	local buff_id = buff.id
	local buff_name = buff_template.name
	local is_cooldown = buff_template.is_cooldown
	local debuff = buff_template.debuff
	local duration = buff.duration
	local already_exists = false
	local active_buffs = self._active_buffs

	for j = 1, #active_buffs, 1 do
		local data = active_buffs[j]

		if data.id == buff_id then
			data.end_time = end_time
			already_exists = true

			break
		elseif data.name == buff_name then
			local stack_count = data.widget.content.stack_count
			data.end_time = end_time and ((data.end_time < end_time and end_time) or data.end_time)
			data.widget.content.stack_count = stack_count + 1
			already_exists = true

			break
		end
	end

	local unused_buff_widgets = self._unused_buff_widgets
	local num_buffs = #self._active_buffs

	if already_exists or MAX_NUMBER_OF_BUFFS <= num_buffs then
		return false
	end

	local widget = table.remove(unused_buff_widgets, 1)
	local widget_content = widget.content
	local widget_style = widget.style

	UIRenderer.set_element_visible(self.ui_renderer, widget.element, true)

	widget_content.texture_icon = buff_template.icon or "icons_placeholder"
	widget_content.is_cooldown = is_cooldown
	widget_content.is_infinite = infinite
	widget_style.texture_duration.color = (debuff and {
		255,
		255,
		30,
		0
	}) or {
		255,
		48,
		255,
		0
	}
	local data = {
		id = buff_id,
		template = buff_template,
		name = buff_name,
		widget = widget,
		end_time = end_time,
		duration = duration
	}
	local active_buffs = self._active_buffs
	active_buffs[#active_buffs + 1] = data

	self:_set_widget_time_progress(widget, 1, duration)

	num_buffs = #self._active_buffs
	local buff_size_x = BUFF_SIZE[1] + mod:get(mod.SETTING_NAMES.SECOND_BUFF_BAR_SIZE_ADJUST_X)
	local horizontal_spacing = buff_size_x + BUFF_SPACING
	local total_length = num_buffs * horizontal_spacing - BUFF_SPACING
	local start_position_x = total_length - horizontal_spacing
	local widget_offset = widget.offset

	if num_buffs > 1 then
		local closest_buff_data = active_buffs[num_buffs - 1]
		local closest_buff_widget = data.widget
		local closest_buff_offset = closest_buff_widget.offset
		local target_position = data.target_position
		local target_distance = data.target_distance
		widget_offset[1] = closest_buff_offset[1] + horizontal_spacing
		data.target_position = start_position_x
		data.target_distance = math.abs(widget_offset[1] - start_position_x)
	else
		widget_offset[1] = start_position_x
	end

	return true
end

PriorityBuffUI._remove_buff = function (self, index)
	for _, buff_data in ipairs( self._active_buffs ) do
		local buff_name = buff_data.name
		if buff_name
		and mod.buff_stacks[buff_name]
		then
			buff_data.widget.style.stack_count.horizontal_alignment = "center"
			buff_data.widget.style.stack_count_shadow.horizontal_alignment = "center"
			buff_data.widget.style.stack_count.offset[1] = 4
			buff_data.widget.style.stack_count.offset[2] = 5
			buff_data.widget.style.stack_count_shadow.offset[1] = 6
			buff_data.widget.style.stack_count_shadow.offset[2] = 3
			buff_data.widget.style.stack_count.text_color = mod.buff_stacks_styling[buff_name].stack_count_text_color
			buff_data.widget.style.texture_duration.color = mod.buff_stacks_styling[buff_name].texture_duration_color

			local rounded_stacks = mod.buff_stacks[buff_name] and math.round(mod.buff_stacks[buff_name]) or nil -- luacheck: ignore math
			if buff_data.widget.content.stack_count ~= rounded_stacks
			or buff_data.widget.content._last_stack_count ~= rounded_stacks then
				buff_data.stack_count = rounded_stacks
				buff_data.widget.content.stack_count = rounded_stacks
				buff_data.widget.content._last_stack_count = rounded_stacks

				self:_set_widget_dirty(buff_data.widget)
				self:set_dirty()
			end
		end
	end

	local active_buffs = self._active_buffs
	local data = table.remove(active_buffs, index)
	local widget = data.widget
	local unused_buff_widgets = self._unused_buff_widgets

	table.insert(unused_buff_widgets, #unused_buff_widgets + 1, widget)
	UIRenderer.set_element_visible(self.ui_renderer, widget.element, false)
end

PriorityBuffUI._update_pivot_alignment = function (self, dt)
	local alignment_duration = self._alignment_duration

	if not alignment_duration then
		return
	end

	alignment_duration = math.min(alignment_duration + dt, ALIGNMENT_DURATION_TIME)
	local progress = alignment_duration / ALIGNMENT_DURATION_TIME
	if mod:get(mod.SETTING_NAMES.PRIORITY_BUFFS_DISABLE_ALIGN_ANIMATION) then
		progress = 1
	end
	local anim_progress = math.easeOutCubic(progress, 0, 1)

	if progress == 1 then
		self._alignment_duration = nil
	else
		self._alignment_duration = alignment_duration
	end

	for _, data in ipairs(self._active_buffs) do
		local widget = data.widget
		local widget_offset = widget.offset
		local widget_target_position = data.target_position
		local widget_target_distance = data.target_distance

		if widget_target_distance then
			widget_offset[1] = widget_target_position + widget_target_distance * (1 - anim_progress)
		end

		self:_set_widget_dirty(widget)
	end

	self:set_dirty()
end

PriorityBuffUI._align_widgets = function (self)
	local gamepad_active = self.input_manager:is_device_active("gamepad")
	local buff_size_x = BUFF_SIZE[1] + mod:get(mod.SETTING_NAMES.SECOND_BUFF_BAR_SIZE_ADJUST_X)
	local horizontal_spacing = buff_size_x + BUFF_SPACING
	local num_buffs = #self._active_buffs
	local total_length = num_buffs * horizontal_spacing - BUFF_SPACING

	for index, data in ipairs(self._active_buffs) do
		local widget = data.widget
		local widget_offset = widget.offset
		local target_position = (index - 1) * horizontal_spacing - total_length/2
		data.target_position = target_position
		data.target_distance = math.abs(widget_offset[1] - target_position)

		self:_set_widget_dirty(widget)
	end

	self:set_dirty()

	self._alignment_duration = 0
end

PriorityBuffUI.set_position = function (self, x, y)
	local position = self.ui_scenegraph.pivot.local_position
	position[1] = x
	position[2] = y

	for _, widget in ipairs(self._active_buffs) do
		self:_set_widget_dirty(widget)
	end

	self:set_dirty()
end

PriorityBuffUI.destroy = function (self)
	self:set_visible(false)
end

PriorityBuffUI.set_visible = function (self, visible)
	self._is_visible = visible
	local ui_renderer = self.ui_renderer

	for _, widget in ipairs(self._buff_widgets) do
		UIRenderer.set_element_visible(ui_renderer, widget.element, visible)
	end

	self:set_dirty()
end

PriorityBuffUI.update = function (self, dt, t)
	if mod.need_to_refresh_priority_bar then
		mod.need_to_refresh_priority_bar = false
		self:_align_widgets()
		self:_on_resolution_modified()
	end

	for index, data in ipairs(self._active_buffs) do
		local widget = data.widget
		local widget_offset = widget.offset
		widget_offset[3] = 501
	end

	local dirty = false
	local gamepad_active = self.input_manager:is_device_active("gamepad")

	if gamepad_active then
		if not self.gamepad_active_last_frame then
			self.gamepad_active_last_frame = true

			self:on_gamepad_activated()

			dirty = true
		end
	elseif self.gamepad_active_last_frame then
		self.gamepad_active_last_frame = false

		self:on_gamepad_deactivated()

		dirty = true
	end

	if dirty then
		self:set_dirty()
	end

	self:_handle_career_change()
	self:_sync_buffs()
	self:_update_pivot_alignment(dt)
	self:_handle_resolution_modified()
	self:_update_buffs(dt)
	self:draw(dt)
end

PriorityBuffUI._handle_resolution_modified = function (self)
	if RESOLUTION_LOOKUP.modified then
		self:_on_resolution_modified()
	end
end

PriorityBuffUI._on_resolution_modified = function (self)
	for _, widget in ipairs(self._buff_widgets) do
		self:_set_widget_dirty(widget)
	end

	self:set_dirty()
end

PriorityBuffUI.draw = function (self, dt)
	for _, buff_data in ipairs( self._active_buffs ) do
		local buff_name = buff_data.name
		if buff_name
		and mod.buff_stacks[buff_name]
		then
			buff_data.widget.style.stack_count.horizontal_alignment = "center"
			buff_data.widget.style.stack_count_shadow.horizontal_alignment = "center"
			buff_data.widget.style.stack_count.offset[1] = 4
			buff_data.widget.style.stack_count.offset[2] = 5
			buff_data.widget.style.stack_count_shadow.offset[1] = 6
			buff_data.widget.style.stack_count_shadow.offset[2] = 3
			buff_data.widget.style.stack_count.text_color = mod.buff_stacks_styling[buff_name].stack_count_text_color
			buff_data.widget.style.texture_duration.color = mod.buff_stacks_styling[buff_name].texture_duration_color

			local rounded_stacks = mod.buff_stacks[buff_name] and math.round(mod.buff_stacks[buff_name]) or nil -- luacheck: ignore math
			if buff_data.widget.content.stack_count ~= rounded_stacks
			or buff_data.widget.content._last_stack_count ~= rounded_stacks then
				buff_data.stack_count = rounded_stacks
				buff_data.widget.content.stack_count = rounded_stacks
				buff_data.widget.content._last_stack_count = rounded_stacks

				self:_set_widget_dirty(buff_data.widget)
				self:set_dirty()
			end
		end
	end

	for _, data in ipairs(self._active_buffs) do
		local widget = data.widget

		if not widget.cloned then
			widget.cloned = pl.tablex.pairmap(function(k,v)
				local parent_temp = v.parent
				v.parent = nil
				local cloned = table.clone(v)
				v.parent = parent_temp
				return cloned,k end, widget.style)
		end

		for name, style in pairs( widget.style ) do
			if style.size then
				style.size[1] = widget.cloned[name].size[1] + mod:get(mod.SETTING_NAMES.SECOND_BUFF_BAR_SIZE_ADJUST_X)
				style.size[2] = widget.cloned[name].size[2] + mod:get(mod.SETTING_NAMES.SECOND_BUFF_BAR_SIZE_ADJUST_Y)
			end
		end

		widget.style.texture_icon_bg.color[1] = mod:get(mod.SETTING_NAMES.SECOND_BUFF_BAR_SIZE_ALPHA)
	end

	self.ui_scenegraph.buff_pivot.position[1] = mod:get(mod.SETTING_NAMES.SECOND_BUFF_BAR_OFFSET_X)
	self.ui_scenegraph.buff_pivot.position[2] = mod:get(mod.SETTING_NAMES.SECOND_BUFF_BAR_OFFSET_Y)

	if not self._is_visible then
		return
	end

	if not self._dirty then
		return
	end

	local ui_renderer = self.ui_renderer
	local ui_scenegraph = self.ui_scenegraph
	local input_service = self.input_manager:get_service("ingame_menu")

	UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, self.render_settings)

	for _, data in ipairs(self._active_buffs) do
		local widget = data.widget

		UIRenderer.draw_widget(ui_renderer, widget)
	end

	UIRenderer.end_pass(ui_renderer)

	self._dirty = false
end

PriorityBuffUI._update_buffs = function (self, dt)
	local dirty = false
	local t = Managers.time:time("game")

	for index, data in ipairs(self._active_buffs) do
		local widget = data.widget
		local end_time = data.end_time
		local stack_count = data.stack_count

		if end_time then
			local duration = data.duration
			local infinite = widget.content.is_infinite
			local is_cooldown = widget.content.is_cooldown

			if not infinite then
				if t < end_time then
					local time_left = math.max(end_time - t, 0)
					local progress = 1 - math.min(time_left / duration, 1)

					self:_set_widget_time_progress(widget, progress, time_left)
				end

				dirty = true
			end
		end

		if widget.content.stack_count > 1 and not widget.element.dirty then
			self:_set_widget_dirty(widget)

			dirty = true
		end
	end

	if dirty then
		self:set_dirty()
	end
end

PriorityBuffUI._handle_career_change = function (self)
	local player = Managers.player:local_player(1)
	local player_unit = player.player_unit

	if player_unit then
		local career_extension = ScriptUnit.extension(player_unit, "career_system")
		local career_index = career_extension:career_index()

		if career_index ~= self._current_career_index then
			while #self._active_buffs > 0 do
				self:_remove_buff(1)
			end

			self._current_career_index = career_index

			self:set_dirty()
		end
	end
end

local floor = math.floor
local ceil = math.ceil

PriorityBuffUI._set_widget_time_progress = function (self, widget, progress, time_left)
	local content = widget.content
	content.progress = progress

	if time_left and time_left > 0 then
		content.set_unsaturated = true
		content.is_expired = false
	else
		content.is_expired = true
		content.set_unsaturated = false
	end

	self:_set_widget_dirty(widget)
end

PriorityBuffUI.set_dirty = function (self)
	self._dirty = true
end

PriorityBuffUI._set_widget_dirty = function (self, widget)
	widget.element.dirty = true
end

PriorityBuffUI.on_gamepad_activated = function (self)
	self:_align_widgets()
end

PriorityBuffUI.on_gamepad_deactivated = function (self)
	self:_align_widgets()
end

PriorityBuffUI.set_panel_alpha = function (self, alpha)
	if self.render_settings.alpha_multiplier ~= alpha then
		self.render_settings.alpha_multiplier = alpha

		self:set_dirty()

		for index, data in ipairs(self._active_buffs) do
			local widget = data.widget

			self:_set_widget_dirty(widget)
		end
	end
end

return
