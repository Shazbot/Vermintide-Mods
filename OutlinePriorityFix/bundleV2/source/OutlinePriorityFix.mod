return {
	run = function()
		local mod_resources = {
			mod_script = "scripts/mods/OutlinePriorityFix/OutlinePriorityFix",
			mod_data = "scripts/mods/OutlinePriorityFix/OutlinePriorityFix_data",
			mod_localization = "scripts/mods/OutlinePriorityFix/OutlinePriorityFix_localization"
		}
		new_mod("OutlinePriorityFix", mod_resources)
	end,
	packages = {
		"resource_packages/OutlinePriorityFix/OutlinePriorityFix"
	}
}
