local mod = get_mod("HideBuffs")

mod:dofile("scripts/mods/HideBuffs/PriorityBuffUI")

-- using this the second buff bar keeps working when reloading mods, not needed normally
mod.persistent = mod:persistent_table("persistent")

mod:hook_safe(BuffUI, "init", function(self, parent, ingame_ui_context) -- luacheck: ignore self
	if mod.buff_ui then
		mod.buff_ui:destroy()
	end

	mod.buff_ui = PriorityBuffUI:new(ingame_ui_context)
	mod.persistent.buff_ui = mod.buff_ui
end)

mod:hook_safe(BuffUI, "update", function(self, dt, t) -- luacheck: ignore self
	if not mod.buff_ui
	and mod.persistent.buff_ui then
		mod.buff_ui = mod.persistent.buff_ui
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
		mod.persistent.buff_ui = nil
	end
end)

mod:hook_safe(BuffUI, "set_visible", function(self, visible) -- luacheck: ignore self
	if mod.buff_ui then
		mod.buff_ui:set_visible(visible)
	end
end)

--- Disable priority_buff popups.
--- e.g. Paced Strikes, Tranquility
mod:hook(BuffPresentationUI, "draw", function(func, self, dt)
	if mod:get(mod.SETTING_NAMES.SECOND_BUFF_BAR)
	and mod:get(mod.SETTING_NAMES.SECOND_BUFF_BAR_DISABLE_BUFF_POPUPS) then
		return
	end

	return func(self, dt)
end)
