local mod = get_mod("CrosshairCustomization")

-- luacheck: globals UIRenderer table ScriptUnit

local pl = require'pl.import_into'()
local tablex = require'pl.tablex'

--- Enums ---
local COLOR_INDEX = {
    DEFAULT = 1,
    RED = 2,
    GREEN = 3,
    CUSTOM = 4
}

local COLORS = {
	[COLOR_INDEX.DEFAULT] = {255, 255, 255, 255},
	[COLOR_INDEX.RED] = {255, 255, 0, 0},
	[COLOR_INDEX.GREEN] = {255, 0, 255, 0},
	DEFAULT = {255, 255, 255, 255},
	RED = {255, 255, 0, 0},
	GREEN = {255, 0, 255, 0},
}

local SETTING_NAMES = {
    COLOR = "color",
    ENLARGE = "enlarge",
    DOT = "dot",
    DOT_TOGGLE_HOTKEY = "dot_toggle_hotkey",
    NO_MELEE_DOT = "no_melee_dot",
    CUSTOM_RED = "custom_red",
    CUSTOM_GREEN = "custom_green",
    CUSTOM_BLUE = "custom_blue",
    NO_RANGE_MARKERS = "no_range_markers",
    NO_LINE_MARKERS = "no_line_markers"
}
---! Enums ---

local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
}
mod_data.options_widgets = {
   {
		["setting_name"] = SETTING_NAMES.COLOR,
		["widget_type"] = "dropdown",
		["text"] = mod:localize("color"),
		["tooltip"] = mod:localize("color_tooltip"),
		["options"] = {
				{text = mod:localize("default"), value = COLOR_INDEX.DEFAULT},
				{text = mod:localize("red"), value = COLOR_INDEX.RED},
				{text = mod:localize("green"), value = COLOR_INDEX.GREEN},
				{text = mod:localize("custom"), value = COLOR_INDEX.CUSTOM},
	    },
		["default_value"] = COLOR_INDEX.DEFAULT,
		["sub_widgets"] = {
		    {
				["show_widget_condition"] = { COLOR_INDEX.CUSTOM },
				["setting_name"] = SETTING_NAMES.CUSTOM_RED,
				["widget_type"] = "numeric",
				["text"] = mod:localize("red"),
				["tooltip"] = mod:localize("custom_red_tooltip"),
				["range"] = {0, 255},
				["default_value"] = 255,
			},
			{
				["show_widget_condition"] = { COLOR_INDEX.CUSTOM },
				["setting_name"] = SETTING_NAMES.CUSTOM_GREEN,
				["widget_type"] = "numeric",
				["text"] = mod:localize("green"),
				["tooltip"] = mod:localize("custom_green_tooltip"),
				["range"] = {0, 255},
				["default_value"] = 255,
			},
			{
				["show_widget_condition"] = { COLOR_INDEX.CUSTOM },
				["setting_name"] = SETTING_NAMES.CUSTOM_BLUE,
				["widget_type"] = "numeric",
				["text"] = mod:localize("blue"),
				["tooltip"] = mod:localize("custom_blue_tooltip"),
				["range"] = {0, 255},
				["default_value"] = 255,
			},
		},
	},
	{
		["setting_name"] = SETTING_NAMES.ENLARGE,
		["widget_type"] = "numeric",
		["text"] = mod:localize("enlarge"),
		["tooltip"] = mod:localize("enlarge_tooltip"),
		["range"] = {0, 300},
		["unit_text"] = "%",
	    ["default_value"] = 100,
	},
	{
		["setting_name"] = SETTING_NAMES.DOT,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("dot"),
		["tooltip"] = mod:localize("dot_tooltip"),
		["default_value"] = false,
	},
	{
		["setting_name"] = SETTING_NAMES.DOT_TOGGLE_HOTKEY,
		["widget_type"] = "keybind",
		["text"] = mod:localize("dot_toggle_hotkey"),
		["tooltip"] = mod:localize("dot_toggle_hotkey_tooltip"),
		["default_value"] = {},
		["action"] = "dot_toggle"
	},
	{
		["setting_name"] = SETTING_NAMES.NO_MELEE_DOT,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("no_melee_dot"),
		["tooltip"] = mod:localize("no_melee_dot_tooltip"),
		["default_value"] = false
	},
	{
		["setting_name"] = SETTING_NAMES.NO_LINE_MARKERS,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("no_line_markers"),
		["tooltip"] = mod:localize("no_line_markers_tooltip"),
		["default_value"] = false
	},
	{
		["setting_name"] = SETTING_NAMES.NO_RANGE_MARKERS,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("no_range_markers"),
		["tooltip"] = mod:localize("no_range_markers_tooltip"),
		["default_value"] = false
	},
}

