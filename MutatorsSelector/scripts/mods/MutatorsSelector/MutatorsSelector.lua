local mod = get_mod("MutatorsSelector")

mod:hook(MutatorHandler, "init", function(func, self, mutators, ...) -- luacheck: no unused
	mutators = {}

	for mut_name, _ in pairs( MutatorTemplates ) do
		if mod:get(mut_name) then
			table.insert(mutators, mut_name)
		end
	end

	return func(self, mutators, ...)
end)

mod:hook(MutatorHandler, "activate_mutators", function(func, self)
	if Managers.state.game_mode
	and Managers.state.game_mode:level_key() == "inn_level"
	then
		return
	end

	return func(self)
end)
