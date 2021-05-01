local mod = get_mod("SpawnTweaks")

-- CHECK
-- AiUtils.is_of_interest_to_gutter_runner = function (gutter_runner_unit, enemy_unit, blackboard, ignore_knocked_down)
mod:hook(AiUtils, "is_of_interest_to_gutter_runner", function(func, gutter_runner_unit, enemy_unit, blackboard, ...)
	if mod.are_specials_customized()
	and mod:get(mod.SETTING_NAMES.ASSASSINS_ALWAYS_FAIL)
	then
		if blackboard.pouncing_target then
			blackboard.ninja_vanish = true
			return false
		end
	end

	return func(gutter_runner_unit, enemy_unit, blackboard, ...)
end)

mod:hook(BTPackMasterAttackAction, "attack_success", function(func, ...)
	if mod.are_specials_customized()
	and mod:get(mod.SETTING_NAMES.PACKMASTERS_ALWAYS_FAIL)
	then
		return
	end

	return func(...)
end)

mod:hook(BTCorruptorGrabAction, "grab_player", function(func, self, t, unit, blackboard)
	if mod.are_specials_customized()
	and mod:get(mod.SETTING_NAMES.CORRUPTORS_ALWAYS_FAIL)
	then
		blackboard.attack_success = false
		blackboard.attack_aborted = true
	end

	return func(self, t, unit, blackboard)
end)
