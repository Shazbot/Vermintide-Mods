return {
	run = function()
		local mod = new_mod("NeuterUltEffects")
		mod:localization("localization/NeuterUltEffects")
		mod:initialize("scripts/mods/NeuterUltEffects/NeuterUltEffects")
	end,
	packages = {
		"resource_packages/NeuterUltEffects/NeuterUltEffects"
	}
}
