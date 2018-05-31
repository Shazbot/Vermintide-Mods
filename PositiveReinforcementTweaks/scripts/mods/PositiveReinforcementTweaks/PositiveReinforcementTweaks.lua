local mod = get_mod("PositiveReinforcementTweaks") -- luacheck: ignore get_mod

-- luacheck: globals UISceneGraph UILayer Colors table

local pl = require'pl.import_into'()

-- overwrite scenegraph definition to be on the left border of screen
local reinforcement_scenegraph_definition = {
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
		vertical_alignment = "center",
		parent = "screen",
		horizontal_alignment = "left",
		position = {
			35,
			120,
			1
		},
		size = {
			0,
			0
		}
	}
}

--- Make scenegraph creation use own scenegraph definition instead.
mod:hook("PositiveReinforcementUI.create_ui_elements", function (func, self)
	local original_init_scenegraph = UISceneGraph.init_scenegraph
	UISceneGraph.init_scenegraph = function (scenegraph) -- luacheck: ignore scenegraph
		return original_init_scenegraph(reinforcement_scenegraph_definition)
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
	text_color = Colors.get_color_table_with_alpha("white", 255),
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

mod:hook("PositiveReinforcementUI.add_event", function (func, self, hash, is_local_player, color_from, event_type, ...)
	func(self, hash, is_local_player, color_from, event_type, ...)

	mod:pcall(function()
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

		local content = widget.content
		new_event.event_amount_count = old_count + 1
		content.event_amount_count = new_event.event_amount_count -- keep a copy in content for the content_check_function
		content.event_amount_count_formatted = "x"..tostring(new_event.event_amount_count)
	end)
end)

--- Callbacks ---
mod.on_disabled = function(is_first_call) -- luacheck: ignore is_first_call
	mod:disable_all_hooks()
end

mod.on_enabled = function(is_first_call) -- luacheck: ignore is_first_call
	mod:enable_all_hooks()
end

-- debug stuff
-- UISettings.positive_reinforcement.show_duration = 4

-- mod:hook("PositiveReinforcementUI.update", function (func, self, ...)
-- 	self.ui_scenegraph = UISceneGraph.init_scenegraph(reinforcement_scenegraph_definition)

-- 	return func(self, ...)
-- end)

