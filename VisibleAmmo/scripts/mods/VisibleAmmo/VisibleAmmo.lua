local mod = get_mod("VisibleAmmo") -- luacheck: ignore get_mod

-- luacheck: globals EquipmentUI GamePadEquipmentUI

--- Hooks ---
mod._animate_ammo_counter_hook = function (func, self, ...)
	self._ammo_counter_fade_delay = math.huge
	return func(self, ...)
end

mod:hook(EquipmentUI, "_animate_ammo_counter", mod._animate_ammo_counter_hook)
mod:hook(GamePadEquipmentUI, "_animate_ammo_counter", mod._animate_ammo_counter_hook)

mod._set_ammo_text_focus_hook = function (func, self, focus) -- luacheck: ignore focus
	return func(self, true)
end

mod:hook(EquipmentUI, "_set_ammo_text_focus", mod._set_ammo_text_focus_hook)
mod:hook(GamePadEquipmentUI, "_set_ammo_text_focus", mod._set_ammo_text_focus_hook)
