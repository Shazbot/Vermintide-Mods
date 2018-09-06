return {
	run = function()
		fassert(rawget(_G, "new_mod"), "StreamingInfo must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("StreamingInfo", {
			mod_script       = "scripts/mods/StreamingInfo/StreamingInfo",
			mod_data         = "scripts/mods/StreamingInfo/StreamingInfo_data",
			mod_localization = "scripts/mods/StreamingInfo/StreamingInfo_localization"
		})
	end,
	packages = {
		"resource_packages/StreamingInfo/StreamingInfo"
	}
}
