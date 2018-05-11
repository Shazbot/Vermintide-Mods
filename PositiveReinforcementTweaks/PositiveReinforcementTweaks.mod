return {
	run = function()
		local mod = new_mod("PositiveReinforcementTweaks")
		mod:localization("localization/PositiveReinforcementTweaks")
		mod:initialize("scripts/mods/PositiveReinforcementTweaks/PositiveReinforcementTweaks")
	end,
	packages = {
		"resource_packages/PositiveReinforcementTweaks/PositiveReinforcementTweaks"
	}
}
