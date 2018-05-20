local mod = get_mod("CustomHUD")

local pl = require'pl.import_into'()
local tablex = require'pl.tablex'

-- luacheck: globals UIRenderer ScriptUnit Managers BackendUtils UIWidget UnitFrameUI
-- luacheck: globals UILayer UISceneGraph EquipmentUI ButtonTextureByName Colors
-- luacheck: globals ChatGui Vector2 Gui Color unpack
-- luacheck: globals math local_require World

mod.custom_player_widget = nil

-- DEBUG
local debug_favs = true
local RETAINED_MODE_ENABLED = not debug_favs

local my_scale_x = 0.45

local SIZE_X = 1920
local SIZE_Y = 1080

-- local player_offset_x = 115
local player_offset_x = SIZE_X/2-100
local player_offset_y = 20

local global_offset_x = 0---750
local global_offset_y = -5

local ability_ui_offset_x = 0
local ability_ui_offset_y = -28 - 8

-- on top of teammates
-- local global_offset_x = -750 -350-8
-- local global_offset_y = 0 +25

-- next to each other
-- local global_offset_x = -750 -350-8+213
-- local global_offset_y = 0 +25-20

local player_ammo_bar_offset_y = -10

local ammo_bar_height = 5
local ult_bar_height = 5

mod.unit_frame_ui_scenegraph_definition = {
	screen = {
		scale = "fit",
		position = {
			0,
			0,
			UILayer.hud
		},
		size = {
			SIZE_X,
			SIZE_Y
		}
	},
	pivot = {
		vertical_alignment = "bottom",
		parent = "screen",
		horizontal_alignment = "left",
		position = {
			70,
			0,
			1
		},
		size = {
			0,
			0
		}
	},
	portrait_pivot = {
		vertical_alignment = "center",
		parent = "pivot",
		horizontal_alignment = "center",
		position = {
			0,
			0,
			0
		},
		size = {
			0,
			0
		}
	}
}

local portrait_scale = 1
local slot_scale = 1
local health_bar_size_fraction = 2
local default_hp_bar_size_x = 400
local default_hp_bar_size_y = 17
local health_bar_size = {
	default_hp_bar_size_x*my_scale_x,
	default_hp_bar_size_y
}
local player_health_bar_size = {
	health_bar_size[1]-1,
	health_bar_size[2]
}
local health_bar_offset = {
	-(health_bar_size[1]/2),
	health_bar_size_fraction*-25,
	0
}

local others_items_offsets = {
	-103,
	-0,
	0
}

mod.create_dynamic_loadout_widget = function(self)
	return {
		scenegraph_id = "pivot",
		element = {
			passes = {
				{
					pass_type = "texture",
					style_id = "item_slot_1",
					texture_id = "item_slot_1",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "item_slot_bg_1",
					texture_id = "item_slot_bg_1",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "item_slot_frame_1",
					texture_id = "slot_frame",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "item_slot_highlight_1",
					texture_id = "item_slot_highlight",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "item_slot_2",
					texture_id = "item_slot_2",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "item_slot_bg_2",
					texture_id = "item_slot_bg_2",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "item_slot_frame_2",
					texture_id = "slot_frame",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "item_slot_highlight_2",
					texture_id = "item_slot_highlight",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "item_slot_3",
					texture_id = "item_slot_3",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "item_slot_bg_3",
					texture_id = "item_slot_bg_3",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "item_slot_frame_3",
					texture_id = "slot_frame",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "item_slot_highlight_3",
					texture_id = "item_slot_highlight",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				}
			}
		},
		content = {
			item_slot_2 = "icons_placeholder",
			item_slot_1 = "icons_placeholder",
			item_slot_bg_2 = "hud_inventory_slot_bg_small_01",
			draw_health_bar = true,
			item_slot_bg_3 = "hud_inventory_slot_bg_small_01",
			item_slot_highlight = "hud_inventory_slot_small_pickup",
			slot_frame = "hud_inventory_slot_small",
			item_slot_bg_1 = "hud_inventory_slot_bg_small_01",
			item_slot_3 = "icons_placeholder"
		},
		style = {
			item_slot_bg_1 = {
				size = {
					slot_scale*29,
					slot_scale*29
				},
				offset = {
					-35,
					0,
					7
				},
				color = {
					255,
					255,
					255,
					255
				}
			},
			item_slot_frame_1 = {
				size = {
					slot_scale*29,
					slot_scale*29
				},
				offset = {
					-35,
					0,
					11
				},
				color = {
					255,
					255,
					255,
					255
				}
			},
			item_slot_1 = {
				size = {
					25,
					25
				},
				offset = {
					-32.5,
					2,
					8
				},
				color = {
					255,
					255,
					255,
					255
				}
			},
			item_slot_highlight_1 = {
				size = {
					slot_scale*29,
					slot_scale*29
				},
				offset = {
					-35,
					0,
					10
				},
				color = {
					0,
					255,
					255,
					255
				}
			},
			item_slot_bg_2 = {
				size = {
					slot_scale*29,
					slot_scale*29
				},
				offset = {
					0,
					0,
					7
				},
				color = {
					255,
					255,
					255,
					255
				}
			},
			item_slot_frame_2 = {
				size = {
					slot_scale*29,
					slot_scale*29
				},
				offset = {
					0,
					0,
					11
				},
				color = {
					255,
					255,
					255,
					255
				}
			},
			item_slot_2 = {
				size = {
					25,
					25
				},
				offset = {
					2.5,
					2,
					8
				},
				color = {
					255,
					255,
					255,
					255
				}
			},
			item_slot_highlight_2 = {
				size = {
					slot_scale*29,
					slot_scale*29
				},
				offset = {
					0,
					0,
					10
				},
				color = {
					0,
					255,
					255,
					255
				}
			},
			item_slot_bg_3 = {
				size = {
					slot_scale*29,
					slot_scale*29
				},
				offset = {
					35,
					0,
					7
				},
				color = {
					255,
					255,
					255,
					255
				}
			},
			item_slot_frame_3 = {
				size = {
					slot_scale*29,
					slot_scale*29
				},
				offset = {
					35,
					0,
					11
				},
				color = {
					255,
					255,
					255,
					255
				}
			},
			item_slot_3 = {
				size = {
					25,
					25
				},
				offset = {
					37.5,
					2,
					8
				},
				color = {
					255,
					255,
					255,
					255
				}
			},
			item_slot_highlight_3 = {
				size = {
					slot_scale*29,
					slot_scale*29
				},
				offset = {
					35,
					0,
					10
				},
				color = {
					0,
					255,
					255,
					255
				}
			}
		},
		offset = {
			-15 + 35 + others_items_offsets[1],
			health_bar_offset[2] - 96 + 65 + others_items_offsets[2],
			0 + others_items_offsets[3]
		}
	}
end

