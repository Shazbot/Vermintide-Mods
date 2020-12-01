local mod = get_mod("HideBuffs")

local pl = require'pl.import_into'()

--- Default HP bar values.
mod.original_health_bar_size = {
	92,
	9
}
mod.health_bar_offset = {
	-(mod.original_health_bar_size[1] / 2),
	-25,
	0
}

--- Elements to reposition inside default_dynamic widget.
mod.def_dynamic_widget_names = pl.List{
	"talk_indicator",
	"talk_indicator_highlight",
	"talk_indicator_highlight_glow",
}

--- Carrer name to hat icon texture lookup.
mod.career_name_to_hat_icon = pl.Map{
	bw_adept = "icon_adept_hat_0001",
	bw_scholar = "icon_scholar_hat_0000",
	bw_unchained = "icon_unchained_hat_0008",
	dr_ironbreaker = "icon_ironbreaker_hat_0006",
	dr_ranger = "icon_ranger_hat_0005",
	dr_slayer = "icon_slayer_hat_0000",
	empire_soldier_tutorial = "icon_knight_hat_0010",
	es_huntsman = "icon_huntsman_hat_0000",
	es_knight = "icon_knight_hat_0010",
	es_mercenary = "icon_mercenary_hat_0007",
	we_maidenguard = "icon_maidenguard_hat_0000",
	we_shade = "icon_shade_hat_0009",
	we_waywatcher = "icon_waywatcher_hat_0001",
	wh_bountyhunter = "icon_bountyhunter_hat_0000",
	wh_captain = "icon_witchhunter_hat_0003",
	wh_zealot = "icon_zealot_hat_0009",
	dr_engineer = "icon_engineer_hat_0001",
	es_questingknight = "icon_questing_knight_hat_0000",
}

--- Elements to reposition inside loadout_dynamic widget.
--- Index is missing, i.e. item_slot_bg_1.
mod.item_slot_widgets = {
	"item_slot_bg_",
	"item_slot_frame_",
	"item_slot_highlight_",
}
mod.item_slot_background_widgets = {
	"item_slot_bg_",
	"item_slot_frame_",
}

--- Healshare talents.
mod.healshare_buff_names = {
	"bardin_ranger_conqueror",
	"bardin_ironbreaker_conqueror",
	"bardin_slayer_conqueror",
	"kerillian_waywatcher_conqueror",
	"kerillian_maidenguard_conqueror",
	"kerillian_shade_conqueror",
	"markus_mercenary_conqueror",
	"markus_huntsman_conqueror",
	"markus_knight_conqueror",
	"sienna_adept_conqueror",
	"sienna_scholar_conqueror",
	"sienna_unchained_conqueror",
	"victor_witchhunter_conqueror",
	"victor_bountyhunter_conqueror",
	"victor_zealot_conqueror",
}

--- Ubersreik level keys.
mod.ubersreik_lvls = pl.List({
	"magnus",
	"cemetery",
	"forest_ambush",
})

--- Portrait frame widget elements: texture_1(static frame) and texture_2(dynamic frame).
mod.frame_texture_names = { "texture_1", "texture_2" }
