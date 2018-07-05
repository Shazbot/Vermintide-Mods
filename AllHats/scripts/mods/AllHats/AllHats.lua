local mod = get_mod("AllHats") -- luacheck: ignore get_mod

-- luacheck: globals ItemMasterList table get_mod PlayFabMirror Managers

mod.loadout_cache = {}

mod.give_hats = function()
	for item_key, item in pairs( ItemMasterList ) do
		if (item.slot_type == "hat" or item.slot_type == "skin") and item.inventory_icon ~= "icons_placeholder" then
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

	-- basically slot_skin with a custom skin will crash you hard on game start
	-- so don't save slot_skin to server
	if not mod.done_hooking_backend and Managers.backend._interfaces["items"] then
		mod.done_hooking_backend = true

		mod:hook(Managers.backend:get_interface("items"), "set_loadout_item", function(func, self, backend_id, career_name, slot_name)
			if slot_name == "slot_skin" then
				mod.loadout_cache[career_name] = mod.loadout_cache[career_name] or {}
				mod.loadout_cache[career_name][slot_name] = backend_id
				return
			end

			return func(self, backend_id, career_name, slot_name)
		end)

		mod:hook(Managers.backend:get_interface("items"), "get_loadout", function(func, self)
			local loadout = func(self)

			for career_name, slots in pairs( mod.loadout_cache ) do
				for slot_name, backend_id in pairs( slots ) do
					loadout[career_name][slot_name] = backend_id
				end
			end

			return loadout
		end)

		mod:hook(Managers.backend:get_interface("items"), "get_loadout_item_id", function(func, self, career_name, slot_name)
			if mod.loadout_cache[career_name] and mod.loadout_cache[career_name][slot_name] then
				return mod.loadout_cache[career_name][slot_name]
			end
			return func(self, career_name, slot_name)
		end)
	end
end