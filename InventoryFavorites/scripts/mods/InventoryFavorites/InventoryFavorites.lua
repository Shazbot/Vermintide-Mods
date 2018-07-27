local mod = get_mod("InventoryFavorites")

local pl = require'pl.import_into'()

-- luacheck: globals Favorite_keymaps Colors table UITooltipPasses UIPasses
-- luacheck: globals UIFrameSettings Managers ItemGridUI Localize UIUtils
-- luacheck: globals BackendInterfaceCommon ItemMasterList UISettings
-- luacheck: globals UISettings UIFontByResolution UIGetFontHeight UIRenderer RESOLUTION_LOOKUP

-- needs to be global for create_input_service
Favorite_keymaps = {
	win32 = {
		fav = {
			"keyboard",
			"f",
			"pressed"
		},
		junk = {
			"keyboard",
			"j",
			"pressed"
		},
	}
}
Favorite_keymaps.xb1 = Favorite_keymaps.win32

local fav_item_text_style = {
	font_size = 25,
	word_wrap = false,
	pixel_perfect = true,
	horizontal_alignment = "left",
	vertical_alignment = "center",
	dynamic_font = true,
	font_type = "hell_shark",
	text_color = Colors.get_color_table_with_alpha("orange", 255),
	size = {
		30,
		38
	},
	offset = {
		220+5,
		35+42,
		6
	}
}
local junk_item_text_style = {
	font_size = 20,
	word_wrap = false,
	pixel_perfect = true,
	horizontal_alignment = "left",
	vertical_alignment = "center",
	dynamic_font = true,
	font_type = "hell_shark",
	text_color = Colors.get_color_table_with_alpha("white", 255),
	size = {
		34+2,
		42+2
	},
	offset = {
		220+28,
		35-8,
		6
	}
}

mod.FAVS_SETTINGS_KEY = "favs"
mod.JUNK_SETTINGS_KEY = "junk"

mod.favs_table = pl.List(mod:get(mod.FAVS_SETTINGS_KEY) or {})
mod.junk_table = pl.List(mod:get(mod.JUNK_SETTINGS_KEY) or {})

local reload = false

mod.remove_passes = function(self, widget)
	local passes = widget.element.passes
	widget.element.dirty = true
	local favorite_pass_index = nil
	for i, pass in ipairs(passes) do
		if pass.text_id == "text_favorite" then
			favorite_pass_index = i
			break
		end
	end
	local junk_pass_index = nil
	for i, pass in ipairs(passes) do
		if pass.text_id == "text_junk" then
			junk_pass_index = i
			break
		end
	end
	if junk_pass_index then
		table.remove(passes, junk_pass_index)
	end
	if favorite_pass_index then
		table.remove(passes, favorite_pass_index)
	end

	local new_passes
	mod:pcall(function()
		new_passes = pl.seq(passes):filter(
			function(pass)
				return not pass.text_id or pass.text_id ~= 'text_favorite' or pass.text_id ~= 'text_junk'
			end):copy()
	end)

	if new_passes then
		widget.element.passes = new_passes
	end

	widget.element.dirty = true
end

mod.create_passes = function(self, widget)
	local passes = widget.element.passes
	local content = widget.content

	local rows = content.rows
	local columns = content.columns

	for i = 1, rows, 1 do
		for k = 1, columns, 1 do
			if widget.content["item_" .. tostring(i) .. "_" .. tostring(k)] then
				local fav_style_key = "text_favorite_" .. tostring(i) .. "_" .. tostring(k)
				local junk_style_key = "text_junk_" .. tostring(i) .. "_" .. tostring(k)

				widget.style[fav_style_key] = table.clone(fav_item_text_style)
				widget.style[junk_style_key] = table.clone(junk_item_text_style)

				widget.style[fav_style_key].offset = table.clone(widget.style["item_icon_" .. tostring(i) .. "_" .. tostring(k)].offset)
				widget.style[fav_style_key].offset[1] = widget.style[fav_style_key].offset[1] + 8
				widget.style[fav_style_key].offset[2] = widget.style[fav_style_key].offset[2] + 41
				widget.style[fav_style_key].offset[3] = 10

				widget.style[junk_style_key].offset = table.clone(widget.style["item_icon_" .. tostring(i) .. "_" .. tostring(k)].offset)
				widget.style[junk_style_key].offset[1] = widget.style[junk_style_key].offset[1] + 63
				widget.style[junk_style_key].offset[2] = widget.style[junk_style_key].offset[2] - 5
				widget.style[junk_style_key].offset[3] = 10

				widget.content["item_" .. tostring(i) .. "_" .. tostring(k)].text_favorite = "F"
				widget.content["item_" .. tostring(i) .. "_" .. tostring(k)].text_junk = "J"
				passes[#passes + 1] = {
					text_id = "text_favorite",
					content_id = "item_" .. tostring(i) .. "_" .. tostring(k),
					pass_type = "text",
					style_id = "text_favorite_" .. tostring(i) .. "_" .. tostring(k),
					content_check_function = function(content)
						return table.contains(mod.favs_table, content.backend_id)
					end,
				}
				widget.element.pass_data[#passes] = {
					text_id = "text_favorite",
					content_id = "item_" .. tostring(i) .. "_" .. tostring(k),
				}

				passes[#passes + 1] = {
					text_id = "text_junk",
					content_id = "item_" .. tostring(i) .. "_" .. tostring(k),
					pass_type = "text",
					style_id = "text_junk_" .. tostring(i) .. "_" .. tostring(k),
					content_check_function = function(content)
						return table.contains(mod.junk_table, content.backend_id)
					end,
				}
				widget.element.pass_data[#passes] = {
					text_id = "text_junk",
					content_id = "item_" .. tostring(i) .. "_" .. tostring(k),
				}
			end
		end
	end
