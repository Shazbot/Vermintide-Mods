local mod = get_mod("PositiveReinforcementTweaks")

local pl = require'pl.import_into'()

-- overwrite scenegraph definition to be on the left border of screen
mod.get_reinforcement_scenegraph_definition = function()
	return {
		screen = {
			scale = "fit",
			position = {
				0,
				0,
				UILayer.hud
			},
			size = {
				1920,
				1080
			}
		},
		message_animated = {
			vertical_alignment = mod.ALIGNMENTS_LOOKUP[mod:get(mod.SETTING_NAMES.VERTICAL_ALIGNMENT)],
			parent = "screen",
			horizontal_alignment = mod.ALIGNMENTS_LOOKUP[mod:get(mod.SETTING_NAMES.HORIZONTAL_ALIGNMENT)],
			position = {
				0,
				0,
				1
			},
			size = {
				0,
				0
			}
		}
	}
end

--- Make scenegraph creation use own scenegraph definition instead.
mod:hook(PositiveReinforcementUI, "create_ui_elements", function (func, self)
	local original_init_scenegraph = UISceneGraph.init_scenegraph
	UISceneGraph.init_scenegraph = function (scenegraph) -- luacheck: ignore scenegraph
		return original_init_scenegraph(mod.get_reinforcement_scenegraph_definition())
	end

	func(self)

	UISceneGraph.init_scenegraph = original_init_scenegraph
end)

local event_amount_count_text_style = {
	font_size = 25,
	word_wrap = false,
	pixel_perfect = true,
	horizontal_alignment = "left",
	vertical_alignment = "center",
	dynamic_font = true,
	font_type = "hell_shark",
	text_color = Colors.get_color_table_with_alpha("cheeseburger", 255),
	size = {
		30,
		38
	},
	offset = {
		188,
		-15-4,
		250
	}
}

mod.event_colors = {
	fade_to = Colors.get_table("white"),
	default = Colors.get_table("cheeseburger"),
	kill = Colors.get_table("red"),
	personal = Colors.get_table("dodger_blue")
}

mod:hook_safe(PositiveReinforcementUI, "add_event", function (self, hash, is_local_player, color_from, event_type, ...) -- luacheck: ignore hash is_local_player color_from ...
	local events = pl.List(self._positive_enforcement_events)

	-- newly created event
	local new_event = events[1]

	-- check if older event already exists
	local duplicate_kill_events = events:clone():remove(1):filter(
		function(event)
			return event_type == "killed_special"
				and event.widget.content["portrait_1"].texture_id == new_event.widget.content["portrait_1"].texture_id
				and event.widget.content["portrait_2"].texture_id == new_event.widget.content["portrait_2"].texture_id
		end)

	-- should be only one duplicate present, get the old count from it
	local old_count = 0
	if #duplicate_kill_events > 0 then
		old_count = duplicate_kill_events[1].event_amount_count
		if not old_count then
			old_count = 0
		end
	end

	-- remove old event, should be only one, but whatever
	duplicate_kill_events:foreach(
		function(kill_event)
			self:remove_event(events:index(kill_event))
		end)

	local widget = new_event.widget
	local passes = pl.List(widget.element.passes)

	widget.style["event_amount_count"] = table.clone(event_amount_count_text_style) -- new style for our text

	-- check if our new pass was already created before
	local widget_already_patched = #passes:filter(
		function(pass)
			return pass.text_id and pass.text_id == 'event_amount_count_formatted' or false
		end) > 0

	-- create new pass and pass_data if needed
	if not widget_already_patched then
		passes[#passes + 1] = {
			text_id = "event_amount_count_formatted",
			pass_type = "text",
			style_id = "event_amount_count",
			content_check_function = function(content)
				return content.event_amount_count > 1
			end,
		}
		widget.element.pass_data[#passes] = {
				text_id = "event_amount_count_formatted",
			}
	end

	local color_to = mod.event_colors.fade_to

	if not new_event._animations then
		new_event._animations = {}
	end
	new_event._animations["text_color_fade_1_"] = UIAnimation.init(UIAnimation.linear_scale, widget.style["event_amount_count"].text_color, 2, color_from[2], color_to[2], 0.8)
	new_event._animations["text_color_fade_2_"] = UIAnimation.init(UIAnimation.linear_scale, widget.style["event_amount_count"].text_color, 3, color_from[3], color_to[3], 0.8)
	new_event._animations["text_color_fade_3_"] = UIAnimation.init(UIAnimation.linear_scale, widget.style["event_amount_count"].text_color, 4, color_from[4], color_to[4], 0.8)
	new_event._animations["text_pulse_"] = UIAnimation.init(
			UIAnimation.linear_scale, widget.style["event_amount_count"], "font_size", 25, 35, 0.2,
			UIAnimation.linear_scale, widget.style["event_amount_count"], "font_size", 35, 25, 0.3
		)

	local content = widget.content
	new_event.event_amount_count = old_count + 1
	content.event_amount_count = new_event.event_amount_count -- keep a copy in content for the content_check_function
	content.event_amount_count_formatted = "x"..tostring(new_event.event_amount_count)
