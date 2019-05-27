local mod = get_mod("ModdedProgression")

mod.create_level_widget = function(scenegraph_id)
	local widget = {
		element = {}
	}
	local passes = {
		{
			pass_type = "texture",
			style_id = "frame",
			texture_id = "frame",
			content_check_function = function (content)
				return content.ons
			end

		},
		{
			pass_type = "texture",
			style_id = "icon",
			texture_id = "icon",
			content_check_function = function (content, style)
				if content.dwons then
					style.offset[2] = -88
					style.offset[3] = 52
					return true
				end

				style.offset[2] = -88+165
				style.offset[3] = 7
				return content.dw
			end
		},
	}
	local content = {
		frame = "achievement_banner",
		icon = "end_screen_banner_victory",
		ons = false,
		dw = false,
	}
	local style = {
		frame = {
			vertical_alignment = "center",
			horizontal_alignment = "center",
			texture_size = {
				164,
				125
			},
			offset = {
				0,-90,50
			},
			color = {
				255,
				220,20,60
			}
		},
		icon = {
			vertical_alignment = "center",
			horizontal_alignment = "center",
			texture_size = {
				680/5,
				240/5,
			},
			offset = {
				0,-88,51
			},
			color = {
				255,
				255,255,255
			}
		},
	}
	widget.element.passes = passes
	widget.content = content
	widget.style = style
	widget.offset = {0,0,0}
	widget.scenegraph_id = scenegraph_id

	return widget
end

mod.description_text_style = {
	word_wrap = true,
	font_size = 18,
	localize = false,
	use_shadow = true,
	horizontal_alignment = "center",
	vertical_alignment = "top",
	font_type = "hell_shark",
	text_color = Colors.get_color_table_with_alpha("font_default", 255),
	offset = {
		0,
		0,
		2
	}
}