end

mod:hook(HeroWindowLoadoutInventory, "on_exit", function (func, self, ...)
	reload = true
	local widget = self._item_grid._widget
	mod:remove_passes(widget)
	return func(self, ...)
end)

mod:hook(HeroWindowLoadoutInventory, "update", function (func, self, ...)
	local widget = self._item_grid._widget
	if not widget.content.item_1_2 then
		mod:remove_passes(widget)
		return func(self, ...)
	end

	if not widget.style.text_favorite or reload then
		widget.style.text_favorite = table.clone(fav_item_text_style)
	end
	if not widget.style.text_junk or reload then
		widget.style.text_junk = table.clone(junk_item_text_style)
	end

	widget.content.text_favorite = "FAV"
	widget.content.text_junk = "JUNK"

	if not self._created_favs or reload then
		mod:create_passes(widget)
		self._created_favs = true
	end

	widget.element.dirty = true

	if reload then
		reload = false
	end

	return func(self, ...)
end)

local function item_sort_func(item_1, item_2)
	local item_data_1 = item_1.data
	local item_data_2 = item_2.data
	local item_1_rarity = item_1.rarity or item_data_1.rarity
	local item_2_rarity = item_2.rarity or item_data_2.rarity
	local item_rarity_order = UISettings.item_rarity_order
	local item_1_rarity_order = item_rarity_order[item_1_rarity]
	local item_2_rarity_order = item_rarity_order[item_2_rarity]

	local backend_id_1 = item_1.backend_id
	local backend_id_2 = item_2.backend_id

	local is_fav_1 = mod.favs_table:contains(backend_id_1)
	local is_fav_2 = mod.favs_table:contains(backend_id_2)

	if is_fav_1 and not is_fav_2 then
		return true
	elseif is_fav_2 and not is_fav_1 then
		return false
	end

	if item_1_rarity_order == item_2_rarity_order then
		local item_type_1 = Localize(item_data_1.item_type)
		local item_type_2 = Localize(item_data_2.item_type)

		if item_type_1 == item_type_2 then
			local _, item_1_display_name = UIUtils.get_ui_information_from_item(item_1)
			local _, item_2_display_name = UIUtils.get_ui_information_from_item(item_2)
			local item_name_1 = Localize(item_1_display_name)
			local item_name_2 = Localize(item_2_display_name)

			return item_name_1 < item_name_2
		else
			return item_type_1 < item_type_2
		end
	else
		return item_1_rarity_order < item_2_rarity_order
	end
end

local function junk_last_item_sort_func(item_1, item_2)
	local backend_id_1 = item_1.backend_id
	local backend_id_2 = item_2.backend_id

	local is_junk_1 = mod.junk_table:contains(backend_id_1)
	local is_junk_2 = mod.junk_table:contains(backend_id_2)

	if is_junk_1 and not is_junk_2 then
		return false
	elseif is_junk_2 and not is_junk_1 then
		return true
	end

	return item_sort_func(item_1, item_2)
end

local function junk_item_sort_func(item_1, item_2)
	local backend_id_1 = item_1.backend_id
	local backend_id_2 = item_2.backend_id

	local is_junk_1 = mod.junk_table:contains(backend_id_1)
	local is_junk_2 = mod.junk_table:contains(backend_id_2)

	if is_junk_1 and not is_junk_2 then
		return true
	elseif is_junk_2 and not is_junk_1 then
		return false
	end

	return item_sort_func(item_1, item_2)
end

mod:hook(ItemGridUI, "change_item_filter", function (func, self, item_filter, change_page)
	if pl.stringx.count(item_filter, "can_salvage") > 0 then
		item_filter = "not is_favorite and " .. item_filter
		self:apply_item_sorting_function(junk_item_sort_func)
	elseif pl.stringx.count(item_filter, "slot_type == loot_chest") == 0 then
		self:apply_item_sorting_function(junk_last_item_sort_func)
	end
	return func(self, item_filter, change_page)
end)

