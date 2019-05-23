local mod = get_mod("HideBuffs")

mod.hp_bg_rect_def =
{
	scenegraph_id = "background_panel_bg",
	element = {
		passes = {
			{
				pass_type = "rect",
				style_id = "hp_bar_rect",
			},
		},
	},
	content = {
	},
	style = {
		hp_bar_rect = {
			offset = {0, 0, 0},
			size = {
				500,
				10
			},
			color = {255, 0, 0, 0},
		},
	},
	offset = {
		0,
		0,
		0
	},
}

mod.ammo_widget_def =
{
	scenegraph_id = "background_panel_bg",
	element = {
		passes = {
			{
				style_id = "ammo_bar",
				pass_type = "texture_uv",
				content_id = "ammo_bar",
				content_change_function = function (content, style) --luacheck: ignore style
					local ammo_progress = content.bar_value
					local uvs = content.uvs
					uvs[2][2] = ammo_progress
					-- moved this to draw hook, refreshes better
					-- local size = style.size
					-- size[1] = mod.ammo_bar_width * ammo_progress
				end
			},
		},
	},
	content = {
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
		ammo_bar = {
			size = {
				mod.ammo_bar_width,
				15
			},
			offset = {
				0,
				0,
				0
			},
			color = {
				255,
				255,
				255,
				255
			},
		},
	},
	offset = {
		0,
		0,
		0
	},
}

mod.numeric_ui_player_widget_def =
{
	scenegraph_id = "background_panel_bg",
	element = {
		passes = {
			{
				style_id = "hp_text",
				pass_type = "text",
				text_id = "health_string",
				retained_mode = false,
			},
			{
				style_id = "hp_text_shadow",
				pass_type = "text",
				text_id = "health_string",
				retained_mode = false,
			},
			{
				style_id = "cooldown_text",
				pass_type = "text",
				text_id = "cooldown_string",
				retained_mode = false,
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
				retained_mode = false,
				content_check_function = function (content)
					if content.cooldown_string == "0:00" then
						return
					end

					return true
				end
			},
		},
	},
	content = {
		cooldown_string = "0:00",
	},
	style = {
		hp_text = {
			vertical_alignment = "center",
			font_type = "hell_shark_arial",
			font_size = 17,
			horizontal_alignment = "center",
			text_color = Colors.get_table("white"),
			offset = {
				0,
				0,
				-8 + 22
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
				-8 + 21
			}
		},
		cooldown_text = {
			vertical_alignment = "center",
			font_size = 16,
			font_type = "hell_shark",
			word_wrap = false,
			horizontal_alignment = "center",
			text_color = Colors.get_color_table_with_alpha("white", 255),
			size = {
				22,
				22
			},
			offset = {
				0,
				0,
				2
			}
		},
		cooldown_text_shadow = {
			vertical_alignment = "center",
			font_size = 16,
			font_type = "hell_shark",
			word_wrap = false,
			horizontal_alignment = "center",
			text_color = Colors.get_color_table_with_alpha("black", 255),
			size = {
				22,
				22
			},
			offset = {
				0,
				0,
				1
			}
		}
	},
	offset = {
		0,
		0,
		0
	},
}

mod.rect_player_ui_layout_def =
{
	scenegraph_id = "background_panel_bg",
	element = {
		passes = {
			{
				pass_type = "rect",
				style_id = "hp_bar_bg",
			},
			{
				pass_type = "border",
				style_id = "hp_bar_border",
			},
			{
				pass_type = "rect",
				style_id = "ult_bar_bg",
			},
			{
				pass_type = "border",
				style_id = "ult_bar_border",
			},
		},
	},
	content = {},
	style = {
		hp_bar_bg = {
			offset = { 0, 0, 0 },
			size = { 500,10 },
			color = { 255, 0, 0, 0 },
		},
		hp_bar_border = {
			thickness = 2,
			color = { 255,255,255,255 },
			offset = { 0,0,10 },
			size = { 500,50 },
		},
		ult_bar_bg = {
			offset = { 0, 0, 0 },
			size = { 500,10 },
			color = { 255, 0, 0, 0 },
		},
		ult_bar_border = {
			thickness = 2,
			color = { 255,255,255,255 },
			offset = { 0,0,0 },
			size = { 500,50 },
		},
	},
	offset = { 0,0,0 },
}
