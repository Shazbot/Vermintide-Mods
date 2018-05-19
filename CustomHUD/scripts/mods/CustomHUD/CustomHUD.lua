local mod = get_mod("CustomHUD")

-- luacheck: globals UIRenderer ScriptUnit Managers BackendUtils UIWidget UnitFrameUI
-- luacheck: globals UILayer UISceneGraph EquipmentUI ButtonTextureByName Colors

local custom_player_widget

-- DEBUG
local debug_favs = false
local RETAINED_MODE_ENABLED = not debug_favs

local my_scale_x = 0.45

local SIZE_X = 1920
local SIZE_Y = 1080

-- local player_offset_x = 115
local player_offset_x = SIZE_X/2-100
local player_offset_y = 20

local global_offset_x = -750
local global_offset_y = 0 + 5

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
local health_bar_size = {
	-- health_bar_size_fraction*92,
	468*my_scale_x,
	17--health_bar_size_fraction*9
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
			-15 + 35,
			health_bar_offset[2] - 96 + 65,
			0
		}
	}
end

mod.create_static_widget = function(self)
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
						-- EchoConsole(tostring(ability_progress))
						local size = style.size
						local uvs = content.uvs
						local offset = style.offset
						local bar_length = health_bar_size[1] - 1
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
				horizontal_alignment = "center",
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
					0,--health_bar_size[1]+6,
					0,--health_bar_size[2]+6,
					--100,
					--17
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
					0,--health_bar_size[1]+6,
					0,--health_bar_size[2]+6,
					-- 100,
					-- 24
				},
				offset = {
					(health_bar_offset[1])-3,
					(health_bar_offset[2] + health_bar_size[2]/2) - 12,
					health_bar_offset[3] + 15
					-- (health_bar_offset[1] + health_bar_size[1]/2) - 50,
					-- (health_bar_offset[2] + health_bar_size[2]/2) - 8.5,
					-- health_bar_offset[3] + 20
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
					0,--health_bar_size[1],
					0,--5,
					-- 92,
					-- 5
				},
				offset = {
					(health_bar_offset[1])-3 +3,
					(health_bar_offset[2] + health_bar_size[2]/2) - 12 - 5,
					--(health_bar_offset[2] + health_bar_size[2]/2) - 12 - 50,
					health_bar_offset[3] + 15
					-- (health_bar_offset[1] + health_bar_size[1]/2) - 46,
					-- health_bar_offset[2] - 9,
					-- health_bar_offset[3] + 15
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

mod.create_dynamic_portait_widget = function(self)
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
						local bar_length = health_bar_size[1] - 1
						uvs[2][2] = ammo_progress
						size[1] = bar_length*ammo_progress

						return
					end
				}
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

mod.create_dynamic_health_widget = function(self)
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
local portrait_area = {
	86,
	108
}
mod.create_player_dynamic_health_widget = function(self)
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
						-- offset[2] = 20
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
					player_health_bar_size[1], --464*my_scale_x,
					player_health_bar_size[2] + 1--19
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
					player_health_bar_size[1], --464*my_scale_x,
					player_health_bar_size[2] + 1 --19
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
					player_health_bar_size[1], --464*my_scale_x,
					player_health_bar_size[2] + 1 --19
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
					player_health_bar_size[1], --464*my_scale_x,
					-- player_health_bar_size[2]
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