mod.create_static_widget = function(self, health_bar_size, health_bar_offset)
	return {
		scenegraph_id = "pivot",
		element = {
			passes = {
				{
					pass_type = "texture",
					style_id = "character_portrait",
					texture_id = "character_portrait",
					retained_mode = RETAINED_MODE_ENABLED
				},
				{
					style_id = "player_level",
					pass_type = "text",
					text_id = "player_level",
					retained_mode = RETAINED_MODE_ENABLED
				},
				{
					pass_type = "texture",
					style_id = "host_icon",
					texture_id = "host_icon",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.is_host
					end
				},
				{
					style_id = "player_name",
					pass_type = "text",
					text_id = "player_name",
					retained_mode = RETAINED_MODE_ENABLED
				},
				{
					style_id = "player_name_shadow",
					pass_type = "text",
					text_id = "player_name",
					retained_mode = RETAINED_MODE_ENABLED
				},
				{
					pass_type = "texture",
					style_id = "hp_bar_bg",
					texture_id = "hp_bar_bg",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return true
					end
				},
				{
					pass_type = "texture",
					style_id = "hp_bar_fg",
					texture_id = "hp_bar_fg",
					retained_mode = RETAINED_MODE_ENABLED
				},
				{
					pass_type = "texture",
					style_id = "ammo_bar_bg",
					texture_id = "ammo_bar_bg",
					retained_mode = RETAINED_MODE_ENABLED
				},
				{
					pass_type = "rect",
					style_id = "hp_bar_rect",
					retained_mode = RETAINED_MODE_ENABLED,
					-- content_check_function = function(content) return content.show end,
				},
				{
					pass_type = "rect",
					style_id = "hp_bar_rect2",
					retained_mode = RETAINED_MODE_ENABLED,
					-- content_check_function = function(content) return content.show end,
				},
				{
					pass_type = "rect",
					style_id = "ammo_bar_rect",
					retained_mode = RETAINED_MODE_ENABLED,
					-- content_check_function = function(content) return content.show end,
				},
				{
					pass_type = "rect",
					style_id = "ammo_bar_rect2",
					retained_mode = RETAINED_MODE_ENABLED,
					-- content_check_function = function(content) return content.show end,
				},
				{
					pass_type = "rect",
					style_id = "ult_bar_rect",
					retained_mode = RETAINED_MODE_ENABLED,
					-- content_check_function = function(content) return content.show end,
				},
				{
					pass_type = "rect",
					style_id = "ult_bar_rect2",
					retained_mode = RETAINED_MODE_ENABLED,
					-- content_check_function = function(content) return content.show end,
				},
				{
					style_id = "ability_bar",
					pass_type = "texture_uv",
					content_id = "ability_bar",
					retained_mode = RETAINED_MODE_ENABLED,
					content_change_function = function (content, style)
						local ability_progress = content.bar_value
						local size = style.size
						local uvs = content.uvs
						local offset = style.offset
						local bar_length = health_bar_size[1]
						uvs[2][2] = ability_progress
						size[1] = bar_length*ability_progress
					end
				},
			}
		},
		content = {
			character_portrait = "unit_frame_portrait_default",
			player_name = "n/a",
			host_icon = "host_icon",
			hp_bar_bg = "hud_teammate_hp_bar_bg",
			is_host = false,
			player_level = "",
			hp_bar_fg = "hud_teammate_hp_bar_frame",
			ammo_bar_bg = "hud_teammate_ammo_bar_bg",
			ability_bar = {
				bar_value = 1,
				texture_id = "hud_player_ability_bar_fill",
				uvs = {
					{
						0,
						0
					},
					{
						1,
						1
					}
				}
			},
		},
		style = {
			character_portrait = {
				size = {
					portrait_scale*86,
					portrait_scale*108
				},
				offset = {
					portrait_scale*-43,
					portrait_scale*-54 + portrait_scale*55,
					0
				},
				color = {
					255,
					255,
					255,
					255
				}
			},
			host_icon = {
				size = {
					18,
					14
				},
				offset = {
					-50,
					10,
					15
				},
				color = {
					150,
					255,
					255,
					255
				}
			},
			player_level = {
				vertical_alignment = "top",
				font_type = "hell_shark",
				font_size = 14,
				-- horizontal_alignment = "center",
				horizontal_alignment = "left",
				text_color = Colors.get_table("cheeseburger"),
				offset = {
					health_bar_offset[1],
					health_bar_offset[2] - 130,
					health_bar_offset[3] + 15
				}
			},
			player_name = {
				vertical_alignment = "bottom",
				font_type = "hell_shark",
				font_size = 18,
				horizontal_alignment = "center",
				text_color = Colors.get_table("white"),
				offset = {
					0,
					portrait_scale*110,
					health_bar_offset[3] + 15
				}
			},
			player_name_shadow = {
				vertical_alignment = "bottom",
				font_type = "hell_shark",
				font_size = 18,
				horizontal_alignment = "center",
				text_color = Colors.get_table("black"),
				offset = {
					2,
					portrait_scale*110 - 2,
					health_bar_offset[3] + 14
				}
			},
			hp_bar_bg = {
				size = {
					0,
					0,
				},
				offset = {
					(health_bar_offset[1])-3,
					(health_bar_offset[2] + health_bar_size[2]/2) - 12,
					health_bar_offset[3] + 15
				},
				color = {
					255,
					255,
					255,
					255
				}
			},
			hp_bar_fg = {
				size = {
					0,
					0,
				},
				offset = {
					(health_bar_offset[1])-3,
					(health_bar_offset[2] + health_bar_size[2]/2) - 12,
					health_bar_offset[3] + 15
				},
				color = {
					255,
					255,
					255,
					255
				}
			},
			hp_bar_rect = {
				offset = {health_bar_offset[1]-2, health_bar_offset[2]-2, 3},
				size = {
					health_bar_size[1]+4,
					health_bar_size[2]+4
				},
				color = {255, 105, 105, 105},
			},
			hp_bar_rect2 = {
				offset = {health_bar_offset[1]-1, health_bar_offset[2]-1, 4},
				size = {
					health_bar_size[1]+2,
					health_bar_size[2]+2
				},
				color = {255, 0, 0, 0},
			},
			ammo_bar_rect = {
				offset = {health_bar_offset[1]-1-1, health_bar_offset[2]-2-8, 0},
				size = { health_bar_size[1]+4, ammo_bar_height+4 },
				color = {255, 105, 105, 105},
			},
			ammo_bar_rect2 = {
				offset = {
					health_bar_offset[1]-1,
					health_bar_offset[2]-1-8,
					1
				},
				size = { health_bar_size[1]+2, ammo_bar_height+2 },
				color = {255, 0, 0, 0},
			},
			ult_bar_rect = {
				offset = {
					health_bar_offset[1]-2,
					health_bar_offset[2]-2-ult_bar_height-ammo_bar_height-6,
					0
				},
				size = {
					health_bar_size[1]+4,
					ult_bar_height + 4
				},
				color = {255, 105, 105, 105},
			},
			ult_bar_rect2 = {
				offset = {
					health_bar_offset[1]-1,
					health_bar_offset[2]-1-ult_bar_height-ammo_bar_height-6,
					1
				},
				size = {
					health_bar_size[1] + 2,
					ult_bar_height + 2,
				},
				color = {255, 0, 0, 0},
			},
			ability_bar = {
				size = {
					health_bar_size[1],
					ult_bar_height
				},
				color = {
					255,
					255,
					255,
					255
				},
				offset = {
					health_bar_offset[1],
					health_bar_offset[2]-ult_bar_height-ammo_bar_height-6,
					2
				}
			},
			ammo_bar_bg = {
				size = {
					0,
					0,
				},
				offset = {
					(health_bar_offset[1])-3 +3,
					(health_bar_offset[2] + health_bar_size[2]/2) - 12 - 5,
					health_bar_offset[3] + 15
				},
				color = {
					255,
					255,
					255,
					255
				}
			}
		},
		offset = {
			0,
			portrait_scale*-55,
			0
		}
	}
end

mod.create_dynamic_portait_widget = function(self, health_bar_size, health_bar_offset)
	return {
		scenegraph_id = "pivot",
		element = {
			passes = {
				{
					pass_type = "texture",
					style_id = "portrait_icon",
					texture_id = "portrait_icon",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.display_portrait_icon
					end
				},
				{
					pass_type = "texture",
					style_id = "talk_indicator_highlight",
					texture_id = "talk_indicator_highlight",
					retained_mode = RETAINED_MODE_ENABLED
				},
				{
					pass_type = "rotated_texture",
					style_id = "connecting_icon",
					texture_id = "connecting_icon",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.connecting
					end
				},
				{
					style_id = "ammo_bar",
					pass_type = "texture_uv",
					content_id = "ammo_bar",
					retained_mode = RETAINED_MODE_ENABLED,
					content_change_function = function (content, style)
						local ammo_progress = content.bar_value
						local size = style.size
						local uvs = content.uvs
						local offset = style.offset
						local bar_length = health_bar_size[1]
						uvs[2][2] = ammo_progress
						size[1] = bar_length*ammo_progress

						return
					end
				},
			}
		},
		content = {
			display_portrait_overlay = false,
			connecting = false,
			display_portrait_icon = false,
			connecting_icon = "matchmaking_connecting_icon",
			bar_start_side = "left",
			portrait_icon = "status_icon_needs_assist",
			talk_indicator_highlight = "speaking_icon",
			ammo_bar = {
				bar_value = 1,
				texture_id = "hud_teammate_ammo_bar_fill",
				uvs = {
					{
						0,
						0
					},
					{
						1,
						1
					}
				}
			}
		},
		style = {
			talk_indicator_highlight = {
				size = {
					40,
					30
				},
				offset = {
					-65,
					55,
					3
				},
				color = {
					0,
					255,
					255,
					255
				}
			},
			connecting_icon = {
				angle = 0,
				size = {
					53,
					53
				},
				offset = {
					-25,
					34,
					15
				},
				color = {
					255,
					255,
					255,
					255
				},
				pivot = {
					27,
					27
				}
			},
			portrait_icon = {
				size = {
					portrait_scale*86,
					portrait_scale*108
				},
				offset = {
					-(portrait_scale*86)/2,
					0,
					1
				},
				color = {
					150,
					255,
					255,
					255
				}
			},
			ammo_bar = {
				size = {
					health_bar_size[1],
					5
				},
				offset = {
					(health_bar_offset[1] -3) +3,
					(health_bar_offset[2] + health_bar_size[2]/2) - 12 - 5,
					--health_bar_offset[2] - 9 - 50,
					health_bar_offset[3] + 18
				},
				color = {
					255,
					255,
					255,
					255
				}
			}
		},
		offset = {
			0,
			portrait_scale*-55,
			0
		}
	}
end