mod:initialize_data(mod_data)

--- Callbacks ---
mod.on_disabled = function(is_first_call) -- luacheck: ignore is_first_call
	-- mod:disable_all_hooks()
end

mod.on_enabled = function(is_first_call) -- luacheck: ignore is_first_call
	mod:enable_all_hooks()
end

--- Mod Logic ---
local function get_color()
	local color_index = mod:is_enabled() and mod:get(SETTING_NAMES.COLOR) or COLOR_INDEX.DEFAULT
	local color = COLORS[color_index] or { 255, mod:get(SETTING_NAMES.CUSTOM_RED), mod:get(SETTING_NAMES.CUSTOM_GREEN), mod:get(SETTING_NAMES.CUSTOM_BLUE) }
	return color
end

local widget_names = pl.List{
	"crosshair_projectile",
	"crosshair_shotgun",
	"crosshair_dot",
	"crosshair_line",
	"crosshair_arrow",
	"crosshair_circle",
}
local function change_crosshair_size(crosshair_ui)
	local scale_by = mod:get(SETTING_NAMES.ENLARGE) / 100

	widget_names:foreach(function(widget_name)
		local widget = crosshair_ui.ui_scenegraph[widget_name]
		if widget then
			if not widget.size_backup then
				widget.size_backup = table.clone(widget.size)
			end
			widget.size = tablex.map("*", widget.size_backup, scale_by)

			if not widget.local_position_backup then
				widget.local_position_backup = table.clone(widget.local_position)
			end
			widget.local_position = tablex.map("*", widget.local_position_backup, scale_by)

			crosshair_ui[widget_name].style.pivot = tablex.map("/", widget.size, 2)
		end
	end)
end

--- Change crosshair color, run before every of the crosshair_ui draw functions.
local function change_crosshair_color(crosshair_ui)
	mod:pcall(function()
		local color = get_color()

		crosshair_ui.crosshair_projectile.style.color = color
		crosshair_ui.crosshair_shotgun.style.color = color
		crosshair_ui.crosshair_dot.style.color = color
		crosshair_ui.crosshair_line.style.color = color
		crosshair_ui.crosshair_arrow.style.color = color
		crosshair_ui.crosshair_circle.style.color = color

		if not crosshair_ui.hit_marker_animations[1] then
			for _,hit_marker in ipairs(crosshair_ui.hit_markers) do
			  hit_marker.style.rotating_texture.color = table.clone(color)
			  hit_marker.style.rotating_texture.color[1] = 0
			end
		end
	end)
end

--- Change color of hit markers.
mod:hook("CrosshairUI.configure_hit_marker_color_and_size", function (func, self, hit_marker, hit_marker_data)
	local additional_hit_icon = func(self, hit_marker, hit_marker_data)

	mod:pcall(function()
		local damage_amount = hit_marker_data.damage_amount
		local hit_critical = hit_marker_data.hit_critical
		local has_armor = hit_marker_data.has_armor
		local hit_player = hit_marker_data.hit_player
		local added_dot = hit_marker_data.added_dot
		local shield_break = hit_marker_data.shield_break
		local shield_open = hit_marker_data.shield_open
		local is_critical = false
		local is_armored = false
		local friendly_fire = false

		if damage_amount <= 0 and has_armor and not added_dot then
			is_armored = true
		elseif hit_player then
			friendly_fire = true
		elseif hit_critical then
			is_critical = true
		end

		if not is_armored and not friendly_fire and not is_critical then
			local color = get_color()

			hit_marker.style.rotating_texture.color = table.clone(color)
			hit_marker.style.rotating_texture.color[1] = 0
		end
	end)

	return additional_hit_icon
end)

