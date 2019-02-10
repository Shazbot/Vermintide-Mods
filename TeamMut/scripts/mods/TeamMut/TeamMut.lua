local mod = get_mod("TeamMut")

local pl = require'pl.import_into'()

mod.simple_ui = get_mod("SimpleUI")

mod.player_modifiers = mod.player_modifiers or {}
-- ddraw(mod.player_modifiers)

mod.player_modifiers_default = {
	elites = true,
	bosses = true,
	specials = true,
	trash = true,
	dmg_dealt = "1",
	dmg_taken = "1",
	stagger_mul = "1",
}
mod.breeds = {
	elites = pl.List{
		"chaos_warrior",
		"skaven_storm_vermin_commander",
		"chaos_raider",
		"skaven_storm_vermin",
		"chaos_berzerker",
		"skaven_storm_vermin_with_shield",
		"skaven_plague_monk",
	},
	bosses = pl.List{
		"skaven_grey_seer",
		"chaos_exalted_champion_norsca",
		"chaos_spawn_exalted_champion_norsca",
		"chaos_exalted_champion_warcamp",
		"chaos_spawn",
		"chaos_troll",
		"skaven_rat_ogre",
		"skaven_stormfiend",
		"skaven_stormfiend_boss",
		"skaven_storm_vermin_warlord",
		"skaven_storm_vermin_champion",
	},
	specials = pl.List{
		"skaven_pack_master",
		"skaven_loot_rat",
		"skaven_warpfire_thrower",
		"chaos_vortex_sorcerer",
		"skaven_poison_wind_globadier",
		"chaos_corruptor_sorcerer",
		"skaven_gutter_runner",
		"chaos_tentacle_sorcerer",
		"chaos_exalted_sorcerer",
		"chaos_plague_sorcerer",
		"chaos_plague_wave_spawner",
		"skaven_ratling_gunner",
		"chaos_vortex",
	},
	trash = pl.List{
		"critter_pig",
		"critter_rat",
		"chaos_marauder",
		"skaven_clan_rat_with_shield",
		"skaven_clan_rat",
		"chaos_marauder_with_shield",
		"skaven_slave",
		"chaos_zombie",
		"chaos_fanatic",
	},
}