mod.create_dynamic_health_widget = function(self, health_bar_size, health_bar_offset)
	return {
		scenegraph_id = "pivot",
		element = {
			passes = {
				{
					pass_type = "texture",
					style_id = "hp_bar_highlight",
					texture_id = "hp_bar_highlight",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content, style)
						return not content.has_shield
					end
				},
				{
					style_id = "grimoire_debuff_divider",
					texture_id = "grimoire_debuff_divider",
					pass_type = "texture",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.hp_bar.draw_health_bar
					end,
					content_change_function = function (content, style)
						local hp_bar_content = content.hp_bar
						local internal_bar_value = hp_bar_content.internal_bar_value
						local actual_active_percentage = content.actual_active_percentage or 1
						local grim_progress = math.max(internal_bar_value, actual_active_percentage)
						local offset = style.offset
						offset[1] = health_bar_offset[1] + health_bar_size[1]*grim_progress

						return
					end
				},
				{
					pass_type = "gradient_mask_texture",
					style_id = "hp_bar",
					texture_id = "texture_id",
					content_id = "hp_bar",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "gradient_mask_texture",
					style_id = "total_health_bar",
					texture_id = "texture_id",
					content_id = "total_health_bar",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					style_id = "grimoire_bar",
					pass_type = "texture_uv",
					content_id = "grimoire_bar",
					retained_mode = RETAINED_MODE_ENABLED,
					content_change_function = function (content, style)
						local parent_content = content.parent
						local hp_bar_content = parent_content.hp_bar
						local internal_bar_value = hp_bar_content.internal_bar_value
						local actual_active_percentage = parent_content.actual_active_percentage or 1
						local grim_progress = math.max(internal_bar_value, actual_active_percentage)
						local size = style.size
						local uvs = content.uvs
						local offset = style.offset
						local bar_length = health_bar_size[1] - 1
						uvs[1][1] = grim_progress
						size[1] = bar_length*(grim_progress - 1)
						-- EchoConsole(tostring(bar_length*grim_progress))
						offset[1] = health_bar_offset[1] + 2*health_bar_size_fraction + bar_length*grim_progress - size[1]

						return
					end
				},
				{
					pass_type = "texture",
					style_id = "hp_bar",
					texture_id = "hp_bar_mask",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.hp_bar.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "portrait_icon",
					texture_id = "portrait_icon",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.display_portrait_icon
					end
				}
			}
		},
		content = {
			grimoire_debuff_divider = "hud_teammate_hp_bar_grim_divider",
			hp_bar_highlight = "hud_teammate_hp_bar_highlight",
			bar_start_side = "left",
			hp_bar_mask = "teammate_hp_bar_mask",
			hp_bar = {
				bar_value = 1,
				internal_bar_value = 0,
				texture_id = "teammate_hp_bar_color_tint_1",
				draw_health_bar = true
			},
			total_health_bar = {
				bar_value = 1,
				internal_bar_value = 0,
				texture_id = "teammate_hp_bar_1",
				draw_health_bar = true
			},
			grimoire_bar = {
				texture_id = "hud_panel_hp_bar_bg_grimoire",
				uvs = {
					{
						0,
						0
					},
					{
						1,
						1
					}
				}
			}
		},
		style = {
			total_health_bar = {
				gradient_threshold = 1,
				size = {
					health_bar_size[1],
					health_bar_size[2]
				},
				color = {
					255,
					255,
					255,
					255
				},
				offset = {
					health_bar_offset[1],
					health_bar_offset[2],
					health_bar_offset[3] + 17
				}
			},
			hp_bar = {
				gradient_threshold = 1,
				size = {
					health_bar_size[1],
					health_bar_size[2]
				},
				color = {
					255,
					255,
					255,
					255
				},
				offset = {
					health_bar_offset[1],
					health_bar_offset[2],
					health_bar_offset[3] + 18
				}
			},
			grimoire_bar = {
				size = {
					health_bar_size[1],
					health_bar_size[2]
				},
				color = {
					255,
					255,
					255,
					255
				},
				offset = {
					health_bar_offset[1],
					health_bar_offset[2],
					health_bar_offset[3] + 16
				}
			},
			ammo_bar = {
				size = {
					92,
					5
				},
				offset = {
					(health_bar_offset[1] + health_bar_size[1]/2) - 46,
					health_bar_offset[2] - 9,
					health_bar_offset[3] + 18
				},
				color = {
					255,
					255,
					255,
					255
				}
			},
			grimoire_debuff_divider = {
				masked = true,
				size = {
					3,
					28
				},
				color = {
					255,
					255,
					255,
					255
				},
				offset = {
					health_bar_offset[1],
					health_bar_offset[2],
					23
				}
			},
			hp_bar_highlight = {
				size = {
					100,
					17
				},
				offset = {
					(health_bar_offset[1] + health_bar_size[1]/2) - 50,
					health_bar_offset[2] - 7,
					health_bar_offset[3] + 19
				},
				color = {
					0,
					255,
					255,
					255
				}
			}
		},
		offset = {
			0,
			portrait_scale*-55,
			0
		}
	}
end

local settings = {
	hp_bar = {
		z = -8,
		x = -232,
		y = 10
	},
	ability_bar = {
		z = -8,
		x = -224,
		y = 33
	}
}
local settings = {
	hp_bar = {
		z = 0,
		x = -1,
		y = 69
	},
	ability_bar = {
		z = 0,
		x = -1+8,
		y = 92
	}
}
local portrait_area = {
	86,
	108
}
mod.create_player_dynamic_health_widget = function(self, player_health_bar_size)
	return {
		scenegraph_id = "pivot",
		element = {
			passes = {
				{
					pass_type = "texture",
					style_id = "hp_bar_highlight",
					texture_id = "hp_bar_highlight",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content, style)
						return not content.has_shield
					end
				},
				{
					style_id = "grimoire_debuff_divider",
					texture_id = "grimoire_debuff_divider",
					pass_type = "texture",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						local hp_bar_content = content.hp_bar
						local internal_bar_value = hp_bar_content.internal_bar_value
						local actual_active_percentage = content.actual_active_percentage or 1
						local grim_progress = math.max(internal_bar_value, actual_active_percentage)

						return grim_progress < 1
					end,
					content_change_function = function (content, style)
						local hp_bar_content = content.hp_bar
						local internal_bar_value = hp_bar_content.internal_bar_value
						local actual_active_percentage = content.actual_active_percentage or 1
						local grim_progress = math.max(internal_bar_value, actual_active_percentage)
						local offset = style.offset
						offset[1] = settings.hp_bar.x - 7*my_scale_x + grim_progress * player_health_bar_size[1]
					end
				},
				{
					pass_type = "gradient_mask_texture",
					style_id = "hp_bar",
					texture_id = "texture_id",
					content_id = "hp_bar",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "gradient_mask_texture",
					style_id = "total_health_bar",
					texture_id = "texture_id",
					content_id = "total_health_bar",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					style_id = "grimoire_bar",
					pass_type = "texture_uv",
					content_id = "grimoire_bar",
					retained_mode = RETAINED_MODE_ENABLED,
					content_change_function = function (content, style)
						local parent_content = content.parent
						local hp_bar_content = parent_content.hp_bar
						local internal_bar_value = hp_bar_content.internal_bar_value
						local actual_active_percentage = parent_content.actual_active_percentage or 1
						local grim_progress = math.max(internal_bar_value, actual_active_percentage)
						local size = style.size
						local uvs = content.uvs
						local offset = style.offset
						local bar_length = player_health_bar_size[1]
						uvs[1][1] = grim_progress
						size[1] = bar_length*(grim_progress - 1)
						offset[1] = settings.hp_bar.x + grim_progress * player_health_bar_size[1] - size[1]
					end
				}
			}
		},
		content = {
			grimoire_debuff_divider = "hud_player_hp_bar_grim_divider",
			hp_bar_highlight = "hud_player_hp_bar_highlight",
			bar_start_side = "left",
			hp_bar = {
				bar_value = 1,
				internal_bar_value = 0,
				texture_id = "player_hp_bar_color_tint",
				draw_health_bar = true
			},
			total_health_bar = {
				bar_value = 1,
				internal_bar_value = 0,
				texture_id = "player_hp_bar",
				draw_health_bar = true
			},
			grimoire_bar = {
				texture_id = "hud_panel_hp_bar_bg_grimoire",
				uvs = {
					{
						0,
						0
					},
					{
						1,
						1
					}
				}
			}
		},
		style = {
			total_health_bar = {
				gradient_threshold = 1,
				size = {
					player_health_bar_size[1],
					player_health_bar_size[2] + 1
				},
				color = {
					255,
					255,
					255,
					255
				},
				offset = {
					settings.hp_bar.x,
					settings.hp_bar.y,
					settings.hp_bar.z + 2
				}
			},
			hp_bar = {
				gradient_threshold = 1,
				size = {
					player_health_bar_size[1],
					player_health_bar_size[2] + 1
				},
				color = {
					255,
					255,
					255,
					255
				},
				offset = {
					settings.hp_bar.x,
					settings.hp_bar.y,
					settings.hp_bar.z + 3
				}
			},
			grimoire_bar = {
				size = {
					player_health_bar_size[1],
					player_health_bar_size[2] + 1
				},
				color = {
					255,
					255,
					255,
					255
				},
				offset = {
					settings.hp_bar.x,
					settings.hp_bar.y,
					settings.hp_bar.z + 1
				}
			},
			grimoire_debuff_divider = {
				size = {
					21*my_scale_x,
					36
				},
				color = {
					255,
					255,
					255,
					255
				},
				offset = {
					settings.hp_bar.x + 10,
					settings.hp_bar.y - 8,
					settings.hp_bar.z + 20
				}
			},
			hp_bar_highlight = {
				size = {
					player_health_bar_size[1],
					30
				},
				offset = {
					settings.hp_bar.x,
					settings.hp_bar.y - 4,
					settings.hp_bar.z + 5
				},
				color = {
					0,
					255,
					255,
					255
				}
			}
		},
		offset = {
			player_offset_x + global_offset_x,
			player_offset_y + global_offset_y,
			0
		}
	}
