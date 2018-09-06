local mod = get_mod("StreamingInfo") -- luacheck: ignore get_mod

local stringx = require'pl.stringx'

local localization = {
	mod_description = {
		en = "Dump information on screen for stream viewers."
	},
}

local function concat_upper_lower(first, rest)
   return first:upper()..rest:lower()
end

mod.original_localize = mod.localize
mod.localize = function (self, text_id, ...)
	local name = stringx.replace(text_id, "_", " ")

	if stringx.lfind(text_id, "_T") == #text_id-1 then
		name = string.sub(name, 1, -3)
		return name:gsub("(%w)(.*)", concat_upper_lower).."."
	end

	if mod.SETTING_NAMES[text_id] then
		return stringx.title(name)
	end

	return mod.original_localize(self, text_id, ...)
end

return localization