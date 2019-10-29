local mod = get_mod("CrosshairCustomization")

local pl = require'pl.import_into'()
local tablex = require'pl.tablex'

mod.on_setting_changed = function()
	mod.do_refresh = true
	mod.set_hit_marker_duration()
end

mod.set_hit_marker_duration = function()
	UISettings.crosshair.hit_marker_fade = mod:get(mod.SETTING_NAMES.HIT_MARKERS_DURATION)
end

mod.get_color = function()
	local color_index = mod:get(mod.SETTING_NAMES.COLOR) or mod.COLOR_INDEX.DEFAULT
	local color = mod.COLORS[color_index] or {
		255,
		mod:get(mod.SETTING_NAMES.CUSTOM_RED),
		mod:get(mod.SETTING_NAMES.CUSTOM_GREEN),
		mod:get(mod.SETTING_NAMES.CUSTOM_BLUE)
	}
	return color
end

local widget_names = pl.List{
	"crosshair_projectile",
	"crosshair_shotgun",
	"crosshair_dot",
	"crosshair_line",
	"crosshair_arrow",
	"crosshair_circle",
}
mod.change_crosshair_size = function(crosshair_ui)
	local scale_by = mod:get(mod.SETTING_NAMES.ENLARGE) / 100

	if crosshair_ui.crosshair_style == "circle" then
		scale_by = 1
	end

	widget_names:foreach(function(widget_name)
		local widget = crosshair_ui.ui_scenegraph[widget_name]
		if widget then
			if not widget.size_backup then
				widget.size_backup = table.clone(widget.size)
			end
			widget.size = tablex.map("*", widget.size_backup, scale_by)

			if not widget.local_position_backup then
				widget.local_position_backup = table.clone(widget.local_position)
			end
			widget.local_position = tablex.map("*", widget.local_position_backup, scale_by)

			crosshair_ui[widget_name].style.pivot = tablex.map("/", widget.size, 2)
		end
	end)
end

--- Change crosshair color, run before every of the crosshair_ui draw functions.
mod.change_crosshair_color = function(crosshair_ui)
	local color = mod.get_color()

	crosshair_ui.crosshair_projectile.style.color = color
	crosshair_ui.crosshair_shotgun.style.color = color
	crosshair_ui.crosshair_dot.style.color = color
	crosshair_ui.crosshair_line.style.color = color
	crosshair_ui.crosshair_arrow.style.color = color
	crosshair_ui.crosshair_circle.style.color = color

	if not crosshair_ui.hit_marker_animations[1] then
		for _,hit_marker in ipairs(crosshair_ui.hit_markers) do
		  hit_marker.style.rotating_texture.color = table.clone(color)
		  hit_marker.style.rotating_texture.color[1] = 0
		end
	end
end

