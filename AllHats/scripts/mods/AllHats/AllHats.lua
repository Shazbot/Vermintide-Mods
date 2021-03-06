local mod = get_mod("AllHats")

mod.loadout_cache = {}

mod.give_hats = function()
	for item_key, item in pairs( ItemMasterList ) do
		if (
			item.slot_type == "hat"
			or item.slot_type == "skin"
			or item.slot_type == "frame"
		)
		and item.inventory_icon ~= "icons_placeholder"
		then
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

mod:hook_origin(AttachmentUtils, "link", function(world, source, target, node_linking)
	for _, link_data in ipairs(node_linking) do
		local source_node = link_data.source
		local target_node = link_data.target

		local target_node_valid = type(target_node) ~= "string" and true or Unit.has_node(target, target_node)
		local source_node_valid = type(source_node) ~= "string" and true or Unit.has_node(source, source_node)
		if target_node_valid and source_node_valid then
			local source_node_index = (type(source_node) == "string" and Unit.node(source, source_node)) or source_node
			local target_node_index = (type(target_node) == "string" and Unit.node(target, target_node)) or target_node

			World.link_unit(world, target, target_node_index, source, source_node_index)
		end
	end
end)

--- Give all keep paintings.
mod:hook_origin(HeroViewStateKeepDecorations, "_setup_paintings_list", function(self)
	local backend_interface = self._keep_decoration_backend_interface
	local unlocked_paintings = (backend_interface and backend_interface:get_unlocked_keep_decorations()) or {}
	local entries = {}

	for _, key in ipairs(PaintingOrder) do
		if not table.contains(DefaultPaintings, key) then
			local settings = Paintings[key]
			local unlocked = true --table.contains(unlocked_paintings, key)
			local display_name = Localize(settings.display_name)

			if unlocked then
				entries[#entries + 1] = {
					key = key,
					display_name = display_name
				}
			end
		end
	end

	local new_painting_order = {}

	for _, table in ipairs(entries) do
		new_painting_order[#new_painting_order + 1] = table.key
	end

	self:_populate_list(entries)
	self:_update_equipped_widget()

	return new_painting_order
end)
