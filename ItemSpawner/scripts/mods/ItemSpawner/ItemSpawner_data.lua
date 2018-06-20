local mod = get_mod("ItemSpawner") -- luacheck: ignore get_mod

-- luacheck: globals AllPickups Localize NetworkLookup Managers Unit

local pl = require'pl.import_into'()

mod.SETTING_NAMES = {
	NEXT_PICKUP_HOTKEY = "next_pickup_hotkey",
	PREV_PICKUP_HOTKEY = "prev_pickup_hotkey",
	SPAWN_PICKUP_HOTKEY = "spawn_pickup_hotkey",
	KEYBINDS_GROUP = "keybinds_group",
}

local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
}

local pickups_cache = pl.List{
	"ammo_ranger_improved",
	"damage_boost_potion",
	"lamp_oil",
	"smoke_grenade_t2",
	"training_dummy_armored",
	"fire_grenade_t1",
	"smoke_grenade_t1",
	"lorebook_page",
	"first_aid_kit",
	"door_stick",
	"tome",
	"torch",
	"cooldown_reduction_potion",
	"fire_grenade_t2",
	"training_dummy",
	"ammo_ranger",
	"all_ammo_small",
	"healing_draught",
	"frag_grenade_t1",
	"all_ammo",
	"frag_grenade_t2",
	"grimoire",
	"speed_boost_potion",
	"explosive_barrel",
}

local keybinds_group_widget = {
	["setting_name"] = mod.SETTING_NAMES.KEYBINDS_GROUP,
	["widget_type"] = "group",
	["text"] = mod:localize("keybinds_group"),
	["sub_widgets"] = {}
}
keybinds_group_widget.sub_widgets = (function()
	local item_keybinds = {}
	pickups_cache:foreach(function(pickup_name)
		table.insert(item_keybinds,
			{
				["setting_name"] = pickup_name,
				["widget_type"] = "keybind",
				["text"] = AllPickups[pickup_name].hud_description and Localize(AllPickups[pickup_name].hud_description) or pickup_name,
				["default_value"] = {},
				["action"] = pickup_name
			})
		mod[pickup_name] = function()
			local local_player_unit = Managers.player:local_player().player_unit
			Managers.state.network.network_transmit:send_rpc_server(
				'rpc_spawn_pickup_with_physics',
				NetworkLookup.pickup_names[pickup_name],
				Unit.local_position(local_player_unit, 0),
				Unit.local_rotation(local_player_unit, 0),
				NetworkLookup.pickup_spawn_types['dropped']
			)
		end
	end)
	return item_keybinds
end)()

mod_data.options_widgets = {
	{
		["setting_name"] = mod.SETTING_NAMES.NEXT_PICKUP_HOTKEY,
		["widget_type"] = "keybind",
		["text"] = mod:localize("next_pickup_hotkey"),
		["tooltip"] = mod:localize("next_pickup_hotkey_tooltip"),
		["default_value"] = {"c", "ctrl"},
		["action"] = "next_pickup"
	},
	{
		["setting_name"] = mod.SETTING_NAMES.PREV_PICKUP_HOTKEY,
		["widget_type"] = "keybind",
		["text"] = mod:localize("prev_pickup_hotkey"),
		["tooltip"] = mod:localize("prev_pickup_hotkey_tooltip"),
		["default_value"] = {"v", "ctrl"},
		["action"] = "prev_pickup"
	},
	{
		["setting_name"] = mod.SETTING_NAMES.SPAWN_PICKUP_HOTKEY,
		["widget_type"] = "keybind",
		["text"] = mod:localize("spawn_pickup_hotkey"),
		["tooltip"] = mod:localize("spawn_pickup_hotkey_tooltip"),
		["default_value"] = {"b", "ctrl"},
		["action"] = "spawn_pickup"
	},
	keybinds_group_widget,
}

return mod_data