end

mod.create_dynamic_ability_widget = function(self, health_bar_size)
	return {
		scenegraph_id = "pivot",
		element = {
			passes = {
				{
					style_id = "ability_bar",
					pass_type = "texture_uv",
					content_id = "ability_bar",
					retained_mode = RETAINED_MODE_ENABLED,
					content_change_function = function (content, style)
						local ability_progress = content.bar_value
						-- EchoConsole(tostring(ability_progress))
						local size = style.size
						local uvs = content.uvs
						local offset = style.offset
						local bar_length = health_bar_size[1] + 1
						uvs[2][2] = ability_progress
						size[1] = bar_length*ability_progress - 1
					end
				}
			}
		},
		content = {
			bar_start_side = "left",
			ability_bar = {
				bar_value = 1,
				texture_id = "hud_player_ability_bar_fill",
				uvs = {
					{
						0,
						0
					},
					{
						1,
						1
					}
				}
			}
		},
		style = {
			ability_bar = {
				size = {
					health_bar_size[1] - 1,
					5
				},
				color = {
					255,
					255,
					255,
					255
				},
				offset = {
					settings.ability_bar.x,
					settings.ability_bar.y,
					settings.ability_bar.z + 1
				}
			}
		},
		offset = {
			player_offset_x-8 + global_offset_x + ability_ui_offset_x,
			player_offset_y-3 + global_offset_y + ability_ui_offset_y,
			0
		}
	}
end

local function get_player_hp_bar_size()
	local hp_scale = 1
	local player_unit = Managers.player:local_player().player_unit
	if player_unit and Unit.alive(player_unit) then
		local health_system = ScriptUnit.extension(player_unit, "health_system")
		hp_scale = health_system:get_max_health() / 100
	end

	local health_bar_size = {
		default_hp_bar_size_x*my_scale_x*hp_scale,
		17
	}

	return health_bar_size
end

local function get_hp_bar_size_and_offset(player_unit)
	local hp_scale = 1
	if player_unit and Unit.alive(player_unit) then
		local health_system = ScriptUnit.extension(player_unit, "health_system")
		hp_scale = health_system:get_max_health() / 100
	end

	local health_bar_size = {
		default_hp_bar_size_x*my_scale_x*hp_scale,
		17
	}
	local health_bar_offset = {
		-115,
		health_bar_size_fraction*-25,
		0
	}

	return health_bar_size, health_bar_offset
end

mod:hook("UnitFrameUI._create_ui_elements", function (func, self, frame_index)
	self._frame_index = frame_index

	if self._frame_index then
		self.definitions.scenegraph_definition = mod.unit_frame_ui_scenegraph_definition
	end

	func(self, frame_index)

	if self._frame_index then
		mod:pcall(function()
			if self._default_widgets then
				UIWidget.destroy(self.ui_renderer, self._default_widgets.default_dynamic)
				UIWidget.destroy(self.ui_renderer, self._default_widgets.default_static)
				UIWidget.destroy(self.ui_renderer, self._health_widgets.health_dynamic)
				UIWidget.destroy(self.ui_renderer, self._equipment_widgets.loadout_dynamic)
			end

			local player_unit = Managers.player:local_player().player_unit
			local health_bar_size, health_bar_offset = get_hp_bar_size_and_offset(player_unit)

			self._mod_health_bar_size_cached = health_bar_size

			self._default_widgets = {
				default_dynamic = UIWidget.init(mod:create_dynamic_portait_widget(health_bar_size, health_bar_offset)),
				default_static = UIWidget.init(mod:create_static_widget(health_bar_size, health_bar_offset))
			}
			self._health_widgets = {
				health_dynamic = UIWidget.init(mod:create_dynamic_health_widget(health_bar_size, health_bar_offset))
			}
			self._equipment_widgets.loadout_dynamic = UIWidget.init(mod:create_dynamic_loadout_widget())

			self._widgets.default_dynamic = self._default_widgets.default_dynamic
			self._widgets.default_static = self._default_widgets.default_static
			self._widgets.health_dynamic = self._health_widgets.health_dynamic
			self._widgets.loadout_dynamic = self._equipment_widgets.loadout_dynamic

			UIRenderer.clear_scenegraph_queue(self.ui_renderer)

			self.slot_equip_animations = {}
			self.bar_animations = {}

			self:reset()

			if self._frame_index then
				self:_widget_by_name("health_dynamic").content.hp_bar.texture_id = "teammate_hp_bar_color_tint_" .. self._frame_index
				self:_widget_by_name("health_dynamic").content.total_health_bar.texture_id = "teammate_hp_bar_" .. self._frame_index
			end

			self:_set_widget_dirty(self._default_widgets.default_dynamic)
			self:_set_widget_dirty(self._default_widgets.default_static)
			self:_set_widget_dirty(self._health_widgets.health_dynamic)
			self:_set_widget_dirty(self._equipment_widgets.loadout_dynamic)

			-- self:set_visible(true)
			self:set_dirty()
		end)
	else
		mod:pcall(function()
			if self._health_widgets then
				UIWidget.destroy(self.ui_renderer, self._health_widgets.health_dynamic)
				UIWidget.destroy(self.ui_renderer, self._ability_widgets.ability_dynamic)
			end

			local health_bar_size = get_player_hp_bar_size()
			self._mod_health_bar_size_cached = health_bar_size

			self._health_widgets = {
				health_dynamic = UIWidget.init(mod:create_player_dynamic_health_widget(health_bar_size))
			}
			self._ability_widgets = {
				ability_dynamic = UIWidget.init(mod:create_dynamic_ability_widget(health_bar_size))
			}

			self._widgets.health_dynamic = self._health_widgets.health_dynamic
			self._widgets.ability_dynamic = self._ability_widgets.ability_dynamic

			self:_set_widget_dirty(self._default_widgets.default_dynamic)
			self:_set_widget_dirty(self._default_widgets.default_static)
			self:_set_widget_dirty(self._health_widgets.health_dynamic)
			self:_set_widget_dirty(self._ability_widgets.ability_dynamic)

			self:set_visible(true)
			self:set_dirty()
		end)
	end
end)

mod:hook("UnitFrameUI.set_inventory_slot_data", function (func, self, ...)
	return func(self, ...)
end)

UnitFrameUI.customhud_update = function (self, is_wounded)
	-- local function set_level_and_name_text_color(color)
	-- 	self._other_players_widget.style.custom_player_name.text_color = color
	-- 	self._other_players_widget.style.custom_player_level.text_color = color
	-- 	unit_frame_ui._default_widgets.default_static.content.ability_bar.bar_value
	-- end
	mod:pcall(function()
		-- is_wounded= true
		if self._frame_index then
			-- set_level_and_name_text_color(Colors.color_definitions.white)
			self._default_widgets.default_static.style.hp_bar_rect.color = is_wounded and {255, 255, 255, 255} or {255, 105, 105, 105}
			-- self._default_widgets.default_static.style.hp_bar_rect2.color = is_wounded and {255, 255, 255, 255} or {255, 0, 0, 0}
			self._default_widgets.default_static.style.ult_bar_rect.color = is_wounded and {255, 255, 255, 255} or {255, 105, 105, 105}
			self._default_widgets.default_static.style.ammo_bar_rect.color = is_wounded and {255, 255, 255, 255} or {255, 105, 105, 105}
		else
			if mod.custom_player_widget then
				mod.custom_player_widget.style.hp_bar_rect.color = is_wounded and {255, 255, 255, 255} or {255, 105, 105, 105}
				-- mod.custom_player_widget.style.hp_bar_rect2.color = is_wounded and {255, 255, 255, 255} or {255, 0, 0, 0}
				mod.custom_player_widget.style.ult_bar_rect.color = is_wounded and {255, 255, 255, 255} or {255, 105, 105, 105}
				mod.custom_player_widget.style.ammo_bar_rect.color = is_wounded and {255, 255, 255, 255} or {255, 105, 105, 105}
			end
		end
	end)
