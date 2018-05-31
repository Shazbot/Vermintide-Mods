local mod = get_mod("CustomHUD") -- luacheck: ignore get_mod

local pl = require'pl.import_into'() -- luacheck: ignore pl
local tablex = require'pl.tablex'

-- luacheck: globals UIRenderer ScriptUnit Managers BackendUtils UIWidget UnitFrameUI
-- luacheck: globals UILayer UISceneGraph EquipmentUI ButtonTextureByName Colors
-- luacheck: globals ChatGui Vector2 Gui Color unpack table PlayerUnitHealthExtension
-- luacheck: globals math local_require World Unit DamageUtils StatBuffIndex

mod.custom_player_widget = nil

-- DEBUG
local debug_favs = false
mod.RETAINED_MODE_ENABLED = not debug_favs

mod.SIZE_X = 1920
mod.SIZE_Y = 1080

mod.player_offset_x = mod.SIZE_X/2-100
mod.player_offset_y = -19

mod.global_offset_y = -5
mod.global_offset_x = 0

mod.ability_ui_offset_x = 0
mod.ability_ui_offset_y = -28 - 8

mod.player_ammo_bar_offset_y = -10

mod.ammo_bar_height = 5
mod.ult_bar_height = 5

mod.portrait_scale = 1
mod.slot_scale = 1
mod.health_bar_size_fraction = 2
mod.default_hp_bar_size_x = 180
mod.default_hp_bar_size_y = 17

mod.others_items_offsets_vertical_align = {
	-101,
	-0,
	0
}
mod.others_items_offsets_horizontal_align = {
	-20,
	-0,
	0
}
mod.others_items_offsets = mod.others_items_offsets_horizontal_align

mod:dofile("scripts/mods/CustomHUD/scenegraph_definitions")
mod:dofile("scripts/mods/CustomHUD/player_definitions")
mod:dofile("scripts/mods/CustomHUD/party_definitions")

mod.cached_player_hp_bars = mod:persistent_table("hp_bars_cache")

PlayerUnitHealthExtension._mod_get_max_health_without_grims = function (self)
	local buff_extension = self.buff_extension
	local max_health_alive = self:_get_base_max_health()
	local max_health

	max_health = buff_extension:apply_buffs_to_value(max_health_alive, StatBuffIndex.MAX_HEALTH_ALIVE)

	max_health = buff_extension:apply_buffs_to_value(max_health, StatBuffIndex.MAX_HEALTH)
	max_health = DamageUtils.networkify_health(max_health)

	return max_health
end

mod.get_player_hp_bar_size = function(self) -- luacheck: ignore self
	local player_unit = Managers.player:local_player().player_unit
	return mod:get_hp_bar_size_and_offset(player_unit)
end