mod.create_dynamic_ability_widget = function(self)
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
						local bar_length = health_bar_size[1]--468*my_scale_x+2-4--health_bar_size[1] +20--488*my_scale_x
						uvs[2][2] = ability_progress
						size[1] = bar_length*ability_progress
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
					health_bar_size[1]+2,
					4+1
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

			self._default_widgets = {
				default_dynamic = UIWidget.init(mod:create_dynamic_portait_widget()),
				default_static = UIWidget.init(mod:create_static_widget())
			}
			self._health_widgets = {
				health_dynamic = UIWidget.init(mod:create_dynamic_health_widget())
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

			self._health_widgets = {
				health_dynamic = UIWidget.init(mod:create_player_dynamic_health_widget())
			}
			self._ability_widgets = {
				ability_dynamic = UIWidget.init(mod:create_dynamic_ability_widget())
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
			if custom_player_widget then
				custom_player_widget.style.hp_bar_rect.color = is_wounded and {255, 255, 255, 255} or {255, 105, 105, 105}
				-- custom_player_widget.style.hp_bar_rect2.color = is_wounded and {255, 255, 255, 255} or {255, 0, 0, 0}
				custom_player_widget.style.ult_bar_rect.color = is_wounded and {255, 255, 255, 255} or {255, 105, 105, 105}
				custom_player_widget.style.ammo_bar_rect.color = is_wounded and {255, 255, 255, 255} or {255, 105, 105, 105}
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

-- CareerExtension._update_game_object_field = function (self, unit)
-- 	if (not self.is_server or not self.player.bot_player) and not self.player.local_player then
-- 		return
-- 	end

-- 	local ability_cooldown, max_cooldown = self:current_ability_cooldown()
-- 	local ability_percentage = 1

-- 	if ability_cooldown then
-- 		ability_percentage = ability_cooldown/max_cooldown
-- 	end

-- 	local network_manager = Managers.state.network
-- 	local game = network_manager:game()
-- 	local go_id = Managers.state.unit_storage:go_id(unit)
-- 	ability_percentage = math.min(1, ability_percentage)

-- 	GameSession.set_game_object_field(game, go_id, "ability_percentage", ability_percentage)

-- 	mod:pcall(function()
-- 		-- pout(1,2,3)
-- 		-- pprint(ability_percentage)
-- 	end)

-- 	return
-- end

mod:hook("UnitFramesHandler._sync_player_stats", function (func, self, unit_frame)
	mod:pcall(function()

		local unit_frame_ui = unit_frame.widget
		local player_data = unit_frame.player_data
		local player_unit = player_data.player_unit
		local is_wounded = false

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

		unit_frame_ui:customhud_update(is_wounded)
	end)
	return func(self, unit_frame)
end)

mod:hook("UnitFrameUI.update", function (func, self, dt, t)
	-- self:on_resolution_modified()

	-- self:_set_widget_dirty(self._default_widgets.default_dynamic)
	-- self:_set_widget_dirty(self._default_widgets.default_static)
	-- self:_set_widget_dirty(self._health_widgets.health_dynamic)

	if self._frame_index then

		mod:pcall(function()
			local widget = self:_widget_by_feature("ability", "dynamic")
			local widget_style = widget.style
			local widget_content = widget.content
			-- widget_content.actual_ability_percent = ability_percent
			-- pprint(widget.content)
			-- EchoConsole(tostring(widget_content.bar_value))
			-- EchoConsole(tostring(self._default_widgets.default_static.content.ability_bar.bar_value))
		end)

		-- local result, error = pcall(function()
		-- 	self:_set_widget_dirty(self._equipment_widgets.loadout_dynamic)

		-- 	if self._default_widgets then
		-- 		UIWidget.destroy(self.ui_renderer, self._default_widgets.default_dynamic)
		-- 		UIWidget.destroy(self.ui_renderer, self._default_widgets.default_static)
		-- 		UIWidget.destroy(self.ui_renderer, self._health_widgets.health_dynamic)
		-- 		UIWidget.destroy(self.ui_renderer, self._equipment_widgets.loadout_dynamic)
		-- 	end

		-- 	self._default_widgets = {
		-- 		default_dynamic = UIWidget.init(mod:create_dynamic_portait_widget()),
		-- 		default_static = UIWidget.init(mod:create_static_widget())
		-- 	}
		-- 	self._health_widgets = {
		-- 		health_dynamic = UIWidget.init(mod:create_dynamic_health_widget())
		-- 	}
		-- 	self._equipment_widgets.loadout_dynamic = UIWidget.init(mod:create_dynamic_loadout_widget())

		-- 	self._widgets.default_dynamic = self._default_widgets.default_dynamic
		-- 	self._widgets.default_static = self._default_widgets.default_static
		-- 	self._widgets.health_dynamic = self._health_widgets.health_dynamic
		-- 	self._widgets.loadout_dynamic = self._equipment_widgets.loadout_dynamic

		-- 	UIRenderer.clear_scenegraph_queue(self.ui_renderer)

		-- 	self.slot_equip_animations = {}
		-- 	self.bar_animations = {}

		-- 	self:reset()

		-- 	if self._frame_index then
		-- 		self:_widget_by_name("health_dynamic").content.hp_bar.texture_id = "teammate_hp_bar_color_tint_" .. self._frame_index
		-- 		self:_widget_by_name("health_dynamic").content.total_health_bar.texture_id = "teammate_hp_bar_" .. self._frame_index
		-- 	end

		-- 	self:_set_widget_dirty(self._default_widgets.default_dynamic)
		-- 	self:_set_widget_dirty(self._default_widgets.default_static)
		-- 	self:_set_widget_dirty(self._health_widgets.health_dynamic)
		-- 	self:_set_widget_dirty(self._equipment_widgets.loadout_dynamic)

		-- 	self:set_visible(true)
		-- 	self:set_dirty()
		-- end)
		-- if not result then
		-- 	EchoConsole(tostring(error))
		-- end
	else
		-- local result, error = pcall(function()
		-- 	self:_set_widget_dirty(self._default_widgets.default_dynamic)
		-- 	self:_set_widget_dirty(self._default_widgets.default_static)
		-- 	self:_set_widget_dirty(self._health_widgets.health_dynamic)
		-- 	self:_set_widget_dirty(self._ability_widgets.ability_dynamic)

		-- 	if self._health_widgets then
		-- 		UIWidget.destroy(self.ui_renderer, self._health_widgets.health_dynamic)
		-- 		UIWidget.destroy(self.ui_renderer, self._ability_widgets.ability_dynamic)
		-- 	end

		-- 	self._health_widgets = {
		-- 		health_dynamic = UIWidget.init(mod:create_player_dynamic_health_widget())
		-- 	}
		-- 	self._ability_widgets = {
		-- 		ability_dynamic = UIWidget.init(mod:create_dynamic_ability_widget())
		-- 	}

		-- 	self._widgets.health_dynamic = self._health_widgets.health_dynamic
		-- 	self._widgets.ability_dynamic = self._ability_widgets.ability_dynamic

		-- 	self:_set_widget_dirty(self._default_widgets.default_dynamic)
		-- 	self:_set_widget_dirty(self._default_widgets.default_static)
		-- 	self:_set_widget_dirty(self._health_widgets.health_dynamic)
		-- 	self:_set_widget_dirty(self._ability_widgets.ability_dynamic)
		-- 	self:set_dirty()
		-- end)
		-- if not result then
		-- 	EchoConsole(tostring(error))
		-- end
	end

	if self._frame_index then
		mod:pcall(function()
			-- pdump(self._default_widgets.default_static.style, "def_static_debug")
		end)
	-- if self._frame_index and not self._repositioned then
		-- self._portrait_widgets.portrait_static.content.scale = 1
		self._portrait_widgets.portrait_static.style.texture_1.size = { 0, 0 }
		self._default_widgets.default_static.style.character_portrait.texture_size = { 86*0.55, 108*0.55 }
		self._default_widgets.default_static.style.character_portrait.offset = { -80, -32, 1 }

		self._default_widgets.default_dynamic.style.portrait_icon.size = { 86*0.55, 108*0.55 }
		self._default_widgets.default_dynamic.style.portrait_icon.offset = { -80, -32, 10 }

		self._default_widgets.default_dynamic.style.connecting_icon.offset = { -25, -70, 20 }

		-- self._dirty=true

		local default_static_style = self._default_widgets.default_static.style
		default_static_style.player_name.offset[1] = 0
		default_static_style.player_name_shadow.offset[1] = 0+1
		local player_name_offset = -89
		default_static_style.player_name.offset[2] = player_name_offset
		default_static_style.player_name_shadow.offset[2] = player_name_offset-1

		default_static_style.player_level.offset[1] = -55
		default_static_style.player_level.offset[2] = -15

		-- default_static_style.player_level.offset = { 0,0,1 }
		-- self._default_widgets.default_static.content.player_level = "100"
		self._portrait_widgets.portrait_static.content.level = ""

		-- local player_name_widget = self:_widget_by_feature("player_name", "static")
		-- if player_name_widget then
		-- 	player_name_widget
			-- self:_set_widget_dirty(player_name_widget)
		-- end

		-- local pos = self.ui_scenegraph.pivot.local_position
		-- EchoConsole(tostring(pos[1]).." "..tostring(pos[2]))
		-- self:set_position(pos[1], pos[2])
		self:set_position(125+(self._frame_index-1)*230, 140)
		-- self:set_position(90+(self._frame_index-1)*150, 140)
		-- did_once = true
	end

	-- DEBUG
	if debug_favs then
		self:set_visible(true)
		self._dirty = true
	end

	return func(self, dt, t)
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

	-- self._dirty = true

	return
end)

local function create_ability_widget()
	return {
		scenegraph_id = "ability_root",
		element = {
			passes = {
				{
					pass_type = "texture",
					style_id = "ability_effect_right",
					texture_id = "texture_id",
					content_id = "ability_effect",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return not content.parent.on_cooldown
					end
				},
				{
					pass_type = "texture",
					style_id = "ability_effect_top_right",
					texture_id = "texture_id",
					content_id = "ability_effect_top",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return not content.parent.on_cooldown
					end
				},
				{
					style_id = "ability_effect_left",
					pass_type = "texture_uv",
					content_id = "ability_effect",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return not content.parent.on_cooldown
					end
				},
				{
					style_id = "ability_effect_top_left",
					pass_type = "texture_uv",
					content_id = "ability_effect_top",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return not content.parent.on_cooldown
					end
				},
				{
					pass_type = "texture",
					style_id = "ability_bar_highlight",
					texture_id = "ability_bar_highlight",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return not content.on_cooldown
					end
				},
				{
					style_id = "input_text",
					pass_type = "text",
					text_id = "input_text",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content, style)
						return not Managers.input:is_device_active("gamepad")
					end
				},
				{
					style_id = "input_text_shadow",
					pass_type = "text",
					text_id = "input_text",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content, style)
						return not Managers.input:is_device_active("gamepad")
					end
				},
				{
					style_id = "input_text_gamepad",
					pass_type = "text",
					text_id = "input_text_gamepad",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content, style)
						return Managers.input:is_device_active("gamepad") and not content.on_cooldown
					end
				},
				{
					style_id = "input_text_shadow_gamepad",
					pass_type = "text",
					text_id = "input_text_gamepad",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content, style)
						return Managers.input:is_device_active("gamepad") and not content.on_cooldown
					end
				},
				{
					pass_type = "texture",
					style_id = "input_texture_left_shoulder",
					texture_id = "input_texture_left_shoulder",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content, style)
						return Managers.input:is_device_active("gamepad") and not content.on_cooldown
					end
				},
				{
					pass_type = "texture",
					style_id = "input_texture_right_shoulder",
					texture_id = "input_texture_right_shoulder",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content, style)
						return Managers.input:is_device_active("gamepad") and not content.on_cooldown
					end
				}
			}
		},
		content = {
			input_text_gamepad = "+",
			ability_bar_highlight = "hud_player_ability_bar_glow",
			input_text = "",
			on_cooldown = true,
			ability_effect = {
				texture_id = "ability_effect",
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
			ability_effect_top = {
				texture_id = "hud_player_ability_icon_glow",
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
			input_texture_left_shoulder = ButtonTextureByName("left_shoulder", "xb1").texture,
			input_texture_right_shoulder = ButtonTextureByName("right_shoulder", "xb1").texture
		},
		style = {
			input_text = {
				word_wrap = false,
				font_size = 16,
				localize = false,
				horizontal_alignment = "center",
				vertical_alignment = "center",
				font_type = "hell_shark",
				text_color = Colors.get_color_table_with_alpha("white", 255),
				size = {
					22,
					18
				},
				offset = {
					38,
					78,
					2
				}
			},
			input_text_shadow = {
				word_wrap = false,
				font_size = 16,
				localize = false,
				horizontal_alignment = "center",
				vertical_alignment = "center",
				font_type = "hell_shark",
				text_color = Colors.get_color_table_with_alpha("black", 255),
				size = {
					22,
					18
				},
				offset = {
					40,
					76,
					1
				}
			},
			input_text_gamepad = {
				vertical_alignment = "center",
				font_size = 32,
				localize = false,
				horizontal_alignment = "center",
				word_wrap = false,
				font_type = "hell_shark",
				text_color = {
					0,
					255,
					255,
					255
				},
				offset = {
					0,
					85,
					20
				}
			},
			input_text_shadow_gamepad = {
				vertical_alignment = "center",
				font_size = 32,
				localize = false,
				horizontal_alignment = "center",
				word_wrap = false,
				font_type = "hell_shark",
				text_color = {
					0,
					0,
					0,
					0
				},
				offset = {
					0,
					83,
					19
				}
			},
			input_texture_left_shoulder = {
				vertical_alignment = "center",
				horizontal_alignment = "center",
				color = {
					0,
					255,
					255,
					255
				},
				offset = {
					-40,
					85,
					20
				},
				texture_size = ButtonTextureByName("left_shoulder", "xb1").size
			},
			input_texture_right_shoulder = {
				vertical_alignment = "center",
				horizontal_alignment = "center",
				color = {
					0,
					255,
					255,
					255
				},
				offset = {
					30,
					85,
					20
				},
				texture_size = ButtonTextureByName("right_shoulder", "xb1").size
			},
			ability_effect_right = {
				vertical_alignment = "bottom",
				horizontal_alignment = "right",
				texture_size = {
					110,
					170
				},
				offset = {
					0,
					-2,
					0
				},
				color = {
					0,
					255,
					255,
					255
				}
			},
			ability_effect_top_right = {
				vertical_alignment = "bottom",
				horizontal_alignment = "right",
				texture_size = {
					110,
					170
				},
				offset = {
					0,
					-2,
					1
				},
				color = {
					0,
					255,
					255,
					255
				}
			},
			ability_effect_left = {
				vertical_alignment = "bottom",
				horizontal_alignment = "left",
				texture_size = {
					110,
					170
				},
				offset = {
					-9,
					-2,
					0
				},
				color = {
					0,
					255,
					255,
					255
				}
			},
			ability_effect_top_left = {
				vertical_alignment = "bottom",
				horizontal_alignment = "left",
				texture_size = {
					110,
					170
				},
				offset = {
					-9,
					-2,
					1
				},
				color = {
					0,
					255,
					255,
					255
				}
			},
			ability_bar_highlight = {
				vertical_alignment = "bottom",
				horizontal_alignment = "center",
				texture_size = {
					player_health_bar_size[1],
					70
				},
				color = {
					0,
					255,
					255,
					255
				},
				offset = {
					0,
					22,
					2
				}
			}
		},
		offset = {
			0,
			0,
			0
		}
	}
end

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
		self._widgets[1].style.ability_effect_left.offset[1] = 105 - ability_ui_offset_x
		self._widgets[1].style.ability_effect_left.offset[2] = -8 - ability_ui_offset_y
		self._widgets[1].style.ability_effect_top_left.offset[1] = 105 - ability_ui_offset_x
		self._widgets[1].style.ability_effect_top_left.offset[2] = -8 - ability_ui_offset_y
	end)

	self._widgets[1].offset[1]= player_offset_x - 125 - 1 + global_offset_x + ability_ui_offset_x
	self._widgets[1].offset[2]= 17 + global_offset_y + ability_ui_offset_y
	-- self._widgets[1].style.ability_bar_highlight.texture_size[1] = 488 * my_scale_x - 3
	self._widgets[1].style.ability_bar_highlight.texture_size[1] = player_health_bar_size[1]+20
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
	local render_settings = self.render_settings

	UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, self.render_settings)

	for _, widget in ipairs(self._widgets) do
		UIRenderer.draw_widget(ui_renderer, widget)
	end

	UIRenderer.end_pass(ui_renderer)
