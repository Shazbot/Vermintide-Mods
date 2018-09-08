local stringx = require'pl.stringx'

local localization = {
	mod_name= {
		en = "Neuter Ult Effects"
	},
	mod_description = {
		en = "Cut down on visual and audio effects during ults."
	},
	wounded= {
		en = "Disable Wounded Filter"
	},
	wounded_tooltip = {
		en = "Disable the grayscale filter when about to die."
	},
	knocked_down = {
		en = "Disable Knocked Down Filter"
	},
	knocked_down_tooltip = {
		en = "Disable the red screen filter when knocked down."
	},
	BLOOD_SPLATTER = {
		en = "Disable Blood Splatters"
	},
	BLOOD_SPLATTER_T = {
		en = "Disable blood splatters that cover the screen."
	},
	HEALING = {
		en = "Disable Healing Filter"
	},
	HEALING_T = {
		en = "Disable getting flashbanged when using healing supplies."
	},
}

for _, name in ipairs( { "SLAYER", "HUNTSMAN", "SHADE", "ZEALOT", "RANGER" } ) do
	localization[name.."_GROUP"] = {
		en = stringx.title(name)
	}
	localization[name.."_VISUAL"] = {
		en = stringx.title(name).." Visual"
	}
	localization[name.."_VISUAL_T"] = {
		en = "Disable visual effects on "..stringx.title(name).." ult."
	}
	localization[name.."_AUDIO"] = {
		en = stringx.title(name).." Audio"
	}
	localization[name.."_AUDIO_T"] = {
		en = "Disable audio effects on "..stringx.title(name).." ult."
	}
end

return localization