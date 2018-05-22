local mod = get_mod("ItemSpawner") -- luacheck: ignore get_mod

-- luacheck: globals AllPickups Spawn Unit NetworkLookup Managers Keyboard

local pl = require'pl.import_into'()
local stringx = require'pl.stringx'

mod.SETTING_NAMES = {
	NEXT_PICKUP_HOTKEY = "next_pickup_hotkey",
	PREV_PICKUP_HOTKEY = "prev_pickup_hotkey",
	SPAWN_PICKUP_HOTKEY = "spawn_pickup_hotkey",
}

-- Everything here is optional. You can remove unused parts.
local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
}
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
}

mod:initialize_data(mod_data)

local pickup_names = pl.Map{}
local current_pickup_name = nil

mod.init_pickups = function(self) -- luacheck: ignore self
	mod:pcall(function()
		if AllPickups and pickup_names:len() == 0 then
			-- get a list of pickup names without those that crash
			pickup_names = pl.Map(AllPickups)
				:keys()
				:remove_value("loot_die")
				:remove_value("lorebook_pages")
				:filter(function(pickup_name)
					return stringx.count(AllPickups[pickup_name].unit_template_name or "", "_limited") == 0
					and stringx.count(pickup_name, "endurance_badge") == 0
				end)

			current_pickup_name = pickup_names[1]
		end
	end)
end

mod.next_pickup = function(self) -- luacheck: ignore self
	if not mod:is_enabled() then
		return
	end

	mod:init_pickups()

	current_pickup_name = pickup_names[pickup_names:index(current_pickup_name) + 1]
	if not current_pickup_name then
		current_pickup_name = pickup_names[1]
	end
	mod:echo("Switched to: "..current_pickup_name)
end

mod.prev_pickup = function(self) -- luacheck: ignore self
	if not mod:is_enabled() then
		return
	end

	mod:init_pickups()

	current_pickup_name = pickup_names[pickup_names:index(current_pickup_name) - 1]
	if not current_pickup_name then
		current_pickup_name = pickup_names[#pickup_names]
	end
	mod:echo("Switched to: "..current_pickup_name)
end

mod.spawn_pickup = function(self) -- luacheck: ignore self
	if not mod:is_enabled() then
		return
	end

	mod:init_pickups()

	local local_player_unit = Managers.player:local_player().player_unit
	Managers.state.network.network_transmit:send_rpc_server(
		'rpc_spawn_pickup_with_physics',
		NetworkLookup.pickup_names[current_pickup_name],
		Unit.local_position(local_player_unit, 0),
		Unit.local_rotation(local_player_unit, 0),
		NetworkLookup.pickup_spawn_types['dropped']
		)
	mod:echo("Spawned: "..current_pickup_name)
end