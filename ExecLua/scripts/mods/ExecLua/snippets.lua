local mod = get_mod("ExecLua")

local pl = require'pl.import_into'()

mod.simple_ui = get_mod("SimpleUI")

mod.snippets = pl.List()

mod.url_origin = "https://gist.verminti.de"

mod.apply_snippet = function(snippet)
	mod.set_lines(pl.stringx.splitlines(snippet.code))
end

mod.get_name_from_snippet = function(snippet)
	return snippet.title
end

mod.snippets_window_size = {350, 250}
mod.snippets_window_position = { 0, 0 }

mod.create_snippets_window = function()
	local screen_width, screen_height = UIResolution()

	mod.snippets_window = mod.simple_ui:create_window("exec_lua_snippets", mod.snippets_window_position, mod.snippets_window_size)

	mod.snippets_window.position = mod.snippets_window_position

	mod.snippets_window:create_title("snippets_title", "Snippets", 40)

	local snippets_close_button = mod.snippets_window:create_close_button("snippets_close_button")
	snippets_close_button.anchor = "top_right"

	local indexed_snippet_names = pl.tablex.index_map(mod.snippets:map(mod.get_name_from_snippet))
	local snippets_dropdown = mod.snippets_window:create_dropdown(
		"snippets_dropdown",
		{0, 50+50},
		{300, 25},
		"middle_top",
		indexed_snippet_names,
		nil,
		1
	)
	snippets_dropdown.on_index_changed = function(dropdown)
		local snippet_to_apply = mod.snippets[dropdown.index]

		mod.apply_snippet(snippet_to_apply)
	end

	mod.snippets_window.on_hover_enter = function(window)
		window:focus()
	end

	mod.snippets_window:init()

	mod.snippets_window.transparent = false
	mod.snippets_window.theme = table.clone(mod.snippets_window.theme)
	mod.snippets_window.theme.color[1] = 255

	-- accounts for a scaling issue in SimpleUI on 1440p
	local snippets_window_width = mod.snippets_window.size[1]
	local snippets_window_height = mod.snippets_window.size[2]
	mod.snippets_window_position[2] = screen_height - snippets_window_height
	mod.snippets_window_position[1] = screen_width - snippets_window_width
end

mod.destroy_snippets_window = function()
	if mod.snippets_window then
		mod.snippets_window:destroy()
		mod.snippets_window = nil
	end
end

mod.get_snippet_cb = function (self, success, code, headers, data, userdata) -- luacheck: no unused
	if not success then
		return
	end

	if code ~= 200 then
		return
	end

	mod.snippets:append({
		title = userdata.title,
		code = data
	})
end

mod.get_snippets_cb = function (self, success, code, headers, data, userdata) -- luacheck: no unused
	if not success then
		return
	end

	if code ~= 200 then
		return
	end

	mod.snippets_definitions = pl.List(cjson.decode(data))

	for _, snippet_definition in ipairs( mod.snippets_definitions ) do
		local url = mod.url_origin..snippet_definition.uri

		Managers.curl:get(url, {}, callback(mod, "get_snippet_cb"), { title = snippet_definition.title }, {})
	end
end

--- Empty snippet to serve as a default dropdown option.
if not mod.empty_snippet then
	mod.empty_snippet = {
		title = "None",
		code = "",
	}
	mod.snippets:insert(1, mod.empty_snippet)
end

mod.load_snippets = function()
	mod:pcall(function()
		mod.snippets = pl.List()
		mod.snippets:insert(1, mod.empty_snippet)

		local url = mod.url_origin.."/index.json"
		Managers.curl:get(url, {}, callback(mod, "get_snippets_cb"), { title = "bleh" }, {})
	end)
end
