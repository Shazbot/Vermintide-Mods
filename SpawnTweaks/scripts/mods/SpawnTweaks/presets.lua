local mod = get_mod("SpawnTweaks")

local vmf = get_mod("VMF")

local pl = require'pl.import_into'()
local serpent = mod:dofile("scripts/mods/"..mod:get_name().."/serpent")

mod.save_preset = function(preset_name)
	mod:pcall(function()
		if not preset_name then
			mod:echo("Preset needs a name:")
			mod:echo("/save_preset name")
			return
		end

		local mods_settings = Application.user_setting("mods_settings")
		if mods_settings then
			local mod_settings = mods_settings[mod:get_name()]
			if mod_settings then
				local presets = mod:get("presets") or {}
				local cloned_settings = table.clone(mod_settings)
				cloned_settings.presets = nil
				presets[preset_name] = cloned_settings
				mod:set("presets", presets)

				vmf.save_unsaved_settings_to_file()
				mod:echo("Saved preset "..preset_name)
			end
		end
	end)
end

mod.load_preset = function(preset_name)
	mod:pcall(function()
		if not preset_name then
			local presets = pl.Map(mod:get("presets"))
			if not presets or presets:len() == 0 then
				mod:echo("No presets to load! Save a new one with /save_preset")
				return
			end

			mod:echo("Available presets:\n"..presets:keys():join("\n"))
			mod:echo("Load using: /load_preset name")
			return
		end

		local presets = mod:get("presets")
		if presets then
			local preset = presets[preset_name]
			if not preset then
				mod:echo("Preset with that name doesn't exist!")
				return
			end

			for setting_name, setting_value in pairs( preset ) do
				mod:set(setting_name, setting_value, true)
			end

			mod:echo("Loaded preset "..preset_name.."!")
		end
	end)
end

mod.delete_preset = function(preset_name)
	mod:pcall(function()
		if not preset_name then
			mod:echo("Need a name of preset to delete: /delete_preset name")
			return
		end

		local presets = mod:get("presets")
		if presets then
			local preset = presets[preset_name]
			if not preset then
				mod:echo("Preset with that name doesn't exist!")
				return
			end

			presets[preset_name] = nil
			mod:set("presets", presets)
			vmf.save_unsaved_settings_to_file()

			mod:echo("Deleted preset "..preset_name.."!")
		end
	end)
end

mod.dump_settings = function()
	local mods_settings = Application.user_setting("mods_settings")
	if mods_settings then
		local mod_settings = mods_settings[mod:get_name()]
		if mod_settings then
			local cloned_settings = table.clone(mod_settings)
			cloned_settings.presets = nil

			for setting_name, default_value in pairs( mod.setting_defaults ) do
				if cloned_settings[setting_name] == default_value then
					cloned_settings[setting_name] = nil
				end
			end
			for setting_name, _ in pairs( cloned_settings ) do
				if mod.setting_defaults[setting_name] == nil then
					cloned_settings[setting_name] = nil
				end
			end
			pl.utils.writefile("spawn_tweaks_settings", serpent.dump(cloned_settings, {compact = false, nocode = true, indent = '  '}))
		end
	end
end

mod:command("st_save_preset", mod:localize("save_preset_command_description"), mod.save_preset)
mod:command("st_load_preset", mod:localize("load_preset_command_description"), mod.load_preset)
mod:command("st_delete_preset", mod:localize("delete_preset_command_description"), mod.delete_preset)
mod:command("st_dump_settings", mod:localize("dump_settings_command_description"), mod.dump_settings)