end

--- Update the ability_bar progress for other players.
mod:hook("UnitFrameUI.set_ability_percentage", function (func, self, ability_percent)
	mod:pcall(function()
		if self._frame_index then
			self._default_widgets.default_static.content.ability_bar.bar_value = ability_percent
			-- EchoConsole(tostring(ability_percent))
		end
	end)
	return func(self, ability_percent)
end)

mod:hook("UnitFramesHandler._sync_player_stats", function (func, self, unit_frame)
	local is_wounded = false
	local unit_frame_ui = unit_frame.widget

	mod:pcall(function()
		local player_data = unit_frame.player_data
		local player_unit = player_data.player_unit

		local go_id = Managers.state.unit_storage:go_id(player_unit)
		local network_manager = Managers.state.network
		local game = network_manager:game()
		if game and go_id then
			-- if not unit_frame_ui._frame_index then
				-- pout(GameSession.game_object_field(game, go_id, "ability_percentage") or 0, go_id)
			-- end
		end

		if player_data and player_data.player_unit and Unit.alive(player_unit) then
			if player_data.extensions then
				is_wounded = player_data.extensions.status:is_wounded()
			end
		end
	end)

	local original_set_portrait_status = UnitFrameUI.set_portrait_status
	UnitFrameUI.set_portrait_status = function (self, is_knocked_down, needs_help, is_dead, assisted_respawn)
		self._mod_display_warning_overlay = not is_dead and (is_knocked_down or (needs_help and not assisted_respawn))
		return original_set_portrait_status(self, is_knocked_down, needs_help, is_dead, assisted_respawn)
	end

	func(self, unit_frame)

	unit_frame_ui:customhud_update(is_wounded)

	UnitFrameUI.set_portrait_status = original_set_portrait_status
end)

local function ufUI_update(self, dt, t, player_unit)
	-- self:_set_widget_dirty(self._default_widgets.default_dynamic)
	-- self:_set_widget_dirty(self._default_widgets.default_static)
	-- self:_set_widget_dirty(self._health_widgets.health_dynamic)

	if self._frame_index then
		-- DEBUG ability bar
		-- mod:pcall(function()
			-- local widget = self:_widget_by_feature("ability", "dynamic")
			-- local widget_style = widget.style
			-- local widget_content = widget.content
			-- widget_content.actual_ability_percent = ability_percent
			-- pprint(widget.content)
			-- EchoConsole(tostring(widget_content.bar_value))
			-- EchoConsole(tostring(self._default_widgets.default_static.content.ability_bar.bar_value))
		-- end)

		mod:pcall(function()
			-- self:_set_widget_dirty(self._equipment_widgets.loadout_dynamic)

			if self._default_widgets then
				-- UIWidget.destroy(self.ui_renderer, self._default_widgets.default_dynamic)
				-- UIWidget.destroy(self.ui_renderer, self._default_widgets.default_static)
				-- UIWidget.destroy(self.ui_renderer, self._health_widgets.health_dynamic)
				-- UIWidget.destroy(self.ui_renderer, self._equipment_widgets.loadout_dynamic)
			end

			local health_bar_size, health_bar_offset = get_hp_bar_size_and_offset(player_unit)

			self._mod_health_bar_size = health_bar_size
			self._mod_health_bar_offset = health_bar_offset

			-- self._default_widgets = {
			-- 	default_dynamic = UIWidget.init(mod:create_dynamic_portait_widget(health_bar_size, health_bar_offset)),
			-- 	default_static = UIWidget.init(mod:create_static_widget(health_bar_size, health_bar_offset))
			-- }
			-- self._health_widgets = {
			-- 	health_dynamic = UIWidget.init(mod:create_dynamic_health_widget(health_bar_size, health_bar_offset))
			-- }
			-- self._equipment_widgets.loadout_dynamic = UIWidget.init(mod:create_dynamic_loadout_widget())

			-- self._widgets.default_dynamic = self._default_widgets.default_dynamic
			-- self._widgets.default_static = self._default_widgets.default_static
			-- self._widgets.health_dynamic = self._health_widgets.health_dynamic
			-- self._widgets.loadout_dynamic = self._equipment_widgets.loadout_dynamic

			-- UIRenderer.clear_scenegraph_queue(self.ui_renderer)

			-- self.slot_equip_animations = {}
			-- self.bar_animations = {}

			-- if self._frame_index then
			-- 	self:_widget_by_name("health_dynamic").content.hp_bar.texture_id = "teammate_hp_bar_color_tint_" .. self._frame_index
			-- 	self:_widget_by_name("health_dynamic").content.total_health_bar.texture_id = "teammate_hp_bar_" .. self._frame_index
			-- end

			-- self:reset()

			-- self:_set_widget_dirty(self._default_widgets.default_dynamic)
			-- self:_set_widget_dirty(self._default_widgets.default_static)
			-- self:_set_widget_dirty(self._health_widgets.health_dynamic)
			-- self:_set_widget_dirty(self._equipment_widgets.loadout_dynamic)

			-- self:set_visible(true)
			-- self:set_dirty()
		end)
	else
			-- self:_set_widget_dirty(self._default_widgets.default_dynamic)
			-- self:_set_widget_dirty(self._default_widgets.default_static)
			-- self:_set_widget_dirty(self._health_widgets.health_dynamic)
			-- self:_set_widget_dirty(self._ability_widgets.ability_dynamic)

		-- 	if self._health_widgets then
		-- 		UIWidget.destroy(self.ui_renderer, self._health_widgets.health_dynamic)
		-- 		UIWidget.destroy(self.ui_renderer, self._ability_widgets.ability_dynamic)
		-- 	end

		local health_bar_size, health_bar_offset = get_hp_bar_size_and_offset(player_unit)

		player_health_bar_size = {
			health_bar_size[1]-1,
			health_bar_size[2]
		}

		self._mod_health_bar_size = health_bar_size
		self._mod_health_bar_offset = health_bar_offset

		if mod.do_reload or not tablex.deepcompare(self._mod_health_bar_size_cached, health_bar_size) then
			self._mod_health_bar_size_cached = health_bar_size

			self._health_widgets = {
				health_dynamic = UIWidget.init(mod:create_player_dynamic_health_widget(health_bar_size))
			}
			self._widgets.health_dynamic = self._health_widgets.health_dynamic
			self:_set_widget_dirty(self._health_widgets.health_dynamic)

			self._ability_widgets = {
				ability_dynamic = UIWidget.init(mod:create_dynamic_ability_widget(health_bar_size))
			}
			self._widgets.ability_dynamic = self._ability_widgets.ability_dynamic
			self:_set_widget_dirty(self._ability_widgets.ability_dynamic)

			player_offset_x = -health_bar_size[1]/2
			player_offset_y = 0
			player_offset_y = player_offset_y - 9 - 10
			global_offset_x = 0

			mod.custom_player_widget = UIWidget.init(mod:get_custom_player_widget_def(health_bar_size))
		end

		-- 	self:_set_widget_dirty(self._default_widgets.default_dynamic)
		-- 	self:_set_widget_dirty(self._default_widgets.default_static)
		-- 	self:set_dirty()
	end

	if self._frame_index then
	-- if self._frame_index and not self._repositioned then
		-- self._portrait_widgets.portrait_static.content.scale = 1
		self._portrait_widgets.portrait_static.style.texture_1.size = { 0, 0 }
		self._default_widgets.default_static.style.character_portrait.texture_size = { 86*0.55, 108*0.55 }
		self._default_widgets.default_static.style.character_portrait.offset = { -80, -32, 1 }

		local portrait_left = true
		if portrait_left then
			-- self._default_widgets.default_static.style.character_portrait.offset = { -180, -80, 1 }
			self._default_widgets.default_static.style.character_portrait.offset = { -180, -75, 1 }
		end

		self._default_widgets.default_dynamic.style.portrait_icon.size = { 86*0.55, 108*0.55 }
		self._default_widgets.default_dynamic.style.portrait_icon.offset = { -80, -32, 10 }

		self._default_widgets.default_dynamic.style.connecting_icon.offset = { -25, -70, 20 }

		-- self._dirty=true

		local default_static_style = self._default_widgets.default_static.style
		local player_name_offset_x = 0
		local player_name_offset_y = -92

		if portrait_left then
			player_name_offset_x = -50
			player_name_offset_y = -95
		end
		default_static_style.player_name.offset[1] = player_name_offset_x
		default_static_style.player_name_shadow.offset[1] = player_name_offset_x+1

		default_static_style.player_name.offset[2] = player_name_offset_y
		default_static_style.player_name_shadow.offset[2] = player_name_offset_y-1

		default_static_style.player_level.offset[1] = -55
		default_static_style.player_level.offset[2] = -15

		-- default_static_style.player_level.offset = { 0,0,1 }
		-- self._default_widgets.default_static.content.player_level = "100"
		self._portrait_widgets.portrait_static.content.level = ""

		-- self._default_widgets.default_static.content.player_name = "Big McLarge Huge"
	else
		self:set_position(0, 0)
	end

	-- DEBUG
	if debug_favs then
		self:set_visible(true)
		self._dirty = true
	end
