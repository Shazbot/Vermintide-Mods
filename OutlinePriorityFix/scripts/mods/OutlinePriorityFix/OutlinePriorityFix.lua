local mod = get_mod("OutlinePriorityFix")

--- Using walterr's Vermintide 1 mod as the base. Credits and gratitude to him.

-- luacheck: globals OutlineSettings Color Managers script_data ScriptUnit

local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
}

mod:initialize_data(mod_data)

--- Callbacks ---
mod.on_disabled = function(is_first_call) -- luacheck: ignore is_first_call
	mod:disable_all_hooks()
end

mod.on_enabled = function(is_first_call) -- luacheck: ignore is_first_call
	mod:enable_all_hooks()
end

--- Mod Logic ---
-- Enables or disables the red outline. We don't actually need to do this, OutlineSystem.update would
-- do it eventually, but there is a brief random delay before it does, and this avoids that.
local function set_outline_immediately(unit, outline_extn, enable)
	local outline_system = Managers.state.entity:system("outline_system")
	local c = outline_extn.outline_color.channel
	local channel = Color(c[1], c[2], c[3], c[4])
	outline_system:outline_unit(unit, outline_extn.flag, channel, enable, outline_extn.apply_method, false)
	outline_extn[(enable and "outlined") or "reapply"] = true
end

-- Wraps the given extension's set_pinged function in a function that checks the
-- _tftweak_override_ping variable and only calls the real set_pinged if it's false.
local function wrap_set_pinged(outline_extn)
	local real_set_pinged = outline_extn.set_pinged

	outline_extn.set_pinged = function (pinged)
		if outline_extn._tftweak_override_ping then
			if pinged then
				if not outline_extn.pinged then
					outline_extn.previous_flag = outline_extn.flag
				end
				outline_extn.flag = "outline_unit"
			else
				outline_extn.flag = outline_extn.previous_flag
			end
			outline_extn.pinged = pinged
		else
			real_set_pinged(pinged)
		end
	end
end

mod:hook("ActionTrueFlightBowAim.client_owner_post_update", function(orig_func, self, ...)
	local old_target = self.target
	orig_func(self, ...)
	local new_target = self.target

	-- If the target has changed, set _tftweak_override_ping on the new target (if any) to cause the
	-- red outline to be prioritized over the blue, also remove _tftweak_override_ping from the old
	-- target (if any).
	if new_target ~= old_target then
		local outline_extn = new_target and ScriptUnit.has_extension(new_target, "outline_system")
		if outline_extn and outline_extn.method == "ai_alive" then
			if outline_extn._tftweak_override_ping == nil then
				wrap_set_pinged(outline_extn)
			end
			outline_extn._tftweak_override_ping = true
			set_outline_immediately(new_target, outline_extn, true)
		end
		outline_extn = old_target and ScriptUnit.has_extension(old_target, "outline_system")
		if outline_extn then
			outline_extn._tftweak_override_ping = false
			set_outline_immediately(old_target, outline_extn, false)
		end
	end
end)

mod:hook("ActionTrueFlightBowAim.finish", function(orig_func, self, ...)
	local outline_extn = self.target and ScriptUnit.has_extension(self.target, "outline_system")
	if outline_extn then
		-- Tidy up.
		outline_extn._tftweak_override_ping = false
		outline_extn.reapply = true
	end

	return orig_func(self, ...)
end)

-- Replace OutlineSystem.update with a modified version of the original code which prioritizes the
-- target-lock outline over the pinged outline (unfortunately I can't see any good way to do this by
-- just hooking the function.
mod:hook("OutlineSystem.update", function (func, self, context, t)  -- luacheck: ignore func context t
	if not mod:is_enabled() then
		return func(self, context, t)
	end

	if #self.units == 0 then
		return
	end

	if script_data.disable_outlines then
		return
	end

	local checks_per_frame = 4
	local current_index = self.current_index
	local units = self.units

	for i = 1, checks_per_frame, 1 do -- luacheck: ignore i
		current_index = current_index + 1

		if not units[current_index] then
			current_index = 1
		end

		local unit = self.units[current_index]
		local extension = self.unit_extension_data[unit]

		if extension or false then
			local is_pinged = extension.pinged
			-- This is the modified code (the next three lines were added).
			if is_pinged and extension._tftweak_override_ping and self[extension.method](self, unit, extension) then
				is_pinged = false
			end
			local method = (is_pinged and extension.pinged_method) or extension.method

			if self[method](self, unit, extension) then
				if not extension.outlined or extension.new_color or extension.reapply then
					local c = (is_pinged and OutlineSettings.colors.player_attention.channel) or extension.outline_color.channel
					local channel = Color(c[1], c[2], c[3], c[4])

					self:outline_unit(unit, extension.flag, channel, true, extension.apply_method, extension.reapply)

					extension.outlined = true
				end
			elseif extension.outlined or extension.new_color or extension.reapply then
				local c = extension.outline_color.channel
				local channel = Color(c[1], c[2], c[3], c[4])

				self:outline_unit(unit, extension.flag, channel, false, extension.apply_method, extension.reapply)

				extension.outlined = false
			end

			extension.new_color = false
			extension.reapply = false
		end
	end

	self.current_index = current_index
end)