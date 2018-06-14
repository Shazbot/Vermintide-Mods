local mod = get_mod("MutatorsSelector") -- luacheck: ignore get_mod

-- luacheck: globals MutatorTemplates Localize

mod:hook(MutatorHandler, "init", function(func, self, mutators, is_server, has_local_client)
	mutators = {}
	for mut_name, _ in pairs( MutatorTemplates ) do
		if mod:get(mut_name) then
			table.insert(mutators, mut_name)
		end
	end
	return func(self, mutators, is_server, has_local_client)
end)