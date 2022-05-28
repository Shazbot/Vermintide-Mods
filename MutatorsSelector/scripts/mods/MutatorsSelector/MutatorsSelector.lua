local mod = get_mod("MutatorsSelector")

mod:hook(MutatorHandler, "init", function(func, self, mutators, ...) -- luacheck: no unused
	mutators = {}

	for mut_name, _ in pairs( MutatorTemplates ) do
		if mod:get(mut_name) then
			table.insert(mutators, mut_name)
		end
	end

	pcall(func, self, mutators, ...)
end)

mod:hook(MutatorHandler, "activate_mutators", function(func, self)
	if DamageUtils.is_in_inn then
		return
	end

	return func(self)
end)
