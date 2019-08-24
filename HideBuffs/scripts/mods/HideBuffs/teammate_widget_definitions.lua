local mod = get_mod("HideBuffs")

mod.teammate_ui_custom_def =
{
	scenegraph_id = "pivot",
	element = {
		passes = {
			{
				pass_type = "texture",
				style_id = "hp_bar_fg",
				texture_id = "hp_bar_fg",
				retained_mode = false,
			},
			{
				style_id = "ammo_bar",
				pass_type = "texture_uv",
				content_id = "ammo_bar",
				retained_mode = false,
				content_change_function = function (content, style)
					local ammo_progress = content.bar_value
					local size = style.size
					local uvs = content.uvs
					local bar_length = mod.team_ammo_bar_length
					uvs[2][2] = ammo_progress
					size[1] = bar_length*ammo_progress
				end,
				content_check_function = function (content)
					return content.draw_ammo_bar
				end,
			},
			{
				pass_type = "rect",
				style_id = "ammo_bar_bg",
				content_id = "ammo_bar",
				content_check_function = function (content)
					return content.draw_ammo_bar
				end,
			},
			{
				pass_type = "texture",
				style_id = "icon_natural_bond",
				texture_id = "icon_natural_bond",
				retained_mode = false,
				content_check_function = function (content)
					return content.has_natural_bond and content.important_icons_enabled
				end,
			},
			{
				pass_type = "texture",
				style_id = "frame_natural_bond",
				texture_id = "talent_frame",
				retained_mode = false,
				content_check_function = function (content)
					return content.has_natural_bond and content.important_icons_enabled
				end,
			},
			{
				pass_type = "texture",
				style_id = "icon_is_wounded",
				texture_id = "icon_is_wounded",
				retained_mode = false,
				content_check_function = function (content)
					return content.is_wounded and content.important_icons_enabled
				end,
			},
			{
				pass_type = "texture",
				style_id = "frame_is_wounded",
				texture_id = "talent_frame",
				retained_mode = false,
				content_check_function = function (content)
					return content.is_wounded and content.important_icons_enabled
				end,
			},
			{
				pass_type = "texture",
				style_id = "icon_hand_of_shallya",
				texture_id = "icon_hand_of_shallya",
				retained_mode = false,
				content_check_function = function (content)
					return content.has_hand_of_shallya and content.important_icons_enabled
				end,
			},
			{
				pass_type = "texture",
				style_id = "frame_hand_of_shallya",
				texture_id = "talent_frame",
				retained_mode = false,
				content_check_function = function (content)
					return content.has_hand_of_shallya and content.important_icons_enabled
				end,
			},
			{
				pass_type = "texture",
				style_id = "icon_healshare_talent",
				texture_id = "icon_healshare_talent",
				retained_mode = false,
				content_check_function = function (content)
					return content.has_healshare_talent and content.important_icons_enabled
				end,
			},
			{
				style_id = "hp_text",
				pass_type = "text",
				text_id = "health_string",
				retained_mode = false,
				content_check_function = function ()
					return true
				end
			},
			{
				style_id = "hp_text_shadow",
				pass_type = "text",
				text_id = "health_string",
				retained_mode = false,
				content_check_function = function ()
					return true
				end
			},
			{
				style_id = "ammo_text",
				pass_type = "text",
				text_id = "ammo_string",
				retained_mode = false,
				content_change_function = function (content, style)
					style.font_type = (content.ammo_style == 2 and "hell_shark_header") or "hell_shark"
				end,
				content_check_function = function (content)
					if content.ammo_string and content.ammo_string == "-1" then
						return false
					end

					if content.ammo_string and content.ammo_string == "-1/-1" then
						return false
					end

					if content.ammo_string and content.ammo_string == "0/0" then
						return false
					end

					local ammo_progress = content.ammo_percent
					local check = ammo_progress and 0 <= ammo_progress

					return not content.is_overcharge and check
				end
			},
			{
				style_id = "ammo_text_shadow",
				pass_type = "text",
				text_id = "ammo_string",
				retained_mode = false,
				content_change_function = function (content, style)
					style.font_type = (content.ammo_style == 2 and "hell_shark_header") or "hell_shark"
				end,
				content_check_function = function (content)
					if content.ammo_string and content.ammo_string == "-1" then
						return false
					end

					if content.ammo_string and content.ammo_string == "-1/-1" then
						return false
					end

					if content.ammo_string and content.ammo_string == "0/0" then
						return false
					end

					local ammo_progress = content.ammo_percent
					local check = ammo_progress and 0 <= ammo_progress

					return not content.is_overcharge and check
				end
			},
			{
					style_id = "cooldown_text",
					pass_type = "text",
					text_id = "cooldown_string",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						if content.cooldown_string == "0:00" then
							return
						end

						return true
					end
				},
				{
					style_id = "cooldown_text_shadow",
					pass_type = "text",
					text_id = "cooldown_string",
					retained_mode = RETAINED_MODE_ENABLED,
					content_check_function = function (content)
						if content.cooldown_string == "0:00" then
							return
						end

						return true
					end
				}
		},
	},
	content = {
		cooldown_string = "0:00",
		ammo_string = nil,
		ammo_style = 1,
		health_string = "",
		has_healshare_talent = false,
		has_hand_of_shallya = false,
		important_icons_enabled = false,
		is_wounded = false,
		has_natural_bond = false,
		talent_frame = "talent_frame",
		icon_healshare_talent = "killfeed_icon_06",
		icon_hand_of_shallya = "necklace_heal_self_on_heal_other",
		icon_is_wounded = "tabs_icon_all_selected",
		icon_natural_bond = "necklace_no_healing_health_regen",
		hp_bar_fg = "hud_teammate_hp_bar_frame",
		ammo_bar = {
			draw_ammo_bar = false,
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
		cooldown_text = {
			vertical_alignment = "center",
			horizontal_alignment = "center",
			font_size = 16,
			font_type = "hell_shark",
			text_color = Colors.get_color_table_with_alpha("white", 255),
			size = {
				22,
				22
			},
			offset = {
				0,
				0,
				50
			}
		},
		cooldown_text_shadow = {
			vertical_alignment = "center",
			horizontal_alignment = "center",
			font_size = 16,
			font_type = "hell_shark",
			text_color = Colors.get_color_table_with_alpha("black", 255),
			size = {
				22,
				22
			},
			offset = {
				2,
				-2,
				50-1
			}
		},
		hp_text = {
			vertical_alignment = "center",
			font_type = "hell_shark_arial",
			font_size = 17,
			horizontal_alignment = "center",
			text_color = Colors.get_table("white"),
			offset = {
				0,
				0,
				52
			}
		},
		hp_text_shadow = {
			vertical_alignment = "center",
			font_type = "hell_shark_arial",
			font_size = 17,
			horizontal_alignment = "center",
			text_color = Colors.get_table("black"),
			offset = {
				0,
				0,
				51
			}
		},
		ammo_text = {
			vertical_alignment = "center",
			font_type = "hell_shark",
			font_size = 22,
			horizontal_alignment = "center",
			text_color = Colors.get_table("white"),
			offset = {
				74,
				45,
				52
			}
		},
		ammo_text_shadow = {
			vertical_alignment = "center",
			font_type = "hell_shark",
			font_size = 22,
			horizontal_alignment = "center",
			text_color = Colors.get_table("black"),
			offset = {
				76,
				43,
				51
			}
		},
		frame_is_wounded = {
			size = {
				26,
				26
			},
			offset = {
				400,
				0,
				22
			},
			color = {
				255,
				255,
				255,
				255
			}
		},
		frame_natural_bond = {
			size = {
				26,
				26
			},
			offset = {
				300,
				0,
				22
			},
			color = {
				255,
				255,
				255,
				255
			}
		},
		frame_hand_of_shallya = {
			size = {
				26,
				26
			},
			offset = {
				300,
				0,
				22
			},
			color = {
				255,
				255,
				255,
				255
			}
		},
		icon_natural_bond = {
			size = {
				22,
				22
			},
			offset = {
				300,
				0,
				21
			},
			color = {
				200,
				255,
				255,
				255
			}
		},
		icon_is_wounded = {
			size = {
				40,
				40
			},
			offset = {
				400,
				0,
				21
			},
			color = {
				150,
				255,
				0,
				0
			}
		},
		icon_hand_of_shallya = {
			size = {
				22,
				22
			},
			offset = {
				500,
				0,
				21
			},
			color = {
				200,
				255,
				255,
				255
			}
		},
		icon_healshare_talent = {
			size = {
				22,
				22
			},
			offset = {
				600,
				0,
				21
			},
			color = {
				200,
				255,
				255,
				255
			}
		},
		hp_bar_fg = {
			size = {
				100,
				24
			},
			offset = {
				0,
				0,
				20
			},
			color = {
				255,
				255,
				255,
				255
			}
		},
		ammo_bar = {
			size = {
				92,
				5
			},
			offset = {
				0,
				0,
				19
			},
			color = {
				255,
				255,
				255,
				255
			}
		},
		ammo_bar_bg = {
			size = {
				92,
				5
			},
			offset = {
				0,
				0,
				18
			},
			color = {
				255,
				0,
				0,
				0
			}
		},
	},
	offset = {
		12+0,
		-60-2+0,
		-10
	},
}
