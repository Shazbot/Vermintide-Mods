local mod = get_mod("WeaponKillCounter")

mod.WEAPON_KILLS_SETTINGS_KEY = "weapon_kills"

local weapon_kills_table = mod:get(mod.WEAPON_KILLS_SETTINGS_KEY) or {}

local function serialize_weapon_kills()
	weapon_kills_table[2] = nil -- prologue hammer backend_id that crashes set_user_setting on weapon_kills_table
	mod:set(mod.WEAPON_KILLS_SETTINGS_KEY, weapon_kills_table)
end

local function increase_kill_counter(backend_id)
	if backend_id == 2 then
		return
	end
	weapon_kills_table[backend_id] = (weapon_kills_table[backend_id] or 0) + 1
	serialize_weapon_kills()
end

local DEFAULT_START_LAYER = 994

mod:hook(StatisticsUtil, "register_kill", function(func, victim_unit, damage_data, statistics_db, is_server)
	mod:pcall(function()
		local attacker_unit = damage_data[DamageDataIndex.ATTACKER]
		attacker_unit = AiUtils.get_actual_attacker_unit(attacker_unit)

		local local_player_unit = Managers.player:local_player().player_unit
		if local_player_unit and attacker_unit == local_player_unit then
			local inventory_extension = ScriptUnit.has_extension(attacker_unit, "inventory_system")
			if inventory_extension then
				local slot_name = inventory_extension:get_wielded_slot_name()
				local slot_data = inventory_extension:get_slot_data(slot_name)
				if slot_data.item_data.key == damage_data[DamageDataIndex.DAMAGE_SOURCE_NAME] then
					local backend_id = slot_data.item_data.backend_id
					if backend_id then
						increase_kill_counter(backend_id)
					end
				end
			end
		end
	end)
	return func(victim_unit, damage_data, statistics_db, is_server)
end)

local function is_weapon(item_data)
	local slot_type = item_data.slot_type
	return slot_type == "melee" or slot_type == "ranged"
end

-- Format an int with commas between every 3 digits.
-- https://stackoverflow.com/questions/10989788/lua-format-integer
local function format_int(number)
  local _, _, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')

  -- reverse the int-string and append a comma to all blocks of 3 digits
  int = int:reverse():gsub("(%d%d%d)", "%1,")

  -- reverse the int-string back remove an optional comma and put the
  -- optional minus and fractional part back
  return minus .. int:reverse():gsub("^,", "") .. fraction
end

UITooltipPasses.weapon_kills = {
	setup_data = function ()
		local data = {
			text_pass_data = {
				text_id = "text"
			},
			text_size = {},
			content = {
			},
			style = {
				text = {
					vertical_alignment = "center",
					name = "description",
					localize = false,
					word_wrap = true,
					font_size = 18,
					horizontal_alignment = "right",
					font_type = "hell_shark",
					text_color = Colors.get_color_table_with_alpha("white", 255),
				}
			}
		}

		return data
	end,
	draw = function (data, draw, draw_downwards, ui_renderer, pass_data, ui_scenegraph, pass_definition, ui_style, ui_content, position, size, input_service, dt, ui_style_global, item)
		local alpha_multiplier = pass_data.alpha_multiplier
		local alpha = 255 * alpha_multiplier
		local start_layer = pass_data.start_layer or DEFAULT_START_LAYER
		local frame_margin = data.frame_margin or 0
		local style = data.style
		local content = data.content

		if not is_weapon(item.data) then
			return 0
		end

		local backend_id = item.backend_id

		if mod:is_enabled() then
			content.text = "Kills: "..format_int(tostring(weapon_kills_table[backend_id] or 0))
			local position_x = position[1]
			local position_y = position[2]
			local position_z = position[3]
			position[3] = start_layer + 5
			local text_style = style.text
			local text_pass_data = data.text_pass_data
			local text_size = data.text_size
			text_size[1] = size[1] - frame_margin * 2
			text_size[2] = 0
			local text_height = UIUtils.get_text_height(ui_renderer, text_size, text_style, content.text, ui_style_global)
			text_size[2] = text_height

			if draw then
				position[1] = position_x + frame_margin
				position[2] = position[2] - text_height + 25
				text_style.text_color[1] = alpha

				UIPasses.text.draw(ui_renderer, text_pass_data, ui_scenegraph, pass_definition, text_style, content, position, text_size, input_service, dt, ui_style_global)
			end

			position[1] = position_x
			position[2] = position_y
			position[3] = position_z

			return 0
		else
			return 0
		end
	end
}

mod:hook(UIPasses.item_tooltip, "init", function(func, pass_definition, ui_content, ui_style, style_global)
	local pass_data = func(pass_definition, ui_content, ui_style, style_global)

	local index_of_insertion = nil
	for i, pass in ipairs( pass_data.passes ) do
		if pass.draw == UITooltipPasses.item_power_level.draw then
			index_of_insertion = i
			break
		end
	end
	if index_of_insertion then
		table.insert(pass_data.passes, index_of_insertion + 1, {
			data = UITooltipPasses.weapon_kills.setup_data(),
			draw = UITooltipPasses.weapon_kills.draw
		})
	end

	return pass_data
end)