--- Change color of hit markers.
mod:hook_safe(CrosshairUI, "configure_hit_marker_color_and_size", function (self, hit_marker, hit_marker_data) -- luacheck: ignore self
	local damage_amount = hit_marker_data.damage_amount
	local hit_critical = hit_marker_data.hit_critical
	local has_armor = hit_marker_data.has_armor
	local friendly_fire = hit_marker_data.friendly_fire
	local added_dot = hit_marker_data.added_dot
	local is_critical = false
	local is_armored = false

	if damage_amount <= 0 and has_armor and not added_dot then
		is_armored = true
	elseif hit_critical then
		is_critical = true
	end

	local hm_rot_texture = hit_marker.style.rotating_texture
	local hm_color = hm_rot_texture.color

	if not is_armored and not friendly_fire and not is_critical then
		if mod:get(mod.SETTING_NAMES.HIT_MARKERS_COLOR_GROUP) then
			hm_color[2] = mod:get(mod.SETTING_NAMES.HIT_MARKERS_RED)
			hm_color[3] = mod:get(mod.SETTING_NAMES.HIT_MARKERS_GREEN)
			hm_color[4] = mod:get(mod.SETTING_NAMES.HIT_MARKERS_BLUE)
		else
			local color = mod.get_color()
			hm_color[2] = color[2]
			hm_color[3] = color[3]
			hm_color[4] = color[4]
		end

		hm_color[1] = 0
	end

	-- change the headshot hit marker color
	if is_armored then
		if mod:get(mod.SETTING_NAMES.HIT_MARKERS_ARMORED_COLOR_GROUP) then
			hm_color[2] = mod:get(mod.SETTING_NAMES.HIT_MARKERS_ARMORED_RED)
			hm_color[3] = mod:get(mod.SETTING_NAMES.HIT_MARKERS_ARMORED_GREEN)
			hm_color[4] = mod:get(mod.SETTING_NAMES.HIT_MARKERS_ARMORED_BLUE)
		end
	elseif friendly_fire then
		if mod:get(mod.SETTING_NAMES.HIT_MARKERS_FF_COLOR_GROUP) then
			hm_color[2] = mod:get(mod.SETTING_NAMES.HIT_MARKERS_FF_RED)
			hm_color[3] = mod:get(mod.SETTING_NAMES.HIT_MARKERS_FF_GREEN)
			hm_color[4] = mod:get(mod.SETTING_NAMES.HIT_MARKERS_FF_BLUE)
		end
	elseif is_critical
	and hit_marker_data._mod_is_crit_proc
	and mod:get(mod.SETTING_NAMES.HIT_MARKERS_HS_AND_CRIT_COLOR_GROUP) then
		hm_color[2] = mod:get(mod.SETTING_NAMES.HIT_MARKERS_HS_AND_CRIT_RED)
		hm_color[3] = mod:get(mod.SETTING_NAMES.HIT_MARKERS_HS_AND_CRIT_GREEN)
		hm_color[4] = mod:get(mod.SETTING_NAMES.HIT_MARKERS_HS_AND_CRIT_BLUE)
	elseif is_critical
	and mod:get(mod.SETTING_NAMES.HIT_MARKERS_CRITICAL_COLOR_GROUP) then
		hm_color[2] = mod:get(mod.SETTING_NAMES.HIT_MARKERS_CRITICAL_RED)
		hm_color[3] = mod:get(mod.SETTING_NAMES.HIT_MARKERS_CRITICAL_GREEN)
		hm_color[4] = mod:get(mod.SETTING_NAMES.HIT_MARKERS_CRITICAL_BLUE)
	elseif hit_marker_data._mod_is_crit_proc
	and mod:get(mod.SETTING_NAMES.HIT_MARKERS_CRITICAL_PROC_COLOR_GROUP) then
		hm_color[2] = mod:get(mod.SETTING_NAMES.HIT_MARKERS_CRITICAL_PROC_RED)
		hm_color[3] = mod:get(mod.SETTING_NAMES.HIT_MARKERS_CRITICAL_PROC_GREEN)
		hm_color[4] = mod:get(mod.SETTING_NAMES.HIT_MARKERS_CRITICAL_PROC_BLUE)
	end

	-- change hit marker size
	local hit_marker_width = mod:get(mod.SETTING_NAMES.HIT_MARKERS_SIZE)
	hm_rot_texture.size = {
		hit_marker_width,
		4
	}
	if not hm_rot_texture.original_offset then
		hm_rot_texture.original_offset = table.clone(hm_rot_texture.offset)
	end
	hm_rot_texture.offset[1] = hm_rot_texture.original_offset[1]
	hm_rot_texture.offset[2] = hm_rot_texture.original_offset[2]
	if hm_rot_texture.offset[1] == -6 then
		hm_rot_texture.offset[1] = -hit_marker_width + 4
	end
	if hm_rot_texture.offset[2] == 6 then
		hm_rot_texture.offset[2] = hit_marker_width - 4
	end
end)

local do_once = false -- DEBUG
--- Show the hit markers for debugging.
mod.simulate_hit = function(crosshair_ui)
	if not do_once then
		local player_unit = crosshair_ui.local_player.player_unit
		local hud_extension = ScriptUnit.extension(player_unit, "hud_system")
		local hit_marker_data = hud_extension.hit_marker_data
		hit_marker_data.hit_enemy = true
		hit_marker_data.damage_amount = 8
		do_once = true
	end
