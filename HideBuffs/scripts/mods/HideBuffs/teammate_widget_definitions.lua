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
		},
	},
	content = {
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