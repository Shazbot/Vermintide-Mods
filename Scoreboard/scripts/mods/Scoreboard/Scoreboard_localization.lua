-- luacheck: ignore get_mod
local mod = get_mod("Scoreboard")

local pl = require'pl.import_into'()

mod.localizations = mod.localizations or pl.Map()
mod.localizations:update({
	mod_description = {
		en = "Scoreboard description"
	},
})

return mod.localizations