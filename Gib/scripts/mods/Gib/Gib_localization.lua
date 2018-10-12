local mod = get_mod("Gib")

local pl = require'pl.import_into'()

mod.localizations = mod.localizations or pl.Map()

mod.localizations:update({
	mod_description = {
		en = "Tweak some gib and ragdoll values."
	},
})

return mod.localizations
