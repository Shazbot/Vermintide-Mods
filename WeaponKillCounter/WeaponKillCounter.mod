return {
	run = function()
		local mod = new_mod("WeaponKillCounter")
		mod:localization("localization/WeaponKillCounter")
		mod:initialize("scripts/mods/WeaponKillCounter/WeaponKillCounter")
	end,
	packages = {
		"resource_packages/WeaponKillCounter/WeaponKillCounter"
	}
}
