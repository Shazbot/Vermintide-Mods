return {
	run = function()
		fassert(rawget(_G, "new_mod"), "ExecLua must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("ExecLua", {
			mod_script       = "scripts/mods/ExecLua/ExecLua",
			mod_data         = "scripts/mods/ExecLua/ExecLua_data",
			mod_localization = "scripts/mods/ExecLua/ExecLua_localization"
		})
	end,
	packages = {
		"resource_packages/ExecLua/ExecLua"
	}
}
