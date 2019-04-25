local mod = get_mod("AnyWeapon")

local pl = require'pl.import_into'()
local tablex = require'pl.tablex'

mod:hook(LobbyAux, "create_network_hash", function(func, config_file_name, project_hash) -- luacheck: ignore project_hash
	return func(config_file_name, "AnyWeapon")
end)

mod.loadout_cache = pl.Map{}

--- Crash prevention.
mod:hook(DamageUtils, "create_explosion", function(func, world, attacker_unit, position, rotation, explosion_template, ...)
	if not explosion_template then
		return
	end

	return func(world, attacker_unit, position, rotation, explosion_template, ...)
end)

--- Crash prevention.
mod:hook(AreaDamageSystem, "create_explosion", function(func, self, attacker_unit, position, rotation, explosion_template_name, ...)
	if not ExplosionTemplates[explosion_template_name] then
		return false
	end

	return func(self, attacker_unit, position, rotation, explosion_template_name, ...)
end)

--- Change inventory tab filters.
mod:hook(ItemGridUI, "_on_category_index_change", function(func, self, index, keep_page_index)
	local settings = self._category_settings[index]
	local item_filter = settings.item_filter

	if item_filter == "slot_type == melee" or item_filter == "slot_type == ranged" then
		settings.item_filter = "slot_type == melee or slot_type == ranged"
	end

	return func(self, index, keep_page_index)
end)

--- Crash prevention.
mod:hook_origin(GearUtils, "link_units", function(world, attachment_node_linking, link_table, source, target)
	for _, attachment_nodes in ipairs(attachment_node_linking) do
		local source_node = attachment_nodes.source
		local target_node = attachment_nodes.target

		local target_node_valid = type(target_node) ~= "string" and true or Unit.has_node(target, target_node)
		local source_node_valid = type(source_node) ~= "string" and true or Unit.has_node(source, source_node)
		if target_node_valid and source_node_valid then
			local source_node_index = (type(source_node) == "string" and Unit.node(source, source_node)) or source_node
			local target_node_index = (type(target_node) == "string" and Unit.node(target, target_node)) or target_node
			link_table[#link_table + 1] = {
				unit = target,
				i = target_node_index,
				parent = Unit.scene_graph_parent(target, target_node_index),
				local_pose = Matrix4x4Box(Unit.local_pose(target, target_node_index))
			}

			World.link_unit(world, target, target_node_index, source, source_node_index)
		end
	end
end)

--- Crash prevention.
mod:hook(MenuWorldPreviewer, "_spawn_item_unit", function(func, self, unit, item_slot_type, item_template, unit_attachment_node_linking, scene_graph_links, material_settings)
	pcall(function()
		func(self, unit, item_slot_type, item_template, unit_attachment_node_linking, scene_graph_links, material_settings)
	end)
end)

--- Crash prevention.
mod:hook(Unit, "animation_event", function(func, ...)
	pcall(function(...)
		return func(...)
	end, ...)
end)

--- Crash prevention.
mod:hook(SimpleHuskInventoryExtension, "_wield_slot", function(func, self, world, equipment, slot_name, unit_1p, unit_3p)
	local item_data
	pcall(function()
		item_data = func(self, world, equipment, slot_name, unit_1p, unit_3p)
	end)
	return item_data
end)

--- Crash prevention.
mod:hook(SimpleInventoryExtension, "_wield_slot", function(func, self, equipment, slot_data, unit_1p, unit_3p, buff_extension)
	local ret_val
	pcall(function()
		ret_val = func(self, equipment, slot_data, unit_1p, unit_3p, buff_extension)
	end)
	return ret_val
end)

--- Workaround for wiz staffs crashing the game because of effects that weren't loaded.
--- Need to find a way to load those packages manually.
--- Could be a mega bad idea performance-wise.
mod:hook(PackageManager, "unload", function(func, self, package_name, reference_name) -- luacheck: no unused
	return
end)

local can_wield_all = {
	"bw_scholar",
	"bw_adept",
	"bw_unchained",
	"we_shade",
	"we_maidenguard",
	"we_waywatcher",
	"dr_ironbreaker",
	"dr_slayer",
	"dr_ranger",
	"wh_zealot",
	"wh_bountyhunter",
	"wh_captain",
	"es_huntsman",
	"es_knight",
	"es_mercenary"
}
mod.on_game_state_changed = function()
	if ItemMasterList then
		-- keep copy of original around is someone needs it
		if not mod:persistent_table("cache").ItemMasterList then
			mod:persistent_table("cache").ItemMasterList = tablex.deepcopy(ItemMasterList)
		end

		for _, weapon_data in pairs( ItemMasterList ) do
			weapon_data.can_wield = can_wield_all
		end
	end
end

mod.update = function()
	if not mod.done_hooking_backend and Managers.backend._interfaces["items"] then
		mod.done_hooking_backend = true

		mod:hook(Managers.backend:get_interface("items"), "set_loadout_item", function(func, self, backend_id, career_name, slot_name) -- luacheck: no unused
			mod.loadout_cache[career_name] = mod.loadout_cache[career_name] or {}
			mod.loadout_cache[career_name][slot_name] = backend_id
		end)

		mod:hook(Managers.backend:get_interface("items"), "get_loadout", function(func, self)
			local loadout = func(self)

			for career_name, slots in mod.loadout_cache:iter() do
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
