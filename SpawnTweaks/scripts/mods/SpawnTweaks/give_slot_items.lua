local mod = get_mod("SpawnTweaks")

local pl = require'pl.import_into'()

mod.slot_name_to_setting_names = {
	slot_grenade = pl.List{
		mod.SETTING_NAMES.KEEP_GIVING_BOMBS,
		mod.SETTING_NAMES.KEEP_GIVING_FIRE_BOMBS,
	},
	slot_potion = pl.List{
		mod.SETTING_NAMES.KEEP_GIVING_STR_POTS,
		mod.SETTING_NAMES.KEEP_GIVING_SPEED_POTS,
		mod.SETTING_NAMES.KEEP_GIVING_CDR_POTS,
	},
	slot_healthkit = pl.List{
		mod.SETTING_NAMES.KEEP_GIVING_HP_POTS
	}
}

mod.setting_name_to_item_name = {
	[mod.SETTING_NAMES.KEEP_GIVING_BOMBS] = "frag_grenade_t1",
	[mod.SETTING_NAMES.KEEP_GIVING_FIRE_BOMBS] = "fire_grenade_t1",
	[mod.SETTING_NAMES.KEEP_GIVING_STR_POTS] = "damage_boost_potion",
	[mod.SETTING_NAMES.KEEP_GIVING_SPEED_POTS] = "speed_boost_potion",
	[mod.SETTING_NAMES.KEEP_GIVING_CDR_POTS] = "cooldown_reduction_potion",
	[mod.SETTING_NAMES.KEEP_GIVING_HP_POTS] = "healing_draught",
}

mod.give_slot_items_slot_names = { "slot_healthkit", "slot_potion", "slot_grenade" }

mod.filter_setting_name_filter = function(setting_name)
	return mod:get(setting_name)
end

mod.give_slot_items_update_func = function()
	if mod.ingame_entered and Managers.player.is_server then
		for _, player in pairs( Managers.player:human_and_bot_players() ) do
			local player_unit = player.player_unit
			local inventory_extension = ScriptUnit.has_extension(player_unit, "inventory_system")
			if inventory_extension then
				for _, slot_name in ipairs( mod.give_slot_items_slot_names ) do
					local slot_data = inventory_extension:get_slot_data(slot_name)
					if not slot_data then
						mod:pcall(function()
							local valid_setting_names =
								mod.slot_name_to_setting_names[slot_name]
								:filter(mod.filter_setting_name_filter)

							if #valid_setting_names > 0 then
								local setting_name = valid_setting_names[math.random(#valid_setting_names)]
								local pickup_type = mod.setting_name_to_item_name[setting_name]

								local slot_id = NetworkLookup.equipment_slots[slot_name]
								local pickup_settings = AllPickups[pickup_type]
								local weapon_skin_id = NetworkLookup.weapon_skins["n/a"]

								local item_name = pickup_settings.item_name
								local item_id = NetworkLookup.item_names[item_name]
								local item_data = ItemMasterList[item_name]
								local unit_template = nil
								local extra_extension_init_data = {}
								inventory_extension:add_equipment(slot_name, item_data, unit_template, extra_extension_init_data)

								local go_id = Managers.state.unit_storage:go_id(player_unit)
								Managers.state.network.network_transmit:send_rpc_clients("rpc_add_equipment", go_id, slot_id, item_id, weapon_skin_id)
							end
						end)
					end
				end
			end
		end
	end
end

table.insert(mod.update_funcs, function() mod.give_slot_items_update_func() end)