end

mod:hook("UnitFramesHandler.update", function(func, self, dt, t, ignore_own_player)
	if not self._is_visible then
		return
	end

	local function uf_comparison(uf_first, uf_second)
		local health_system_first = ScriptUnit.has_extension(uf_first.player_data.player_unit, "health_system")
		local health_system_second = ScriptUnit.has_extension(uf_second.player_data.player_unit, "health_system")
		if health_system_first and health_system_second then
			return health_system_first:get_max_health() > health_system_second:get_max_health()
		end
		return not not health_system_first
	end

	for index, unit_frame in ipairs(self._unit_frames) do
		if index ~= 1 or not ignore_own_player then
			ufUI_update(unit_frame.widget, dt, t, unit_frame.player_data.player_unit)
		end
	end

	local i = 1
	for index, unit_frame in tablex.sortv(self._unit_frames, uf_comparison) do
		if index ~= 1 then
			unit_frame.widget:set_position(205, 160+(i-1)*110)
			i = i + 1
		end
	end

	func(self, dt, t, ignore_own_player)
end)

local did_once = false
mod:hook("UnitFrameUI.draw", function (func, self, dt)
	-- return func(self, dt)
	-- -- self:set_visible(true)
	-- self._dirty = true

	if not self._is_visible then
		return
	end

	if not self._dirty then
		return
	end

	local ui_renderer = self.ui_renderer
	local ui_scenegraph = self.ui_scenegraph
	local input_service = self.input_manager:get_service("ingame_menu")
	local render_settings = self.render_settings
	local alpha_multiplier = render_settings.alpha_multiplier

	UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, self.render_settings)

	render_settings.alpha_multiplier = self._default_alpha_multiplier or alpha_multiplier

	if self._frame_index then
		for _, widget in pairs(self._default_widgets) do
			UIRenderer.draw_widget(ui_renderer, widget)
		end
	end

	render_settings.alpha_multiplier = self._portrait_alpha_multiplier or alpha_multiplier

	if self._frame_index then
		for _, widget in pairs(self._portrait_widgets) do
			UIRenderer.draw_widget(ui_renderer, widget)
		end
	end

	render_settings.alpha_multiplier = self._equipment_alpha_multiplier or alpha_multiplier

	for _, widget in pairs(self._equipment_widgets) do
		UIRenderer.draw_widget(ui_renderer, widget)
	end

	render_settings.alpha_multiplier = self._health_alpha_multiplier or alpha_multiplier

	for _, widget in pairs(self._health_widgets) do
		UIRenderer.draw_widget(ui_renderer, widget)
	end

	render_settings.alpha_multiplier = self._ability_alpha_multiplier or alpha_multiplier

	if not self._frame_index then
		for _, widget in pairs(self._ability_widgets) do
			UIRenderer.draw_widget(ui_renderer, widget)
		end
	end

	UIRenderer.end_pass(ui_renderer)

	if not self.ufUI_draw_warning_icon then
		self.ufUI_draw_warning_icon = mod.ufUI_draw_warning_icon
	end

	-- if true then
	if self._mod_display_warning_overlay then
		self:ufUI_draw_warning_icon(dt)
	end

	-- self._dirty = true
end)

mod.warning_icon_alpha_up = false
mod.warning_icon_color = {255, 255, 0, 0}
mod.ufUI_draw_warning_icon = function(self, dt)
	if not mod.gui and Managers.world:world("top_ingame_view") then
		mod:create_gui()
	end

	if not mod.gui then
		return
	end

	local color = mod.warning_icon_color
	color[1] = color[1] + 100*dt*(mod.warning_icon_alpha_u and 1 or -1)
	if color[1] < 150 then
		mod.warning_icon_alpha_u = true
		color[1] = 150
	end
	if color[1] > 255 then
		mod.warning_icon_alpha_u = false
		color[1] = 255
	end

	local black = Color(color[1], 0, 0, 0)
	local draw_color = Color(unpack(color))

	local position2dt = self.ui_scenegraph.pivot.world_position
	position2dt[1] = position2dt[1] + self._mod_health_bar_size[1] - 95
	position2dt[2] = position2dt[2] - 123
	local offset_vis = {0, 0, 0}

	local font_name, font_material, font_size = mod:fonts(60)
	Gui.text(mod.gui, "!", font_material, font_size, font_name, Vector2(position2dt[1]+1+offset_vis[1], position2dt[2]-1+offset_vis[2]), black)
	Gui.text(mod.gui, "!", font_material, font_size, font_name, Vector2(position2dt[1]+1+offset_vis[1], position2dt[2]+1+offset_vis[2]), black)
	Gui.text(mod.gui, "!", font_material, font_size, font_name, Vector2(position2dt[1]-1+offset_vis[1], position2dt[2]-1+offset_vis[2]), black)
	Gui.text(mod.gui, "!", font_material, font_size, font_name, Vector2(position2dt[1]-1+offset_vis[1], position2dt[2]+1+offset_vis[2]), black)
	Gui.text(mod.gui, "!", font_material, font_size, font_name, Vector2(position2dt[1]+offset_vis[1], position2dt[2]+offset_vis[2]), draw_color)
end

