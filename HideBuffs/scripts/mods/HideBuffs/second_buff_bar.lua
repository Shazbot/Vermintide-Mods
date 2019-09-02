local mod = get_mod("HideBuffs")

local pl = require'pl.import_into'()

mod:dofile("scripts/mods/HideBuffs/PriorityBuffUI")

-- using this the second buff bar keeps working when reloading mods, not needed normally
mod.persistent = mod:persistent_table("persistent")

-- CHECK
-- BuffUI.init = function (self, parent, ingame_ui_context)
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

mod:hook(PriorityBuffUI, "_sync_buffs", function(func, self, ...)
	if not mod:get(mod.SETTING_NAMES.PRIORITY_BUFFS_PRESERVE_ORDER) then
		return func(self, ...)
	end

	local before = pl.List(self._active_buffs):map(function(buff)
			return buff.template.name
		end)

	func(self, ...)

	for _, before_buff in ripairs( before ) do
		local new_index = pl.tablex.find_if(self._active_buffs, function(buff)
				return buff.template.name == before_buff
			end)
		if new_index then
			local shuffled_buff = table.remove(self._active_buffs, new_index)
			table.insert(self._active_buffs, 1, shuffled_buff)
		end
	end

	self:_align_widgets()
end)
