local mod = get_mod("NeuterUltEffects")

local pl = require'pl.import_into'()

--- Keep this disabled when not needed.
mod:hook(Unit, "flow_event", function(func, unit, event_name, ...)
	if mod:get(mod.SETTING_NAMES.DISABLE_PROJECTILE_TRAILS)
	and (
			event_name == "lua_trail"
			or event_name == "lua_bullet_trail"
		)
	then
		return
	end

	return func(unit, event_name, ...)
end)
mod:hook_disable(Unit, "flow_event")

--- Hook that wraps functions that make flow_event calls we want.
mod.trail_hook = function(func, ...)
	mod:hook_enable(Unit, "flow_event")
	func(...)
	mod:hook_disable(Unit, "flow_event")
end

-- functions that call lua_bullet_trail flow_event
mod:hook(ActionBountyHunterHandgun, "_shotgun_shoot", mod.trail_hook)

for _, object in ipairs( { ActionBulletSpray, ActionShotgun, ActionHandgunLock, ActionHandgun } ) do
	mod:hook(object, "client_owner_post_update", mod.trail_hook)
end

-- functions that call lua_trail flow_event
mod:hook(GenericTrailExtension, "init", mod.trail_hook)
mod:hook(PlayerProjectileHuskExtension, "initialize_projectile",  mod.trail_hook)
mod:hook(PlayerProjectileUnitExtension, "initialize_projectile",  mod.trail_hook)
