local mod = get_mod("SpawnTweaks")

mod:hook(StatusSystem, "rpc_status_change_bool", function(func, self, sender, status_id, status_bool, ...)
	if mod:get(mod.SETTING_NAMES.NO_INVIS_MUTATOR)
	and Managers.player.is_server
	and status_id == NetworkLookup.statuses.invisible
	and status_bool
	then
		return
	end

	return func(self, sender, status_id, status_bool, ...)
end)

mod:hook(GenericStatusExtension, "set_invisible", function(func, self, invisible)
	if mod:get(mod.SETTING_NAMES.NO_INVIS_MUTATOR)
	and invisible
	then
		return
	end

	return func(self, invisible)
end)
