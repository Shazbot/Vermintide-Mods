return {
	run = function()
		local mod = new_mod("Killbots")
		mod:localization("localization/Killbots")
		mod:initialize("scripts/mods/Killbots/Killbots")
	end,
	packages = {
		"resource_packages/Killbots/Killbots"
	}
}
