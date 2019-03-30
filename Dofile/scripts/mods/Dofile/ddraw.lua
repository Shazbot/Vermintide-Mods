-- luacheck: globals get_mod IngameUI Keyboard Color World EndScreenUI
-- luacheck: globals RESOLUTION_LOOKUP Gui Vector3 LevelEndView
-- luacheck: globals Dbg ddraw ddump dkeys
local mod = get_mod("Dofile")

local pl = require'pl.import_into'()
local stringx = require'pl.stringx'

-- please don't create global objects in normal mods, very bad practice
Dbg = Dbg or {}
Dbg.text = Dbg.text or ""
Dbg.current_table = nil

mod.clear_time = 30

pl.pretty = mod:dofile("scripts/mods/"..mod:get_name().."/pretty")

ddraw = function(table)
	if Dbg.current_table and Dbg.current_table == table then
		return
	end

	Dbg.current_table = table

	Dbg.text = pl.pretty.write(table, nil, nil, 4)
end

ddump = function(table, filename)
	if not filename then
		filename = tostring(table)
	end
	pl.pretty.dump(table, filename, 4)
end

dkeys = function(table)
	return pl.Map(table):keys()
end

mod.lines = pl.List()

local font_size = 20
local font = "gw_arial_16"
local font_mtrl = "materials/fonts/" .. font

mod.draw_debug_text = function(self, existing_gui)
	if
	not self.world
	and not self._world
	and not self.world_manager
	and not self.world_manager:world("level_world") then
		return
	end

	local world = self.world or self._world or self.world_manager:world("level_world")

	local gui = existing_gui
	if not gui then
		if not self._mod_gui then
			self._mod_gui = World.create_screen_gui(world, "material", "materials/fonts/gw_fonts", "immediate")
		end
		gui = self._mod_gui
	end
	local header_color = Color(250, 0, 255, 0)
	local start_x = RESOLUTION_LOOKUP.res_w - 550 - 550
	local spacing_y = 22

	local start_y = RESOLUTION_LOOKUP.res_h-20
	local i = 0
	mod:pcall(function()
		local lines = mod.lines
		local num_lines = #lines
		if num_lines < 91 then
			start_x = start_x + 300
		end

		lines:foreach(function(line)
			local pos = Vector3(start_x, start_y-spacing_y*i, 101)
			Gui.text(gui, line, font_mtrl, font_size, font, pos, header_color)
			i = i + 1
			if i > 45 then
				start_x = start_x + 375
				i = 0
			end
			if i > 90 then
				start_x = start_x + 725
				i = 0
			end
		end)
	end)
end

mod:hook_safe(LevelEndView, "update", function(self)
	mod.draw_debug_text(self)
end)

mod.destroy_gui = function(func, self, ...)
	if self._mod_gui then
		local world = self.world or self._world or self.world_manager:world("level_world")
		World.destroy_gui(world, self._mod_gui)
		self._mod_gui = nil
	end

	return func(self, ...)
end

local objects_to_hook_destroy = { LevelEndView, IngameUI }

for _, obj in ipairs( objects_to_hook_destroy ) do
	mod:hook(obj, "destroy", mod.destroy_gui)
end
mod:hook(StateLoading, "on_exit", mod.destroy_gui)

mod:hook_safe(IngameUI, "update", function(self, dt, t) -- luacheck: ignore dt
	if Dbg.text ~= mod.dbg_text_lf then
		mod.dbg_text_lf = Dbg.text
		mod.clear_text_t = t + mod.clear_time
		mod.lines = stringx.splitlines(Dbg.text):slice(0, 135)
	end
	if mod.clear_text_t and mod.clear_text_t < t then
		Dbg.text = ""
		mod.clear_text_t = nil
	end

	mod.draw_debug_text(self, self.ui_renderer.gui)
end)

mod.clear_ddraw = function()
	ddraw()
end

mod:command("dd", "Clear ddraw.", mod.clear_ddraw)
