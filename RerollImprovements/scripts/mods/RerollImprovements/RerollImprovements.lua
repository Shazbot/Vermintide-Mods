local mod = get_mod("RerollImprovements") -- luacheck: ignore get_mod

 -- luacheck: globals CraftPageRollProperties Managers UIUtils Managers UIWidgets
 -- luacheck: globals UIWidget Colors UISettings WeaponTraits CraftPageRollTrait
 -- luacheck: globals Localize

UISettings.crafting_progress_time = 0.01

mod.last_backend_id = nil

mod.property_text_style = {
	font_size = 24,
	upper_case = false,
	localize = false,
	use_shadow = true,
	word_wrap = false,
	horizontal_alignment = "center",
	vertical_alignment = "center",
	font_type = "hell_shark",
	text_color = Colors.get_color_table_with_alpha("white", 200),
	offset = {
		0,
		0,
		-35
	}
}

mod:hook_safe(CraftPageRollProperties, "_add_craft_item", function(self, backend_id)
	mod:pcall(function()
		if self._craft_items[1] and self._widgets_by_name["mod_properties_1"] then
			local properties = Managers.backend:get_interface("items"):get_properties(self._craft_items[1])

			self._widgets_by_name["mod_properties_1"].content.text = ""
			self._widgets_by_name["mod_properties_2"].content.text = ""

			local index = 1
			for prop_name, prop_value in pairs( properties ) do
				self._widgets_by_name["mod_properties_"..index].content.text = UIUtils.get_property_description(prop_name, prop_value)
				index = index + 1
			end
		end
		mod.last_backend_id = backend_id
	end)
end)

mod:hook_safe(CraftPageRollProperties, "_remove_craft_item", function(self)
	if not self._craft_items[1] and self._widgets_by_name["mod_properties_1"] then
		self._widgets_by_name["mod_properties_1"].content.text = ""
		self._widgets_by_name["mod_properties_2"].content.text = ""
		mod.last_backend_id = nil
	end
end)

mod:hook_safe(CraftPageRollProperties, "on_craft_completed", function(self)
	local item_interface = Managers.backend:get_interface("items")
	if item_interface:get_item_from_id(mod.last_backend_id) then
		self:_add_craft_item(mod.last_backend_id)
	end
end)

mod:hook_safe(CraftPageRollProperties, "create_ui_elements", function(self)
	local widgets = self._widgets
	local widgets_by_name = self._widgets_by_name

	for i = 1, 2 do
		local text_definition = UIWidgets.create_simple_text("", "recipe_grid", nil, nil, mod.property_text_style)
		local widget = UIWidget.init(text_definition)
		widgets[#widgets + 1] = widget
		widgets_by_name["mod_properties_"..i] = widget
		widget.offset[1] = 0
		widget.offset[2] = 87+(i-1)*(-26)
		widget.offset[3] = 50
	end
end)

--- Trait Rerolling ---
mod:hook_safe(CraftPageRollTrait, "_add_craft_item", function(self, backend_id)
	mod:pcall(function()
		if self._craft_items[1] and self._widgets_by_name["mod_trait"] then
			local traits = Managers.backend:get_interface("items"):get_traits(self._craft_items[1])

			self._widgets_by_name["mod_trait"].content.text = ""

			local trait = traits[1]
			if trait then
				self._widgets_by_name["mod_trait"].content.text = Localize(WeaponTraits.traits[trait].display_name)
			end
		end
		mod.last_backend_id = backend_id
	end)
end)

mod:hook_safe(CraftPageRollTrait, "_remove_craft_item", function(self)
	if not self._craft_items[1] and self._widgets_by_name["mod_trait"] then
		self._widgets_by_name["mod_trait"].content.text = ""
		mod.last_backend_id = nil
	end
end)

mod:hook_safe(CraftPageRollTrait, "on_craft_completed", function(self)
	local item_interface = Managers.backend:get_interface("items")
	if item_interface:get_item_from_id(mod.last_backend_id) then
		self:_add_craft_item(mod.last_backend_id)
	end
end)

mod:hook_safe(CraftPageRollTrait, "create_ui_elements", function(self)
	local widgets = self._widgets
	local widgets_by_name = self._widgets_by_name

	local text_definition = UIWidgets.create_simple_text("", "recipe_grid", nil, nil, mod.property_text_style)
	local widget = UIWidget.init(text_definition)
	widgets[#widgets + 1] = widget
	widgets_by_name["mod_trait"] = widget
	widget.offset[1] = -5
	widget.offset[2] = 73
	widget.offset[3] = 50
end)
