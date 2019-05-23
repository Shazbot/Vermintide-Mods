local mod = get_mod("HideBuffs")

local pl = require'pl.import_into'()

mod.local_presets = pl.Map{}
mod.force_local_save = true
mod.local_presets_file_name = "ut_tweaks_presets"

mod.save_local_preset = function(preset_name)
	mod:pcall(function()
		if not preset_name then
			mod:echo("Preset needs a name, for example:")
			mod:echo("/ut_save_preset somename")
			return
		end

		local preset_data = mod.get_preset_data()
		if preset_data then
			preset_data.player_name = preset_name
			preset_data.comment = ""

			mod.local_presets[preset_name] = preset_data
			Managers.save:auto_save(mod.local_presets_file_name, mod.local_presets, nil, mod.force_local_save)

			mod:echo("Saved preset "..preset_name)
		end
	end)
end

mod.delete_local_preset = function(preset_name)
	mod:pcall(function()
		if #mod.local_presets:keys() == 0 then
			mod:echo("No local presets exist to delete!")
			return
		end

		if not preset_name then
			mod:echo("Need a name of preset to delete: /ut_delete_preset name")
			mod:echo("Available presets:\n"..mod.local_presets:keys():join("\n"))
			return
		end

		if not mod.local_presets[preset_name] then
			mod:echo("Preset with that name doesn't exist!")
			mod:echo("Available presets:\n"..mod.local_presets:keys():join("\n"))
			return
		end

		mod.local_presets[preset_name] = nil
		Managers.save:auto_save(mod.local_presets_file_name, mod.local_presets, nil, mod.force_local_save)

		mod:echo("Deleted preset "..preset_name.."!")
	end)
end

-- Not just passing mod.save_local_preset as function
-- for better hooking support.
mod:command("ut_save_preset", "Locally save current UI Tweaks preset.", function(...) mod.save_local_preset(...) end)
mod:command("ut_delete_preset", "Delete local UI Tweaks preset.", function(...) mod.delete_local_preset(...) end)

mod.cb_load_local_presets_done = function(_, result)
	local local_presets = result.data
	if local_presets then
		mod.local_presets = pl.Map(local_presets)
	end
end

--- We load local presets on StateIngame enter.
