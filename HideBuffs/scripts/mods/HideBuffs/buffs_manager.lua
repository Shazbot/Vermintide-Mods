local mod = get_mod("HideBuffs")

local pl = require'pl.import_into'()

mod.bm = {}
local bm = mod.bm

bm.added_buffs = pl.Map{
	-- traits_melee_attack_speed_on_crit_proc = "melee_attack_speed_on_crit",
}

bm.is_buff_manager_maximized = false

bm.buff_manager_storage_key = "buff_manager_storage"
bm.priority_buffs_key = "priority_buffs"
bm.hidden_buffs_key = "hidden_buffs"

local white = Color(255, 255, 255, 255)
mod.buffs_manager_BuffUI_draw = function(self)
	if not bm.main_window
	or not bm.is_buff_manager_maximized
	then
		return
	end

	local row = 0
	for _, icon in pairs( bm.added_buffs ) do
		row = row + 1

		local screen_width, screen_height = UIResolution()
		local position2d = Vector3(screen_width-485, screen_height-128-(row-1)*50, 900)
		local icon_size = Vector2(50, 50)

		if UIAtlasHelper.has_atlas_settings_by_texture_name(icon) then
			local texture_settings = UIAtlasHelper.get_atlas_settings_by_texture_name(icon)
			local uv00_table = texture_settings.uv00
			local uv11_table = texture_settings.uv11
			local uv00, uv11 = Vector2(uv00_table[1], uv00_table[2]), Vector2(uv11_table[1], uv11_table[2])
			Gui.bitmap_uv(self.ui_renderer.gui, texture_settings.material_name, uv00, uv11, Vector3(position2d[1], position2d[2], 900), icon_size, white)
		end
	end
end

mod.buffs_manager_BuffUI_add_buff = function(buff)
	local icon = buff.template.icon
	local buff_type = buff.buff_type
	if buff_type and not bm.added_buffs[buff_type] then
		bm.added_buffs[buff_type] = icon
		if bm.main_window then
			bm.reload_window()
		end
	end
end

bm.set_in_storage = function(settings_key, buff_type, to_set)
	local buff_manager_storage = mod:get(bm.buff_manager_storage_key) or {}
	local priority_buffs = pl.Set(buff_manager_storage[settings_key] or {})

	priority_buffs = to_set and pl.Set.union(priority_buffs, pl.Set{buff_type})
		or pl.Set.difference(priority_buffs, pl.Set{buff_type})

	buff_manager_storage[settings_key] = pl.Set.values(priority_buffs)
	setmetatable(buff_manager_storage[settings_key], nil)
	mod:set(bm.buff_manager_storage_key, buff_manager_storage)
	mod.vmf.save_unsaved_settings_to_file()
end

bm.set_priority = function(buff_type, is_priority)
	bm.set_in_storage(bm.priority_buffs_key, buff_type, is_priority)
end

bm.set_hidden = function(buff_type, is_hidden)
	bm.set_in_storage(bm.hidden_buffs_key, buff_type, is_hidden)
end

bm.get_in_storage = function(settings_key, buff_type)
	local buff_manager_storage = mod:get(bm.buff_manager_storage_key) or {}
	local buffs = pl.List(buff_manager_storage[settings_key] or {})
	return buffs:contains(buff_type)
end

bm.is_priority_buff = function(buff_type)
	return bm.get_in_storage(bm.priority_buffs_key, buff_type)
end

bm.is_hidden_buff = function(buff_type)
	return bm.get_in_storage(bm.hidden_buffs_key, buff_type)
end

