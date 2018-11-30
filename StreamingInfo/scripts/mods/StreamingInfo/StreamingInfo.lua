local mod = get_mod("StreamingInfo")

local pl = require'pl.import_into'()
local tablex = require'pl.tablex'
local stringx = require'pl.stringx'
local stringio = require'pl.stringio'

mod.streaming_data = {}

mod.out_lines = pl.List()

mod.append_traits = function(out, slot)
	local traits = slot.traits
	if traits and #traits then
		for _,trait_name in ipairs(traits) do
			local localized_trait_name = Localize(WeaponTraits.traits[trait_name].display_name)
			out:write(localized_trait_name)
			out:write(", ")
		end
	end
	local properties = slot.properties
	if properties then
		local properties_size = tablex.size(properties)
		local property_index = 0
		for prop_name, prop_value in pairs( properties ) do
			property_index = property_index + 1
			local prop_description_original = UIUtils.get_property_description(prop_name, prop_value)
			local _, _, prop_description = stringx.partition(prop_description_original, " ")
			prop_description = stringx.replace(prop_description, "Power vs ", "Pv")
			out:write(stringx.strip(prop_description))
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
	local out = stringio.create()
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
	end)
	return out:value()
end

mod:hook(DifficultyManager, "set_difficulty", function (func, self, difficulty)
	local current_difficulty = Localize(DifficultySettings[difficulty].display_name)
	if mod.streaming_data.difficulty ~= current_difficulty then
		mod.streaming_data.difficulty = current_difficulty
	end

	return func(self, difficulty)
end)

mod:hook(BackendUtils, "get_loadout_item", function (func, career_name, slot)
	local item_data = func(career_name, slot)

	mod.streaming_data[slot] = item_data

	return item_data
end)

mod.font = "gw_arial_16"
mod.font_mtrl = "materials/fonts/" .. mod.font

mod:hook_safe(StateLoading, "update", function(self)
	mod.draw_info(self)
end)

mod:hook_safe(LevelEndView, "update", function(self)
	mod.draw_info(self)
end)

mod:hook_safe(EndScreenUI, "draw", function(self)
	mod.draw_info(self)
end)

mod:hook_safe(GameModeManager, "server_update", function(self)
	if not self._game_mode then
		return
	end

	if self._game_mode.lost_condition_timer or self._game_mode.level_complete_timer then
		mod.draw_info(self)
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

	if not (is_in_inn or in_score_screen or end_screen_active) then
		if round_started then
			return
		end
	end

	mod.draw_info(self)
end)

mod.draw_info = function(owner)
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

	local font_size = mod:get(mod.SETTING_NAMES.FONT_SIZE)
	local vertical_spacing = mod:get(mod.SETTING_NAMES.SPACING)

	local start_x = 10 + mod:get(mod.SETTING_NAMES.OFFSET_X)
	local start_y = RESOLUTION_LOOKUP.res_h - 30  + mod:get(mod.SETTING_NAMES.OFFSET_Y)
	local i = 0

	mod:pcall(function()
		local current_frame = Application.time_since_launch()
		if mod.drew_rect_at_frame ~= current_frame then
			mod.drew_rect_at_frame = current_frame
			local padding_x = font_size > 19 and 10+(font_size-19)*25 or 0
			local padding_y = font_size > 30 and (font_size-30)*0.8 or 0
			local num_lines = 6 + #mod.out_lines
			Gui.rect(gui,
				Vector3(start_x-10, start_y-(font_size*0.08)*num_lines-vertical_spacing*(num_lines-1)+padding_y-2, 400),
				Vector2(450+padding_x, 30+vertical_spacing*(num_lines-1)+(font_size*0.08)*num_lines+padding_y),
				Color(100, 0, 0, 0)
			)
			pl.List(stringx.splitlines(mod.get_streaming_info())):extend(mod.out_lines)
				:foreach(function(line)
					local pos = Vector3(start_x, start_y-vertical_spacing*i, 500)
					Gui.text(gui, line, mod.font_mtrl, font_size, mod.font, pos, header_color)
						-- shadow?
						-- pos = Vector3(start_x+2, start_y-vertical_spacing*i-2, 450)
						-- Gui.text(self.gui, line, mod.font_mtrl, font_size, mod.font, pos, Color(255, 0, 0, 0))
					i = i + 1
				end)
		end
	end)
end

mod.out_lines_setting_key = "out_lines"

mod.set_lines = function(...)
	local arg={...}
	if #arg == 0 then
		mod.out_lines = pl.List()
	end
	mod:pcall(function()
		local input = pl.stringx.join(' ', pl.List(arg):map(pl.stringx.strip))
		mod.out_lines = pl.stringx.split(input, ';')
	end)

	mod:set(mod.out_lines_setting_key, mod.out_lines)
end

mod:command("set_lines", mod:localize("set_lines_command_description"), function(...) mod.set_lines(...) end)

local out_lines = mod:get(mod.out_lines_setting_key)
if out_lines then
	mod.out_lines = pl.List(out_lines)
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
