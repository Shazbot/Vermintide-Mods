local mod = get_mod("MutatorsSelector")

local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
}

mod:hook("Localize", function(func, id, ...)
		if not id then return end

		local localized = func(id, ...)

		if string.find(localized, "<") == 1 then
			localized = string.match(localized, "<display_name_mutator_(.+)>") or localized
			if string.match(localized, "<description_mutator_(.+)>") then
				localized = "Description missing, this is an unreleased mutator!"
			end
		end

		return localized
end)

mod_data.options_widgets = (function()
	local mutator_checkboxes = {}
	for mut_name, mut_template in pairs( MutatorTemplates ) do
		if mut_template.display_name and mut_template.description then
			table.insert(
				mutator_checkboxes,
				{
					["setting_name"] = mut_name,
					["widget_type"] = "checkbox",
					["text"] = Localize(mut_template.display_name or ""),
					["tooltip"] = Localize(mut_template.description or ""),
					["default_value"] = false
				}
			)
		end
	end
	return mutator_checkboxes
end)()

mod:hook_disable("Localize")

return mod_data