mod.get_hp_bar_size_and_offset = function(self, player_unit) -- luacheck: ignore self
	local hp_scale = 1

	local is_valid = player_unit and Unit.alive(player_unit)
	if not is_valid and mod.cached_player_hp_bars[player_unit] then
		return mod.cached_player_hp_bars[player_unit]
	end

	if is_valid then
		local health_system = ScriptUnit.extension(player_unit, "health_system")

		if health_system.state == "knocked_down" or health_system.state == "dead" then
			if mod.cached_player_hp_bars[player_unit] then
				return mod.cached_player_hp_bars[player_unit]
			end
		else
			if mod:get(mod.SETTING_NAMES.PARTY_UI_ORIENTATION) ~= mod.ORIENTATIONS.HORIZONTAL
			and mod:get(mod.SETTING_NAMES.HP_BAR_SIZE_METHOD) ~= mod.HP_BAR_SIZE_METHODS.FIXED then
				hp_scale = health_system:_mod_get_max_health_without_grims() / 100
			end
			if mod:get(mod.SETTING_NAMES.HP_BAR_SIZE_METHOD) ~= mod.HP_BAR_SIZE_METHODS.DEFAULT then
				hp_scale = hp_scale * mod:get(mod.SETTING_NAMES.HP_BAR_SIZE_SCALE_BY) / 100
			end
		end
	else
		if mod:get(mod.SETTING_NAMES.HP_BAR_SIZE_METHOD) ~= mod.HP_BAR_SIZE_METHODS.DEFAULT then
			hp_scale = hp_scale * mod:get(mod.SETTING_NAMES.HP_BAR_SIZE_SCALE_BY) / 100
		end
	end

	local health_bar_size = {
		mod.default_hp_bar_size_x*hp_scale,
		mod.default_hp_bar_size_y
	}
	local health_bar_offset = {
		-115,
		mod.health_bar_size_fraction*-25,
		0
	}

	health_bar_size[1] = math.round(health_bar_size[1])

	if player_unit then
		mod.cached_player_hp_bars[player_unit] = health_bar_size
	end

	return health_bar_size, health_bar_offset
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

			local player_unit = Managers.player:local_player().player_unit
			local health_bar_size, health_bar_offset = mod:get_hp_bar_size_and_offset(player_unit)

			self._mod_health_bar_size_cached = health_bar_size

			self._default_widgets = {
				default_dynamic = UIWidget.init(mod:create_dynamic_portait_widget(health_bar_size, health_bar_offset)),
				default_static = UIWidget.init(mod:create_static_widget(health_bar_size, health_bar_offset))
			}
			self._health_widgets = {
				health_dynamic = UIWidget.init(mod:create_dynamic_health_widget(health_bar_size, health_bar_offset))
			}
			self._equipment_widgets.loadout_dynamic = UIWidget.init(mod:create_dynamic_loadout_widget(health_bar_size, health_bar_offset))

			self._widgets.default_dynamic = self._default_widgets.default_dynamic
			self._widgets.default_static = self._default_widgets.default_static
			self._widgets.health_dynamic = self._health_widgets.health_dynamic
			self._widgets.loadout_dynamic = self._equipment_widgets.loadout_dynamic

			UIRenderer.clear_scenegraph_queue(self.ui_renderer)

			self.slot_equip_animations = {}
			self.bar_animations = {}
			self.slot_equip_animations  = {}

			if self._frame_index then
				self:_widget_by_name("health_dynamic").content.hp_bar.texture_id = "teammate_hp_bar_color_tint_" .. self._frame_index
				self:_widget_by_name("health_dynamic").content.total_health_bar.texture_id = "teammate_hp_bar_" .. self._frame_index
			end

			self:_set_widget_dirty(self._default_widgets.default_dynamic)
			self:_set_widget_dirty(self._default_widgets.default_static)
			self:_set_widget_dirty(self._health_widgets.health_dynamic)
			self:_set_widget_dirty(self._equipment_widgets.loadout_dynamic)

			self:reset()
			-- self:set_visible(true)
			self:set_dirty()
		end)
	else
		mod:pcall(function()
			if self._health_widgets then
				UIWidget.destroy(self.ui_renderer, self._health_widgets.health_dynamic)
				UIWidget.destroy(self.ui_renderer, self._ability_widgets.ability_dynamic)
			end

			local health_bar_size = mod:get_player_hp_bar_size()
			self._mod_health_bar_size_cached = health_bar_size

			self._health_widgets = {
				health_dynamic = UIWidget.init(mod:create_player_dynamic_health_widget(health_bar_size))
			}
			self._ability_widgets = {
				ability_dynamic = UIWidget.init(mod:create_dynamic_ability_widget(health_bar_size))
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

UnitFrameUI.customhud_update = function (self, is_dead, is_wounded, has_respawned)
	mod:pcall(function()
		-- is_wounded = true
		if self._frame_index then
			self._default_widgets.default_static.style.hp_bar_rect.color = is_wounded and {200, 255, 255, 255} or {255, 105, 105, 105}
			-- self._default_widgets.default_static.style.hp_bar_rect2.color = is_wounded and {255, 255, 255, 255} or {255, 0, 0, 0}
			self._default_widgets.default_static.style.ult_bar_rect.color = is_wounded and {200, 255, 255, 255} or {255, 105, 105, 105}
			self._default_widgets.default_static.style.ammo_bar_rect.color = is_wounded and {200, 255, 255, 255} or {255, 105, 105, 105}

			if has_respawned then
				-- self._widgets.health_dynamic.content.hp_bar.texture_id = "hud_teammate_ammo_bar_fill"
				self._widgets.health_dynamic.style.hp_bar.color = {100, 255, 255, 255}
			else
				-- self._widgets.health_dynamic.content.hp_bar.texture_id = "teammate_hp_bar_color_tint_1"
				self._widgets.health_dynamic.style.hp_bar.color = {255, 255, 255, 255}
			end
		else
			if mod.custom_player_widget then
				mod.custom_player_widget.style.hp_bar_rect.color = is_wounded and {200, 255, 255, 255} or {255, 105, 105, 105}
				-- mod.custom_player_widget.style.hp_bar_rect2.color = is_wounded and {255, 255, 255, 255} or {255, 0, 0, 0}
				mod.custom_player_widget.style.ult_bar_rect.color = is_wounded and {200, 255, 255, 255} or {255, 105, 105, 105}
				mod.custom_player_widget.style.ammo_bar_rect.color = is_wounded and {200, 255, 255, 255} or {255, 105, 105, 105}
			end
		end
	end)
end

--- Update the ability_bar progress for other players.
mod:hook("UnitFrameUI.set_ability_percentage", function (func, self, ability_percent)
	mod:pcall(function()
		if self._frame_index then
			self._default_widgets.default_static.content.ability_bar.bar_value = ability_percent
		end
	end)
	return func(self, ability_percent)
end)

mod:hook("UnitFramesHandler._sync_player_stats", function (func, self, unit_frame)
	func(self, unit_frame)


	mod:pcall(function()
		local unit_frame_ui = unit_frame.widget
		local player_data = unit_frame.player_data
		local data = unit_frame.data

		if player_data then
			unit_frame_ui._mod_display_warning_overlay = not data.is_dead and (data.is_knocked_down or (data.needs_help and not data.assisted_respawn))
			unit_frame_ui:customhud_update(data.is_dead, data.is_wounded, data.assisted_respawn)
		end
	end)
end)

mod:hook("UnitFrameUI.set_visible", function(func, self, visible)
	if visible and self._is_visible ~= visible then
		self._mod_resync = true
	end
	return func(self, visible)
end)

local function ufUI_update(self, dt, t, player_unit) -- luacheck: ignore dt t
	if self._mod_reloaded then
		self._mod_reloaded = nil
		mod.do_reload = false
	end

	local health_bar_size, health_bar_offset = mod:get_hp_bar_size_and_offset(player_unit)
	self._mod_health_bar_size = health_bar_size
	self._mod_health_bar_offset = health_bar_offset

	if self._frame_index then
		mod:pcall(function()
			if (not self._mod_reloaded and (mod.do_reload or not tablex.deepcompare(self._mod_health_bar_size_cached, health_bar_size))) then
				if not self._mod_reloaded then
					self._mod_reloaded = true
				end

				self._mod_resync = true

				self._mod_health_bar_size_cached = health_bar_size

				if self._default_widgets then
					UIWidget.destroy(self.ui_renderer, self._default_widgets.default_dynamic)
					UIWidget.destroy(self.ui_renderer, self._default_widgets.default_static)
					UIWidget.destroy(self.ui_renderer, self._health_widgets.health_dynamic)
					UIWidget.destroy(self.ui_renderer, self._equipment_widgets.loadout_dynamic)
				end

				self._default_widgets = {
					default_dynamic = UIWidget.init(mod:create_dynamic_portait_widget(health_bar_size, health_bar_offset)),
					default_static = UIWidget.init(mod:create_static_widget(health_bar_size, health_bar_offset))
				}
				self._health_widgets = {
					health_dynamic = UIWidget.init(mod:create_dynamic_health_widget(health_bar_size, health_bar_offset))
				}
				self._equipment_widgets.loadout_dynamic = UIWidget.init(mod:create_dynamic_loadout_widget(health_bar_size, health_bar_offset))

				self._widgets.default_dynamic = self._default_widgets.default_dynamic
				self._widgets.default_static = self._default_widgets.default_static
				self._widgets.health_dynamic = self._health_widgets.health_dynamic
				self._widgets.loadout_dynamic = self._equipment_widgets.loadout_dynamic

				UIRenderer.clear_scenegraph_queue(self.ui_renderer)
				self.slot_equip_animations = {}
				self.bar_animations = {}
				self.slot_equip_animations  = {}

				self:_widget_by_name("health_dynamic").content.hp_bar.texture_id = "teammate_hp_bar_color_tint_" .. self._frame_index
				self:_widget_by_name("health_dynamic").content.total_health_bar.texture_id = "teammate_hp_bar_" .. self._frame_index

				self:reset()

				self:_set_widget_dirty(self._default_widgets.default_dynamic)
				self:_set_widget_dirty(self._default_widgets.default_static)
				self:_set_widget_dirty(self._health_widgets.health_dynamic)
				self:_set_widget_dirty(self._equipment_widgets.loadout_dynamic)

				-- self:set_dirty()
			end
			-- self:set_visible(true)
			-- self:set_dirty()
		end)
	else
		if not self._mod_reloaded
		and (mod.do_reload or not tablex.deepcompare(self._mod_health_bar_size_cached, health_bar_size)) then
			mod:pcall(function()
				if self._health_widgets then
					UIWidget.destroy(self.ui_renderer, self._health_widgets.health_dynamic)
					UIWidget.destroy(self.ui_renderer, self._ability_widgets.ability_dynamic)
				end
			end)

			if not self._mod_reloaded then
				self._mod_reloaded = true
			end
			self._mod_health_bar_size_cached = health_bar_size

			mod.player_offset_x = -health_bar_size[1]/2 + mod:get(mod.SETTING_NAMES.PLAYER_UI_OFFSET)

			self._health_widgets = {
				health_dynamic = UIWidget.init(mod:create_player_dynamic_health_widget(health_bar_size))
			}
			self._widgets.health_dynamic = self._health_widgets.health_dynamic
			self:_set_widget_dirty(self._health_widgets.health_dynamic)

			self._ability_widgets = {
				ability_dynamic = UIWidget.init(mod:create_dynamic_ability_widget(health_bar_size))
			}
			self._widgets.ability_dynamic = self._ability_widgets.ability_dynamic
			self:_set_widget_dirty(self._ability_widgets.ability_dynamic)

			mod.custom_player_widget = UIWidget.init(mod:get_custom_player_widget_def(health_bar_size))

			self:reset()

			self:set_dirty()
		end

		-- self:_set_widget_dirty(self._default_widgets.default_dynamic)
		-- self:_set_widget_dirty(self._default_widgets.default_static)
		-- self:_set_widget_dirty(self._health_widgets.health_dynamic)
		-- self:_set_widget_dirty(self._ability_widgets.ability_dynamic)
		-- self:set_dirty()
	end

	if self._frame_index then
		mod:pcall(function()
			-- self._portrait_widgets.portrait_static.content.scale = 1
			self._portrait_widgets.portrait_static.style.texture_1.size = { 0, 0 }
			self._default_widgets.default_static.style.character_portrait.texture_size = { 86*0.55, 108*0.55 }
			self._default_widgets.default_static.style.character_portrait.offset = { -105, -32, 1 }

			self._default_widgets.default_dynamic.style.portrait_icon.size = { 86*0.55, 108*0.55 }
			self._default_widgets.default_dynamic.style.portrait_icon.offset = { -105, -32, 10 }

			self._default_widgets.default_dynamic.style.connecting_icon.offset = { -25, -70, 20 }

			mod.others_items_offsets = mod.others_items_offsets_horizontal_align

			local portrait_left = mod:get(mod.SETTING_NAMES.PARTY_UI_ORIENTATION) == mod.ORIENTATIONS.VERTICAL
			if portrait_left then
				self._default_widgets.default_static.style.character_portrait.offset = { -180, -80, 1 }
				self._default_widgets.default_dynamic.style.portrait_icon.offset = { -180, -80, 10 }
				mod.others_items_offsets = mod.others_items_offsets_vertical_align
			end

			local default_static_style = self._default_widgets.default_static.style
			local player_name_offset_x = -115 + health_bar_size[1]/2
			local player_name_offset_y = -94
			default_static_style.player_name.horizontal_alignment = "center"
			default_static_style.player_name_shadow.horizontal_alignment = "center"

			if portrait_left then
				default_static_style.player_name.horizontal_alignment = "left"
				default_static_style.player_name_shadow.horizontal_alignment = "left"
				player_name_offset_x = -117
				player_name_offset_y = -94
			end
			default_static_style.player_name.offset[1] = player_name_offset_x
			default_static_style.player_name_shadow.offset[1] = player_name_offset_x+1

			default_static_style.player_name.offset[2] = player_name_offset_y
			default_static_style.player_name_shadow.offset[2] = player_name_offset_y-1

			default_static_style.player_level.offset[1] = -55
			default_static_style.player_level.offset[2] = -15

			self._portrait_widgets.portrait_static.content.level = ""

			-- self._default_widgets.default_static.content.player_name = "Big McLarge Huge"
		end)
	else
		self:set_position(0, 0)
	end

	-- DEBUG
	if debug_favs then
		self:set_visible(true)
		self._dirty = true
	end
end

mod:hook("UnitFramesHandler.update", function(func, self, dt, t, ignore_own_player)
	if not self._is_visible then
		return
	end

	for _, unit_frame in ipairs(self._unit_frames) do
		if mod.do_reload or unit_frame.widget._mod_resync then
			table.clear(unit_frame.data)
			unit_frame.widget._mod_resync = false
		end
	end

	local function uf_comparison(uf_first, uf_second)
		local hp_bar_size_first = mod:get_hp_bar_size_and_offset(uf_first.player_data.player_unit)[1]
		local hp_bar_size_second = mod:get_hp_bar_size_and_offset(uf_second.player_data.player_unit)[1]

		return hp_bar_size_first > hp_bar_size_second
	end

	for index, unit_frame in ipairs(self._unit_frames) do
		if index ~= 1 or not ignore_own_player then
			ufUI_update(unit_frame.widget, dt, t, unit_frame.player_data.player_unit)
		end
	end

	local i = 1
	for index, unit_frame in tablex.sortv(self._unit_frames, uf_comparison) do
		if index ~= 1 then
			if mod:get(mod.SETTING_NAMES.PARTY_UI_ORIENTATION) == mod.ORIENTATIONS.VERTICAL then
				unit_frame.widget:set_position(205, 160+(i-1)*110)
			else
				local scale = 1
				if mod:get(mod.SETTING_NAMES.HP_BAR_SIZE_METHOD) ~= mod.HP_BAR_SIZE_METHODS.DEFAULT then
					scale = mod:get(mod.SETTING_NAMES.HP_BAR_SIZE_SCALE_BY) / 100
				end
				unit_frame.widget:set_position(150+(i-1)*145+((i-1)*105*scale), 150)
			end

			i = i + 1
		end
	end

	func(self, dt, t, ignore_own_player)
end)

local did_once = false -- luacheck: ignore did_once
mod:hook("UnitFrameUI.draw", function (func, self, dt) -- luacheck: ignore func
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

	if not self.ufUI_draw_warning_icon then
		self.ufUI_draw_warning_icon = mod.ufUI_draw_warning_icon
	end

	-- if true then
	if self._mod_display_warning_overlay then
		self:ufUI_draw_warning_icon(dt)
	end
end)

mod.warning_icon_alpha_up = false
mod.warning_icon_color = {255, 255, 0, 0}
mod.ufUI_draw_warning_icon = function(self, dt)
	if not mod.gui and Managers.world:world("top_ingame_view") then
		mod:create_gui()
	end

	if not mod.gui then
		return
	end

	local color = mod.warning_icon_color
	color[1] = color[1] + 100*dt*(mod.warning_icon_alpha_u and 1 or -1)
	if color[1] < 150 then
		mod.warning_icon_alpha_u = true
		color[1] = 150
	end
	if color[1] > 255 then
		mod.warning_icon_alpha_u = false
		color[1] = 255
	end

	local black = Color(color[1], 0, 0, 0)
	local draw_color = Color(unpack(color))

	local position2dt = self.ui_scenegraph.pivot.world_position
	position2dt[1] = position2dt[1] + self._mod_health_bar_size[1] - 95
	position2dt[2] = position2dt[2] - 123
	local offset_vis = {0, 0, 0}

	local font_name, font_material, font_size = mod:fonts(60)
	Gui.text(mod.gui, "!", font_material, font_size, font_name, Vector2(position2dt[1]+1+offset_vis[1], position2dt[2]-1+offset_vis[2]), black)
	Gui.text(mod.gui, "!", font_material, font_size, font_name, Vector2(position2dt[1]+1+offset_vis[1], position2dt[2]+1+offset_vis[2]), black)
	Gui.text(mod.gui, "!", font_material, font_size, font_name, Vector2(position2dt[1]-1+offset_vis[1], position2dt[2]-1+offset_vis[2]), black)
	Gui.text(mod.gui, "!", font_material, font_size, font_name, Vector2(position2dt[1]-1+offset_vis[1], position2dt[2]+1+offset_vis[2]), black)
	Gui.text(mod.gui, "!", font_material, font_size, font_name, Vector2(position2dt[1]+offset_vis[1], position2dt[2]+offset_vis[2]), draw_color)
end

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

EquipmentUI._customhud_update_ammo = function (self, left_hand_wielded_unit, right_hand_wielded_unit, item_template) -- luacheck: ignore self
	local ammo_extension

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
	    mod.custom_player_widget.content.ammo_bar.bar_value = remaining_ammo / max_ammo
	end
end

mod:hook("EquipmentUI._create_ui_elements", function (func, ...)
	local original_init_scenegraph = UISceneGraph.init_scenegraph
	UISceneGraph.init_scenegraph = function(scenegraph_definition)
		scenegraph_definition.slot.horizontal_alignment = "center"
		scenegraph_definition.slot.position = { 0, 0, -8 }
		return original_init_scenegraph(scenegraph_definition)
	end
	func(...)
	UISceneGraph.init_scenegraph = original_init_scenegraph
end)

mod:hook("EquipmentUI.draw", function (func, self, dt)
	if not mod.custom_player_widget then
		local health_bar_size = mod:get_player_hp_bar_size()

		mod.player_offset_x = -health_bar_size[1]/2 + mod:get(mod.SETTING_NAMES.PLAYER_UI_OFFSET)

		mod.custom_player_widget = UIWidget.init(mod:get_custom_player_widget_def(health_bar_size))
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

	UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, render_settings)

	-- update player consumables slots
	for i,slot_name in ipairs({"slot_healthkit", "slot_potion", "slot_grenade"}) do
		local widget_slot_name = "item_slot_"..i
		local slot_bg_name = "bg_slot_"..i
		local slot_data = self._slot_widgets[i+2]
		local orig_slot_style = slot_data.style
		if slot_data.content.visible and orig_slot_style.texture_icon.color[1] ~= 0  then
			mod.custom_player_widget.content[widget_slot_name].texture_id = slot_data.content.texture_icon
			mod.custom_player_widget.style[widget_slot_name].color[1] = 255
			mod.custom_player_widget.style[widget_slot_name].color[2] = 255
			mod.custom_player_widget.style[widget_slot_name].color[3] =	255
			mod.custom_player_widget.style[widget_slot_name].color[4] = 255
			-- mod.custom_player_widget.style[widget_slot_name].color = {255, 138,43,226}
		else
			mod.custom_player_widget.content[widget_slot_name].texture_id = empty_slot_icons[slot_name]
			mod.custom_player_widget.style[widget_slot_name].color[1] = 75
			mod.custom_player_widget.style[slot_bg_name].color[1] = 75
		end

			mod.custom_player_widget.style[widget_slot_name].color[1] = 0
			mod.custom_player_widget.style[slot_bg_name].color[1] = 0
	end
	UIRenderer.draw_widget(ui_renderer, mod.custom_player_widget)

	UIRenderer.end_pass(ui_renderer)

	mod:pcall(function()
		for _, widget in ipairs( self._ammo_widgets ) do
			widget.offset[1] = mod:get(mod.SETTING_NAMES.AMMO_BAR_OFFSET_X)
			widget.offset[2] = mod:get(mod.SETTING_NAMES.AMMO_BAR_OFFSET_Y)
		end
	end)

	-- self._dirty = true

	self._show_ammo_meter = true

	local original_draw_widget = UIRenderer.draw_widget
	UIRenderer.draw_widget = function(ui_renderer, ui_widget) -- luacheck: ignore ui_renderer
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
			widget.offset[1] = widget.offset_original[1] - 140 - 70 + mod.global_offset_x + mod:get(mod.SETTING_NAMES.PLAYER_UI_OFFSET)
			widget.offset[2] = widget.offset_original[2] + 68 + 5 + mod.global_offset_y
		end
	end)

	func(self, dt)

	UIRenderer.draw_widget = original_draw_widget
end)

