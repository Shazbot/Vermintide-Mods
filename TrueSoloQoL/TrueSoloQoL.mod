return {
	run = function()
		local mod = new_mod("TrueSoloQoL")
		mod:localization("localization/TrueSoloQoL")
		mod:initialize("scripts/mods/TrueSoloQoL/TrueSoloQoL")
	end,
	packages = {
		"resource_packages/TrueSoloQoL/TrueSoloQoL"
	}
}