mod.get_custom_player_widget_def = function(self, player_health_bar_size)
	local even_hp_offset = player_health_bar_size[1] % 2 == 0 and -1 or 0
	return {
		scenegraph_id = "pivot",
		offset = { player_offset_x + global_offset_x + even_hp_offset, player_offset_y + global_offset_y, 1 },
		element = {
			passes = {
				{
					pass_type = "texture",
					style_id = "bg_slot_1",
					texture_id = "bg_slot",
				},
				{
					pass_type = "texture_uv",
					style_id = "item_slot_1",
					content_id = "item_slot_1",
				},
				{
					pass_type = "texture",
					style_id = "bg_slot_2",
					texture_id = "bg_slot",
				},
				{
					pass_type = "texture_uv",
					style_id = "item_slot_2",
					content_id = "item_slot_2",
				},
				{
					pass_type = "texture",
					style_id = "bg_slot_3",
					texture_id = "bg_slot",
				},
				{
					pass_type = "texture_uv",
					style_id = "item_slot_3",
					content_id = "item_slot_3",
				},
				{
					pass_type = "rect",
					style_id = "hp_bar_rect",
					content_check_function = function(content) return content.show end,
				},
				{
					pass_type = "rect",
					style_id = "hp_bar_rect2",
					content_check_function = function(content) return content.show end,
				},
				{
					pass_type = "rect",
					style_id = "ult_bar_rect",
					content_check_function = function(content) return content.show end,
				},
				{
					pass_type = "rect",
					style_id = "ult_bar_rect2",
					content_check_function = function(content) return content.show end,
				},
				{
					pass_type = "texture",
					style_id = "host_icon",
					texture_id = "host_icon",
					content_check_function = function(content) return content.is_host end,
				},
				{
					style_id = "ammo_bar",
					pass_type = "texture_uv",
					content_id = "ammo_bar",
					content_change_function = function (content, style)
						local ammo_progress = content.bar_value
						local size = style.size
						local uvs = content.uvs
						local bar_length = player_health_bar_size[1]
						uvs[2][2] = ammo_progress
						size[1] = bar_length*ammo_progress
					end
				},
				{
					pass_type = "rect",
					style_id = "ammo_bar_rect",
					-- content_check_function = function(content) return content.show end,
				},
				{
					pass_type = "rect",
					style_id = "ammo_bar_rect2",
					-- content_check_function = function(content) return content.show end,
				},
				{
					pass_type = "rect",
					style_id = "player_hp_bar_rect",
					-- content_check_function = function(content) return content.show end,
				},
			},
		},
		content = {
			item_slot_bg_1 = "hud_inventory_slot_bg_01",
			item_slot_bg_2 = "hud_inventory_slot_bg_02",
			item_slot_1 = {
				texture_id = "teammate_consumable_icon_medpack_empty",
				uvs = {
					{ 0.15, 0.15 },
					{ 0.85, 0.85 }
				},
			},
			item_slot_2 = {
				texture_id = "teammate_consumable_icon_potion_empty",
				uvs = {
					{ 0.15, 0.15 },
					{ 0.85, 0.85 }
				},
			},
			item_slot_3 = {
				texture_id = "teammate_consumable_icon_grenade_empty",
				uvs = {
					{ 0.15, 0.15 },
					{ 0.85, 0.85 }
				},
			},
			bg_slot = "consumables_frame_bg_lit",
			show_reload_reminder = false,
			show = true,
			is_host = false,
			host_icon = "host_icon",
			ammo_bar = {
				bar_value = 1,
				texture_id = "hud_teammate_ammo_bar_fill",
				uvs = {
					{
						0,
						0
					},
					{
						1,
						1
					}
				}
			},
		},
		style = {
			bg_slot_1 = {
				size = {
					64,
					64
				},
				offset = {
					4+2+0,
					30,
					1
				},
				color = {
					100,
					255,
					255,
					255
				},
			},
			item_slot_1 = {
				size = {
					48,
					48
				},
				offset = {
					8+6+0,
					38,
					2,
				},
				color = {
					50,
					255,
					255,
					255
				},
			},
			bg_slot_2 = {
				size = {
					64,
					64
				},
				offset = {
					64+3+0,
					30,
					1
				},
				color = {
					100,
					255,
					255,
					255
				},
			},
			item_slot_2 = {
				size = {
					48,
					48
				},
				offset = {
					64+8+3+0,
					38,
					2,
				},
				color = {
					50,
					255,
					255,
					255
				},
			},
			bg_slot_3 = {
				size = {
					64,
					64
				},
				offset = {
					64*2+0,
					30,
					1
				},
				color = {
					100,
					255,
					255,
					255
				},
			},
			item_slot_3 = {
				size = {
					48,
					48
				},
				offset = {
					64*2+8+0,
					38,
					2,
				},
				color = {
					50,
					255,
					255,
					255
				},
			},
			hp_bar_rect = {
				offset = {-2, -2, 0},
				size = {
					player_health_bar_size[1]+4,
					player_health_bar_size[2]+4,
				},
				color = {255, 105, 105, 105},
			},
			player_hp_bar_rect = {
				offset = {0, 0, 10+500+1},
				size = {
					player_health_bar_size[1],
					player_health_bar_size[2],
				},
				color = {0, 255, 255, 51}
			},
			hp_bar_rect2 = {
				offset = {-1, -1, 0},
				size = {
					player_health_bar_size[1]+2,
					player_health_bar_size[2]+2,
				},
				color = {255, 0, 0, 0},
			},
			ult_bar_rect = {
				offset = {6-8 + ability_ui_offset_x, 21-2-1 + ability_ui_offset_y, 0},
				size = {
					player_health_bar_size[1]+4,
					ult_bar_height + 4
				},
				color = {255, 105, 105, 105},
			},
			ult_bar_rect2 = {
				offset = {7-8 + ability_ui_offset_x, 22-2-1 + ability_ui_offset_y, 0},
				size = {
					player_health_bar_size[1]+2,
					ult_bar_height + 2,
				},
				color = {255, 0, 0, 0},
			},
			ammo_bar = {
				size = {
					player_health_bar_size[1],
					ammo_bar_height
				},
				offset = {
					-1 + even_hp_offset*-1,
					player_ammo_bar_offset_y+2,
					10
				},
				color = {
					255,
					255,
					255,
					255
				},
			},
			ammo_bar_rect = {
				offset = {-2, player_ammo_bar_offset_y+0, 0},
				size = { player_health_bar_size[1]+4, ammo_bar_height+4 },
				color = {255, 105, 105, 105},
			},
			ammo_bar_rect2 = {
				offset = {
					-1,
					player_ammo_bar_offset_y+1,
					1
				},
				size = { player_health_bar_size[1]+2, ammo_bar_height+2 },
				color = {255, 0, 0, 0},
			},
		},
	}
end

-- compatibility with the no ammo bar patch change
mod:hook("UnitFrameUI.set_ammo_percentage", function (func, self, ammo_percent)
	mod:pcall(function()
		local widget = self:_widget_by_feature("ammo", "dynamic")
		local widget_content = widget.content
		widget_content.actual_ammo_percent = ammo_percent

		self:_on_player_ammo_changed("ammo", widget, ammo_percent)
	end)

	return func(self, ammo_percent)
end)

local empty_slot_icons = {
	slot_healthkit = "default_heal_icon",
	slot_potion = "default_potion_icon",
	slot_grenade = "default_grenade_icon",
}

EquipmentUI._customhud_update_ammo = function (self, left_hand_wielded_unit, right_hand_wielded_unit, item_template)
	local ammo_extension = nil

	if not item_template.ammo_data then
		return
	end

	local ammo_unit_hand = item_template.ammo_data.ammo_hand

	if ammo_unit_hand == "right" then
		ammo_extension = ScriptUnit.extension(right_hand_wielded_unit, "ammo_system")
	elseif ammo_unit_hand == "left" then
		ammo_extension = ScriptUnit.extension(left_hand_wielded_unit, "ammo_system")
	else
		return
	end

	local max_ammo = ammo_extension:get_max_ammo()
	local remaining_ammo = ammo_extension:total_remaining_ammo()

	if max_ammo and remaining_ammo then
	    mod.custom_player_widget.content.ammo_bar.bar_value = remaining_ammo / max_ammo
	end
end

mod:hook("EquipmentUI._create_ui_elements", function (func, ...)
	local original_init_scenegraph = UISceneGraph.init_scenegraph
	UISceneGraph.init_scenegraph = function(scenegraph_definition)
		scenegraph_definition.slot.horizontal_alignment = "center"
		scenegraph_definition.slot.position = { 0, 0, -8 }
		return original_init_scenegraph(scenegraph_definition)
	end
	func(...)
	UISceneGraph.init_scenegraph = original_init_scenegraph
end)

mod:hook("EquipmentUI.draw", function (func, self, dt)
	if not mod.custom_player_widget then
		local health_bar_size = get_player_hp_bar_size()

		player_offset_x = -health_bar_size[1]/2
		player_offset_y = 0
		player_offset_y = player_offset_y - 9 - 10
		global_offset_x = 0

		mod.custom_player_widget = UIWidget.init(mod:get_custom_player_widget_def(health_bar_size))
	end

	mod:pcall(function()
		local inventory_extension = ScriptUnit.extension(Managers.player:local_player().player_unit, "inventory_system")
		local equipment = inventory_extension:equipment()
		local slot_data = equipment.slots["slot_ranged"]
		if slot_data then
			local item_data = slot_data.item_data
			self:_customhud_update_ammo(slot_data.left_unit_1p, slot_data.right_unit_1p, BackendUtils.get_item_template(item_data))
		end
	end)

	local ui_renderer = self.ui_renderer
	local ui_scenegraph = self.ui_scenegraph
	local input_service = self.input_manager:get_service("ingame_menu")
	local render_settings = self.render_settings

	UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, render_settings)

	-- update player consumables slots
	for i,slot_name in ipairs({"slot_healthkit", "slot_potion", "slot_grenade"}) do
		local widget_slot_name = "item_slot_"..i
		local slot_bg_name = "bg_slot_"..i
		local slot_data = self._slot_widgets[i+2]
		local orig_slot_style = slot_data.style
		if slot_data.content.visible and orig_slot_style.texture_icon.color[1] ~= 0  then
			mod.custom_player_widget.content[widget_slot_name].texture_id = slot_data.content.texture_icon
			mod.custom_player_widget.style[widget_slot_name].color[1] = 255
			mod.custom_player_widget.style[widget_slot_name].color[2] = 255
			mod.custom_player_widget.style[widget_slot_name].color[3] =	255
			mod.custom_player_widget.style[widget_slot_name].color[4] = 255
			-- mod.custom_player_widget.style[widget_slot_name].color = {255, 138,43,226}
		else
			mod.custom_player_widget.content[widget_slot_name].texture_id = empty_slot_icons[slot_name]
			mod.custom_player_widget.style[widget_slot_name].color[1] = 75
			mod.custom_player_widget.style[slot_bg_name].color[1] = 75
		end

			mod.custom_player_widget.style[widget_slot_name].color[1] = 0
			mod.custom_player_widget.style[slot_bg_name].color[1] = 0
	end
	UIRenderer.draw_widget(ui_renderer, mod.custom_player_widget)

	UIRenderer.end_pass(ui_renderer)

	mod:pcall(function()
		for _, widget in ipairs( self._ammo_widgets ) do
			widget.offset[1] = 0
			widget.offset[2] = 0
		end
	end)

	-- self._dirty = true

	self._show_ammo_meter = true

	local original_draw_widget = UIRenderer.draw_widget
	UIRenderer.draw_widget = function(ui_renderer, ui_widget)
		local match = false
		for i, widget in ipairs(self._slot_widgets) do
			if ui_widget == widget then
				if i == 1 or i == 2 then
					match = true
				end
			end
			for _, pass in ipairs( widget.element.passes ) do
				if pass.style_id == "input_text"
					or pass.style_id == "input_text_shadow"
					then
						pass.content_check_function = function() return false end
				end
			end
		end
		for _, widget in ipairs(self._static_widgets) do
			if ui_widget == widget then
				match = true
			end
		end
		if not match then
			return original_draw_widget(ui_renderer, ui_widget)
		end
	end

	mod:pcall(function()
		for _, widget in ipairs( self._slot_widgets ) do
			if not widget.offset_original then
				widget.offset_original = table.clone(widget.offset)
			end
			widget.offset[1] = widget.offset_original[1] - 140 - 70 + global_offset_x--+ 90 + 575 + global_offset_x
			widget.offset[2] = widget.offset_original[2] + 68 + global_offset_y
		end
	end)

	func(self, dt)

	UIRenderer.draw_widget = original_draw_widget