local do_once = false -- DEBUG
--- Show the hit markers for debugging.
local function simulate_hit(crosshair_ui)
	if not do_once then
		local player_unit = crosshair_ui.local_player.player_unit
		local hud_extension = ScriptUnit.extension(player_unit, "hud_system")
		local hit_marker_data = hud_extension.hit_marker_data
		hit_marker_data.hit_enemy = true
		hit_marker_data.damage_amount = 8
		do_once = true
	end
end

local function draw_crosshair_prehook(crosshair_ui)
	mod:pcall(function()
		-- simulate_hit(crosshair_ui)
		change_crosshair_size(crosshair_ui)
		change_crosshair_color(crosshair_ui)
	end)
end

local CROSSHAIR_STYLE_FUNCTIONS = {
	-- default = "draw_default_style_crosshair",
	circle = "draw_circle_style_crosshair",
	-- shotgun = "draw_shotgun_style_crosshair",
	-- dot = "draw_dot_style_crosshair",
	arrows = "draw_arrows_style_crosshair",
	-- projectile = "draw_projectile_style_crosshair"
}

for _, method_name in pairs( CROSSHAIR_STYLE_FUNCTIONS ) do
	mod:hook("CrosshairUI."..method_name, function(func, self, ...)
		draw_crosshair_prehook(self)
		return func(self, ...)
	end)
end

--- No crosshair at all with a melee weapon.
mod:hook("CrosshairUI.draw_dot_style_crosshair", function(func, self, ...)
	draw_crosshair_prehook(self)

	if mod:is_enabled() and mod:get(SETTING_NAMES.NO_MELEE_DOT) then
		return
	end

    return func(self, ...)
end)

local function dot_only_prehook(func, self, ...)
	draw_crosshair_prehook(self)

	if mod:is_enabled() and mod:get(SETTING_NAMES.DOT) then
		return self:draw_dot_style_crosshair(...)
	end

    return func(self, ...)
end

--- Hide lines, keep dot.
mod:hook("CrosshairUI.draw_default_style_crosshair", dot_only_prehook)
mod:hook("CrosshairUI.draw_shotgun_style_crosshair", dot_only_prehook)

--- Hide headshot markers.
mod:hook("CrosshairUI.draw_projectile_style_crosshair", function (func, self, ui_renderer, pitch_percentage, yaw_percentage)
	if mod:is_enabled() and mod:get(SETTING_NAMES.DOT) then
		return self:draw_dot_style_crosshair(ui_renderer, pitch_percentage, yaw_percentage)
	end

	local original_draw_widget = UIRenderer.draw_widget
	UIRenderer.draw_widget = function (ui_renderer, ui_widget)
		if mod:get(SETTING_NAMES.NO_RANGE_MARKERS) and ui_widget == self.crosshair_projectile then
			return
		end
		if mod:get(SETTING_NAMES.NO_LINE_MARKERS) and ui_widget == self.crosshair_line then
			return
		end
		return original_draw_widget(ui_renderer, ui_widget)
	end

	draw_crosshair_prehook(self)
	func(self, ui_renderer, pitch_percentage, yaw_percentage)

	UIRenderer.draw_widget = original_draw_widget
end)

--- Actions ---
--- Dot only on_toggle.
mod.dot_toggle = function()
	local current_dot_only = mod:get(SETTING_NAMES.DOT)
	mod:set(SETTING_NAMES.DOT, not current_dot_only, true)
end