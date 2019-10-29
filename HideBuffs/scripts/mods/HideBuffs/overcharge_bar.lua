local mod = get_mod("HideBuffs")

--- Reposition the heat bar.
mod:hook_safe(OverchargeBarUI, "update", function(self)
	local charge_bar = self.charge_bar
	if not charge_bar.offset then
		charge_bar.offset = { 0, 0, 0 }
	end
	charge_bar.offset[1] = mod:get(mod.SETTING_NAMES.OTHER_ELEMENTS_HEAT_BAR_OFFSET_X)
	charge_bar.offset[2] = mod:get(mod.SETTING_NAMES.OTHER_ELEMENTS_HEAT_BAR_OFFSET_Y)
end)

--- Show ammo in clip using the overcharge bar.
-- CHECK
-- OverchargeBarUI._update_overcharge = function (self, player, dt)
mod:hook(OverchargeBarUI, "_update_overcharge", function(func, self, player, dt)
	local has_overcharge = func(self, player, dt)

	-- reset the max pip and the main bar to default size so they're not hidden
	self.charge_bar.style.max_threshold.size[2] = 10
	self.charge_bar.style.bar_1.size[2] = 10

	-- check if already using overcharge weapon
	if has_overcharge then
		return true
	end

	local show_ammo_status = mod:get(mod.SETTING_NAMES.PLAYER_UI_SHOW_CLIP_USING_OVERCHARGE)
	if not show_ammo_status or not player then
		return
	end

	local player_unit = player.player_unit

	if not Unit.alive(player_unit) then
		return
	end

	local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")
	local equipment = inventory_extension:equipment()

	if not equipment then
		return
	end

	local slot_data = equipment.slots["slot_ranged"]
	if not slot_data then
		return
	end

	local item_data = slot_data.item_data
	local item_template = BackendUtils.get_item_template(item_data)

	-- only show when currently wielding ranged weapon
	if equipment.wielded ~= item_data then
		return
	end

	if not item_template.ammo_data then
		return
	end

	local ammo_unit_hand = item_template.ammo_data.ammo_hand

	local ammo_extension
	if ammo_unit_hand == "right" then
		ammo_extension = ScriptUnit.extension(slot_data.right_unit_1p, "ammo_system")
	elseif ammo_unit_hand == "left" then
		ammo_extension = ScriptUnit.extension(slot_data.left_unit_1p, "ammo_system")
	else
		return
	end

	local ammo_count = ammo_extension:ammo_count()
	local clip_size = ammo_extension:clip_size()

	if clip_size == 1
	and (
		ammo_extension._reload_time < 0.67
		or not mod:get(mod.SETTING_NAMES.PLAYER_UI_SHOW_CLIP_ON_LONG_RELOAD_WEAPONS)
		)
	then
		return
	end

	if ammo_count and clip_size and clip_size > 0 then
	    local ammo_fraction = ammo_count / clip_size
	    local use_grey_color = mod:get(mod.SETTING_NAMES.PLAYER_UI_SHOW_CLIP_USE_GREY_COLOR)
	    local min_threshold_fraction = use_grey_color and 1 or -5
	    local max_threshold_fraction = 2
	    -- skip the bar lerp animation
	    self.charge_bar.content.internal_gradient_threshold = ammo_fraction
	    self:set_charge_bar_fraction(ammo_fraction, min_threshold_fraction, max_threshold_fraction)
	    self.charge_bar.style.max_threshold.size[2] = 0
	    if ammo_count == 0 then
				self.charge_bar.style.bar_1.size[2] = 0
	    end
	    return true
	end
end)
