local mod = get_mod("HideBuffs")

mod.persistent_storage = mod.persistent_storage or mod:persistent_table("persistent_storage")

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
