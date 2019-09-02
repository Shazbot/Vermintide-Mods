local mod = get_mod("SpawnTweaks")

-- CHECK
-- StatusSystem.rpc_status_change_bool = function (self, sender, status_id, status_bool, game_object_id, other_object_id)
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

-- CHECK
-- GenericStatusExtension.set_invisible = function (self, invisible)
mod:hook(GenericStatusExtension, "set_invisible", function(func, self, invisible)
	if mod:get(mod.SETTING_NAMES.NO_INVIS_MUTATOR)
	and invisible
	then
		return
	end

	return func(self, invisible)
end)
