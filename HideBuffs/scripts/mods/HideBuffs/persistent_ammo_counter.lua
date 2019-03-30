local mod = get_mod("HideBuffs")

mod._animate_ammo_counter_hook = function (func, self, ...)
	if mod:get(mod.SETTING_NAMES.PERSISTENT_AMMO_COUNTER) then
		self._ammo_counter_fade_delay = math.huge
	end
	return func(self, ...)
end

mod:hook(EquipmentUI, "_animate_ammo_counter", mod._animate_ammo_counter_hook)
mod:hook(GamePadEquipmentUI, "_animate_ammo_counter", mod._animate_ammo_counter_hook)

mod._set_ammo_text_focus_hook = function (func, self, focus)
	if mod:get(mod.SETTING_NAMES.PERSISTENT_AMMO_COUNTER) then
		focus = true
	end
	return func(self, focus)
end

mod:hook(EquipmentUI, "_set_ammo_text_focus", mod._set_ammo_text_focus_hook)
mod:hook(GamePadEquipmentUI, "_set_ammo_text_focus", mod._set_ammo_text_focus_hook)
