local mod = get_mod("StreamingInfo")

local pl = require'pl.import_into'()

mod.mutators_setting_name_to_table_name = {
	MUTATORS_INFO_TEMP = "temp_external_lines",
	MUTATORS_INFO = "perm_external_lines",
}

mod.dwons_setting_name_to_table_name = {
	ONS_DW_INFO_TEMP = "temp_external_lines",
	ONS_DW_INFO = "perm_external_lines",
}

-- Update active FS Mutators.
mod.handle_mutators = function()
	if not Managers.state.game_mode or
	not Managers.state.game_mode._game_mode then
		return
	end

	local mutators = Managers.state.game_mode._game_mode:mutators()
	if not mutators then
		mod.temp_external_lines["FSMutators"] = nil
		mod.perm_external_lines["FSMutators"] = nil
		mod.cached_mutators = nil
		return
	end

	if mod.cached_mutators
	and pl.tablex.compare_no_order(mod.cached_mutators, mutators)
	then
		return
	end

	mod.cached_mutators = mutators
	for setting_name, table_name in pairs( mod.mutators_setting_name_to_table_name ) do
		if mod:get(mod.SETTING_NAMES[setting_name]) then
			mod[table_name]["FSMutators"] =  {}

			for _, mutator_key in ipairs( mutators ) do
				pcall(function()
					local mutator_name = Localize(MutatorTemplates[mutator_key].display_name)
					table.insert(mod[table_name]["FSMutators"], mutator_name)
				end)
			end

			if #mod[table_name]["FSMutators"] > 0 then
				table.insert(mod[table_name]["FSMutators"], 1, "Mutators:")
			end
		end
	end
end

-- Update whether DW and ONS are active.
mod.handle_dwons = function()
	local dwons_mod = get_mod("is-dwons-on")
	if dwons_mod then
		local dw_enabled, ons_enabled = dwons_mod.get_status()
		if mod.dw_enabled ~= dw_enabled
		or mod.ons_enabled ~= ons_enabled
		then
			mod.dw_enabled = dw_enabled
			mod.ons_enabled = ons_enabled
			for setting_name, table_name in pairs( mod.dwons_setting_name_to_table_name ) do
				if mod:get(mod.SETTING_NAMES[setting_name]) then
					mod[table_name]["DWONS"] =  {}
					if dw_enabled then
						table.insert(mod[table_name]["DWONS"], "Deathwish enabled!")
					end
					if ons_enabled then
						table.insert(mod[table_name]["DWONS"], "Onslaught enabled!")
					end
				end
			end
		end
	end
end

mod.update = function()
	mod.handle_mutators()
	mod.handle_dwons()
end
