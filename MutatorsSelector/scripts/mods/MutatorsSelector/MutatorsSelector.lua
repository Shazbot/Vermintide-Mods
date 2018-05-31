local mod = get_mod("MutatorsSelector") -- luacheck: ignore get_mod

-- luacheck: globals MutatorTemplates Localize

mod:hook("MutatorHandler.init", function(func, self, mutators, is_server, has_local_client)
	mutators = {}
	for mut_name, _ in pairs( MutatorTemplates ) do
		if mod:get(mut_name) then
			table.insert(mutators, mut_name)
		end
	end
	return func(self, mutators, is_server, has_local_client)
end)

--- Callbacks ---
mod.on_disabled = function(is_first_call) -- luacheck: ignore is_first_call
	mod:disable_all_hooks()
end

mod.on_enabled = function(is_first_call) -- luacheck: ignore is_first_call
	mod:enable_all_hooks()
end