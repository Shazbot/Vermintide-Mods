local mod = get_mod("StreamingInfo") -- luacheck: ignore get_mod

local pl = require'pl.import_into'()

mod.localizations = mod.localizations or pl.Map()

mod.localizations:update({
	mod_description = {
		en = "Dump information on screen for stream viewers."
	},
	set_lines_command_description = {
		en = "Lines to show below items, separated by \";\"."
			.."\ne.g. /set_lines NOTES: ; DRUNK STREAM ; I'M SOOOO DRUNK RIGHT NOW GUYS"
			.."\nStart with just \";\" for an empty line: /set_lines ; LINE1 ; LINE2"
			.."\nCall without arguments to clear lines. \"/set_lines\""
	},
	info_command_description = {
		en = "Information to permanently show, check /set_lines for formatting."
	},
	LINE_SPACING_T = {
		en = "Adjust vertical space between lines."
	}
})

local function concat_upper_lower(first, rest)
   return first:upper()..rest:lower()
end

mod.original_localize = mod.localize
mod.localize = function (self, text_id, ...)
	if mod.localizations[text_id] then
		return mod.original_localize(self, text_id, ...)
	end

	local name = pl.stringx.replace(text_id, "_", " ")

	if pl.stringx.lfind(text_id, "_T") == #text_id-1 then
		name = string.sub(name, 1, -3)
		return name:gsub("(%w)(.*)", concat_upper_lower).."."
	end

	if mod.SETTING_NAMES[text_id] then
		return pl.stringx.title(name)
	end

	return mod.original_localize(self, text_id, ...)
end

return mod.localizations
