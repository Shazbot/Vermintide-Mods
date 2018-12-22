local mod = get_mod("MutatorsSelector")

local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
}

mod_data.options_widgets = (function()
	local mutator_checkboxes = {}
	for mut_name, mut_template in pairs( MutatorTemplates ) do
		table.insert(mutator_checkboxes,
			{
				["setting_name"] = mut_name,
				["widget_type"] = "checkbox",
				["text"] = Localize(mut_template.display_name),
				["tooltip"] = Localize(mut_template.description),
				["default_value"] = false
			})
	end
	return mutator_checkboxes
end)()

return mod_data
