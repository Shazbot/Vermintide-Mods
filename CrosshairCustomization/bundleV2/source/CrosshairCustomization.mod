return {
	run = function()
		local mod_resources = {
			mod_script = "scripts/mods/CrosshairCustomization/CrosshairCustomization",
			mod_data = "scripts/mods/CrosshairCustomization/CrosshairCustomization_data",
			mod_localization = "scripts/mods/CrosshairCustomization/CrosshairCustomization_localization"
		}
		new_mod("CrosshairCustomization", mod_resources)
	end,
	packages = {
		"resource_packages/CrosshairCustomization/CrosshairCustomization"
	}
}