end)

--- BuffUI stuff ---
local buff_ui_definitions = local_require("scripts/ui/hud_ui/buff_ui_definitions")
local ALIGNMENT_DURATION_TIME = 0--0.3
local MAX_NUMBER_OF_BUFFS = buff_ui_definitions.MAX_NUMBER_OF_BUFFS
local BUFF_SIZE = buff_ui_definitions.BUFF_SIZE
local BUFF_SPACING = buff_ui_definitions.BUFF_SPACING
mod:hook("BuffUI._align_widgets", function (func, self) -- luacheck: ignore func
	local horizontal_spacing = BUFF_SIZE[1] + BUFF_SPACING

	for index, data in ipairs(self._active_buffs) do
		local widget = data.widget
		local widget_offset = widget.offset
		local target_position = (index - 1)*horizontal_spacing + get_player_hp_bar_size()[1]/2 + 20
		data.target_position = target_position
		data.target_distance = math.abs(widget_offset[1] - target_position)

		widget.offset[2] = -8

		self:_set_widget_dirty(widget)
	end

	self:set_dirty()

	self._alignment_duration = 0
end)

mod:hook("BuffUI._add_buff", function (func, self, buff, ...)
	if buff.buff_type == "victor_bountyhunter_passive_infinite_ammo_buff"
	  or buff.buff_type == "grimoire_health_debuff"
	  or buff.buff_type == "markus_huntsman_passive_crit_aura_buff" then
		return false
	end

	return func(self, buff, ...)
end)

mod:hook("BuffUI._update_pivot_alignment", function (func, self, dt)
	-- return func(self, dt)
	local alignment_duration = self._alignment_duration

	if not alignment_duration then
		return
	end

	-- alignment_duration = math.min(alignment_duration + dt, ALIGNMENT_DURATION_TIME)
	local progress = 1--alignment_duration/ALIGNMENT_DURATION_TIME
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
			widget_offset[1] = widget_target_position + widget_target_distance*(anim_progress - 1)
		end

		self:_set_widget_dirty(widget)
	end

	self:set_dirty()
end)

mod:hook("BuffUI.draw", function(func, self, dt)
	local player_hp_bar_size = get_player_hp_bar_size()
	if mod.do_reload or not tablex.deepcompare(self._mod_player_health_bar_size_cached, player_hp_bar_size) then
		self._mod_player_health_bar_size_cached = player_hp_bar_size
		self:_align_widgets()
	end
	return func(self, dt)
end)

mod.buff_ui_scenegraph_definition = {
	screen = {
		scale = "fit",
		position = {
			0,
			0,
			UILayer.hud
		},
		size = {
			SIZE_X,
			SIZE_Y
		}
	},
	pivot = {
		vertical_alignment = "bottom",
		parent = "screen",
		horizontal_alignment = "center",
		position = {
			0,--150,
			18,
			1
		},
		size = {
			0,
			0
		}
	},
	buff_pivot = {
		vertical_alignment = "center",
		parent = "pivot",
		horizontal_alignment = "center",
		position = {
			0,
			0,
			1
		},
		size = {
			0,
			0
		}
	}
}

mod:hook("BuffUI._create_ui_elements", function (func, ...)
	local original_init_scenegraph = UISceneGraph.init_scenegraph
	UISceneGraph.init_scenegraph = function(scenegraph_definition) -- luacheck: ignore scenegraph_definition
		return original_init_scenegraph(mod.buff_ui_scenegraph_definition)
	end
	func(...)
	UISceneGraph.init_scenegraph = original_init_scenegraph
end)

local abilityUI_scenegraph_definition = {
	screen = {
		scale = "fit",
		position = {
			0,
			0,
			UILayer.hud
		},
		size = {
			SIZE_X,
			SIZE_Y
		}
	},
	ability_root = {
		vertical_alignment = "bottom",
		parent = "screen",
		horizontal_alignment = "center",
		position = {
			0,
			0,
			10
		},
		size = {
			0,
			0
		}
	}
}

mod:hook("AbilityUI._create_ui_elements", function (func, ...)
	local original_init_scenegraph = UISceneGraph.init_scenegraph
	UISceneGraph.init_scenegraph = function(scenegraph_definition) -- luacheck: ignore scenegraph_definition
		return original_init_scenegraph(abilityUI_scenegraph_definition)
	end
	func(...)
	UISceneGraph.init_scenegraph = original_init_scenegraph
end)

mod:hook("AbilityUI.draw", function (func, self, dt)
	-- pdump(self._widgets, "AbilityUI._widgets")
	for _, pass in ipairs( self._widgets[1].element.passes ) do
		if pass.style_id == "ability_effect_right"
			or pass.style_id == "ability_effect_top_right"
			or pass.style_id == "input_text"
			or pass.style_id == "input_text_shadow" then
				pass.content_check_function = function() return false end
		end
	end
	mod:pcall(function()
		local skull_offsets = { 0, -15 }
		self._widgets[1].style.ability_effect_left.offset[1] = -player_health_bar_size[1]/2 - 50
		self._widgets[1].style.ability_effect_left.horizontal_alignment = "center"
		self._widgets[1].style.ability_effect_left.offset[2] = skull_offsets[2] - ability_ui_offset_y
		self._widgets[1].style.ability_effect_top_left.horizontal_alignment = "center"
		self._widgets[1].style.ability_effect_top_left.offset[1] = -player_health_bar_size[1]/2 - 50
		self._widgets[1].style.ability_effect_top_left.offset[2] = skull_offsets[2] - ability_ui_offset_y

		-- mod:dtf(self._widgets[1], "AbilityUI._widgets[1]", 8)
	end)

	self._widgets[1].offset[1]= -1
	self._widgets[1].offset[2]= 56 + global_offset_y + ability_ui_offset_y + player_offset_y
	self._widgets[1].style.ability_bar_highlight.texture_size[1] = player_health_bar_size[1]*1.09
	self._widgets[1].style.ability_bar_highlight.texture_size[2] = 50
	self._widgets[1].style.ability_bar_highlight.offset[2] = 22 + 4
	-- UIWidget.destroy(self.ui_renderer, self._widgets[1])
	-- self._widgets[1] = UIWidget.init(create_ability_widget())

	-- self:_set_widget_dirty(self._widgets[1])
	-- self._dirty = true

	-- return func(self, ...)

	local ui_renderer = self.ui_renderer
	local ui_scenegraph = self.ui_scenegraph
	local input_service = self.input_manager:get_service("ingame_menu")

	UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, self.render_settings)

	for _, widget in ipairs(self._widgets) do
		UIRenderer.draw_widget(ui_renderer, widget)
	end

	UIRenderer.end_pass(ui_renderer)
end)

mod.ChatGui_mod_set_position = function(self, x, y)
	mod:pcall(function()
		local position = self.ui_scenegraph.chat_window_root.local_position
		position[1] = x
		position[2] = y
	end)
end

mod:hook("ChatGui.update", function(func, self, ...)
	if not ChatGui.mod_set_position then
		ChatGui.mod_set_position = mod.ChatGui_mod_set_position
	end

	if not self._mod_repositioned then
		self._mod_repositioned = true
		self:mod_set_position(0, 1080/2-200)
	end

	return func(self, ...)
end)

mod.fonts = function(self, size)
	if size == nil then size = 20 end
	if size >= 32 then
		return "gw_head_32", "materials/fonts/gw_head_32", size
	else
		return "gw_head_20", "materials/fonts/gw_head_32", size
	end
end

--- ingame GUI ---
mod.gui = nil
mod.create_gui = function(self)
	local top_world = Managers.world:world("top_ingame_view")
	self.gui = World.create_screen_gui(top_world, "immediate", "material", "materials/fonts/gw_fonts")
end

mod.destroy_gui = function(self)
	local top_world = Managers.world:world("top_ingame_view")
	World.destroy_gui(top_world, self.gui)
	self.gui = nil
end

mod.on_unload = function(exit_game) -- luacheck: ignore exit_game
	if mod.gui and Managers.world:world("top_ingame_view") then
		mod:destroy_gui()
	end
end

mod.on_enabled = function(is_first_call) -- luacheck: ignore is_first_call
	if not is_first_call then
		mod.do_reload = true
	end
end