--- BuffUI stuff ---
local buff_ui_definitions = local_require("scripts/ui/hud_ui/buff_ui_definitions")
-- local ALIGNMENT_DURATION_TIME = 0--0.3
-- local MAX_NUMBER_OF_BUFFS = buff_ui_definitions.MAX_NUMBER_OF_BUFFS
local BUFF_SIZE = buff_ui_definitions.BUFF_SIZE
local BUFF_SPACING = buff_ui_definitions.BUFF_SPACING
mod:hook("BuffUI._align_widgets", function (func, self) -- luacheck: ignore func
	local horizontal_spacing = BUFF_SIZE[1] + BUFF_SPACING

	for index, data in ipairs(self._active_buffs) do
		local widget = data.widget
		local widget_offset = widget.offset
		local buffs_direction = mod:get(mod.SETTING_NAMES.BUFFS_DIRECTION) == mod.DIRECTIONS.RIGHT and 1 or -1
		local target_position = buffs_direction*(index - 1)*horizontal_spacing + mod:get_player_hp_bar_size()[1]/2 + 20
		data.target_position = target_position
		data.target_distance = math.abs(widget_offset[1] - target_position)

		widget.offset[1] = widget.offset[1] + mod:get(mod.SETTING_NAMES.BUFFS_OFFSET_X)

		widget.offset[2] = -8

		self:_set_widget_dirty(widget)
	end

	self:set_dirty()

	self._alignment_duration = 0
end)

