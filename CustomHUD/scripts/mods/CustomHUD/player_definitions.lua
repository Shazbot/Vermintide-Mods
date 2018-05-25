local mod = get_mod("CustomHUD") -- luacheck: ignore get_mod

mod.settings = {
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

mod.create_player_dynamic_health_widget = function(self, player_health_bar_size) -- luacheck: ignore self
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
						offset[1] = mod.settings.hp_bar.x - 3 + grim_progress * player_health_bar_size[1]
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
						local bar_length = player_health_bar_size[1]
						uvs[1][1] = grim_progress
						size[1] = bar_length*(grim_progress - 1)
						offset[1] = mod.settings.hp_bar.x + grim_progress * player_health_bar_size[1] - size[1]
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
					mod.settings.hp_bar.x,
					mod.settings.hp_bar.y,
					mod.settings.hp_bar.z + 2
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
					mod.settings.hp_bar.x,
					mod.settings.hp_bar.y,
					mod.settings.hp_bar.z + 3
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
					mod.settings.hp_bar.x,
					mod.settings.hp_bar.y,
					mod.settings.hp_bar.z + 1
				}
			},
			grimoire_debuff_divider = {
				size = {
					10,
					36
				},
				color = {
					255,
					255,
					255,
					255
				},
				offset = {
					mod.settings.hp_bar.x + 10,
					mod.settings.hp_bar.y - 8,
					mod.settings.hp_bar.z + 20
				}
			},
			hp_bar_highlight = {
				size = {
					player_health_bar_size[1],
					30
				},
				offset = {
					mod.settings.hp_bar.x,
					mod.settings.hp_bar.y - 4,
					mod.settings.hp_bar.z + 5
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
			mod.player_offset_x + mod.global_offset_x,
			mod.player_offset_y + mod.global_offset_y,
			0
		}
	}
end

mod.create_dynamic_ability_widget = function(self, health_bar_size) -- luacheck: ignore self
	return {
		scenegraph_id = "pivot",
		element = {
			passes = {
				{
					style_id = "ability_bar",
					pass_type = "texture_uv",
					content_id = "ability_bar",
					retained_mode = mod.RETAINED_MODE_ENABLED,
					content_change_function = function (content, style)
						local ability_progress = content.bar_value
						-- EchoConsole(tostring(ability_progress))
						local size = style.size
						local uvs = content.uvs
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
					mod.settings.ability_bar.x,
					mod.settings.ability_bar.y,
					mod.settings.ability_bar.z + 1
				}
			}
		},
		offset = {
			mod.player_offset_x-8 + mod.global_offset_x + mod.ability_ui_offset_x,
			mod.player_offset_y-3 + mod.global_offset_y + mod.ability_ui_offset_y,
			0
		}
	}
end

mod.get_custom_player_widget_def = function(self, player_health_bar_size) -- luacheck: ignore self
	local even_hp_offset = player_health_bar_size[1] % 2 == 0 and -1 or 0
	return {
		scenegraph_id = "pivot",
		offset = { mod.player_offset_x + mod.global_offset_x + even_hp_offset, mod.player_offset_y + mod.global_offset_y, 1 },
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
					content_check_function = function(content) return content.show end,
				},
				{
					pass_type = "rect",
					style_id = "ammo_bar_rect2",
					content_check_function = function(content) return content.show end,
				},
				{
					pass_type = "rect",
					style_id = "player_hp_bar_rect",
					content_check_function = function(content) return content.show end,
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
				offset = {6-8 + mod.ability_ui_offset_x, 21-2-1 + mod.ability_ui_offset_y, 0},
				size = {
					player_health_bar_size[1]+4,
					mod.ult_bar_height + 4
				},
				color = {255, 105, 105, 105},
			},
			ult_bar_rect2 = {
				offset = {7-8 + mod.ability_ui_offset_x, 22-2-1 + mod.ability_ui_offset_y, 0},
				size = {
					player_health_bar_size[1]+2,
					mod.ult_bar_height + 2,
				},
				color = {255, 0, 0, 0},
			},
			ammo_bar = {
				size = {
					player_health_bar_size[1],
					mod.ammo_bar_height
				},
				offset = {
					-1 + even_hp_offset*-1,
					mod.player_ammo_bar_offset_y+2,
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
				offset = {-2, mod.player_ammo_bar_offset_y+0, 0},
				size = { player_health_bar_size[1]+4, mod.ammo_bar_height+4 },
				color = {255, 105, 105, 105},
			},
			ammo_bar_rect2 = {
				offset = {
					-1,
					mod.player_ammo_bar_offset_y+1,
					1
				},
				size = { player_health_bar_size[1]+2, mod.ammo_bar_height+2 },
				color = {255, 0, 0, 0},
			},
		},
	}
end