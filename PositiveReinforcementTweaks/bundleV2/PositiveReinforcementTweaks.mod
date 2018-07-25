return {
	run = function()
		local mod_resources = {
			mod_script = "scripts/mods/PositiveReinforcementTweaks/PositiveReinforcementTweaks",
			mod_data = "scripts/mods/PositiveReinforcementTweaks/PositiveReinforcementTweaks_data",
			mod_localization = "scripts/mods/PositiveReinforcementTweaks/PositiveReinforcementTweaks_localization"
		}
		new_mod("PositiveReinforcementTweaks", mod_resources)
	end,
	packages = {
		"resource_packages/PositiveReinforcementTweaks/PositiveReinforcementTweaks"
	}
}
