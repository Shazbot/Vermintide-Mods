local mod = get_mod("HideBuffs")

mod.persistent_storage = mod.persistent_storage or mod:persistent_table("persistent_storage")
if not mod.persistent_storage.ui_settings_backup then
	local ui_settings_backup = {}
	mod.persistent_storage.ui_settings_backup = ui_settings_backup

	ui_settings_backup.bar_progress_min_time =
		UISettings.summary_screen.bar_progress_min_time
	ui_settings_backup.bar_progress_max_time =
		UISettings.summary_screen.bar_progress_max_time
	ui_settings_backup.chest_upgrade_score_topics_max_duration =
		UISettings.chest_upgrade_score_topics_max_duration
end

mod.set_anim_ui_settings = function()
	UISettings.summary_screen.bar_progress_min_time = 1
	UISettings.summary_screen.bar_progress_max_time = 1.5
	UISettings.chest_upgrade_score_topics_max_duration = 3.5
end

mod.reset_anim_ui_settings = function()
	local ui_settings_backup = mod.persistent_storage.ui_settings_backup
	UISettings.summary_screen.bar_progress_min_time = ui_settings_backup.bar_progress_min_time
	UISettings.summary_screen.bar_progress_max_time = ui_settings_backup.bar_progress_max_time
	UISettings.chest_upgrade_score_topics_max_duration = ui_settings_backup.chest_upgrade_score_topics_max_duration
end

if mod:get(mod.SETTING_NAMES.SPEEDUP_ANIMATIONS) then
	mod.set_anim_ui_settings()
end

mod:hook(RewardPopupUI, "create_ui_elements", function(func, self, ...)
	func(self, ...)

	if mod:get(mod.SETTING_NAMES.SPEEDUP_ANIMATIONS) then
		local definitions = local_require("scripts/ui/reward_popup/reward_popup_ui_definitions")
		local animation_definitions = table.clone(definitions.animations)

		for _, anims in pairs( animation_definitions ) do
			for _, anim in ipairs( anims ) do
				anim.start_progress = anim.start_progress / 2
				anim.end_progress = anim.end_progress / 2
			end
		end
		self.ui_animator = UIAnimator:new(self.ui_scenegraph, animation_definitions)
	end
end)

mod:hook(EndViewStateSummary, "create_ui_elements", function(func, self, ...)
	func(self, ...)

	if mod:get(mod.SETTING_NAMES.SPEEDUP_ANIMATIONS) then
		local definitions = local_require("scripts/ui/views/level_end/states/definitions/end_view_state_summary_definitions")
		local animation_definitions = table.clone(definitions.animation_definitions)

		for _, anims in pairs( animation_definitions ) do
			for _, anim in ipairs( anims ) do
				anim.start_progress = anim.start_progress / 2
				anim.end_progress = anim.end_progress / 2
			end
		end
		self.ui_animator = UIAnimator:new(self.ui_scenegraph, animation_definitions)
	end
end)

mod:hook(EndViewStateChest, "create_ui_elements", function(func, self, ...)
	func(self, ...)

	if mod:get(mod.SETTING_NAMES.SPEEDUP_ANIMATIONS) then
		local definitions = local_require("scripts/ui/views/level_end/states/definitions/end_view_state_chest_definitions")
		local animation_definitions = table.clone(definitions.animation_definitions)

		for _, anims in pairs( animation_definitions ) do
			for _, anim in ipairs( anims ) do
				anim.start_progress = anim.start_progress / 2
				anim.end_progress = anim.end_progress / 2
			end
		end
		self.ui_animator = UIAnimator:new(self.ui_scenegraph, animation_definitions)
	end
end)