mod.serialize = function(self)
	mod:set(mod.FAVS_SETTINGS_KEY, mod.favs_table)
	mod:set(mod.JUNK_SETTINGS_KEY, mod.junk_table)
end

mod.is_favorite = function(self, backend_id)
	return mod.favs_table:contains(backend_id)
end

mod.is_junk = function(self, backend_id)
	return mod.junk_table:contains(backend_id)
end

mod.remove_item_from_junk = function(self, backend_id)
	if mod.junk_table:contains(backend_id) then
		mod.junk_table:remove_value(backend_id)
		mod:serialize()
	end
end

mod.toggle_item_as_favorite = function(self, backend_id)
	if mod.favs_table:contains(backend_id) then
		mod.favs_table:remove_value(backend_id)
	else
		mod:remove_item_from_junk(backend_id)
		mod.favs_table:append(backend_id)
	end
	mod:serialize()
end

mod.toggle_item_as_junk = function(self, backend_id)
	if mod.junk_table:contains(backend_id) then
		mod.junk_table:remove_value(backend_id)
	else
		mod.junk_table:append(backend_id)
	end
	mod:serialize()
end

mod.get_fav_input_service = function(self)
	if not Managers.input:get_input_service("favorite_input_service") then
		Managers.input:create_input_service("favorite_input_service", "Favorite_keymaps")
		Managers.input:map_device_to_service("favorite_input_service", "keyboard")
		Managers.input:map_device_to_service("favorite_input_service", "mouse")
		Managers.input:map_device_to_service("favorite_input_service", "gamepad")
	end

	Managers.input:device_unblock_service("keyboard", 1, "favorite_input_service")

	return Managers.input:get_input_service("favorite_input_service")
end

mod:hook(ItemGridUI, "_populate_inventory_page", function (func, self, ...)
	local widget = self._widget
	mod:remove_passes(widget)
	func(self, ...)
	mod:create_passes(widget)
end)

-- variable for enforcing a delay between fav/junk toggle on an item in an item grid
-- without delay we get one toggle registering as multiple through successive draw function calls
local toggled_time = -math.huge