mod:hook("BuffUI._add_buff", function (func, self, buff, ...)
	if buff.buff_type == "victor_bountyhunter_passive_infinite_ammo_buff"
	  or buff.buff_type == "grimoire_health_debuff"
	  or buff.buff_type == "markus_huntsman_passive_crit_aura_buff" then
		return false
	end

	return func(self, buff, ...)
end)

mod:hook("BuffUI._update_pivot_alignment", function (func, self, dt) -- luacheck: ignore func dt
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

mod:hook("BuffUI.draw", function(func, self, dt)
	mod:pcall(function()
		local buffs_direction = mod:get(mod.SETTING_NAMES.BUFFS_DIRECTION)
		if self._mod_cached_buffs_direction ~= buffs_direction then
			self._mod_cached_buffs_direction = buffs_direction
			self:_align_widgets()
			self:_on_resolution_modified()
		end
		local buffs_offset_x = mod:get(mod.SETTING_NAMES.BUFFS_OFFSET_X)
		if self._mod_cached_buffs_offset_x ~= buffs_offset_x then
			self._mod_cached_buffs_offset_x = buffs_offset_x
			self.ui_scenegraph.pivot.local_position[1] = buffs_offset_x
			self:_on_resolution_modified()
		end
		local player_hp_bar_size = mod:get_player_hp_bar_size()
		if mod.do_reload or not tablex.deepcompare(self._mod_player_health_bar_size_cached, player_hp_bar_size) then
			self._mod_player_health_bar_size_cached = player_hp_bar_size
			self:_align_widgets()
		end
	end)
	return func(self, dt)
end)

mod:hook("BuffUI._create_ui_elements", function (func, ...)
	local original_init_scenegraph = UISceneGraph.init_scenegraph
	UISceneGraph.init_scenegraph = function(scenegraph_definition) -- luacheck: ignore scenegraph_definition
		return original_init_scenegraph(mod.buff_ui_scenegraph_definition)
	end
	func(...)
	UISceneGraph.init_scenegraph = original_init_scenegraph
end)

mod:hook("AbilityUI._create_ui_elements", function (func, ...)
	local original_init_scenegraph = UISceneGraph.init_scenegraph
	UISceneGraph.init_scenegraph = function(scenegraph_definition) -- luacheck: ignore scenegraph_definition
		return original_init_scenegraph(mod.abilityUI_scenegraph_definition)
	end
	func(...)
	UISceneGraph.init_scenegraph = original_init_scenegraph
end)

mod:hook("AbilityUI.draw", function (func, self, dt) -- luacheck: ignore func
	-- pdump(self._widgets, "AbilityUI._widgets")
	for _, pass in ipairs( self._widgets[1].element.passes ) do
		if pass.style_id == "ability_effect_right"
			or pass.style_id == "ability_effect_top_right"
			or pass.style_id == "input_text"
			or pass.style_id == "input_text_shadow" then
				pass.content_check_function = function() return false end
		end
	end

	local player_health_bar_size = mod:get_player_hp_bar_size()

	mod:pcall(function()
		local skull_offsets = { 0, -15 }
		self._widgets[1].style.ability_effect_left.offset[1] = -player_health_bar_size[1]/2 - 50
		self._widgets[1].style.ability_effect_left.horizontal_alignment = "center"
		self._widgets[1].style.ability_effect_left.offset[2] = skull_offsets[2] - mod.ability_ui_offset_y
		self._widgets[1].style.ability_effect_top_left.horizontal_alignment = "center"
		self._widgets[1].style.ability_effect_top_left.offset[1] = -player_health_bar_size[1]/2 - 50
		self._widgets[1].style.ability_effect_top_left.offset[2] = skull_offsets[2] - mod.ability_ui_offset_y
	end)

	self._widgets[1].offset[1]= -1 + mod.player_offset_x + player_health_bar_size[1]/2
	self._widgets[1].offset[2]= 56 + mod.global_offset_y + mod.ability_ui_offset_y + mod.player_offset_y
	self._widgets[1].style.ability_bar_highlight.texture_size[1] = player_health_bar_size[1]*1.09
	self._widgets[1].style.ability_bar_highlight.texture_size[2] = 50
	self._widgets[1].style.ability_bar_highlight.offset[2] = 22 + 4
	-- UIWidget.destroy(self.ui_renderer, self._widgets[1])
	-- self._widgets[1] = UIWidget.init(create_ability_widget())

	-- self:_set_widget_dirty(self._widgets[1])
	-- self._dirty = true

	local ui_renderer = self.ui_renderer
	local ui_scenegraph = self.ui_scenegraph
	local input_service = self.input_manager:get_service("ingame_menu")

	UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, self.render_settings)

	for _, widget in ipairs(self._widgets) do
		UIRenderer.draw_widget(ui_renderer, widget)
	end

	UIRenderer.end_pass(ui_renderer)
end)

