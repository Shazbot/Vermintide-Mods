return {
	run = function()
		local mod = new_mod("CustomHUD")
		mod:localization("localization/CustomHUD")
		mod:initialize("scripts/mods/CustomHUD/CustomHUD")
	end,
	packages = {
		"resource_packages/CustomHUD/CustomHUD"
	}
}