end)

local SLOTS_LIST = InventorySettings.weapon_slots

mod.custom_player_widget_def =
{
	scenegraph_id = "background_panel_bg",
	offset = { player_offset_x - 0 + global_offset_x, player_offset_y + global_offset_y, 1 },
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
					local offset = style.offset
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
				player_health_bar_size[2]+4,--22
			},
			color = {255, 105, 105, 105},
		},
		player_hp_bar_rect = {
			offset = {0, 0, 10+500+1},
			size = {
				player_health_bar_size[1],
				player_health_bar_size[2],--22
			},
			-- color = {255, 115, 150, 65},
			color = {0--[[150]], 255, 255, 51}--255,0,51},
		},
		hp_bar_rect2 = {
			offset = {-1, -1, 0},
			size = {
				player_health_bar_size[1]+2,
				player_health_bar_size[2]+2,--22-2
			},
			color = {255, 0, 0, 0},
		},
		ult_bar_rect = {
			offset = {6-8 + ability_ui_offset_x, 21-2-1 + ability_ui_offset_y, 0},
			-- size = {450*my_scale_x, 8},
			size = {
				player_health_bar_size[1]+4,
				ult_bar_height + 4
			},
			color = {255, 105, 105, 105},
		},
		ult_bar_rect2 = {
			offset = {7-8 + ability_ui_offset_x, 22-2-1 + ability_ui_offset_y, 0},
			-- size = {450*my_scale_x-2, 8-2},
			size = {
				player_health_bar_size[1]+2,
				ult_bar_height + 2,
			},
			color = {255, 0, 0, 0},
		},
		-- ammo_bar = {
		-- 	size = {
		-- 		health_bar_size[1],
		-- 		health_bar_size[2]
		-- 		-- ammo_bar_height +
		-- 	},
		-- 	offset = {
		-- 		0,
		-- 		-- -2,
		-- 		player_ammo_bar_offset_y+ 8+2,--health_bar_offset[2] - 9 - 50,
		-- 		10+500
		-- 	},
		-- 	-- color = {
		-- 	-- 	50,
		-- 	-- 	255,
		-- 	-- 	0,
		-- 	-- 	0
		-- 	-- },
		-- 	color = {
		-- 		255,
		-- 		255,
		-- 		255,
		-- 		255
		-- 	},
		-- },
		ammo_bar = {
			size = {
				health_bar_size[1],
				ammo_bar_height
			},
			offset = {
				0,
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
	    custom_player_widget.content.ammo_bar.bar_value = remaining_ammo / max_ammo
	end
end

mod:hook("EquipmentUI.draw", function (func, self, dt)
	if not custom_player_widget then
		custom_player_widget = UIWidget.init(mod.custom_player_widget_def)
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
	local alpha_multiplier = render_settings.alpha_multiplier

	UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, render_settings)

	-- update player consumables slots
	for i,slot_name in ipairs({"slot_healthkit", "slot_potion", "slot_grenade"}) do
		local widget_slot_name = "item_slot_"..i
		local slot_bg_name = "bg_slot_"..i
		local slot_data = self._slot_widgets[i+2]
		local orig_slot_style = slot_data.style
		if slot_data.content.visible and orig_slot_style.texture_icon.color[1] ~= 0  then
			custom_player_widget.content[widget_slot_name].texture_id = slot_data.content.texture_icon
			custom_player_widget.style[widget_slot_name].color[1] = 255
			custom_player_widget.style[widget_slot_name].color[2] = 255
			custom_player_widget.style[widget_slot_name].color[3] =	255
			custom_player_widget.style[widget_slot_name].color[4] = 255
			-- custom_player_widget.style[widget_slot_name].color = {255, 138,43,226}
		else
			custom_player_widget.content[widget_slot_name].texture_id = empty_slot_icons[slot_name]
			custom_player_widget.style[widget_slot_name].color[1] = 75
			custom_player_widget.style[slot_bg_name].color[1] = 75
		end

			custom_player_widget.style[widget_slot_name].color[1] = 0
			custom_player_widget.style[slot_bg_name].color[1] = 0
	end
	UIRenderer.draw_widget(ui_renderer, custom_player_widget)

	UIRenderer.end_pass(ui_renderer)

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
			widget.offset[1] = widget.offset_original[1] + 90 + 575 + global_offset_x
			widget.offset[2] = widget.offset_original[2] + 12 + global_offset_y
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
		local target_position = (index - 1)*horizontal_spacing + 20
		data.target_position = target_position
		data.target_distance = math.abs(widget_offset[1] - target_position)

		widget.offset[2] = -15

		self:_set_widget_dirty(widget)
	end

	self:set_dirty()

	self._alignment_duration = 0
end)

mod:hook("BuffUI._add_buff", function (func, self, buff, ...)
	mod:pcall(function()
		-- pprint(buff)
	end)
	if buff.buff_type == "victor_bountyhunter_passive_infinite_ammo_buff"
		or buff.buff_type == "grimoire_health_debuff" then
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

mod:hook("BuffUI.update", function (func, self, ...)
	-- self:_align_widgets()
	-- self:set_dirty()
	return func(self, ...)
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
			150,
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