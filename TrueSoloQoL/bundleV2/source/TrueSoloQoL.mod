return {
	run = function()
		local mod_resources = {
			mod_script = "scripts/mods/TrueSoloQoL/TrueSoloQoL",
			mod_data = "scripts/mods/TrueSoloQoL/TrueSoloQoL_data",
			mod_localization = "scripts/mods/TrueSoloQoL/TrueSoloQoL_localization"
		}
		new_mod("TrueSoloQoL", mod_resources)
	end,
	packages = {
		"resource_packages/TrueSoloQoL/TrueSoloQoL"
	}
}
