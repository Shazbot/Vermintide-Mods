local mod = get_mod("HideBuffs")

mod:hook(HeroViewStateLoot, "_open_chest", function(func, self, selected_item)
	self._mod_show_loot = false
	return func(self, selected_item)
end)

mod:hook(HeroViewStateLoot, "_handle_input", function(func, self, dt, t)
	if mod:get(mod.SETTING_NAMES.FASTER_CHEST_OPENING) then
		if not self._wait_for_backend_reload
		and self._chest_presentation_active
		and not self._mod_show_loot
		then
			self._mod_show_loot = true
			local active_reward_options = self._active_reward_options
			for index, _ in ipairs(self._option_widgets) do
				if active_reward_options[index] then
					self:open_reward_option(index)
				end
			end
		end
	end

	return func(self, dt, t)
end)

mod:hook(HeroViewStateLoot, "_update_chest_open_wait_time", function(func, self, dt, t)
	if not mod:get(mod.SETTING_NAMES.FASTER_CHEST_OPENING) then
		return func(self, dt, t)
	end

	local chest_open_wait_duration = self._chest_open_wait_duration

	if not chest_open_wait_duration then
		return
	end

	chest_open_wait_duration = chest_open_wait_duration + dt
	local progress = 1 -- just changing this line

	if progress == 1 then
		self._camera_look_up_duration = 0
		self._reward_options_entry_progress = 0

		self:play_sound("play_gui_chest_reward_enter")

		self._chest_open_wait_duration = nil
	else
		self._chest_open_wait_duration = chest_open_wait_duration
	end
end)

mod:hook(HeroViewStateLoot, "_update_chest_zoom_in_time", function(func, self, dt, t)
	if not mod:get(mod.SETTING_NAMES.FASTER_CHEST_OPENING) then
		return func(self, dt, t)
	end

	local chest_zoom_in_duration = self._chest_zoom_in_duration

	if not chest_zoom_in_duration then
		return
	end

	chest_zoom_in_duration = chest_zoom_in_duration + dt
	local progress = 1 -- just changing this line
	local animation_progress = math.easeOutCubic(progress)

	self:set_camera_zoom(animation_progress)
	self:set_grid_animation_progress(animation_progress)
	self:set_chest_title_alpha_progress(1 - animation_progress)

	if progress == 1 then
		self._chest_zoom_in_duration = nil
		self._chest_open_wait_duration = 0
	else
		self._chest_zoom_in_duration = chest_zoom_in_duration
	end
end)
