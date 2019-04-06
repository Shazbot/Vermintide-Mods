local mod = get_mod("HideBuffs")

--- Overwrite LockedAndLoaded.check_if_range_is_reloaded to change UI offsets.
mod.locked_and_loaded_update = function()
	local lnl_mod = get_mod("LockedAndLoaded")
	local hide_buffs = mod
	if lnl_mod and not lnl_mod.hooked_by_hidebuffs then
		lnl_mod.hooked_by_hidebuffs = true
		local mod = lnl_mod
		lnl_mod.check_if_range_is_reloaded = function()
			if Managers and Managers.player then
				local local_player = Managers.player:local_player()

				if local_player and local_player.player_unit then
					local inventory_extension = ScriptUnit.extension(local_player.player_unit, "inventory_system")

					if inventory_extension then
						local equipment = inventory_extension:equipment()

						if equipment then
							local slot_ranged = equipment.slots["slot_ranged"]

							if slot_ranged then
								local slot_data = slot_ranged.item_data
								local item_type = slot_data.item_type

								local right = slot_ranged.right_unit_1p
								local left = slot_ranged.left_unit_1p

								local ammo_ext = GearUtils.get_ammo_extension(right, left)

								if ammo_ext then
									local ammo_loaded = ammo_ext:ammo_count()

									local icon_size = math.floor(32 * RESOLUTION_LOOKUP.scale)
									local icon_x = math.floor(RESOLUTION_LOOKUP.res_w - icon_size - (RESOLUTION_LOOKUP.res_w *  RESOLUTION_LOOKUP.scale * 0.075))
									local icon_y = math.floor(icon_size + (RESOLUTION_LOOKUP.res_h *  RESOLUTION_LOOKUP.scale * 0.1))

									local global_ammo_offset_x = hide_buffs:get(hide_buffs.SETTING_NAMES.AMMO_COUNTER_OFFSET_X)
									local global_ammo_offset_y = hide_buffs:get(hide_buffs.SETTING_NAMES.AMMO_COUNTER_OFFSET_Y)
									icon_x = icon_x + global_ammo_offset_x
									icon_y = icon_y + global_ammo_offset_y

									if ammo_loaded > 0 then
											Gui.bitmap(mod.reloaded_gui, 'reloaded_yes', Vector2(icon_x, icon_y), Vector2(icon_size, icon_size), Color(150,0,255,0))
									else
											Gui.bitmap(mod.reloaded_gui, 'reloaded_nope', Vector2(icon_x, icon_y), Vector2(icon_size, icon_size), Color(150,255,0,0))
									end

								end
							end
						end
					end
				end
			end
		end
	end
end
table.insert(mod.update_funcs, function() mod.locked_and_loaded_update() end)
