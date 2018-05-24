return {
	run = function()
		local mod = new_mod("MutatorsSelector")
		mod:localization("localization/MutatorsSelector")
		mod:initialize("scripts/mods/MutatorsSelector/MutatorsSelector")
	end,
	packages = {
		"resource_packages/MutatorsSelector/MutatorsSelector"
	}
}
