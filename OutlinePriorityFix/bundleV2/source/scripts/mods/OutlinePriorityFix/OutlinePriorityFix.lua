local mod = get_mod("OutlinePriorityFix") -- luacheck: ignore get_mod

--- Using walterr's Vermintide 1 mod as the base. Credits and gratitude to him.

-- luacheck: globals OutlineSettings Color Managers script_data ScriptUnit OutlineSystem
-- luacheck: globals ActionTrueFlightBowAim

-- Enables or disables the red outline. We don't actually need to do this, OutlineSystem.update would
-- do it eventually, but there is a brief random delay before it does, and this avoids that.
mod.set_outline_immediately = function(unit, outline_extn, enable)
	if outline_extn.flag then
		local outline_system = Managers.state.entity:system("outline_system")
		local c = outline_extn.outline_color.channel
		local channel = Color(c[1], c[2], c[3], c[4])
		outline_system:outline_unit(unit, outline_extn.flag, channel, enable, outline_extn.apply_method, false)
		outline_extn[(enable and "outlined") or "reapply"] = true
	end
end

-- Wraps the given extension's set_pinged function in a function that checks the
-- _tftweak_override_ping variable and only calls the real set_pinged if it's false.
mod.wrap_set_pinged = function(outline_extn)
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
			if not outline_extn.flag then
				outline_extn.flag = "outline_unit"
			end
			real_set_pinged(pinged)
		end
	end
end

mod.ActionTrueFlightBowAim_finish = function(orig_func, self, ...)
	local outline_extn = self.target and ScriptUnit.has_extension(self.target, "outline_system")
	if outline_extn then
		outline_extn._tftweak_override_ping = false
		outline_extn.set_pinged(outline_extn.pinged)
	end

	return orig_func(self, ...)
end

mod.ActionTrueFlightBowAim_client_owner_post_update = function(orig_func, self, ...)
	local old_target = self.target
	orig_func(self, ...)
	local new_target = self.target

	-- If the target has changed, set _tftweak_override_ping on the new target (if any) to cause the
	-- red outline to be prioritized over the blue, also remove _tftweak_override_ping from the old
	-- target (if any).
	if new_target then
		local outline_extn = new_target and ScriptUnit.has_extension(new_target, "outline_system")
		if outline_extn and outline_extn.method == "ai_alive" then
			if outline_extn._tftweak_override_ping == nil then
				mod.wrap_set_pinged(outline_extn)
			end
			outline_extn._tftweak_override_ping = true
			mod.set_outline_immediately(new_target, outline_extn, true)
		end
	end
	if old_target and new_target ~= old_target then
		local outline_extn = old_target and ScriptUnit.has_extension(old_target, "outline_system")
		if outline_extn then
			outline_extn._tftweak_override_ping = false
			outline_extn.set_pinged(outline_extn.pinged)
		end
	end
end

mod:hook(ActionTrueFlightBowAim, "finish", function(...) return mod.ActionTrueFlightBowAim_finish(...) end)
mod:hook(ActionTrueFlightBowAim, "client_owner_post_update", function(...) return mod.ActionTrueFlightBowAim_client_owner_post_update(...) end)
