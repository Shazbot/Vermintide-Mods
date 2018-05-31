local mod = get_mod("ItemSpawner") -- luacheck: ignore get_mod

-- luacheck: globals AllPickups Spawn Unit NetworkLookup Managers Keyboard

local pl = require'pl.import_into'()
local stringx = require'pl.stringx'

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