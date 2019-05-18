local mod = get_mod("HideBuffs")

mod.player_ability_dynamic_content_change_fun = function (content, style)
	if not content.uvs then
		local ability_progress = content.bar_value
		local size = style.texture_size
		local offset = style.offset
		offset[2] = -size[2] + size[2] * ability_progress
		return
	end
	local ability_progress = content.bar_value
	local size = style.size
	local uvs = content.uvs
	local bar_length = mod.ult_bar_width
	uvs[2][2] = ability_progress
	size[1] = bar_length * ability_progress
end

mod.team_ammo_indicator_content_check_fun = function (content, style)
	local ammo_progress = content.ammo_percent

	if ammo_progress then
		local make_green = ammo_progress > 0.33
		style.color[2] = make_green and 0 or 255
		style.color[4] = make_green and 0 or 255
	end

	if mod:get(mod.SETTING_NAMES.TEAM_UI_KEEP_AMMO_ICON_VISIBLE) then
		return ammo_progress and ammo_progress > 0
	end

	return ammo_progress and ammo_progress > 0 and ammo_progress <= 0.33
end

mod.team_grimoire_debuff_divider_content_change_fun = function (content, style)
	local hp_bar_content = content.hp_bar
	local internal_bar_value = hp_bar_content.internal_bar_value
	local actual_active_percentage = content.actual_active_percentage or 1
	local grim_progress = math.max(internal_bar_value, actual_active_percentage)
	local offset = style.offset
	offset[1] = mod.health_bar_offset[1] + mod.hp_bar_size[1] * grim_progress + mod.hp_bar_offset_x
	offset[2] = mod.health_bar_offset[2] + mod.hp_bar_offset_y
end

mod.team_grimoire_bar_content_change_fun = function (content, style)
	local parent_content = content.parent
	local hp_bar_content = parent_content.hp_bar
	local internal_bar_value = hp_bar_content.internal_bar_value
	local actual_active_percentage = parent_content.actual_active_percentage or 1
	local grim_progress = math.max(internal_bar_value, actual_active_percentage)
	local size = style.size
	local uvs = content.uvs
	local offset = style.offset
	local bar_length = mod.hp_bar_size[1]
	uvs[1][1] = grim_progress
	size[1] = bar_length * (1 - grim_progress)
	offset[1] = 2 + mod.health_bar_offset[1] + bar_length * grim_progress + mod.hp_bar_offset_x
	offset[2] = mod.health_bar_offset[2] + mod.hp_bar_offset_y
		+ (mod.hp_bar_delta_y and mod.hp_bar_delta_y/2 or 0)
end

mod.team_ability_bar_content_change_fun = function (content, style)
	local ability_progress = content.bar_value
	local size = style.size
	local uvs = content.uvs
	local bar_length = mod.hp_bar_size[1]
	uvs[2][2] = ability_progress
	size[1] = bar_length * ability_progress
end

mod.player_grimoire_debuff_divider_content_change_fun =  function (content, style)
	local hp_bar_content = content.hp_bar
	local internal_bar_value = hp_bar_content.internal_bar_value
	local actual_active_percentage = content.actual_active_percentage or 1
	local grim_progress = math.max(internal_bar_value, actual_active_percentage)
	local offset = style.offset
	offset[1] = (-276.5 - 7 + 553 * grim_progress) * mod.hp_bar_w_scale
	offset[2] = 35-8
end

mod.player_grimoire_bar_content_change_fun = function (content, style)
	local parent_content = content.parent
	local hp_bar_content = parent_content.hp_bar
	local internal_bar_value = hp_bar_content.internal_bar_value
	local actual_active_percentage = parent_content.actual_active_percentage or 1
	local grim_progress = math.max(internal_bar_value, actual_active_percentage)
	local size = style.size
	local uvs = content.uvs
	local offset = style.offset
	local bar_length = mod.hp_bar_width - 18 * mod.hp_bar_w_scale
	uvs[1][1] = grim_progress
	size[1] = bar_length * (1 - grim_progress)
	offset[1] = (-276.5 + 2 + 553 * grim_progress) * mod.hp_bar_w_scale
	offset[2] = 35
end
