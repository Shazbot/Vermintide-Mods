return {
	run = function()
		local mod_resources = {
			mod_script = "scripts/mods/NeuterUltEffects/NeuterUltEffects",
			mod_data = "scripts/mods/NeuterUltEffects/NeuterUltEffects_data",
			mod_localization = "scripts/mods/NeuterUltEffects/NeuterUltEffects_localization"
		}
		new_mod("NeuterUltEffects", mod_resources)
	end,
	packages = {
		"resource_packages/NeuterUltEffects/NeuterUltEffects"
	}
}