end

mod.draw_crosshair_prehook = function(crosshair_ui, need_to_refresh)
	if need_to_refresh
	or mod.do_refresh
	or crosshair_ui._mod_last_crosshair_style ~= crosshair_ui.crosshair_style
	then
		crosshair_ui._mod_last_crosshair_style = crosshair_ui.crosshair_style
		mod.do_refresh = false
		mod.change_crosshair_size(crosshair_ui)
		mod.change_crosshair_color(crosshair_ui)
	end
	-- mod.simulate_hit(crosshair_ui)
end

mod:hook(CrosshairUI, "draw_circle_style_crosshair", function(func, self, ...)
	-- skip a single draw frame when changing crosshair style
	-- or we're off center for a single frame when enlarged
	if self._mod_last_crosshair_style ~= self.crosshair_style then
		self._mod_last_crosshair_style = self.crosshair_style
		mod.draw_crosshair_prehook(self, true)
		return
	end
	mod.draw_crosshair_prehook(self)
	return func(self, ...)
end)

--- No crosshair at all with a melee weapon.
mod:hook(CrosshairUI, "draw_dot_style_crosshair", function(func, self, ...)
	if self._mod_last_crosshair_style == "circle" then
		self._mod_last_crosshair_style = self.crosshair_style
		mod.draw_crosshair_prehook(self, true)
		return
	end
	mod.draw_crosshair_prehook(self)

	if mod:get(mod.SETTING_NAMES.FORCE_MELEE_CROSSHAIR_GROUP)
	and self.crosshair_style
	and self.crosshair_style == "dot"
	then
		local pitch_percentage = mod:get(mod.SETTING_NAMES.MELEE_CROSSHAIR_PITCH) / 100
		local yaw_percentage = mod:get(mod.SETTING_NAMES.MELEE_CROSSHAIR_YAW) / 100

		local num_points = 4
		local start_degrees = 45
		local pitch_offset = 5
		local yaw_offset = 5
		pitch_percentage = math.max(0.0001, pitch_percentage)
		yaw_percentage = math.max(0.0001, yaw_percentage)

		if not mod:get(mod.SETTING_NAMES.FORCE_MELEE_CROSSHAIR_NO_DOT) then
			UIRenderer.draw_widget(self.ui_renderer, self.crosshair_dot)
		end

		local only_lower_markers = mod:get(mod.SETTING_NAMES.ONLY_LOWER_MARKERS)
		for i = 1, num_points, 1 do
			if not only_lower_markers
			or (only_lower_markers and i ~= 3 and i ~= 4)
			then
				self:_set_widget_point_offset(self.crosshair_line, i, num_points, pitch_percentage, yaw_percentage, start_degrees, pitch_offset, yaw_offset)
				UIRenderer.draw_widget(self.ui_renderer, self.crosshair_line)
			end
		end

		return
	end

	if mod:get(mod.SETTING_NAMES.NO_MELEE_DOT)
	and self.crosshair_style
	and self.crosshair_style == "dot" then
		return
	end

    return func(self, ...)
end)

mod.generic_ranged_hook = function(func, self, ...)
	mod.draw_crosshair_prehook(self)

	if mod:get(mod.SETTING_NAMES.DOT) then
		return self:draw_dot_style_crosshair(...)
	end

	local crosshair_dot_visible_temp = self.crosshair_dot.content.visible
	if mod:get(mod.SETTING_NAMES.NO_RANGED_DOT) then
		self.crosshair_dot.content.visible = false
	end

    func(self, ...)

    self.crosshair_dot.content.visible = crosshair_dot_visible_temp
end

--- Hide lines, keep dot.
mod:hook(CrosshairUI, "draw_default_style_crosshair", mod.generic_ranged_hook)
mod:hook(CrosshairUI, "draw_shotgun_style_crosshair", mod.generic_ranged_hook)
mod:hook(CrosshairUI, "draw_arrows_style_crosshair", mod.generic_ranged_hook)

