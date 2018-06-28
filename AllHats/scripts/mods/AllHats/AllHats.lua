local mod = get_mod("AllHats") -- luacheck: ignore get_mod

-- luacheck: globals ItemMasterList table get_mod

mod.give_hats = function()
	for item_key, item in pairs( ItemMasterList ) do
		if item.slot_type == "hat" and item.inventory_icon ~= "icons_placeholder" then
			local entry = table.clone(ItemMasterList[item_key])

			entry.mod_data = {
			    backend_id = tostring(item_key) .. "_from_AllHats",
			    ItemInstanceId = tostring(item_key) .. "_from_AllHats",
			    CustomData = {},
			}

			local more_items_library = get_mod("MoreItemsLibrary")
			if more_items_library then
				more_items_library:add_mod_items_to_local_backend({entry}, "AllHats")
			end
		end
	end
end

mod.update = function()
	if ItemMasterList and not mod.gave_hats then
		mod.gave_hats = true

		mod.give_hats()
	end
end