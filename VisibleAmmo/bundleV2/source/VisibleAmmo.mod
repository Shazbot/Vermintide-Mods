return {
	run = function()
		local mod_resources = {
			mod_script = "scripts/mods/VisibleAmmo/VisibleAmmo",
			mod_data = "scripts/mods/VisibleAmmo/VisibleAmmo_data",
			mod_localization = "scripts/mods/VisibleAmmo/VisibleAmmo_localization"
		}
		new_mod("VisibleAmmo", mod_resources)
	end,
	packages = {
		"resource_packages/VisibleAmmo/VisibleAmmo"
	}
}
