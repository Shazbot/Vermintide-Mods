-- luacheck: globals get_mod RETAINED_MODE_ENABLED

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
				retained_mode = false
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
				end
			},
			{
				pass_type = "texture",
				style_id = "icon_natural_bond",
				texture_id = "icon_natural_bond",
				retained_mode = false,
				content_check_function = function (content)
					return content.has_natural_bond
				end,
			},
			{
				pass_type = "texture",
				style_id = "frame_natural_bond",
				texture_id = "talent_frame",
				retained_mode = false,
				content_check_function = function (content)
					return content.has_natural_bond
				end,
			},
			{
				pass_type = "texture",
				style_id = "icon_is_wounded",
				texture_id = "icon_is_wounded",
				retained_mode = false,
				content_check_function = function (content)
					return content.is_wounded
				end,
			},
			{
				pass_type = "texture",
				style_id = "frame_is_wounded",
				texture_id = "talent_frame",
				retained_mode = false,
				content_check_function = function (content)
					return content.is_wounded
				end,
			},
		},
	},
	content = {
		is_wounded = false,
		has_natural_bond = false,
		talent_frame = "talent_frame",
		icon_is_wounded = "mutator_icon_instant_death",
		icon_natural_bond = "necklace_no_healing_health_regen",
		hp_bar_fg = "hud_teammate_hp_bar_frame",
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
		frame_is_wounded = {
			size = {
				28,
				28
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
				28,
				28
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
				24,
				24
			},
			offset = {
				300,
				0,
				21
			},
			color = {
				255,
				255,
				255,
				255
			}
		},
		icon_is_wounded = {
			size = {
				24,
				24
			},
			offset = {
				400,
				0,
				21
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
	},
	offset = {
		12+0,
		-60-2+0,
		-10
	},
}