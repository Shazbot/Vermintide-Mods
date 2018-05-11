return {
	run = function()
		local mod = new_mod("VisibleAmmo")
		mod:localization("localization/VisibleAmmo")
		mod:initialize("scripts/mods/VisibleAmmo/VisibleAmmo")
	end,
	packages = {
		"resource_packages/VisibleAmmo/VisibleAmmo"
	}
}
