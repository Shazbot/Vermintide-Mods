local mod = get_mod("StreamingInfo")

local pl = require'pl.import_into'()

fassert(pl, "Info Dump For Streaming requires Penlight Lua Libraries!")

mod.persistent = mod:persistent_table("persistent")
mod.persistent.temp_external_lines = mod.persistent.temp_external_lines or {}
mod.persistent.perm_external_lines = mod.persistent.perm_external_lines or {}
mod.temp_external_lines = mod.persistent.temp_external_lines
mod.perm_external_lines = mod.persistent.perm_external_lines

mod.streaming_data = {}

mod.out_lines_setting_key = "out_lines"
mod.perm_lines_setting_key = "perm_lines"
mod.perm_lines = pl.List()
mod.out_lines = pl.List()

mod.append_traits = function(out, slot)
	local traits = slot.traits
	if traits then
		for _,trait_name in ipairs(traits) do
			local trait = WeaponTraits.traits[trait_name] or WeaveTraits.traits[trait_name]
			if trait then
				local localized_trait_name = Localize(trait.display_name)
				out:write(localized_trait_name)
				out:write(", ")
			end
		end
	end
	local properties = slot.properties
	if properties then
		local properties_size = pl.tablex.size(properties)
		local property_index = 0
		for prop_name, prop_value in pairs( properties ) do
			property_index = property_index + 1
			local prop_description_original = UIUtils.get_property_description(prop_name, prop_value)
			local _, _, prop_description = pl.stringx.partition(prop_description_original, " ")
			prop_description = pl.stringx.replace(prop_description, "Power vs ", "Pv")
			out:write(pl.stringx.strip(prop_description))
			if property_index ~= properties_size then
				out:write(", ")
			end
		end
	end
end

mod.talents_cached = ""

mod.get_talents = function()
	local local_player_unit =
	Managers.player
	and Managers.player:local_player()
	and Managers.player:local_player().player_unit

	if local_player_unit then
		local career_extension = ScriptUnit.extension(local_player_unit, "career_system")
		if career_extension and career_extension:career_name() then
			local talent_interface = Managers.backend:get_interface("talents")
			local career_name = career_extension:career_name()
			local current_talents = talent_interface:get_talents(career_name)

			local talents = pl.List(current_talents):join(" ")
			mod.talents_cached = talents
			return talents
		end
	end

	return mod.talents_cached
end

mod.get_streaming_info = function()
	local out = pl.stringio.create()
	mod:pcall(function()
		if mod.streaming_data.slot_melee then
			mod.append_traits(out, mod.streaming_data.slot_melee)
			out:write("\n")
		end
		if mod.streaming_data.slot_ranged then
			mod.append_traits(out, mod.streaming_data.slot_ranged)
			out:write("\n")
		end
		if mod.streaming_data.slot_necklace then
			mod.append_traits(out, mod.streaming_data.slot_necklace)
			out:write("\n")
		end
		if mod.streaming_data.slot_ring then
			mod.append_traits(out, mod.streaming_data.slot_ring)
			out:write("\n")
		end
		if mod.streaming_data.slot_trinket_1 then
			mod.append_traits(out, mod.streaming_data.slot_trinket_1)
			out:write("\n")
		end

		local talents = mod.get_talents()
		if talents and talents ~= "" then
			out:write("Talents: ")
			out:write(talents)
			out:write("\n")
		end

		if mod.streaming_data.difficulty then
			out:write(mod.streaming_data.difficulty)
			out:write("\n")
		end
	end)
	return out:value()
end

-- CHECK
-- DifficultyManager.set_difficulty = function (self, difficulty)
mod:hook(DifficultyManager, "set_difficulty", function (func, self, difficulty)
	local current_difficulty = Localize(DifficultySettings[difficulty].display_name)
	if mod.streaming_data.difficulty ~= current_difficulty then
		mod.streaming_data.difficulty = current_difficulty
	end

	return func(self, difficulty)
end)


-- CHECK
-- BackendUtils.get_loadout_item = function (career_name, slot)
mod:hook(BackendUtils, "get_loadout_item", function (func, career_name, slot)
	local item_data = func(career_name, slot)

	mod.streaming_data[slot] = item_data

	return item_data
end)

mod.font = "materials/fonts/arial"
mod.font_name = "arial"

mod:hook_safe(StateLoading, "update", function(self)
	mod.draw_temp_info(self)
end)

mod:hook_safe(LevelEndView, "update", function(self)
	mod.draw_temp_info(self)
end)

mod:hook_safe(EndScreenUI, "draw", function(self)
	mod.draw_temp_info(self)
end)

mod:hook_safe(GameModeManager, "server_update", function(self)
	if not self._game_mode then
		return
	end

	if self._game_mode.lost_condition_timer or self._game_mode.level_complete_timer then
		mod.draw_temp_info(self)
	end
end)