local DEFAULT_START_LAYER = 994
local function get_text_height(ui_renderer, size, ui_style, ui_content, text, ui_style_global)
	local widget_scale = nil

	if ui_style_global then
		widget_scale = ui_style_global.scale
	end

	local font_material, font_size, font_name = nil

	if ui_style.font_type then
		local font, size_of_font = UIFontByResolution(ui_style, widget_scale)
		font_name = font[3]
		font_size = font[2]
		font_material = font[1]
		font_size = size_of_font
	else
		local font = ui_style.font
		font_name = font[3]
		font_size = font[2]
		font_material = font[1]

		if not ui_style.font_size then
		end
	end

	if ui_style.localize then
		text = Localize(text)
	end

	local font_height, font_min, font_max = UIGetFontHeight(ui_renderer.gui, font_name, font_size)
	local texts = UIRenderer.word_wrap(ui_renderer, text, font_material, font_size, size[1])
	local text_start_index = ui_content.text_start_index or 1
	local max_texts = ui_content.max_texts or #texts
	local num_texts = math.min(#texts - text_start_index - 1, max_texts)
	local inv_scale = RESOLUTION_LOOKUP.inv_scale
	local full_font_height = (font_max + math.abs(font_min))*inv_scale*num_texts

	return full_font_height
end

local function is_chest(item_data)
	local item_type = item_data.item_type
	return item_type == "loot_chest"
end

--NOTE: can refactor this to create UITooltipPasses.junk from UITooltipPasses.fav
UITooltipPasses.fav = {
	setup_data = function ()
		local data = {
			text_pass_data = {
				text_id = "text"
			},
			text_size = {},
			content = {
				prefix_text = "Favorite"
			},
			style = {
				text = {
					vertical_alignment = "center",
					name = "description",
					localize = false,
					word_wrap = true,
					font_size = 18,
					horizontal_alignment = "center",
					font_type = "hell_shark",
					text_color = Colors.get_color_table_with_alpha("orange", 255)
				}
			}
		}

		return data
	end,
	draw = function (draw, ui_renderer, pass_data, ui_scenegraph, pass_definition, ui_style, ui_content, position, size, input_service, dt, ui_style_global, item, data, draw_downwards)
		local alpha_multiplier = pass_data.alpha_multiplier
		local alpha = 255 * alpha_multiplier
		local start_layer = pass_data.start_layer or DEFAULT_START_LAYER
		local frame_margin = data.frame_margin or 0
		local style = data.style
		local content = data.content

		if is_chest(item.data) then
			return 0
		end

		local backend_id = item.backend_id

		if mod.favs_table:contains(backend_id) then
			content.text = content.prefix_text
			local position_x = position[1]
			local position_y = position[2]
			local position_z = position[3]
			position[3] = start_layer + 5
			local text_style = style.text
			local text_pass_data = data.text_pass_data
			local text_size = data.text_size
			text_size[1] = size[1] - frame_margin * 2
			text_size[2] = 0
			local text_height = -1*get_text_height(ui_renderer, text_size, text_style, content, content.text, ui_style_global)
			text_size[2] = text_height

			if draw then
				position[1] = position_x + frame_margin
				position[2] = position[2] - text_height
				text_style.text_color[1] = alpha

				UIPasses.text.draw(ui_renderer, text_pass_data, ui_scenegraph, pass_definition, text_style, content, position, text_size, input_service, dt, ui_style_global)
			end

			position[1] = position_x
			position[2] = position_y
			position[3] = position_z

			return text_height
		else
			return 0
		end
	end
}
UITooltipPasses.junk = {
	setup_data = function ()
		local data = {
			text_pass_data = {
				text_id = "text"
			},
			text_size = {},
			content = {
				prefix_text = "Junk"
			},
			style = {
				text = {
					vertical_alignment = "center",
					name = "description",
					localize = false,
					word_wrap = true,
					font_size = 18,
					horizontal_alignment = "center",
					font_type = "hell_shark",
					text_color = Colors.get_color_table_with_alpha("white", 255)
				}
			}
		}

		return data
	end,
	draw = function (draw, ui_renderer, pass_data, ui_scenegraph, pass_definition, ui_style, ui_content, position, size, input_service, dt, ui_style_global, item, data, draw_downwards)
		local alpha_multiplier = pass_data.alpha_multiplier
		local alpha = 255 * alpha_multiplier
		local start_layer = pass_data.start_layer or DEFAULT_START_LAYER
		local frame_margin = data.frame_margin or 0
		local style = data.style
		local content = data.content

		if is_chest(item.data) then
			return 0
		end

		local backend_id = item.backend_id

		if mod.junk_table:contains(backend_id) then
			content.text = content.prefix_text
			local position_x = position[1]
			local position_y = position[2]
			local position_z = position[3]
			position[3] = start_layer + 5
			local text_style = style.text
			local text_pass_data = data.text_pass_data
			local text_size = data.text_size
			text_size[1] = size[1] - frame_margin * 2
			text_size[2] = 0
			local text_height = -1*get_text_height(ui_renderer, text_size, text_style, content, content.text, ui_style_global)
			text_size[2] = text_height

			if draw then
				position[1] = position_x + frame_margin
				position[2] = position[2] - text_height
				text_style.text_color[1] = alpha

				UIPasses.text.draw(ui_renderer, text_pass_data, ui_scenegraph, pass_definition, text_style, content, position, text_size, input_service, dt, ui_style_global)
			end

			position[1] = position_x
			position[2] = position_y
			position[3] = position_z

			return text_height
		else
			return 0
		end
	end
}

UITooltipPasses.advanced_input_helper_favorite = {
	setup_data = function ()
		local frame_name = "item_tooltip_frame_01"
		local frame_settings = UIFrameSettings[frame_name]
		local data = {
			frame_name = "item_tooltip_frame_01",
			background_color = {
				240,
				3,
				3,
				3
			},
			text_pass_data = {
				text_id = "text"
			},
			text_size = {},
			frame_pass_data = {},
			frame_pass_definition = {
				texture_id = "frame",
				style_id = "frame"
			},
			frame_size = {
				0,
				0
			},
			content = {
				text = "",
				frame = frame_settings.texture
			},
			style = {
				frame = {
					texture_size = frame_settings.texture_size,
					texture_sizes = frame_settings.texture_sizes,
					color = {
						255,
						255,
						255,
						255
					},
					offset = {
						0,
						0,
						1
					}
				},
				text = {
					vertical_alignment = "center",
					font_size = 16,
					horizontal_alignment = "center",
					word_wrap = true,
					font_type = "hell_shark",
					text_color = Colors.get_color_table_with_alpha("font_title", 255)
				},
				background = {
					color = {
						255,
						10,
						10,
						10
					},
					offset = {
						0,
						0,
						-1
					}
				}
			}
		}

		return data
	end,
	draw = function (draw, ui_renderer, pass_data, ui_scenegraph, pass_definition, ui_style, ui_content, position, size, input_service, dt, ui_style_global, item, data, draw_downwards)
		local alpha_multiplier = pass_data.alpha_multiplier
		local alpha = 255 * alpha_multiplier
		local start_layer = pass_data.start_layer or DEFAULT_START_LAYER
		local frame_margin = data.frame_margin or 0
		local style = data.style
		local content = data.content

		if is_chest(item.data) then
			return 0
		end

		local position_x = position[1]
		local position_y = position[2]
		local position_z = position[3]
		local total_height = 0
		position[3] = start_layer - 6

		if (#pass_data.items == 2 or #pass_data.items == 3) and item ~= pass_data.items[1] then
			return 0
		end

		local backend_id = item.backend_id
		mod:pcall(function()
			local fav_input_service = mod:get_fav_input_service()
			if fav_input_service:get("fav") or fav_input_service:get("junk") then
				local current_time = Managers.time:time("main")
				-- if 2 tooltips open while in comparison make sure we're changing the correct one
				if #pass_data.items == 1
				or #pass_data.items == 2 and item == pass_data.items[1] then
					if toggled_time + 0.1 < current_time then
						toggled_time = current_time
						if fav_input_service:get("fav") then
							mod:toggle_item_as_favorite(backend_id)
						end
						if fav_input_service:get("junk") then
							if not mod.favs_table:contains(backend_id) then
								mod:toggle_item_as_junk(backend_id)
							end
						end
					end
				end
			end
		end)

		if mod:is_favorite(backend_id) then
			content.text = "Click [f] to unmark as favorite."
		else
			content.text = "Click [f] to mark as favorite."
		end

		if true then
			local text_style = style.text
			local text_pass_data = data.text_pass_data
			local text = content.text
			local text_size = data.text_size
			text_size[1] = size[1] - frame_margin*2
			text_size[2] = 0
			local text_height = -1 * get_text_height(ui_renderer, text_size, text_style, content, text, ui_style_global)
			total_height = total_height + text_height
			text_size[2] = text_height
			local frame_size = data.frame_size
			local frame_pass_data = data.frame_pass_data
			local frame_pass_definition = data.frame_pass_definition
			local frame_content = data.content
			local frame_style = data.style.frame
			frame_size[1] = text_size[1]
			frame_size[2] = text_size[2] + frame_margin/2
			total_height = total_height + frame_size[2]
			position[2] = position[2] - frame_size[2] - frame_margin/2
			position[1] = position[1] + frame_margin
			local old_y_position = position[2]

			if draw then
				local frame_color = frame_style.color
				frame_color[1] = alpha

				UIPasses.texture_frame.draw(ui_renderer, frame_pass_data, ui_scenegraph, frame_pass_definition, frame_style, frame_content, position, frame_size, input_service, dt, ui_style_global)

				local background_style = data.style.background
				local background_color = background_style.color
				background_color[1] = alpha
				position[3] = position[3] - 1

				UIRenderer.draw_rect(ui_renderer, position, frame_size, background_color)

				position[3] = position[3] + 1
			end

			position[2] = old_y_position + frame_margin/4
			text_size[1] = frame_size[1]

			if draw then
				local text_color = text_style.text_color
				text_color[1] = alpha

				UIPasses.text.draw(ui_renderer, text_pass_data, ui_scenegraph, pass_definition, text_style, content, position, text_size, input_service, dt, ui_style_global)
			end

			position[1] = position_x
			position[2] = position_y
			position[3] = position_z

			return 0
		end
	end
}

UITooltipPasses.advanced_input_helper_junk = {
	setup_data = function ()
		local frame_name = "item_tooltip_frame_01"
		local frame_settings = UIFrameSettings[frame_name]
		local data = {
			frame_name = "item_tooltip_frame_01",
			background_color = {
				240,
				3,
				3,
				3
			},
			text_pass_data = {
				text_id = "text"
			},
			text_size = {},
			frame_pass_data = {},
			frame_pass_definition = {
				texture_id = "frame",
				style_id = "frame"
			},
			frame_size = {
				0,
				0
			},
			content = {
				text = "",
				frame = frame_settings.texture
			},
			style = {
				frame = {
					texture_size = frame_settings.texture_size,
					texture_sizes = frame_settings.texture_sizes,
					color = {
						255,
						255,
						255,
						255
					},
					offset = {
						0,
						0,
						1
					}
				},
				text = {
					vertical_alignment = "center",
					font_size = 16,
					horizontal_alignment = "center",
					word_wrap = true,
					font_type = "hell_shark",
					text_color = Colors.get_color_table_with_alpha("font_title", 255)
				},
				background = {
					color = {
						255,
						10,
						10,
						10
					},
					offset = {
						0,
						0,
						-1
					}
				}
			}
		}

		return data
	end,
	draw = function (draw, ui_renderer, pass_data, ui_scenegraph, pass_definition, ui_style, ui_content, position, size, input_service, dt, ui_style_global, item, data, draw_downwards)
		local alpha_multiplier = pass_data.alpha_multiplier
		local alpha = 255 * alpha_multiplier
		local start_layer = pass_data.start_layer or DEFAULT_START_LAYER
		local frame_margin = data.frame_margin or 0
		local style = data.style
		local content = data.content

		if is_chest(item.data) then
			return 0
		end

		local position_x = position[1]
		local position_y = position[2]
		local position_z = position[3]
		local total_height = 0
		position[3] = start_layer - 6

		if (#pass_data.items == 2 or #pass_data.items == 3) and item ~= pass_data.items[1] then
			return 0
		end

		local backend_id = item.backend_id

		if mod:is_favorite(backend_id) then
			return 0
		end

		if mod:is_junk(backend_id) then
			content.text = "Click [j] to unmark as junk."
		else
			content.text = "Click [j] to mark as junk."
		end

		if true then
			local text_style = style.text
			local text_pass_data = data.text_pass_data
			local text = content.text
			local text_size = data.text_size
			text_size[1] = size[1] - frame_margin*2
			text_size[2] = 0
			local text_height = -1 * get_text_height(ui_renderer, text_size, text_style, content, text, ui_style_global)
			total_height = total_height + text_height
			text_size[2] = text_height
			local frame_size = data.frame_size
			local frame_pass_data = data.frame_pass_data
			local frame_pass_definition = data.frame_pass_definition
			local frame_content = data.content
			local frame_style = data.style.frame
			frame_size[1] = text_size[1]
			frame_size[2] = text_size[2] + frame_margin/2
			total_height = total_height + frame_size[2]
			position[2] = position[2] - frame_size[2] - frame_margin/2 - 28
			position[1] = position[1] + frame_margin
			local old_y_position = position[2]

			if draw then
				local frame_color = frame_style.color
				frame_color[1] = alpha

				UIPasses.texture_frame.draw(ui_renderer, frame_pass_data, ui_scenegraph, frame_pass_definition, frame_style, frame_content, position, frame_size, input_service, dt, ui_style_global)

				local background_style = data.style.background
				local background_color = background_style.color
				background_color[1] = alpha
				position[3] = position[3] - 1

				UIRenderer.draw_rect(ui_renderer, position, frame_size, background_color)

				position[3] = position[3] + 1
			end

			position[2] = old_y_position + frame_margin/4
			text_size[1] = frame_size[1]

			if draw then
				local text_color = text_style.text_color
				text_color[1] = alpha

				UIPasses.text.draw(ui_renderer, text_pass_data, ui_scenegraph, pass_definition, text_style, content, position, text_size, input_service, dt, ui_style_global)
			end
		end

		position[1] = position_x
		position[2] = position_y
		position[3] = position_z

		return 0
	end
}

mod:hook(UIPasses.item_tooltip, "init", function(func, pass_definition, ui_content, ui_style, style_global)
	local pass_data = func(pass_definition, ui_content, ui_style, style_global)
	table.insert(pass_data.passes, 4, {
			data = UITooltipPasses.fav.setup_data(),
			draw = UITooltipPasses.fav.draw
		})
	table.insert(pass_data.passes, 5, {
			data = UITooltipPasses.junk.setup_data(),
			draw = UITooltipPasses.junk.draw
		})
	table.insert(pass_data.passes, #pass_data.passes + 1, {
			data = UITooltipPasses.advanced_input_helper_favorite.setup_data(),
			draw = UITooltipPasses.advanced_input_helper_favorite.draw
		})
	table.insert(pass_data.passes, #pass_data.passes + 1, {
			data = UITooltipPasses.advanced_input_helper_junk.setup_data(),
			draw = UITooltipPasses.advanced_input_helper_junk.draw
		})
	return pass_data
end)

local filter_operators = {
	["not"] = {
		4,
		1,
		function (op1)
			return not op1
		end
	},
	["<"] = {
		3,
		2,
		function (op1, op2)
			return op1 < op2
		end
	},
	[">"] = {
		3,
		2,
		function (op1, op2)
			return op2 < op1
		end
	},
	["<="] = {
		3,
		2,
		function (op1, op2)
			return op1 <= op2
		end
	},
	[">="] = {
		3,
		2,
		function (op1, op2)
			return op2 <= op1
		end
	},
	["~="] = {
		3,
		2,
		function (op1, op2)
			return op1 ~= op2
		end
	},
	["=="] = {
		3,
		2,
		function (op1, op2)
			return op1 == op2
		end
	},
	["and"] = {
		2,
		2,
		function (op1, op2)
			return op1 and op2
		end
	},
	["or"] = {
		1,
		2,
		function (op1, op2)
			return op1 or op2
		end
	}
}
local filter_macros = {
	is_favorite = function (item, backend_id)
		return mod.favs_table:contains(backend_id)
	end,
	item_key = function (item, backend_id)
		local item_data = item.data

		return item_data.key
	end,
	item_rarity = function (item, backend_id)
		local item_data = item.data
		local backend_items = Managers.backend:get_interface("items")
		local rarity = backend_items:get_item_rarity(backend_id)

		return rarity
	end,
	slot_type = function (item, backend_id)
		local item_data = item.data

		return item_data.slot_type
	end,
	item_type = function (item, backend_id)
		local item_data = item.data

		return item_data.item_type
	end,
	chest_category = function (item, backend_id)
		local item_data = item.data

		return item_data.chest_category
	end,
	trinket_as_hero = function (item, backend_id)
		local item_data = item.data

		if item_data.traits then
			for _, trait_name in ipairs(item_data.traits) do
				local trait_config = BuffTemplates[trait_name]
				local roll_dice_as_hero = trait_config.roll_dice_as_hero

				if roll_dice_as_hero then
					return true
				end
			end
		end

		return
	end,
	equipped_by_current_career = function (item, backend_id, params)
		local item_data = item.data
		local profile_synchronizer = Managers.state.network.profile_synchronizer
		local player = nil

		if params and params.player then
			player = params.player
		else
			player = Managers.player:local_player()
		end

		if not player then
			return false
		end

		local profile_index = player:profile_index()

		if not profile_index or profile_index == 0 then
			return false
		end

		local career_index = player:career_index()

		if not career_index or career_index == 0 then
			return false
		end

		local hero_data = SPProfiles[profile_index]
		local career_data = hero_data.careers[career_index]
		local career_name = career_data.name
		local backend_items = Managers.backend:get_interface("items")
		local career_names = backend_items:equipped_by(backend_id)

		return table.contains(career_names, career_name)
	end,
	is_equipped = function (item, backend_id)
		local item_data = item.data
		local backend_items = Managers.backend:get_interface("items")
		local career_names = backend_items:equipped_by(backend_id)

		if 0 < #career_names then
			return true
		end

		return false
	end,
	is_equipment_slot = function (item, backend_id)
		local item_data = item.data
		local is_slot = false

		for _, slot in ipairs(InventorySettings.equipment_slots) do
			if item_data.slot_type == slot.type then
				is_slot = true

				break
			end
		end

		return is_slot
	end,
	current_hero = function (item, backend_id)
		local item_data = item.data
		local profile_synchronizer = Managers.state.network.profile_synchronizer
		local player = Managers.player:local_player()
		local profile_index = profile_synchronizer:profile_by_peer(player:network_id(), player:local_player_id())
		local hero_data = SPProfiles[profile_index]
		local hero_name = hero_data.display_name

		return hero_name
	end,
	can_wield_by_current_career = function (item, backend_id)
		local item_data = item.data
		local profile_synchronizer = Managers.state.network.profile_synchronizer
		local player = Managers.player:local_player()
		local profile_index = player:profile_index()
		local career_index = player:career_index()
		local hero_data = SPProfiles[profile_index]
		local career_data = hero_data.careers[career_index]
		local career_name = career_data.name
		local item_can_wield = item_data.can_wield

		return table.contains(item_can_wield, career_name)
	end,
	can_wield_by_current_hero = function (item, backend_id)
		local item_data = item.data
		local profile_synchronizer = Managers.state.network.profile_synchronizer
		local player = Managers.player:local_player()
		local profile_index = player:profile_index()
		local career_index = player:career_index()
		local hero_data = SPProfiles[profile_index]
		local careers = hero_data.careers
		local item_can_wield = item_data.can_wield

		for career_index, career in ipairs(careers) do
			local career_name = career.name

			if table.contains(item_can_wield, career_name) then
				return true
			end
		end

		return false
	end,
	can_wield_bright_wizard = function (item, backend_id)
		local item_data = item.data
		local hero_name = "bright_wizard"
		local can_wield = item_data.can_wield

		return table.contains(can_wield, hero_name)
	end,
	can_wield_dwarf_ranger = function (item, backend_id)
		local item_data = item.data
		local hero_name = "dwarf_ranger"
		local can_wield = item_data.can_wield

		return table.contains(can_wield, hero_name)
	end,
	can_wield_empire_soldier = function (item, backend_id)
		local item_data = item.data
		local hero_name = "empire_soldier"
		local can_wield = item_data.can_wield

		return table.contains(can_wield, hero_name)
	end,
	can_wield_witch_hunter = function (item, backend_id)
		local item_data = item.data
		local hero_name = "witch_hunter"
		local can_wield = item_data.can_wield

		return table.contains(can_wield, hero_name)
	end,
	can_wield_wood_elf = function (item, backend_id)
		local item_data = item.data
		local hero_name = "wood_elf"
		local can_wield = item_data.can_wield

		return table.contains(can_wield, hero_name)
	end,
	player_owns_item_key = function (item, backend_id)
		local item_data = item.data
		local backend_items = Managers.backend:get_interface("items")
		local all_items = backend_items:get_all_backend_items()

		for backend_id, config in pairs(all_items) do
			if item_data.key == config.key then
				return true
			end
		end

		return false
	end,
	can_salvage = function (item, backend_id)
		local item_data = item.data
		local slot_type = item_data.slot_type

		if slot_type == "ranged" or slot_type == "melee" or slot_type == "ring" or slot_type == "necklace" or slot_type == "trinket" or slot_type == "hat" then
			local backend_items = Managers.backend:get_interface("items")
			local rarity = backend_items:get_item_rarity(backend_id)

			if rarity ~= "default" then
				local career_names = backend_items:equipped_by(backend_id)

				if #career_names == 0 then
					return true
				end
			end
		end

		return false
	end,
	has_properties = function (item, backend_id)
		if item.properties then
			return true
		end

		return false
	end,
	has_traits = function (item, backend_id)
		if item.traits then
			return true
		end

		return false
	end,
	has_applied_skin = function (item, backend_id)
		local item_data = item.data
		local slot_type = item_data.slot_type

		if item.skin and slot_type ~= "weapon_skin" then
			return true
		end

		return false
	end,
	can_apply_skin = function (item, backend_id)
		local item_data = item.data
		local slot_type = item_data.slot_type

		if (slot_type == "ranged" or slot_type == "melee") and not item.skin then
			local backend_items = Managers.backend:get_interface("items")
			local career_names = backend_items:equipped_by(backend_id)

			if #career_names == 0 then
				local weapon_skin_name = item_data.key .. "_skin"

				return backend_items:has_item(weapon_skin_name)
			end
		end

		return false
	end,
	can_upgrade = function (item, backend_id)
		local item_data = item.data
		local slot_type = item_data.slot_type

		if slot_type == "ranged" or slot_type == "melee" or slot_type == "ring" or slot_type == "necklace" or slot_type == "trinket" then
			local backend_items = Managers.backend:get_interface("items")
			local rarity = backend_items:get_item_rarity(backend_id)

			if rarity == "plentiful" or rarity == "common" or rarity == "rare" then
				return true
			end
		end

		return
	end,
	can_craft_with = function (item, backend_id)
		local item_data = item.data
		local slot_type = item_data.slot_type

		if slot_type == "ranged" or slot_type == "melee" or slot_type == "ring" or slot_type == "necklace" or slot_type == "trinket" then
			local backend_items = Managers.backend:get_interface("items")
			local rarity = backend_items:get_item_rarity(backend_id)

			if rarity == "default" then
				return true
			end
		end

		return
	end
}

local empty_params = {}
mod:hook_origin(BackendInterfaceCommon, "filter_items", function (self, items, filter_infix, params)
	local filter_postfix = BackendInterfaceCommon.filter_postfix_cache[filter_infix]

	if not filter_postfix then
		filter_postfix = self:_infix_to_postfix_item_filter(filter_infix)
		BackendInterfaceCommon.filter_postfix_cache[filter_infix] = filter_postfix
	end

	local item_master_list = ItemMasterList
	local stack = {}
	local passed = {}

	for backend_id, item in pairs(items) do
		local key = item.key
		local item_data = item_master_list[key]

		table.clear(stack)

		for i = 1, #filter_postfix, 1 do
			local token = filter_postfix[i]

			if filter_operators[token] then
				local num_params = filter_operators[token][2]
				local op_func = filter_operators[token][3]
				local op1 = table.remove(stack)

				if num_params == 1 then
					stack[#stack + 1] = op_func(op1)
				else
					local op2 = table.remove(stack)
					stack[#stack + 1] = op_func(op1, op2)
				end
			else
				local macro_func = filter_macros[token]

				if macro_func then
					stack[#stack + 1] = macro_func(item, backend_id, params or empty_params)
				else
					stack[#stack + 1] = token
				end
			end
		end

		if stack[1] == true then
			local item = table.clone(item)
			passed[#passed + 1] = item
		end
	end

	return passed
end)

-- sublime lua reformat loses its wits here
mod:hook_origin(BackendInterfaceCommon, "_infix_to_postfix_item_filter", function (self, filter_infix)
	local output = {}
	local stack = {}

	for token in string.gmatch(filter_infix, "%S+") do
		if filter_operators[token] then
			while 0 < #stack do
				local top = stack[#stack]

				if filter_operators[top] and filter_operators[token][1] <= filter_operators[top][1] then
					output[#output + 1] = table.remove(stack)
				else
					break
				end
			end

			stack[#stack + 1] = token

		elseif token == "(" then
			stack[#stack + 1] = "("
			elseif token == ")" then
				while 0 < #stack do
					local top = stack[#stack]

					if top ~= "(" then
						output[#output + 1] = table.remove(stack)
					else
						stack[#stack] = nil

						break
					end
				end
			else
				output[#output + 1] = token
			end
		end

		while 0 < #stack do
			output[#output + 1] = table.remove(stack)
		end

		for i = 1, #output, 1 do
			local token = output[i]

			if token == "true" then
				output[i] = true
			elseif token == "false" then
				output[i] = false
			elseif tonumber(token) then
				output[i] = tonumber(token)
			end
		end

	return output
end)