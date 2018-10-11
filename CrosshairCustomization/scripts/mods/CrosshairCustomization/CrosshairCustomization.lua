-- luacheck: globals get_mod UIRenderer table ScriptUnit CrosshairUI

local mod = get_mod("CrosshairCustomization")

local pl = require'pl.import_into'()
local tablex = require'pl.tablex'

mod.on_setting_changed = function()
	mod.do_refresh = true
end

mod.get_color = function()
	local color_index = mod:get(mod.SETTING_NAMES.COLOR) or mod.COLOR_INDEX.DEFAULT
	local color = mod.COLORS[color_index] or { 255, mod:get(mod.SETTING_NAMES.CUSTOM_RED), mod:get(mod.SETTING_NAMES.CUSTOM_GREEN), mod:get(mod.SETTING_NAMES.CUSTOM_BLUE) }
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
	local hit_player = hit_marker_data.hit_player
	local added_dot = hit_marker_data.added_dot
	local is_critical = false
	local is_armored = false
	local friendly_fire = false

	if damage_amount <= 0 and has_armor and not added_dot then
		is_armored = true
	elseif hit_player then
		friendly_fire = true
	elseif hit_critical then
		is_critical = true
	end

	if not is_armored and not friendly_fire and not is_critical then
		local color = mod.get_color()

		hit_marker.style.rotating_texture.color = table.clone(color)
		hit_marker.style.rotating_texture.color[1] = 0
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
	return func(self, hit_markers, hit_markers_n, hit_marker_animations, hit_marker_data)
end)

--- Actions ---
--- Dot only on_toggle.
mod.dot_toggle = function()
	local current_dot_only = mod:get(mod.SETTING_NAMES.DOT)
	mod:set(mod.SETTING_NAMES.DOT, not current_dot_only, true)
end
