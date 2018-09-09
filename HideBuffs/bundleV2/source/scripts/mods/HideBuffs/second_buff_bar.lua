local mod = get_mod("HideBuffs") -- luacheck: ignore get_mod

-- luacheck: globals BuffUI PriorityBuffUI

mod:dofile("scripts/mods/HideBuffs/PriorityBuffUI")

-- using this the second buff bar keeps working when reloading mods, not needed normally
mod.persistent_storage = mod:persistent_table("persistent_storage")

mod:hook_safe(BuffUI, "init", function(self, ingame_ui_context) -- luacheck: ignore self
	if mod.buff_ui then
		mod.buff_ui:destroy()
	end

	mod.buff_ui = PriorityBuffUI:new(ingame_ui_context)
	mod.persistent_storage.buff_ui = mod.buff_ui
end)

mod:hook_safe(BuffUI, "update", function(self, dt, t) -- luacheck: ignore self
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

mod:hook_safe(BuffUI, "destroy", function()
	if mod.buff_ui then
		mod.buff_ui:destroy()
		mod.buff_ui = nil
		mod.persistent_storage.buff_ui = nil
	end
end)

mod:hook_safe(BuffUI, "set_visible", function(self, visible) -- luacheck: ignore self
	if mod.buff_ui then
		mod.buff_ui:set_visible(visible)
	end
end)