mod:hook_safe(IngameUI, "update", function(self, dt, t, disable_ingame_ui, end_of_level_ui) -- luacheck: no unused
	local level_transition_handler = Managers.state.game_mode.level_transition_handler
	local level_key = level_transition_handler:get_current_level_keys()
	local is_in_inn = level_key == "inn_level"

	local in_score_screen = end_of_level_ui ~= nil
	local end_screen_active = self:end_screen_active()

	local game_mode_manager = Managers.state.game_mode
	local round_started = game_mode_manager:is_round_started()

	mod.draw_perm_info(self)

	if not (is_in_inn or in_score_screen or end_screen_active) then
		if round_started then
			return
		end
	end

	mod.draw_temp_info(self)
end)

mod.text_size = function (gui, text, font_size)
	local min, max = Gui.text_extents(gui, text, mod.font, font_size)
	local inv_scaling = RESOLUTION_LOOKUP.inv_scale
	local width = (max.x + min.x) * inv_scaling
	local height = (max.y - min.y) * inv_scaling

	return width, height, min
end

mod.get_text_size = function (gui, font_size, line)
	local _, font_min, font_max = UIGetFontHeight(gui, mod.font_name, font_size)
	local inv_scale = RESOLUTION_LOOKUP.inv_scale
	local full_font_height = (font_max + math.abs(font_min)) * inv_scale
	local width = mod.text_size(gui, line, font_size)

	return width, full_font_height
end

mod.draw_line = function(gui, font_size, line, layer, start_x, start_y, longest, height, vertical_spacing, header_color)
	local line_width, line_height = mod.get_text_size(gui, font_size, line)
	if line_width > longest then
		longest = line_width
	end
	height = height + line_height
	local pos = Vector3(start_x, start_y-height, layer)
	height = height + vertical_spacing
	Gui.text(gui, line, mod.font, font_size, mod.font, pos, header_color)

	return longest, height
end

mod.draw_perm_info = function(owner)
	local self = owner

	if not (self.world or self._world or (self.world_manager and self.world_manager:world("level_world"))) then
		return
	end

	local world = self.world or self._world or self.world_manager:world("level_world")

	local gui = self.gui or self._mod_gui
	if not gui then
		self._mod_gui = World.create_screen_gui(world, "material", "materials/fonts/gw_fonts", "immediate")
		gui = self._mod_gui
	end

	local header_color = Color(
		255,
		mod:get(mod.SETTING_NAMES.PERM_RED),
		mod:get(mod.SETTING_NAMES.PERM_GREEN),
		mod:get(mod.SETTING_NAMES.PERM_BLUE)
	)
	local bg_alpha = mod:get(mod.SETTING_NAMES.PERM_BG_OPACITY)

	local font_size = mod:get(mod.SETTING_NAMES.PERM_FONT_SIZE)
	local vertical_spacing = mod:get(mod.SETTING_NAMES.PERM_LINE_SPACING)

	local start_x = mod:get(mod.SETTING_NAMES.PERM_OFFSET_X)
	local start_y = RESOLUTION_LOOKUP.res_h + mod:get(mod.SETTING_NAMES.PERM_OFFSET_Y)

	mod:pcall(function()
			local longest = 0
			local height = 0
			mod.perm_lines:foreach(function(line)
				longest, height = mod.draw_line(gui, font_size, line, 1012, start_x, start_y, longest, height, vertical_spacing, header_color)
			end)
			for _, lines in pairs( mod.perm_external_lines ) do
				for _, line in ipairs( lines ) do
					longest, height = mod.draw_line(gui, font_size, line, 1002, start_x, start_y, longest, height, vertical_spacing, header_color)
				end
			end
			height = height - vertical_spacing
			Gui.rect(gui,
				Vector3(start_x - 10, start_y - height - 10, 1011),
				Vector2(longest + 20, height),
				Color(bg_alpha, 0, 0, 0)
			)
	end)
end

