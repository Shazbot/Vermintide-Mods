local mod = get_mod("HideBuffs") -- luacheck: ignore get_mod

-- luacheck: globals BuffUI PriorityBuffUI

mod:dofile("scripts/mods/HideBuffs/PriorityBuffUI")

mod.persistent_storage = mod:persistent_table("persistent_storage")

mod:hook(BuffUI, "init", function(func, self, ingame_ui_context)
	func(self, ingame_ui_context)

	if mod.buff_ui then
		mod.buff_ui:destroy()
	end

	mod.buff_ui = PriorityBuffUI:new(ingame_ui_context)
	mod.persistent_storage.buff_ui = mod.buff_ui
end)

mod:hook(BuffUI, "update", function(func, self, dt, t)
	func(self, dt, t)

	if not mod.buff_ui
	and mod.persistent_storage.buff_ui then
		mod.buff_ui = mod.persistent_storage.buff_ui
	end

	if mod.buff_ui
	and mod:get(mod.SETTING_NAMES.SECOND_BUFF_BAR)
	then
		mod.buff_ui:update(dt, t)
	end
end)

mod:hook(BuffUI, "destroy", function(func, self)
	func(self)

	if mod.buff_ui then
		mod.buff_ui:destroy()
		mod.buff_ui = nil
		mod.persistent_storage.buff_ui = nil
	end
end)

mod:hook(BuffUI, "set_visible", function(func, self, visible)
	func(self, visible)

	if mod.buff_ui then
		mod.buff_ui:set_visible(visible)
	end
end)
