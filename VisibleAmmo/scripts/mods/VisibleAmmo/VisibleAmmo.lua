local mod = get_mod("VisibleAmmo")

--- Hooks ---
mod:hook("EquipmentUI._animate_ammo_counter", function (func, self, ...)
	self._ammo_counter_fade_delay = math.huge
	return func(self, ...)
end)

mod:hook("EquipmentUI._set_ammo_text_focus", function (func, self, focus) -- luacheck: ignore focus
	return func(self, true)
end)

--- Callbacks ---
mod.on_disabled = function(is_first_call) -- luacheck: ignore is_first_call
	mod:disable_all_hooks()
end

mod.on_enabled = function(is_first_call) -- luacheck: ignore is_first_call
	mod:enable_all_hooks()
end

