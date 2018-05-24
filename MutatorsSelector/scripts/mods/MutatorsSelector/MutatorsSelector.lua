local mod = get_mod("MutatorsSelector") -- luacheck: ignore get_mod

-- luacheck: globals MutatorTemplates Localize

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
				["tooltip"] = Localize(mut_template.display_name).."\n"..Localize(mut_template.description),
				["default_value"] = false
			})
	end
	return mutator_checkboxes
end)()

mod:hook("MutatorHandler.init", function(func, self, mutators, is_server, has_local_client)
	mutators = {}
	for mut_name, _ in pairs( MutatorTemplates ) do
		if mod:get(mut_name) then
			table.insert(mutators, mut_name)
		end
	end
	return func(self, mutators, is_server, has_local_client)
end)

mod:initialize_data(mod_data)

--- Callbacks ---
mod.on_disabled = function(is_first_call) -- luacheck: ignore is_first_call
	mod:disable_all_hooks()
end

mod.on_enabled = function(is_first_call) -- luacheck: ignore is_first_call
	mod:enable_all_hooks()
end


