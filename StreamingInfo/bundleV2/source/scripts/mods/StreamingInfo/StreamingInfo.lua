local mod = get_mod("StreamingInfo") -- luacheck: ignore get_mod

-- luacheck: globals Localize WeaponTraits UIUtils DifficultyManager BackendUtils
-- luacheck: globals DifficultySettings Managers ScriptUnit RESOLUTION_LOOKUP Vector3
-- luacheck: globals Gui World Color IngameUI

local pl = require'pl.import_into'()
local tablex = require'pl.tablex'
local stringx = require'pl.stringx'
local stringio = require'pl.stringio'

mod.streaming_data = {}

mod.dump_traits = function(out, slot)
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

			return pl.List(current_talents):join(" ")
		end
	end
end

mod.dump_data_file = function()
	local out = stringio.create()
	mod:pcall(function()
		if mod.streaming_data.slot_melee then
			mod.dump_traits(out, mod.streaming_data.slot_melee)
			out:write("\n")
		end
		if mod.streaming_data.slot_ranged then
			mod.dump_traits(out, mod.streaming_data.slot_ranged)
			out:write("\n")
		end
		if mod.streaming_data.slot_necklace then
			mod.dump_traits(out, mod.streaming_data.slot_necklace)
			out:write("\n")
		end
		if mod.streaming_data.slot_ring then
			mod.dump_traits(out, mod.streaming_data.slot_ring)
			out:write("\n")
		end
		if mod.streaming_data.slot_trinket_1 then
			mod.dump_traits(out, mod.streaming_data.slot_trinket_1)
			out:write("\n")
		end

		out:write("Talents: ")
		out:write(mod.get_talents())
		out:write("\n")
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

local font = "gw_arial_16"
local font_mtrl = "materials/fonts/" .. font

mod:hook(IngameUI, "update", function(func, self, ...)
	if not self.gui then
		self.gui = World.create_screen_gui(self.world, "material", "materials/fonts/gw_fonts", "immediate")
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
		pl.List(stringx.splitlines(mod.dump_data_file()))
			:foreach(function(line)
				local pos = Vector3(start_x, start_y-vertical_spacing*i, 200)
				Gui.text(self.gui, line, font_mtrl, font_size, font, pos, header_color)
				i = i + 1
		end)
    end)

	return func(self, ...)
end)
