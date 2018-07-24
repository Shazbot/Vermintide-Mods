local mod = get_mod("Penlight Lua Libraries")

if not rawget(_G, "_penlight_require_hook") then
	rawset(_G, "_penlight_require_hook", true)
	local original_require = _G.require
	_G.require = function(require_name)
		if string.find(require_name, "pl.") == 1 then
			require_name = string.gsub(require_name, "pl.", "", 1)
			require_name = "scripts/mods/Penlight Lua Libraries/pl/"..require_name
		end
		return original_require(require_name)
	end
end

-- local pl = require'pl.import_into'()
-- mod:echo("penlight init done")
-- mod:echo(pl.List({1,2,3}))