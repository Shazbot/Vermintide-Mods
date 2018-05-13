return {
	run = function()
		local mod = new_mod("OutlinePriorityFix")
		mod:localization("localization/OutlinePriorityFix")
		mod:initialize("scripts/mods/OutlinePriorityFix/OutlinePriorityFix")
	end,
	packages = {
		"resource_packages/OutlinePriorityFix/OutlinePriorityFix"
	}
}