bm.create_window = function()
	if not mod.simple_ui then
		return
	end

	local screen_width, screen_height = UIResolution()
	local window_size = {525, 800}
	local window_position = {
	screen_width/2 - window_size[1]/2, screen_height/2 - window_size[2]/2}

	bm.main_window = mod.simple_ui:create_window("buff_manager", window_position, window_size)

	bm.main_window.position = { 0, screen_height-50 }

	bm.main_window:create_title("buff_manager_title", "Buff Manager", 30)

	local x_pos = 20
	local y_pos = 80

	if bm.is_buff_manager_maximized then
		local row = 0
		for buff_type, _ in pairs( bm.added_buffs ) do
			row = row + 1

			local priority_chk
			local hide_chk
			local default_chk = bm.main_window:create_checkbox(
				buff_type.."_default_ckh",
				{x_pos, y_pos+(row-1)*50},
				{40, 40},
				"top_left"
			)
			default_chk.text = "Normal"
			default_chk.tooltip = buff_type
			default_chk.value = not (bm.is_priority_buff(buff_type) or bm.is_hidden_buff(buff_type))
			default_chk.on_value_changed = function()
				local is_normal = default_chk.value
				if is_normal then
					priority_chk.value = false
					hide_chk.value = false

					bm.set_priority(buff_type, false)
					bm.set_hidden(buff_type, false)
				else
					default_chk.value = true
				end
			end

			priority_chk = bm.main_window:create_checkbox(
				buff_type.."_priority_ckh",
				{x_pos+150, y_pos+(row-1)*50},
				{40, 40},
				"top_left"
			)
			priority_chk.text = "Priority"
			priority_chk.tooltip = buff_type
			priority_chk.value = bm.is_priority_buff(buff_type)
			priority_chk.on_value_changed = function()
				local is_priority = priority_chk.value
				if is_priority then
					default_chk.value = false
					hide_chk.value = false

					bm.set_hidden(buff_type, false)
				else
					default_chk.value = true
				end

				bm.set_priority(buff_type, is_priority)
			end

			hide_chk = bm.main_window:create_checkbox(
				buff_type.."_hide_ckh",
				{x_pos+300, y_pos+(row-1)*50},
				{40, 40},
				"top_left"
			)
			hide_chk.text = "Hide"
			hide_chk.tooltip = buff_type
			hide_chk.value = bm.is_hidden_buff(buff_type)
			hide_chk.on_value_changed = function()
				local is_hidden = hide_chk.value
				if is_hidden then
					default_chk.value = false
					priority_chk.value = false

					bm.set_priority(buff_type, false)
				else
					default_chk.value = true
				end

				bm.set_hidden(buff_type, is_hidden)
			end
		end
	end

	local show_button = bm.main_window:create_button("show_button",
		{0, 40},
		{100, 30},
		"middle_top",
		bm.is_buff_manager_maximized and "Hide" or "Show")
	show_button.tooltip =
		"Buff Manager"
		.."\nHide or prioritize buffs."
		.."\nTracks the recieved buffs,"
		.."\nso empty at game start."
	show_button.on_click = function()
		bm.is_buff_manager_maximized = not bm.is_buff_manager_maximized
		bm.reload_window()
	end

	bm.main_window.on_hover_enter = function(window)
		window:focus()
	end

	bm.reset_position()

	bm.main_window:init()

	bm.main_window.theme = table.clone(bm.main_window.theme)
	bm.main_window.theme.color[1] = 200

	bm.reset_position()
end

bm.reset_position = function()
	if bm.is_buff_manager_maximized then
		bm.maximize_window()
	else
		bm.minimize_window()
	end
end

bm.recalculate_position = function()
	local screen_width, screen_height = UIResolution()
	bm.main_window.position[1] = screen_width - bm.main_window.size[1]
	bm.main_window.position[2] = screen_height - bm.main_window.size[2]
end

bm.maximize_window = function()
	bm.main_window.size = { 430, 305 }
	bm.main_window.size[2] = 105+bm.added_buffs:len()*50
	bm.recalculate_position()
end

bm.minimize_window = function()
	bm.main_window.size = { 430, 80 }
	bm.recalculate_position()
end

bm.reload_window = function()
	bm.destroy_window()
	bm.create_window()
end

bm.destroy_window = function()
	if bm.main_window then
		bm.main_window:destroy()
		bm.main_window = nil
	end
end

--- Open UI on chat open.
mod.bm_on_chat_gui_update = function(chat_gui)
	if not Managers.state.game_mode
	or not mod:get(mod.SETTING_NAMES.SHOW_BUFFS_MANAGER_UI)
	or not mod.simple_ui
	then
		bm.destroy_window()
		return
	end

	if not chat_gui.chat_focused then
		bm.destroy_window()
	elseif mod.was_ingame_entered and not bm.main_window then
		bm.reload_window()
	end
end
