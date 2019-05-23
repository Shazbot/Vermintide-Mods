local mod = get_mod("GiveWeapon")

local pl = require'pl.import_into'()
local tablex = require'pl.tablex'
local stringx = require'pl.stringx'

mod.simple_ui = get_mod("SimpleUI")
mod.more_items_library = get_mod("MoreItemsLibrary")

mod.properties = {}
mod.traits = {}

fassert(mod.simple_ui, "GiveWeapon must be lower than SimpleUI in your launcher's load order.")
fassert(mod.more_items_library, "GiveWeapon must be lower than MoreItemsLibrary in your launcher's load order.")

mod.pos_y = -35

mod.create_skins_dropdown = function(item_type, window_size)
	mod:pcall(function()
		local all_skins = pl.List(mod.get_skins(item_type))
		mod.skin_names = tablex.pairmap(function(_, skin) return skin, Localize(WeaponSkins.skins[skin].display_name) end, all_skins)
		mod.sorted_skin_names = all_skins:map(function(skin) return Localize(WeaponSkins.skins[skin].display_name) end)

		table.sort(mod.sorted_skin_names,
			function(skin_name_first, skin_name_second)
				local skin_key_first = mod.skin_names[skin_name_first]
				local skin_key_second = mod.skin_names[skin_name_second]

				if pl.stringx.lfind(skin_key_first, "_runed")
				and pl.stringx.lfind(skin_key_second, "_runed")
				then
					if pl.stringx.lfind(skin_key_first, "_runed_02")
					and pl.stringx.lfind(skin_key_second, "_runed_02")
					then
						return skin_name_first < skin_name_second
					end

					if pl.stringx.lfind(skin_key_first, "_runed_02") then
						return true
					end

					if pl.stringx.lfind(skin_key_second, "_runed_02") then
						return false
					end

					return skin_name_first < skin_name_second
				end

				if pl.stringx.lfind(skin_key_first, "_runed") then
					return true
				elseif pl.stringx.lfind(skin_key_second, "_runed") then
					return false
				else
					return skin_name_first < skin_name_second
				end
			end)
		local skin_options = tablex.index_map(mod.sorted_skin_names)

		if mod.skins_dropdown then
			mod.skins_dropdown.visible = false
		end

		mod.skins_dropdown = mod.main_window:create_dropdown("skins_dropdown", {5+180+180+5+5+260+5+260+5, mod.pos_y+window_size[2]-35},  {200, 30}, nil, skin_options, "skins_dropdown", 1)
		mod.skins_dropdown:select_index(1)
	end)
end

mod.get_skins = function(item_type)
	local current_career_names = mod.current_careers:map(function(career) return career.name end)
	for _, item in pairs( ItemMasterList ) do
		if item.item_type == item_type
		and item.template
		and item.can_wield
		and pl.List(item.can_wield) -- check if the item is valid career-wise
			:map(function(career_name) return current_career_names:contains(career_name) end)
			:reduce('or')
		then
			if item.skin_combination_table or pl.List{"necklace", "ring", "trinket"}:contains(item_type) then
				if item.skin_combination_table then
					local all_skins = pl.List()
					tablex.foreach(WeaponSkins.skin_combinations[item.skin_combination_table], function(value)
						all_skins:extend(pl.List(value))
					end)
					return pl.Map.keys(pl.Set(all_skins))
				end
			end
		end
	end
end

