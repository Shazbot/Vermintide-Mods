return {
	run = function()
		local mod = new_mod("WeaponSwitch")
		mod:localization("localization/WeaponSwitch")
		mod:initialize("scripts/mods/WeaponSwitch/WeaponSwitch")
	end,
	packages = {
		"resource_packages/WeaponSwitch/WeaponSwitch"
	}
}
