local mod = get_mod("MaxProperties") -- luacheck: ignore get_mod

-- luacheck: globals BuffTemplates WeaponProperties WeaponTraits

mod:hook_origin(GearUtils, "get_property_and_trait_buffs", function(backend_items, backend_id, buffs_table)
	local properties = backend_items:get_properties(backend_id)

	if properties then
		for property_key, property_value in pairs(properties) do -- luacheck: ignore property_value
			local property_data = WeaponProperties.properties[property_key]
			local buff_name = property_data.buff_name
			local buffer = property_data.buffer or "client"

			if BuffTemplates[buff_name] then
				buffs_table[buffer][buff_name] = {
					variable_value = 1 --property_value
				}
			end
		end
	end

	local traits = backend_items:get_traits(backend_id)

	if traits then
		for _, trait_key in pairs(traits) do
			local trait_data = WeaponTraits.traits[trait_key]
			local buff_name = trait_data.buff_name
			local buffer = trait_data.buffer or "client"

			if BuffTemplates[buff_name] then
				buffs_table[buffer][buff_name] = {
					variable_value = 1
				}
			end
		end
	end

	return buffs_table
end)