mod.dmg_values = pl.List{}
for i = 0, 3.1, 0.1 do
	mod.dmg_values[#mod.dmg_values+1] = i
end
mod.dmg_values:extend{ 0.25, 0.75, 1.25, 1.75, 2.25, 2.75 }
table.sort(mod.dmg_values)
mod.dmg_values = pl.tablex.index_map(mod.dmg_values:map(function(val)
	-- get rid of 1.0000000000001 garbage
	return string.format("%.2f", val):gsub("%.?0+$", "")
end))

mod.breed_categories = pl.List{ "trash", "elites", "specials", "bosses" }
mod.dmg_categories = pl.List{ "dmg_taken", "dmg_dealt", "stagger_mul" }
mod.category_to_en_lookup = {
	trash = "Trash",
	elites = "Elites",
	specials = "Specials",
	bosses = "Bosses",
	dmg_dealt = "Dmg Dealt",
	dmg_taken = "Dmg Taken",
	stagger_mul = "Stagger"
}

mod.get_player_modifiers = function(player)
	local player_name = player._cached_name or player:name()

	if not mod.player_modifiers[player_name] then
		mod.player_modifiers[player_name] = table.clone(mod.player_modifiers_default)
	end

	return mod.player_modifiers[player_name]
end

mod.reset_player_modifiers = function(player)
	local player_name = player._cached_name or player:name()
	mod.player_modifiers[player_name] = table.clone(mod.player_modifiers_default)
end

mod.create_window = function()
	mod.mutator_chks = {}
	mod.summary_labels = {}

	local screen_width, screen_height = UIResolution()
	local window_size = {1125, 400}
	local window_position = {
	screen_width/2 - window_size[1]/2 - 300, screen_height/2 - window_size[2]/2}

	mod.main_window = mod.simple_ui:create_window("team_mutator", window_position, window_size)

	mod.main_window.position = { 0, screen_height - window_size[2] }

	mod.main_window:create_title("team_mutator_title", "Team Mutator", 40)
	-- local team_mutator_close_button = mod.main_window:create_close_button("team_mutator_close_button")
	-- team_mutator_close_button.anchor = "top_left"

	local start_y = 30
	local option_delta_x = 120

	for row, player in ipairs( pl.tablex.values(Managers.player:human_and_bot_players()) ) do
		local player_name = player._cached_name or player:name()
		local player_modifiers = mod.get_player_modifiers(player)
		local player_label = mod.main_window:create_label(player_name.."_label",
			{20, start_y+row*75},
			{120, 40},
			"top_left"
		)
		player_label.text = player_name

		for i, breed_category in ipairs( mod.breed_categories ) do
			local mutator_chk = mod.main_window:create_checkbox(
				player_name.."_"..breed_category.."_ckh",
				{i*option_delta_x+40, start_y+row*75},
				{40, 40},
				"top_left",
				nil,
				player_modifiers[breed_category]
			)
			mutator_chk.on_value_changed = function()
				local chk_enabled = mutator_chk.value
				player_modifiers[breed_category] = chk_enabled
			end
		end

		for i, dmg_category in ipairs( mod.dmg_categories ) do
			local dmg_dropdown = mod.main_window:create_dropdown(
				dmg_category.."_dropdown",
				{20+(5+i-1)*option_delta_x, start_y+row*75+8},
				{80, 22},
				"top_left",
				mod.dmg_values,
				nil,
				1
			)
			dmg_dropdown.on_index_changed = function(dropdown)
				player_modifiers[dmg_category] = dropdown.text
			end
			dmg_dropdown:select_index(mod.dmg_values[player_modifiers[dmg_category]])
		end

		local reset_button = mod.main_window:create_button(player_name.."_reset_button",
			{6*150+100, start_y+row*75+5},
			{80, 30},
			"top_left",
			"Reset")
		reset_button.on_click = function()
			mod.reset_player_modifiers(player)
			mod.reload_windows()
		end
	end

	for i, category in ipairs( mod.breed_categories..mod.dmg_categories ) do
		local enemy_group_label = mod.main_window:create_label(category.."_label",
			{i*option_delta_x, start_y+15},
			{120, 40},
			"top_left")
		enemy_group_label.text = mod.category_to_en_lookup[category]
	end

	mod.main_window.on_hover_enter = function(window)
		window:focus()
	end

	mod.main_window:init()

	mod.main_window.transparent = false
	mod.main_window.theme.color[1] = 150
end

mod.reload_windows = function()
	mod.destroy_windows()
	mod.create_window()
end

mod.destroy_windows = function()
	if mod.main_window then
		mod.main_window:destroy()
		mod.main_window = nil
	end
end

--- Change damage dealt to bosses.
--- Only used as an intermediate hook inside DamageUtils.add_damage_network_player.
mod:hook(DamageUtils, "calculate_damage", function(func, damage_output, target_unit, attacker_unit, ...)
	local dmg = func(damage_output, target_unit, attacker_unit, ...)

	if target_unit and attacker_unit then
		local attacking_player = Managers.player:owner(attacker_unit)
		if attacking_player then
			local player_modifiers = mod.get_player_modifiers(attacking_player)
			local breed = Unit.get_data(target_unit, "breed")
			if breed then
				for breed_category, breeds_in_category in pairs( mod.breeds ) do
					if breeds_in_category:contains(breed.name) and not player_modifiers[breed_category] then
						dmg = 0
					end
				end
			end

			dmg = dmg * tonumber(player_modifiers.dmg_dealt)
		end
	end

	return dmg
end)
mod:hook_disable(DamageUtils, "calculate_damage")

mod:hook(DamageUtils, "add_damage_network_player", function(func, ...)
	mod:hook_enable(DamageUtils, "calculate_damage")

	func(...)

	mod:hook_disable(DamageUtils, "calculate_damage")
end)

mod:hook(DamageUtils, "add_damage_network", function(func, attacked_unit, attacker_unit, original_damage_amount, ...)
	local dmg = original_damage_amount
	local attacked_player = Managers.player:owner(attacked_unit)
	if attacked_player then
		local player_modifiers = mod.get_player_modifiers(attacked_player)
		dmg = dmg * tonumber(player_modifiers.dmg_taken)
	end
	return func(attacked_unit, attacker_unit, dmg, ...)
end)

mod.update = function()
	if not mod.done_hooking_chat and ChatGui then
		mod.done_hooking_chat = true

		mod:hook(ChatGui, "update", function(func, self, ...)
			if not self.chat_focused then
				mod.destroy_windows()
			elseif not mod.main_window then
				mod.reload_windows()
			end

			return func(self, ...)
		end)
	end
end

mod:hook(DamageUtils, "calculate_stagger_player", function(func, stagger_table, target_unit, attacker_unit, hit_zone_name, original_power_level, ...)
	local new_original_power_level = original_power_level

	if attacker_unit then
		local attacking_player = Managers.player:owner(attacker_unit)
		if attacking_player then
			local player_modifiers = mod.get_player_modifiers(attacking_player)
			new_original_power_level = new_original_power_level * tonumber(player_modifiers.stagger_mul)
		end
	end

	return func(stagger_table, target_unit, attacker_unit, hit_zone_name, new_original_power_level, ...)
end)

-- mod.reload_windows()
-- mod.destroy_windows()