mod.draw_temp_info = function(owner)
	local self = owner

	if not (self.world or self._world or (self.world_manager and self.world_manager:world("level_world"))) then
		return
	end

	local world = self.world or self._world or self.world_manager:world("level_world")

	local gui = self.gui or self._mod_gui
	if not gui then
		self._mod_gui = World.create_screen_gui(world, "material", "materials/fonts/gw_fonts", "immediate")
		gui = self._mod_gui
	end

	local header_color = Color(
		255,
		mod:get(mod.SETTING_NAMES.RED),
		mod:get(mod.SETTING_NAMES.GREEN),
		mod:get(mod.SETTING_NAMES.BLUE)
	)
	local bg_alpha = mod:get(mod.SETTING_NAMES.BG_OPACITY)

	local font_size = mod:get(mod.SETTING_NAMES.FONT_SIZE)
	local vertical_spacing = mod:get(mod.SETTING_NAMES.LINE_SPACING)

	local start_x = mod:get(mod.SETTING_NAMES.OFFSET_X)
	local start_y = RESOLUTION_LOOKUP.res_h + mod:get(mod.SETTING_NAMES.OFFSET_Y)

	mod:pcall(function()
		local current_frame = Application.time_since_launch()
		if mod.drew_rect_at_frame ~= current_frame then
			mod.drew_rect_at_frame = current_frame

			local longest = 0
			local height = 0
			pl.List(pl.stringx.splitlines(mod.get_streaming_info())):extend(mod.out_lines)
				:foreach(function(line)
					longest, height = mod.draw_line(gui, font_size, line, 1002, start_x, start_y, longest, height, vertical_spacing, header_color)
				end)
			for _, lines in pairs( mod.temp_external_lines ) do
				for _, line in ipairs( lines ) do
					longest, height = mod.draw_line(gui, font_size, line, 1002, start_x, start_y, longest, height, vertical_spacing, header_color)
				end
			end
			height = height - vertical_spacing
			Gui.rect(gui,
				Vector3(start_x - 10, start_y - height - 10, 1001),
				Vector2(longest + 20, height),
				Color(bg_alpha, 0, 0, 0)
			)
		end
	end)
end

mod.set_lines = function(lines_table_key, lines_settings_key,...)
	local arg={...}
	if #arg == 0 then
		mod[lines_table_key] = pl.List()
	end
	mod:pcall(function()
		local input = pl.stringx.join(' ', pl.List(arg):map(pl.stringx.strip))
		mod[lines_table_key] = pl.stringx.split(input, ';')
	end)

	mod:set(mod[lines_settings_key], mod[lines_table_key])
end

mod.set_temp_lines = function(...)
	mod.set_lines("out_lines", "out_lines_setting_key", ...)
end

mod.set_info_lines = function(...)
	mod.set_lines("perm_lines", "perm_lines_setting_key", ...)
end

mod:command("set_lines",
	mod:localize("set_lines_command_description"),
	function(...)
		mod.set_temp_lines(...)
	end)

mod:command("info",
	mod:localize("info_command_description"),
	function(...)
		mod.set_info_lines(...)
	end)

local out_lines = mod:get(mod.out_lines_setting_key)
if out_lines then
	mod.out_lines = pl.List(out_lines)
end

local perm_lines = mod:get(mod.perm_lines_setting_key)
if perm_lines then
	mod.perm_lines = pl.List(perm_lines)
end

--- self._mod_gui cleanup
mod.destroy_gui = function(func, self, ...)
	if self._mod_gui then
		local world = self.world or self._world or self.world_manager:world("level_world")
		World.destroy_gui(world, self._mod_gui)
		self._mod_gui = nil
	end

	return func(self, ...)
end

local objects_to_hook_destroy = { LevelEndView, EndScreenUI, GameModeManager, IngameUI }

for _, obj in ipairs( objects_to_hook_destroy ) do
	mod:hook(obj, "destroy", mod.destroy_gui)
end
mod:hook(StateLoading, "on_exit", mod.destroy_gui)

mod.on_disabled = function(init_call) -- luacheck: ignore init_call
	for _, obj in ipairs( objects_to_hook_destroy ) do
		mod:hook_enable(obj, "destroy")
	end
	mod:hook_enable(StateLoading, "on_exit")
end

mod.on_enabled = function()
	mod.create_external_lines()
end

mod.on_setting_changed = function(setting_name)
	mod.dw_enabled = nil
	mod.ons_enabled = nil
	mod.cached_mutators = nil

	-- Handle turning off Show Additional Info options by clearing everything.
	if not mod:get(setting_name) then
		if setting_name == mod.SETTING_NAMES.MUTATORS_INFO_TEMP then
			mod.temp_external_lines["FSMutators"] = nil
		end
		if setting_name == mod.SETTING_NAMES.MUTATORS_INFO then
			mod.perm_external_lines["FSMutators"] = nil
		end
		if setting_name == mod.SETTING_NAMES.ONS_DW_INFO_TEMP then
			mod.temp_external_lines["DWONS"] = nil
		end
		if setting_name == mod.SETTING_NAMES.ONS_DW_INFO then
			mod.perm_external_lines["DWONS"] = nil
		end
	end
end

mod:dofile("scripts/mods/"..mod:get_name().."/additional_info_lines")

mod.create_external_lines = function()
	mod.persistent.temp_external_lines = mod.persistent.temp_external_lines or {}
	mod.persistent.perm_external_lines = mod.persistent.perm_external_lines or {}
	mod.temp_external_lines = mod.persistent.temp_external_lines
	mod.perm_external_lines = mod.persistent.perm_external_lines
end
mod.create_external_lines()
