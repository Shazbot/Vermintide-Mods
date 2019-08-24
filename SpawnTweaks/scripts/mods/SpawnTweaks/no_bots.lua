local mod = get_mod("SpawnTweaks")

--- Disable the bots.
mod:hook(GameModeAdventure, "_handle_bots",
function(func, self, ...)
	local original_cap_num_bots = script_data.cap_num_bots

	if mod:get(mod.SETTING_NAMES.NO_BOTS) then
		script_data.cap_num_bots = 0
	end

	func(self, ...)

	script_data.cap_num_bots = original_cap_num_bots
end)

--- Prevent a crash with disabled bots.
mod:hook(AdventureSpawning, "force_update_spawn_positions", function(func, ...)
	if not mod:get(mod.SETTING_NAMES.NO_BOTS) then
		return func(...)
	end

	pcall(func, ...)
end)