mod.ChatGui_mod_set_position = function(self, x, y)
	mod:pcall(function()
		local position = self.ui_scenegraph.chat_window_root.local_position
		position[1] = x
		position[2] = y
	end)
end

mod:hook("ChatGui.update", function(func, self, ...)
	if not ChatGui.mod_set_position then
		ChatGui.mod_set_position = mod.ChatGui_mod_set_position
	end

	if not self._mod_repositioned then
		self._mod_repositioned = true
		self:mod_set_position(0, 1080/2-200)
	end

	return func(self, ...)
end)

mod.fonts = function(self, size) -- luacheck: ignore self
	if size == nil then size = 20 end
	if size >= 32 then
		return "gw_head_32", "materials/fonts/gw_head_32", size
	else
		return "gw_head_20", "materials/fonts/gw_head_32", size
	end
end

--- ingame GUI ---
mod.gui = nil
mod.create_gui = function(self)
	local top_world = Managers.world:world("top_ingame_view")
	self.gui = World.create_screen_gui(top_world, "immediate", "material", "materials/fonts/gw_fonts")
end

mod.destroy_gui = function(self)
	local top_world = Managers.world:world("top_ingame_view")
	World.destroy_gui(top_world, self.gui)
	self.gui = nil
end

mod.on_unload = function(exit_game) -- luacheck: ignore exit_game
	if mod.gui and Managers.world:world("top_ingame_view") then
		mod:destroy_gui()
	end
end

mod.on_enabled = function(is_first_call) -- luacheck: ignore is_first_call
	-- mod.do_reload = true
end

mod.on_setting_changed = function(setting_name)
	if setting_name == mod.SETTING_NAMES.PLAYER_UI_OFFSET then
		mod.do_reload = true
	end
end

mod.do_reload = true