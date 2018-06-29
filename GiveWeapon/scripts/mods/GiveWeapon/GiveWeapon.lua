local mod = get_mod("GiveWeapon") -- luacheck: ignore get_mod

-- luacheck: globals get_mod fassert HeroView Managers UIResolutionScale UIResolution InventorySettings
-- luacheck: globals WeaponProperties WeaponTraits WeaponSkins table ItemMasterList SPProfiles Localize

local pl = require'pl.import_into'()
local tablex = require'pl.tablex'
local stringx = require'pl.stringx'

mod.simple_ui = get_mod("SimpleUI")
mod.more_items_library = get_mod("MoreItemsLibrary")

mod.properties = {}
mod.traits = {}

fassert(mod.simple_ui, "GiveWeapon must be lower than SimpleUI in your launcher's load order.")
fassert(mod.more_items_library, "GiveWeapon must be lower than MoreItemsLibrary in your launcher's load order.")

mod.create_weapon = function(item_type)
	for item_key, item in pairs( ItemMasterList ) do
		if item.item_type == item_type and item.template then
			local skin
			local skins = {}
			for skin_key, weapon_skin in pairs( WeaponSkins.skins ) do
				if weapon_skin.template == item.template then
					skin = skin_key
					table.insert(skins, skin)
				end
			end

			skin = skins[math.random(#skins)]

			local entry = table.clone(ItemMasterList[item_key])

			local rnd = math.random(100000)
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

			entry.mod_data = {
			    backend_id = tostring(item_key) .. rnd .. "_from_GiveWeapon",
			    ItemInstanceId = tostring(item_key) .. rnd .. "_from_GiveWeapon",
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

			mod.more_items_library:add_mod_items_to_local_backend({entry}, "GiveWeapon")

			mod:echo("Spawned "..item_key)

			Managers.backend:get_interface("items"):_refresh()

			mod.properties = {}
			mod.traits = {}
			break
		end
	end
end

local hero_options = {}
for i, profile in ipairs(pl.List(SPProfiles):slice(1, 5)) do
	hero_options[Localize(profile.ingame_display_name)] = i
end

mod.create_item_types_dropdown = function(profile_index, window_size)
	local careers = SPProfiles[profile_index].careers

	local career_item_types = {}
	for _, item in pairs( ItemMasterList ) do
		for _, career in ipairs( careers ) do
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

	mod.item_types_dropdown = mod.main_window:create_dropdown("item_types_dropdown", {5+180+5, window_size[2]-35},  {180, 30}, nil, item_types_options, "item_types_dropdown", 1)
	mod.item_types_dropdown:select_index(1)
end

mod.create_window = function(self, profile_index)
	local scale = UIResolutionScale()
	local screen_width, screen_height = UIResolution() -- luacheck: ignore screen_width
	local window_size = {905, 80}
	local window_position = {850*scale, screen_height - window_size[2]*scale - 5}

	self.main_window = mod.simple_ui:create_window("give_weapon", window_position, window_size)

	local pos_x = 5

	mod.create_weapon_button = self.main_window:create_button("create_weapon_button", {pos_x+90, window_size[2]-35-35}, {200, 30}, nil, ">Create Weapon<", nil)
	mod.create_weapon_button.on_click = function(button) -- luacheck: ignore button
			local item_type = mod.career_item_types[mod.item_types_dropdown.index]
			if item_type then
				local trait_name = mod.trait_names[mod.traits_dropdown.index]
				if trait_name then
					table.insert(mod.traits, trait_name)
				end
				mod.create_weapon(item_type)
			end
		end

	mod.heroes_dropdown = self.main_window:create_dropdown("heroes_dropdown", {pos_x, window_size[2]-35},  {180, 30}, nil, hero_options, nil, 1)
	mod.heroes_dropdown.on_index_changed = function(dropdown)
		mod.create_item_types_dropdown(dropdown.index, window_size)
	end
	if profile_index then
		mod.heroes_dropdown:select_index(profile_index)
		-- mod.create_item_types_dropdown(profile_index, window_size)
	end

	mod.add_property_button = self.main_window:create_button("add_property_button", {pos_x+180+180+5+5+260+5+40, window_size[2]-70}, {180, 30}, nil, "Add Property", nil)
	mod.add_property_button.on_click = function(button) -- luacheck: ignore button
			local property_name = mod.property_names[mod.properties_dropdown.index]
			if property_name then
				table.insert(mod.properties, property_name)
			end
		end

	-- mod.add_trait_button = self.main_window:create_button("add_trait_button", {pos_x+180+180+50+5, window_size[2]-70}, {180, 30}, nil, "Add Trait", nil)
	-- mod.add_trait_button.on_click = function(button)
	-- 		local trait_name = mod.trait_names[mod.traits_dropdown.index]
	-- 		if trait_name then
	-- 			table.insert(mod.traits, trait_name)
	-- 		end
	-- 	end

	mod.property_names = tablex.pairmap(function(property_key, _) return property_key end, WeaponProperties.properties)
	local properties_options = tablex.pairmap(function(property_key, property) -- luacheck: ignore property_key
			return stringx.replace(property.display_name, "properties_", "")
		end, WeaponProperties.properties)
	properties_options = tablex.index_map(properties_options)

	mod.properties_dropdown = self.main_window:create_dropdown("properties_dropdown", {pos_x+180+180+5+5+260+5, window_size[2]-35},  {260, 30}, nil, properties_options, nil, 1)

	mod.trait_names = tablex.pairmap(function(trait_key, _) return trait_key end, WeaponTraits.traits)
	local traits_options = tablex.pairmap(function(trait_key, trait) -- luacheck: ignore trait_key
			return Localize(trait.display_name)
		end, WeaponTraits.traits)
	traits_options = tablex.index_map(traits_options)

	mod.traits_dropdown = self.main_window:create_dropdown("traits_dropdown", {pos_x+180+180+5+5, window_size[2]-35}, {260, 30}, nil, traits_options, nil, 1)

	self.main_window.on_hover_enter = function(window)
		window:focus()
	end

	self.main_window:init()
end

--- Create window when opening hero view.
mod:hook_safe(HeroView, "on_enter", function()
	local player = Managers.player:local_player()
	local profile_index = player:profile_index()
	mod:reload_windows(profile_index)
end)

--- Create window when unsuspending hero view.
mod:hook_safe(HeroView, "unsuspend", function()
	mod:reload_windows()
end)

mod.reload_windows = function(self, profile_index)
	self:destroy_windows()
	self:create_window(profile_index)
end

mod.destroy_windows = function(self)
	if self.main_window then
		self.main_window:destroy()
		self.main_window = nil
	end
end

mod:hook(HeroView, "on_exit", function(func, self)
	func(self)

	mod:destroy_windows()
end)