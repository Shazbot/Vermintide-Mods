local mod = get_mod("Dofile") -- luacheck: ignore get_mod

local pl = require'pl.import_into'()

-- luacheck: globals loadstring

mod.do_exec = function() -- luacheck: ignore self
	if not mod:is_enabled() then
		return
	end

	mod:pcall(function()
		loadstring(pl.utils.readfile("../mods/exec.lua"))()
	end)
end

--- Callbacks ---
mod.on_disabled = function(is_first_call) -- luacheck: ignore is_first_call
	mod:disable_all_hooks()
end

mod.on_enabled = function(is_first_call) -- luacheck: ignore is_first_call
	mod:enable_all_hooks()
end