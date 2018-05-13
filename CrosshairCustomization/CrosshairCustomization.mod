return {
	run = function()
		local mod = new_mod("CrosshairCustomization")
		mod:localization("localization/CrosshairCustomization")
		mod:initialize("scripts/mods/CrosshairCustomization/CrosshairCustomization")
	end,
	packages = {
		"resource_packages/CrosshairCustomization/CrosshairCustomization"
	}
}