end)

mod.on_setting_changed = function(setting_name)
	if setting_name == mod.SETTING_NAMES.HORIZONTAL_ALIGNMENT
	or setting_name == mod.SETTING_NAMES.VERTICAL_ALIGNMENT then
		mod.init_new_scenegraph = true
		mod.reposition_widgets = true
	end

	if setting_name == mod.SETTING_NAMES.OFFSET_X
	or setting_name == mod.SETTING_NAMES.OFFSET_Y then
		mod.reposition_widgets = true
	end

	if setting_name == mod.SETTING_NAMES.SHOW_DURATION then
		UISettings.positive_reinforcement.show_duration = mod:get(mod.SETTING_NAMES.SHOW_DURATION)
	end
end

mod.alignment_offsets_lookup = {
	-60,
	60,
	40,
	-230,
	0,
}

-- keep a reference to PositiveReinforcementUI._positive_enforcement_events to pass into draw_widget
local positive_enforcement_events

mod:hook(UIRenderer, "draw_widget", function(func, ui_renderer, widget)
	local original_offset_y = widget.offset[2]
	for _, event in ipairs(positive_enforcement_events) do
		if widget == event.widget then
			local step_size = 80
			widget.offset[2] = widget.offset[2] + #positive_enforcement_events*step_size
			break
		end
	end

	func(ui_renderer, widget)

	widget.offset[2] = original_offset_y
end)
mod:hook_disable(UIRenderer, "draw_widget")

mod:hook(PositiveReinforcementUI, "update", function (func, self, dt, t)
	if mod.init_new_scenegraph  then
		mod.init_new_scenegraph = false
		self.ui_scenegraph = UISceneGraph.init_scenegraph(mod.get_reinforcement_scenegraph_definition())
	end

	if mod.reposition_widgets then
		local position = self.ui_scenegraph.message_animated.local_position
		position[1] = mod.alignment_offsets_lookup[mod:get(mod.SETTING_NAMES.HORIZONTAL_ALIGNMENT)]
		position[2] = mod.alignment_offsets_lookup[mod:get(mod.SETTING_NAMES.VERTICAL_ALIGNMENT)]
		if mod:get(mod.SETTING_NAMES.VERTICAL_ALIGNMENT) == mod.ALIGNMENTS.CENTER then
			position[2] = 0
		end
		if mod:get(mod.SETTING_NAMES.HORIZONTAL_ALIGNMENT) == mod.ALIGNMENTS.CENTER then
			position[1] = -67
		end

		position[1] = position[1] + mod:get(mod.SETTING_NAMES.OFFSET_X)
		position[2] = position[2] + mod:get(mod.SETTING_NAMES.OFFSET_Y)
	end

	local events = self._positive_enforcement_events
	for _, event in ipairs(events) do
		if event._animations then
			for name, animation in pairs( event._animations ) do
				if not UIAnimation.completed(animation) then
					UIAnimation.update(animation, dt)
				else
					event._animations[name] = nil
				end
			end
		end
	end

	positive_enforcement_events = self._positive_enforcement_events
	if mod:get(mod.SETTING_NAMES.REVERSE_FLOW) then
		mod:hook_enable(UIRenderer, "draw_widget")
	end
	func(self, dt, t)
	mod:hook_disable(UIRenderer, "draw_widget")
end)

--- Disable kill message for breeds.
mod:hook(PositiveReinforcementUI, "event_add_positive_enforcement_kill", function(func, self, hash, is_local_player, event_type, breed_name_attacker, breed_name_killed)
	if breed_name_killed then
		if mod:get(mod.SETTING_NAMES[breed_name_killed]) then
			return
		end

		-- for SV also check skaven_storm_vermin_commander
		if breed_name_killed == "skaven_storm_vermin_commander"
		and mod:get(mod.SETTING_NAMES["skaven_storm_vermin"]) then
			return
		end

		-- for beastmen_standard_bearer also check the _crater variant
		if breed_name_killed == "beastmen_standard_bearer_crater"
		and mod:get(mod.SETTING_NAMES["beastmen_standard_bearer"]) then
			return
		end
	end

	return func(self, hash, is_local_player, event_type, breed_name_attacker, breed_name_killed)
end)

mod.reposition_widgets = true
