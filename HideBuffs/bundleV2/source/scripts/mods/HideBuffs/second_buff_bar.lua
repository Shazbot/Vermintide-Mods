local mod = get_mod("HideBuffs") -- luacheck: ignore get_mod

-- luacheck: globals BuffUI UISceneGraph UIRenderer local_require table math

mod:hook(BuffUI, "init", function(func, self, ingame_ui_context)
	mod.ingame_ui_context = ingame_ui_context
	if mod.skip_hooking then
		mod:hook(self, "_create_ui_elements", function(...) mod.BuffUI_create_ui_elements(...) end)
	end

	func(self, ingame_ui_context)

	if mod.skip_hooking then -- inside dublicate BuffUI
		self.set_visible = function(...) return mod.BuffUI_set_visible(...) end
		self.destroy = function(...) return mod.BuffUI_destroy(...) end
		self.update = function(...) return mod.BuffUI_update(...) end
		self.draw = function(...)return  mod.BuffUI_draw(...) end
		self._update_pivot_alignment = function(...) return mod.BuffUI_update_pivot_alignment(...) end
		self._align_widgets = function(...) return mod.BuffUI_align_widgets(...) end
		return
	end

	if not mod.hooked_main then
		mod.hooked_main = true
		mod:hook(self, "set_visible", function(...) mod.BuffUI_main_set_visible(...) end)
		mod:hook(self, "destroy", function(...) mod.BuffUI_main_destroy(...) end)
	end
end)

mod.BuffUI_main_set_visible = function(func, self, visible)
	if mod.buff_ui then
		mod.buff_ui:set_visible(visible)
	end
	return func(self, visible)
end

mod.BuffUI_main_destroy = function(func, self)
	if mod.buff_ui then
		mod.buff_ui:destroy()
		mod.buff_ui = nil
	end
	return func(self)
end

mod:hook(BuffUI, "update", function(func, self, dt, t)
	func(self, dt, t)

	if mod.buff_ui
	and mod:get(mod.SETTING_NAMES.SECOND_BUFF_BAR)
	then
		mod.buff_ui:update(dt, t)
	end

	if self == mod.buff_ui then
		return
	end

	if not mod.buff_ui and mod.ingame_ui_context then
		local buff_ui_temp = rawget(_G, "buff_ui")

		mod.skip_hooking = true
		mod.buff_ui = BuffUI:new(mod.ingame_ui_context)
		mod.skip_hooking = false

		rawset(_G, "buff_ui", buff_ui_temp)
	end
end)

mod.BuffUI_create_ui_elements = function(func, self)
	local init_scenegraph_temp = UISceneGraph.init_scenegraph
	UISceneGraph.init_scenegraph = function(scenegraph_definition)
		scenegraph_definition = table.clone(scenegraph_definition)
		scenegraph_definition.pivot = {
			vertical_alignment = "top",
			parent = "root",
			horizontal_alignment = "center",
			position = {
				0,
				-150,
				1
			},
			size = {
				0,
				0
			}
		}
		return init_scenegraph_temp(scenegraph_definition)
	end
	func(self)
	UISceneGraph.init_scenegraph = init_scenegraph_temp
end

mod.BuffUI_set_visible = function(self, visible)
	self._is_visible = visible
	local ui_renderer = self.ui_renderer

	for _, widget in ipairs(self._buff_widgets) do
		UIRenderer.set_element_visible(ui_renderer, widget.element, visible)
	end

	self:set_dirty()
end

mod.BuffUI_draw = function (self, dt)
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

		-- widget.style.texture_icon_bg.color[1] = 175

		UIRenderer.draw_widget(ui_renderer, widget)
	end

	UIRenderer.end_pass(ui_renderer)

	self._dirty = false
end

mod.BuffUI_destroy = function(self)
	self:set_visible(false)
end

mod.BuffUI_update = function (self, dt, t)
	self.ui_scenegraph.buff_pivot.position[1] = mod:get(mod.SETTING_NAMES.SECOND_BUFF_BAR_OFFSET_X)
	self.ui_scenegraph.buff_pivot.position[2] = mod:get(mod.SETTING_NAMES.SECOND_BUFF_BAR_OFFSET_Y)

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

local definitions = local_require("scripts/ui/hud_ui/buff_ui_definitions")
local ALIGNMENT_DURATION_TIME = 0.3
local BUFF_SIZE = definitions.BUFF_SIZE
local BUFF_SPACING = definitions.BUFF_SPACING
mod.BuffUI_align_widgets = function (self)
	local horizontal_spacing = BUFF_SIZE[1] + BUFF_SPACING
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

mod.BuffUI_update_pivot_alignment = function (self, dt)
	local alignment_duration = self._alignment_duration

	if not alignment_duration then
		return
	end

	alignment_duration = math.min(alignment_duration + dt, ALIGNMENT_DURATION_TIME)
	local progress = alignment_duration / ALIGNMENT_DURATION_TIME
	if mod:get(mod.SETTING_NAMES.BUFFS_DISABLE_ALIGN_ANIMATION) then
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