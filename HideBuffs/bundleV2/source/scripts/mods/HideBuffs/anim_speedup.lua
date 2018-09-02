local mod = get_mod("HideBuffs") -- luacheck: ignore get_mod

-- luacheck: globals UISettings RewardPopupUI local_require UIAnimator EndViewStateSummary
-- luacheck: globals table EndViewStateChest

UISettings.summary_screen.bar_progress_min_time = 1
UISettings.summary_screen.bar_progress_max_time = 1.5
UISettings.chest_upgrade_score_topics_max_duration = 3.5

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