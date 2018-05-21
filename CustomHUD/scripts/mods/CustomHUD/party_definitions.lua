local mod = get_mod("CustomHUD") -- luacheck: ignore get_mod

-- luacheck: globals Colors

mod.create_dynamic_portait_widget = function(self, health_bar_size, health_bar_offset) -- luacheck: ignore self
	return {
		scenegraph_id = "pivot",
		element = {
			passes = {
				{
					pass_type = "texture",
					style_id = "portrait_icon",
					texture_id = "portrait_icon",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.display_portrait_icon
					end
				},
				{
					pass_type = "texture",
					style_id = "talk_indicator_highlight",
					texture_id = "talk_indicator_highlight",
					retained_mode = mod.RETAINED_MODE_ENABLED
				},
				{
					pass_type = "rotated_texture",
					style_id = "connecting_icon",
					texture_id = "connecting_icon",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.connecting
					end
				},
				{
					style_id = "ammo_bar",
					pass_type = "texture_uv",
					content_id = "ammo_bar",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					content_change_function = function (content, style)
						local ammo_progress = content.bar_value
						local size = style.size
						local uvs = content.uvs
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
					mod.portrait_scale*86,
					mod.portrait_scale*108
				},
				offset = {
					-(mod.portrait_scale*86)/2,
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
			mod.portrait_scale*-55,
			0
		}
	}
end

mod.create_static_widget = function(self, health_bar_size, health_bar_offset) -- luacheck: ignore self
	return {
		scenegraph_id = "pivot",
		element = {
			passes = {
				{
					pass_type = "texture",
					style_id = "character_portrait",
					texture_id = "character_portrait",
					retained_mode = mod.RETAINED_MODE_ENABLED
				},
				{
					style_id = "player_level",
					pass_type = "text",
					text_id = "player_level",
					retained_mode = mod.RETAINED_MODE_ENABLED
				},
				{
					pass_type = "texture",
					style_id = "host_icon",
					texture_id = "host_icon",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.is_host
					end
				},
				{
					style_id = "player_name",
					pass_type = "text",
					text_id = "player_name",
					retained_mode = mod.RETAINED_MODE_ENABLED
				},
				{
					style_id = "player_name_shadow",
					pass_type = "text",
					text_id = "player_name",
					retained_mode = mod.RETAINED_MODE_ENABLED
				},
				{
					pass_type = "texture",
					style_id = "hp_bar_bg",
					texture_id = "hp_bar_bg",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					content_check_function = function ()
						return true
					end
				},
				{
					pass_type = "texture",
					style_id = "hp_bar_fg",
					texture_id = "hp_bar_fg",
					retained_mode = mod.RETAINED_MODE_ENABLED
				},
				{
					pass_type = "texture",
					style_id = "ammo_bar_bg",
					texture_id = "ammo_bar_bg",
					retained_mode = mod.RETAINED_MODE_ENABLED
				},
				{
					pass_type = "rect",
					style_id = "hp_bar_rect",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					-- content_check_function = function(content) return content.show end,
				},
				{
					pass_type = "rect",
					style_id = "hp_bar_rect2",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					-- content_check_function = function(content) return content.show end,
				},
				{
					pass_type = "rect",
					style_id = "ammo_bar_rect",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					-- content_check_function = function(content) return content.show end,
				},
				{
					pass_type = "rect",
					style_id = "ammo_bar_rect2",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					-- content_check_function = function(content) return content.show end,
				},
				{
					pass_type = "rect",
					style_id = "ult_bar_rect",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					-- content_check_function = function(content) return content.show end,
				},
				{
					pass_type = "rect",
					style_id = "ult_bar_rect2",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					-- content_check_function = function(content) return content.show end,
				},
				{
					style_id = "ability_bar",
					pass_type = "texture_uv",
					content_id = "ability_bar",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					content_change_function = function (content, style)
						local ability_progress = content.bar_value
						local size = style.size
						local uvs = content.uvs
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
					mod.portrait_scale*86,
					mod.portrait_scale*108
				},
				offset = {
					mod.portrait_scale*-43,
					mod.portrait_scale*-54 + mod.portrait_scale*55,
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
				horizontal_alignment = "left",
				text_color = Colors.get_table("white"),
				offset = {
					0,
					mod.portrait_scale*110,
					health_bar_offset[3] + 15
				}
			},
			player_name_shadow = {
				vertical_alignment = "bottom",
				font_type = "hell_shark",
				font_size = 18,
				horizontal_alignment = "left",
				text_color = Colors.get_table("black"),
				offset = {
					2,
					mod.portrait_scale*110 - 2,
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
				size = { health_bar_size[1]+4, mod.ammo_bar_height+4 },
				color = {255, 105, 105, 105},
			},
			ammo_bar_rect2 = {
				offset = {
					health_bar_offset[1]-1,
					health_bar_offset[2]-1-8,
					1
				},
				size = { health_bar_size[1]+2, mod.ammo_bar_height+2 },
				color = {255, 0, 0, 0},
			},
			ult_bar_rect = {
				offset = {
					health_bar_offset[1]-2,
					health_bar_offset[2]-2-mod.ult_bar_height-mod.ammo_bar_height-6,
					0
				},
				size = {
					health_bar_size[1]+4,
					mod.ult_bar_height + 4
				},
				color = {255, 105, 105, 105},
			},
			ult_bar_rect2 = {
				offset = {
					health_bar_offset[1]-1,
					health_bar_offset[2]-1-mod.ult_bar_height-mod.ammo_bar_height-6,
					1
				},
				size = {
					health_bar_size[1] + 2,
					mod.ult_bar_height + 2,
				},
				color = {255, 0, 0, 0},
			},
			ability_bar = {
				size = {
					health_bar_size[1],
					mod.ult_bar_height
				},
				color = {
					255,
					255,
					255,
					255
				},
				offset = {
					health_bar_offset[1],
					health_bar_offset[2]-mod.ult_bar_height-mod.ammo_bar_height-6,
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
			mod.portrait_scale*-55,
			0
		}
	}
end

mod.create_dynamic_health_widget = function(self, health_bar_size, health_bar_offset) -- luacheck: ignore self
	return {
		scenegraph_id = "pivot",
		element = {
			passes = {
				{
					pass_type = "texture",
					style_id = "hp_bar_highlight",
					texture_id = "hp_bar_highlight",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return not content.has_shield
					end
				},
				{
					style_id = "grimoire_debuff_divider",
					texture_id = "grimoire_debuff_divider",
					pass_type = "texture",
					retained_mode = mod.RETAINED_MODE_ENABLED,
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
					retained_mode = mod.RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "gradient_mask_texture",
					style_id = "total_health_bar",
					texture_id = "texture_id",
					content_id = "total_health_bar",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					style_id = "grimoire_bar",
					pass_type = "texture_uv",
					content_id = "grimoire_bar",
					retained_mode = mod.RETAINED_MODE_ENABLED,
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
						offset[1] = health_bar_offset[1] + 2*mod.health_bar_size_fraction + bar_length*grim_progress - size[1]

						return
					end
				},
				{
					pass_type = "texture",
					style_id = "hp_bar",
					texture_id = "hp_bar_mask",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.hp_bar.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "portrait_icon",
					texture_id = "portrait_icon",
					retained_mode = mod.RETAINED_MODE_ENABLED,
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
			mod.portrait_scale*-55,
			0
		}
	}
end

mod.create_dynamic_loadout_widget = function(self, health_bar_size, health_bar_offset) -- luacheck: ignore self health_bar_size
	return {
		scenegraph_id = "pivot",
		element = {
			passes = {
				{
					pass_type = "texture",
					style_id = "item_slot_1",
					texture_id = "item_slot_1",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "item_slot_bg_1",
					texture_id = "item_slot_bg_1",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "item_slot_frame_1",
					texture_id = "slot_frame",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "item_slot_highlight_1",
					texture_id = "item_slot_highlight",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "item_slot_2",
					texture_id = "item_slot_2",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "item_slot_bg_2",
					texture_id = "item_slot_bg_2",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "item_slot_frame_2",
					texture_id = "slot_frame",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "item_slot_highlight_2",
					texture_id = "item_slot_highlight",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "item_slot_3",
					texture_id = "item_slot_3",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "item_slot_bg_3",
					texture_id = "item_slot_bg_3",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "item_slot_frame_3",
					texture_id = "slot_frame",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						return content.draw_health_bar
					end
				},
				{
					pass_type = "texture",
					style_id = "item_slot_highlight_3",
					texture_id = "item_slot_highlight",
					retained_mode = mod.RETAINED_MODE_ENABLED,
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
					mod.slot_scale*29,
					mod.slot_scale*29
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
					mod.slot_scale*29,
					mod.slot_scale*29
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
					mod.slot_scale*29,
					mod.slot_scale*29
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
					mod.slot_scale*29,
					mod.slot_scale*29
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
					mod.slot_scale*29,
					mod.slot_scale*29
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
					mod.slot_scale*29,
					mod.slot_scale*29
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
					mod.slot_scale*29,
					mod.slot_scale*29
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
					mod.slot_scale*29,
					mod.slot_scale*29
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
					mod.slot_scale*29,
					mod.slot_scale*29
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
			-15 + 35 + mod.others_items_offsets[1],
			health_bar_offset[2] - 96 + 65 + mod.others_items_offsets[2],
			0 + mod.others_items_offsets[3]
		}
	}
end