mod.create_weapon = function(item_type, give_random_skin, rarity, no_skin)
	if not mod.current_careers then
		local player = Managers.player:local_player()
		local profile_index = player:profile_index()
		mod.current_careers = pl.List(SPProfiles[profile_index].careers)
	end
	local current_career_names = mod.current_careers:map(function(career) return career.name end)
	for item_key, item in pairs( ItemMasterList ) do
		if item.item_type == item_type
		and item.template
		and item.can_wield
		and pl.List(item.can_wield) -- check if the item is valid career-wise
			:map(function(career_name) return current_career_names:contains(career_name) end)
			:reduce('or')
		then
			if item.skin_combination_table or pl.List{"necklace", "ring", "trinket"}:contains(item_type) then
				local skin
				if item.skin_combination_table and mod.skin_names then
					skin = mod.skin_names[mod.sorted_skin_names[mod.skins_dropdown.index]]
				end
				if mod:get(mod.SETTING_NAMES.NO_SKINS) then
					skin = nil
				end
				if give_random_skin then
					local skins = mod.get_skins(item_type)
					skin = skins[math.random(#skins)]
				end

				local custom_properties = "{"
				for _, prop_name in ipairs( mod.properties ) do
					custom_properties = custom_properties..'\"'..prop_name..'\":1,'
				end
				custom_properties = custom_properties.."}"

				local properties = {}
				for _, prop_name in ipairs( mod.properties ) do
					properties[prop_name] = 1
				end

				local custom_traits = "["
				for _, trait_name in ipairs( mod.traits ) do
					custom_traits = custom_traits..'\"'..trait_name..'\",'
				end
				custom_traits = custom_traits.."]"

				local rnd = math.random(1000000) -- uhh yeah
				local new_backend_id =  tostring(item_key) .. "_" .. rnd .. "_from_GiveWeapon"
				local entry = table.clone(ItemMasterList[item_key])
				entry.mod_data = {
				    backend_id = new_backend_id,
				    ItemInstanceId = new_backend_id,
				    CustomData = {
						-- traits = "[\"melee_attack_speed_on_crit\", \"melee_timed_block_cost\"]",
						traits = custom_traits,
						power_level = "300",
						properties = custom_properties,
						rarity = "exotic",
					},
					rarity = "exotic",
				    -- traits = { "melee_timed_block_cost", "melee_attack_speed_on_crit" },
				    traits = table.clone(mod.traits),
				    power_level = 300,
				    properties = properties,
				}
				if skin then
					entry.mod_data.CustomData.skin = skin
					entry.mod_data.skin = skin
					entry.mod_data.inventory_icon = WeaponSkins.skins[skin].inventory_icon
				end

				entry.rarity = "exotic"

				entry.rarity = "default"
				entry.mod_data.rarity = "default"
				entry.mod_data.CustomData.rarity = "default"

				mod.more_items_library:add_mod_items_to_local_backend({entry}, "GiveWeapon")

				mod:echo("Spawned "..item_key)

				Managers.backend:get_interface("items"):_refresh()

				ItemHelper.mark_backend_id_as_new(new_backend_id)

				local backend_items = Managers.backend:get_interface("items")
				local new_item = backend_items:get_item_from_id(new_backend_id)

				if rarity then
					new_item.rarity = rarity
					new_item.data.rarity = rarity
					new_item.CustomData.rarity = rarity
				end

				if no_skin then
					new_item.skin = nil
				end

				mod.properties = {}
				mod.traits = {}
				return new_backend_id
			end
		end
	end
end

mod.hero_options = {}
for i, profile in ipairs(pl.List(SPProfiles):slice(1, 5)) do
	mod.hero_options[Localize(profile.ingame_display_name)] = i
end

mod.create_item_types_dropdown = function(profile_index, window_size)
	mod.current_careers = pl.List(SPProfiles[profile_index].careers)

	local item_master_list = ItemMasterList
	local any_weapon = get_mod("AnyWeapon")
	if any_weapon then
		local cached_item_master_list = any_weapon:persistent_table("cache").ItemMasterList
		if cached_item_master_list then
			item_master_list = cached_item_master_list
		end
	end

	local career_item_types = {}
	for _, item in pairs( item_master_list ) do
		for _, career in ipairs( mod.current_careers ) do
			if table.contains(item.can_wield, career.name)
			and (item.slot_type == "melee" or item.slot_type == "ranged") then
				career_item_types[item.item_type] = true
				break
			end
		end
	end

	mod.career_item_types = tablex.keys(career_item_types)
	mod.career_item_types:extend({"necklace", "ring", "trinket"})

	career_item_types = mod.career_item_types:map(Localize)

	local item_types_options = tablex.index_map(career_item_types)

	if mod.item_types_dropdown then
		mod.item_types_dropdown.visible = false
	end

	mod.item_types_dropdown = mod.main_window:create_dropdown("item_types_dropdown", {5+180+5, mod.pos_y+window_size[2]-35},  {180, 30}, nil, item_types_options, "item_types_dropdown", 1)
	mod.item_types_dropdown.on_index_changed = function(dropdown)
		local item_type = mod.career_item_types[dropdown.index]
		mod.create_skins_dropdown(item_type, window_size)
	end
	mod.item_types_dropdown:select_index(1)
end

mod.on_create_weapon_click = function(button) -- luacheck: ignore button
	local item_type = mod.career_item_types[mod.item_types_dropdown.index]
	if item_type then
		local trait_name = mod.trait_names[mod.sorted_trait_names[mod.traits_dropdown.index]]
		if trait_name then
			table.insert(mod.traits, trait_name)
		end

		local rarity = mod:get(mod.SETTING_NAMES.NO_SKINS) and "default" or "exotic"
		local no_skin = mod:get(mod.SETTING_NAMES.NO_SKINS)
		local backend_id = mod.create_weapon(item_type, false, rarity, no_skin)
		mod:pcall(function()
			local backend_items = Managers.backend:get_interface("items")

			if mod.loadout_inv_view then
				backend_items:_refresh()
				local inv_item_grid = mod.loadout_inv_view._item_grid
				inv_item_grid:change_item_filter(inv_item_grid._item_filter, false)
				inv_item_grid:repopulate_current_inventory_page()
			end
		end)
	end
end

mod.create_window = function(self, profile_index, loadout_inv_view)
	mod.loadout_inv_view = loadout_inv_view
	local scale = UIResolutionScale_pow2()
	local screen_width, screen_height = UIResolution() -- luacheck: ignore screen_width
	local window_size = {905+190+15, 80+32}
	local window_position = {850-160, screen_height - window_size[2] - 5}

	self.main_window = mod.simple_ui:create_window("give_weapon", window_position, window_size)
	mod.main_window:create_title("give_weapon_title", "Give Weapon", 35)

	self.main_window.position = {screen_width - (905+190+15)*scale - 150, screen_height - window_size[2]*scale - 5}

	local pos_x = 5
	local pos_y = mod.pos_y

	mod.create_weapon_button = self.main_window:create_button("create_weapon_button", {pos_x+90, pos_y+window_size[2]-35-35}, {200, 30}, nil, ">Create Weapon<", nil)
	mod.create_weapon_button.on_click = mod.on_create_weapon_click

	mod.heroes_dropdown = self.main_window:create_dropdown("heroes_dropdown", {pos_x, pos_y+window_size[2]-35},  {180, 30}, nil, mod.hero_options, nil, 1)
	mod.heroes_dropdown.on_index_changed = function(dropdown)
		mod.create_item_types_dropdown(dropdown.index, window_size)
	end
	if profile_index then
		mod.heroes_dropdown:select_index(profile_index)
	end

	mod.add_property_button = self.main_window:create_button("add_property_button", {pos_x+180+180+5+5+260+5+40, pos_y+window_size[2]-70}, {180, 30}, nil, "Add Property", nil)
	mod.add_property_button.on_click = function(button) -- luacheck: ignore button
			local property_name = mod.property_names[mod.sorted_property_names[mod.properties_dropdown.index]]
			if property_name then
				table.insert(mod.properties, property_name)
			end
		end

	-- mod.add_trait_button = self.main_window:create_button("add_trait_button", {pos_x+180+180+50+5, pos_y+window_size[2]-70}, {180, 30}, nil, "Add Trait", nil)
	-- mod.add_trait_button.on_click = function(button)
	-- 		local trait_name = mod.trait_names[mod.traits_dropdown.index]
	-- 		if trait_name then
	-- 			table.insert(mod.traits, trait_name)
	-- 		end
	-- 	end

	mod.property_names = tablex.pairmap(function(property_key, _)
		local full_prop_description = UIUtils.get_property_description(property_key, 0)
		local _, _, prop_description = stringx.partition(full_prop_description, " ")
		prop_description = stringx.replace(prop_description, "Damage", "Dmg")
		return property_key, prop_description
		end, WeaponProperties.properties)
	mod.sorted_property_names = tablex.pairmap(function(property_key, _)
			local full_prop_description = UIUtils.get_property_description(property_key, 0)
			local _, _, prop_description = stringx.partition(full_prop_description, " ")
			prop_description = stringx.replace(prop_description, "Damage", "Dmg")
			return prop_description
			end, WeaponProperties.properties)
	table.sort(mod.sorted_property_names)
	local properties_options = tablex.index_map(mod.sorted_property_names)

	mod.properties_dropdown = self.main_window:create_dropdown("properties_dropdown", {pos_x+180+180+5+5+260+5, pos_y+window_size[2]-35},  {260, 30}, nil, properties_options, nil, 1)

	mod.trait_names = tablex.pairmap(function(trait_key, trait) return trait_key, Localize(trait.display_name) end, WeaponTraits.traits)
	mod.sorted_trait_names = tablex.pairmap(function(trait_key, trait) -- luacheck: ignore trait_key
			return Localize(trait.display_name)
		end, WeaponTraits.traits)
	table.sort(mod.sorted_trait_names)
	local traits_options = tablex.index_map(mod.sorted_trait_names)

	mod.traits_dropdown = self.main_window:create_dropdown("traits_dropdown", {pos_x+180+180+5+5, pos_y+window_size[2]-35}, {260, 30}, nil, traits_options, nil, 1)

	self.main_window.on_hover_enter = function(window)
		window:focus()
	end

	self.main_window:init()
end

--- Create window when opening hero view.
mod:hook_safe(HeroWindowLoadoutInventory, "on_enter", function(self)
	local player = Managers.player:local_player()
	local profile_index = player:profile_index()
	mod:reload_windows(profile_index, self)
end)

mod.reload_windows = function(self, profile_index, loadout_inv_view)
	self:destroy_windows()
	self:create_window(profile_index, loadout_inv_view)
end

mod.destroy_windows = function(self)
	if self.main_window then
		self.main_window:destroy()
		self.main_window = nil
	end
end

mod:hook(HeroWindowLoadoutInventory, "on_exit", function(func, self)
	func(self)

	mod:destroy_windows()
end)

mod:dofile("scripts/mods/"..mod:get_name().."/wooden_2h_hammer")
