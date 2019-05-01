local mod = get_mod("ExecLua")

local pl = require'pl.import_into'()

--- Disable the F2 console that was intended for hosted servers.
mod:hook_origin("RconUI", "_update_input", function()
end)

mod.simple_ui = get_mod("SimpleUI")

mod.exec_window_size = {1200, 1750}
mod.exec_window_position = { 0, 0 }
mod.lines = pl.List()
mod.textboxes = pl.List{}

mod.exec_window_was_destroyed = false

mod.do_exec = function()
	mod:pcall(function()
			local context = {}
			context.mod = mod
			context.pl = pl
			setmetatable(context, { __index = _G })

			local exec_text = mod.textboxes:map(function(textbox) return textbox.text end):join('\n')
			local exec = loadstring(exec_text)
			if exec then
				setfenv(exec, context)
				exec()
			end
		end)
end

mod.create_exec_window = function()
	local screen_width, screen_height = UIResolution()

	mod.exec_window = mod.simple_ui:create_window("presets", mod.exec_window_position, mod.exec_window_size)

	mod.exec_window.position = mod.exec_window_position

	mod.exec_window:create_title("presets_title", "Execute Lua", 40)

	local presets_close_button = mod.exec_window:create_close_button("presets_close_button")
	presets_close_button.anchor = "top_right"

	mod.textboxes = pl.List{}
	local start_y = 65
	for i = 1, 100 do
		local textbox = mod.exec_window:create_textbox(i.."_label",
			{0, start_y+i*31},
			{1000, 30},
			"middle_top"
		)
		textbox.text = mod.lines[i] or ""
		mod.textboxes:append(textbox)
	end

	local execute_button = mod.exec_window:create_button("execute_button",
		{0, 50},
		{150, 40},
		"middle_top",
		"Execute")
	execute_button.on_click = function()
		mod.do_exec()
	end

	mod.exec_window.before_destroy = function(window)
		mod.exec_window_was_destroyed = true
	end

	mod.exec_window.on_hover_enter = function(window)
		window:focus()
	end

	mod.exec_window:init()

	mod.exec_window.transparent = false
	mod.exec_window.theme.color[1] = 255

	-- accounts for a scaling issue in SimpleUI on 1440p
	local exec_window_width = mod.exec_window.size[1]
	mod.exec_window_position[2] = -900
	mod.exec_window_position[1] = screen_width/2 - exec_window_width/2
end

mod.destroy_exec_window = function()
	if mod.exec_window then
		mod.exec_window:destroy()
		mod.exec_window = nil
	end
end

mod:hook("ChatGui", "update", function(func, self, ...)
	mod:pcall(function()
		if Keyboard.pressed(Keyboard.button_index("f2")) then
			if mod.exec_window then
				mod.destroy_exec_window()
			else
				self:block_input()
				mod.create_exec_window()
			end
		end

		if mod.exec_window_was_destroyed then
			mod.exec_window_was_destroyed = false
			self:unblock_input()
		end

		-- mostly VMF code for pasting into chat
		if Keyboard.pressed(Keyboard.button_index("v")) and Keyboard.button(Keyboard.button_index("left ctrl")) == 1 then
		  local newly_pasted = ""

		  -- remove carriage returns
		  local clipboard_data = tostring(Clipboard.get()):gsub("\r", "")

		  -- remove invalid characters
		  if Utf8.valid(clipboard_data) then
				newly_pasted = newly_pasted .. clipboard_data
		  else
				local valid_data = ""
				clipboard_data:gsub(".", function(c)
				  if Utf8.valid(c) then
					valid_data = valid_data .. c
				  end
				end)
				newly_pasted = newly_pasted .. valid_data
		  end

		  mod.pasted = newly_pasted
		  mod.lines = pl.stringx.splitlines(newly_pasted)

		  for i, textbox in ipairs( mod.textboxes ) do
				textbox.text = mod.lines[i] or ""
		  end
		end
	end)

	return func(self, ...)
end)