--- Hide projectile markers.
mod:hook(CrosshairUI, "draw_projectile_style_crosshair", function (func, self, ui_renderer, pitch_percentage, yaw_percentage)
	if mod:get(mod.SETTING_NAMES.DOT) then
		return self:draw_dot_style_crosshair(ui_renderer, pitch_percentage, yaw_percentage)
	end

	local crosshair_projectile_visible_temp = self.crosshair_projectile.content.visible
	if mod:get(mod.SETTING_NAMES.NO_RANGE_MARKERS) then
		self.crosshair_projectile.content.visible = false
	end
	local crosshair_line_visible_temp = self.crosshair_line.content.visible
	if mod:get(mod.SETTING_NAMES.NO_LINE_MARKERS) then
		self.crosshair_line.content.visible = false
	end
	local crosshair_dot_visible_temp = self.crosshair_dot.content.visible
	if mod:get(mod.SETTING_NAMES.NO_RANGED_DOT) then
		self.crosshair_dot.content.visible = false
	end

	mod.draw_crosshair_prehook(self)
	func(self, ui_renderer, pitch_percentage, yaw_percentage)

	self.crosshair_dot.content.visible = crosshair_dot_visible_temp
	self.crosshair_line.content.visible = crosshair_line_visible_temp
	self.crosshair_projectile.content.visible = crosshair_projectile_visible_temp
end)

--- Disable hit markers.
mod:hook(CrosshairUI, "set_hit_marker_animation", function(func, self, hit_markers, hit_markers_n, hit_marker_animations, hit_marker_data)
	if self.crosshair_style then
		if mod:get(mod.SETTING_NAMES.NO_MELEE_HIT_MARKERS)
		and self.crosshair_style == "dot" then
			return
		end
		if mod:get(mod.SETTING_NAMES.NO_RANGED_HIT_MARKERS)
		and self.crosshair_style ~= "dot" then
			return
		end
	end

	func(self, hit_markers, hit_markers_n, hit_marker_animations, hit_marker_data)

	-- change hit marker transparency, need to edit the animation table
	for _, hit_marker_anim in ipairs( hit_marker_animations ) do
		hit_marker_anim.data_array[4] = mod:get(mod.SETTING_NAMES.HIT_MARKERS_ALPHA)
	end
end)

--- Hook to catch crits.
mod:hook_safe(DamageUtils, "buff_on_attack", function(unit, hit_unit, attack_type, is_critical) -- luacheck: no unused
	local hud_extension = ScriptUnit.has_extension(unit, "hud_system")
	if is_critical and hud_extension then
		local hit_marker_data = hud_extension.hit_marker_data
		hit_marker_data._mod_is_crit_proc = true
	end
end)

--- Reset hit_marker_data crit proc flag back to false.
--- Option to show FF hit markers based on damage dealt.
mod:hook(CrosshairUI, "update_hit_markers", function(func, self, ...)
	local player_unit = self.local_player.player_unit
	local hud_extension = ScriptUnit.extension(player_unit, "hud_system")
	local hit_marker_data = hud_extension.hit_marker_data

	if hit_marker_data.hit_enemy then
		local damage_amount = hit_marker_data.damage_amount
		local friendly_fire = hit_marker_data.friendly_fire
		if friendly_fire
		and damage_amount < mod:get(mod.SETTING_NAMES.IGNORE_FF_TRESHOLD) then
			hit_marker_data.hit_enemy = false
		end
	end

	func(self, ...)

	hit_marker_data._mod_is_crit_proc = false
end)

--- Actions ---
--- Dot only on_toggle.
mod.dot_toggle = function()
	local current_dot_only = mod:get(mod.SETTING_NAMES.DOT)
	mod:set(mod.SETTING_NAMES.DOT, not current_dot_only, true)
end

mod.set_hit_marker_duration()
