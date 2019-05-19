local mod = get_mod("StreamingInfo")

local pl = require'pl.import_into'()

local mutators_setting_name_to_table_name = {
	MUTATORS_INFO_TEMP = "temp_external_lines",
	MUTATORS_INFO = "perm_external_lines",
}

local dwons_setting_name_to_table_name = {
	ONS_DW_INFO_TEMP = "temp_external_lines",
	ONS_DW_INFO = "perm_external_lines",
}

mod.update = function()
	-- FS Mutators.
	pcall(function()
		if not Managers.state.game_mode or
		not Managers.state.game_mode._game_mode then
			return -- just from pcall
		end

		local mutators = Managers.state.game_mode._game_mode:mutators()
		if not mutators then
			mod.temp_external_lines["FSMutators"] =  {}
			mod.perm_external_lines["FSMutators"] =  {}
			mod.cached_mutators = nil
		end

		if mod.cached_mutators
		and pl.tablex.compare_no_order(mod.cached_mutators, mutators)
		then
			return
		end

		mod.cached_mutators = mutators
		for setting_name, table_name in pairs( mutators_setting_name_to_table_name ) do
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
	end)

	-- DW and ONS.
	local dwons_mod = get_mod("is-dwons-on")
	if dwons_mod then
		local dw_enabled, ons_enabled = dwons_mod.get_status()
		if mod.dw_enabled ~= dw_enabled
		or mod.ons_enabled ~= ons_enabled
		then
			mod.dw_enabled = dw_enabled
			mod.ons_enabled = ons_enabled
			for setting_name, table_name in pairs( dwons_setting_name_to_table_name ) do
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
