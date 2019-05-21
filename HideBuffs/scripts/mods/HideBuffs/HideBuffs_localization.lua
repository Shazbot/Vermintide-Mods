
local mod = get_mod("HideBuffs")

local pl = require'pl.import_into'()

mod.localizations = mod.localizations or pl.Map()

mod.localizations:update({
	mod_description = {
		en = "UI Tweaks."
	},
	victor_bountyhunter_passive_infinite_ammo_buff = {
		en = "Bounty Hunter Passive"
	},
	victor_bountyhunter_passive_infinite_ammo_buff_tooltip = {
		en = "Bounty Hunter passive."
	},
	grimoire_health_debuff = {
		en = "Grimoire"
	},
	grimoire_health_debuff_tooltip = {
		en = "Grimoire."
	},
	markus_huntsman_passive_crit_aura_buff = {
		en = "Huntsman Passive Crit Aura"
	},
	markus_huntsman_passive_crit_aura_buff_tooltip = {
		en = "Huntsman passive crit aura."
	},
	markus_knight_passive_defence_aura = {
		en = "Foot Knight Aura"
	},
	markus_knight_passive_defence_aura_tooltip = {
		en = "Foot Knight aura."
	},
	kerillian_waywatcher_passive = {
		en = "Waywatcher Passive"
	},
	kerillian_waywatcher_passive_tooltip = {
		en = "Waywatcher passive."
	},
	kerillian_maidenguard_passive_stamina_regen_buff = {
		en = "Handmaiden Passive"
	},
	kerillian_maidenguard_passive_stamina_regen_buff_tooltip = {
		en = "Handmaiden passive."
	},
	HIDE_WHC_GRIMOIRE_POWER_BUFF = {
		en = "WHC Grimoire Power Buff"
	},
	HIDE_WHC_GRIMOIRE_POWER_BUFF_T = {
		en = "WHC grimoire power buff."
	},
	HIDE_SHADE_GRIMOIRE_POWER_BUFF = {
		en = "Shade Grimoire Power Buff"
	},
	HIDE_SHADE_GRIMOIRE_POWER_BUFF_T = {
		en = "Shade grimoire power buff."
	},
	HIDE_ZEALOT_HOLY_CRUSADER_BUFF = {
		en = "Zealot Holy Crusader Buff"
	},
	HIDE_ZEALOT_HOLY_CRUSADER_BUFF_T = {
		en = "Zealot Holy Crusader buff."
	},
	buffs_group = {
		en = "Buffs Tweaks"
	},
	hide_hotkeys_tooltip = {
		en = "Hide hotkeys."
	},
	hide_hotkeys = {
		en = "Hide Hotkeys"
	},
	hide_levels_T = {
		en = "Hide player levels."
	},
	hide_levels = {
		en = "Hide Player Levels"
	},
	hide_frames_T = {
		en = "Hide portrait frames."
	},
	hide_frames = {
		en = "Hide Portrait Frames"
	},
	no_tutorial_ui = {
		en = "Hide Floating Objective Marker"
	},
	no_tutorial_ui_T = {
		en = "Disable objective markers like \"Set Free\" for dead players."
	},
	no_mission_objective = {
		en = "Hide Mission Objective"
	},
	no_mission_objective_T = {
		en = "Hide the mission objective on top of the screen."
	},
	force_default_frame = {
		en = "Use Default Portrait Frames"
	},
	force_default_frame_tooltip = {
		en = "Always use the default portrait frame."
	},
	hide_player_portrait = {
		en = "Hide Player Portrait"
	},
	hide_player_portrait_tooltip = {
		en = "Hide player portrait at bottom left."
	},
	AMMO_COUNTER_GROUP = {
		en = "Ammo Counter Tweaks"
	},
	AMMO_COUNTER_GROUP_T = {
		en = "Tweaks related to the ammo counter."
	},
	AMMO_COUNTER_OFFSET_X = {
		en = "Offset X"
	},
	AMMO_COUNTER_OFFSET_X_T = {
		en = "Optionally offset on the x axis."
	},
	AMMO_COUNTER_OFFSET_Y = {
		en = "Offset Y"
	},
	AMMO_COUNTER_OFFSET_Y_T = {
		en = "Optionally offset on the y axis."
	},
	BUFFS_GROUP = {
		en = "Buffs Tweaks"
	},
	BUFFS_GROUP_T = {
		en = "Tweaks related to active buffs indicators."
	},
	BUFFS_OFFSET_X = {
		en = "Offset X"
	},
	BUFFS_OFFSET_X_T = {
		en = "Optionally offset on the x axis."
	},
	BUFFS_OFFSET_Y = {
		en = "Offset Y"
	},
	BUFFS_OFFSET_Y_T = {
		en = "Optionally offset on the y axis."
	},
	REVERSE_BUFF_DIRECTION = {
		en = "Reverse Buff Direction"
	},
	REVERSE_BUFF_DIRECTION_T = {
		en = "Make active buffs flow from right to left."
	},
	CENTERED_BUFFS = {
		en = "Center Buffs"
	},
	CENTERED_BUFFS_T = {
		en = "Center the buffs."
	},
	CENTERED_BUFFS_REALIGN = {
		en = "Center On Screen"
	},
	CENTERED_BUFFS_REALIGN_T = {
		en = "Also center on the middle of the screen."
	},
	BUFFS_FLOW_VERTICALLY = {
		en = "Buffs Flow Vertically"
	},
	BUFFS_FLOW_VERTICALLY_T = {
		en = "Make active buffs flow from top to bottom."
	},
	BUFFS_DISABLE_ALIGN_ANIMATION = {
		en = "Disable Align Animation"
	},
	BUFFS_DISABLE_ALIGN_ANIMATION_T = {
		en = "Disable the animation of a new buff sliding into place."
	},
	TEAM_UI_GROUP = {
		en = "Teammate UI Tweaks"
	},
	TEAM_UI_GROUP_T = {
		en = "Tweaks related to the teammate portraits."
	},
	TEAM_UI_OFFSET_X = {
		en = "Offset X"
	},
	TEAM_UI_OFFSET_X_T = {
		en = "Optionally offset on the x axis."
	},
	TEAM_UI_OFFSET_Y = {
		en = "Offset Y"
	},
	TEAM_UI_OFFSET_Y_T = {
		en = "Optionally offset on the y axis."
	},
	TEAM_UI_SPACING = {
		en = "Spacing Between Portraits"
	},
	TEAM_UI_SPACING_T = {
		en = "Change the spacing between portraits. Default is 220."
	},
	HIDE_BUFFS_GROUP = {
		en = "Hide Active Buffs"
	},
	TEAM_UI_FLOWS_HORIZONTALLY = {
		en = "Arrange Horizontally"
	},
	TEAM_UI_FLOWS_HORIZONTALLY_T = {
		en = "Arrange the teammate portraits horizontally."
	},
	CHAT_GROUP = {
		en = "Chat Tweaks"
	},
	CHAT_GROUP_T = {
		en = "Tweaks related to the chat UI."
	},
	CHAT_OFFSET_X = {
		en = "Offset X"
	},
	CHAT_OFFSET_X_T = {
		en = "Optionally offset on the x axis."
	},
	CHAT_OFFSET_Y = {
		en = "Offset Y"
	},
	CHAT_OFFSET_Y_T = {
		en = "Optionally offset on the y axis."
	},
	CHAT_BG_ALPHA = {
		en = "Chat Background Transparency"
	},
	CHAT_BG_ALPHA_T = {
		en = "Change the transparency of the chat background."
			.."\n0 is fully transparent."
			.."\nDefault is 255."
	},
	HIDE_WEAPON_SLOTS = {
		en = "Hide Melee and Ranged Item Slots"
	},
	HIDE_WEAPON_SLOTS_T = {
		en = "Hide the first 2 item slots(melee and ranged weapon)."
	},
	REPOSITION_WEAPON_SLOTS = {
		en = "Reposition Weapon Slots"
	},
	REPOSITION_WEAPON_SLOTS_T = {
		en = "Reposition the visible item slots to the left."
	},
	TEAM_UI_PORTRAIT_SCALE = {
		en = "Portrait Scale"
	},
	TEAM_UI_PORTRAIT_SCALE_T = {
		en = "Scale the portraits."
	},
	TEAM_UI_PORTRAIT_OFFSET_X = {
		en = "Portraits Offset X"
	},
	TEAM_UI_PORTRAIT_OFFSET_X_T = {
		en = "Optionally offset the portraits on the x axis."
	},
	TEAM_UI_PORTRAIT_OFFSET_Y = {
		en = "Portraits Offset Y"
	},
	TEAM_UI_PORTRAIT_OFFSET_Y_T = {
		en = "Optionally offset the portraits on the y axis."
	},
	TEAM_UI_NAME_OFFSET_X = {
		en = "Player Name Offset X"
	},
	TEAM_UI_NAME_OFFSET_X_T = {
		en = "Optionally offset the player name on the x axis."
	},
	TEAM_UI_NAME_OFFSET_Y = {
		en = "Player Name Offset Y"
	},
	TEAM_UI_NAME_OFFSET_Y_T = {
		en = "Optionally offset the player name on the y axis."
	},
	SECOND_BUFF_BAR = {
		en = "Priority Buff Bar"
	},
	SECOND_BUFF_BAR_T = {
		en = "Add a second buff bar for priority buffs."
			.."\nCustomize below what buffs go into this bar."
	},
	SECOND_BUFF_BAR_OFFSET_X = {
		en = "Offset X"
	},
	SECOND_BUFF_BAR_OFFSET_X_T = {
		en = "Optionally offset the Priority Buff Bar on the x axis."
	},
	SECOND_BUFF_BAR_OFFSET_Y = {
		en = "Offset Y"
	},
	SECOND_BUFF_BAR_OFFSET_Y_T = {
		en = "Optionally offset the Priority Buff Bar on the y axis."
	},
	PLAYER_UI_GROUP = {
		en = "Player UI Tweaks"
	},
	PLAYER_UI_GROUP_T = {
		en = "Tweaks related to the player UI on the bottom of the screen."
	},
	PLAYER_UI_OFFSET_X = {
		en = "Offset X"
	},
	PLAYER_UI_OFFSET_X_T = {
		en = "Optionally offset the Player UI on the x axis."
	},
	PLAYER_UI_OFFSET_Y = {
		en = "Offset Y"
	},
	PLAYER_UI_OFFSET_Y_T = {
		en = "Optionally offset the Player UI on the y axis."
	},
	PERSISTENT_AMMO_COUNTER = {
		en = "Persistent Ammo Counter"
	},
	PERSISTENT_AMMO_COUNTER_T = {
		en = "Keep the ammo counter visible with melee weapon equipped."
			.."\nSame thing as the stand-alone mod version of this option."
	},
	HIDE_BOSS_HP_BAR = {
		en = "Hide Boss HP Bar"
	},
	HIDE_BOSS_HP_BAR_T = {
		en = "Hide the HP bar on Bosses."
	},

	PRIORITY_BUFFS_GROUP = {
		en = "Priority Buffs"
	},
	PRIORITY_BUFFS_GROUP_T = {
		en = "Buffs to show in the Priority Buff Bar."
	},
	HIDE_UI_ELEMENTS_GROUP = {
		en = "Hide UI Elements"
	},
	HIDE_UI_ELEMENTS_GROUP_T = {
		en = "Hide some of the UI elements."
	},
	UNOBTRUSIVE_FLOATING_OBJECTIVE = {
		en = "Unobtrusive Objective Marker"
	},
	UNOBTRUSIVE_FLOATING_OBJECTIVE_T = {
		en = "Make the floating objective marker smaller and always transparent."
	},
	UNOBTRUSIVE_MISSION_TOOLTIP = {
		en = "Unobtrusive Mission Marker"
	},
	UNOBTRUSIVE_MISSION_TOOLTIP_T = {
		en = "Make the floating mission marker smaller and always transparent."
			.."\nUsed for revive warning."
	},
	top = {
		en = "Top"
	},
	bottom = {
		en = "Bottom"
	},
	left = {
		en = "Left"
	},
	right = {
		en = "Right"
	},
	center = {
		en = "Center"
	},
	default = {
		en = "Default"
	},
	hero = {
		en = "Hero"
	},
	hats = {
		en = "Hats"
	},

	-- priority buffs
	PACED_STRIKES = {
		en = "Merc Paced Strikes"
	},
	KNIGHT_ULT_BLOCK = {
		en = "Knight Inf Block After Ult"
	},
	KNIGHT_ULT_POWER = {
		en = "Knight Power After Ult"
	},
	WHC_ULT = {
		en = "WHC Ult"
	},
	WHC_PING_AS = {
		en = "WHC Ping AS Buff"
	},
	WHC_PING_CRIT = {
		en = "WHC Ping Crit Buff"
	},
	BW_TRANQUILITY = {
		en = "BW Tranquility Passive"
	},
	BH_CRIT_PASSIVE = {
		en = "BH Crit/Ammo Passive"
	},
	GROMRIL = {
		en = "Gromril Armour"
	},
	SWIFT_SLAYING = {
		en = "Swift Slaying Trait"
	},
	HUNTER = {
		en = "Hunter Trait"
	},
	BARRAGE = {
		en = "Barrage Trait"
	},
	DMG_POT = {
		en = "Strength Potion"
	},
	SPEED_POT = {
		en = "Speed Potion"
	},
	CDR_POT = {
		en = "CDR Potion"
	},
	MARKUS_HUNTSMAN_ACTIVATED_ABILITY = {
		en = "Huntsman Ult"
	},
	KERILLIAN_SHADE_ACTIVATED_ABILITY = {
		en = "Shade Ult"
	},
	VICTOR_ZEALOT_ACTIVATED_ABILITY = {
		en = "Zealot Ult"
	},
	BARDIN_RANGER_ACTIVATED_ABILITY = {
		en = "Ranger Ult"
	},
	BARDIN_IRONBREAKER_ACTIVATED_ABILITY = {
		en = "Ironbreaker Ult"
	},
	BARDIN_SLAYER_ACTIVATED_ABILITY = {
		en = "Slayer Ult"
	},
	HUNTSMAN_HS_CRIT_BUFF = {
		en = "Huntsman Makin' It Look Easy"
	},
	HUNTSMAN_HS_RELOAD_SPEED_BUFF = {
		en = "Huntsman Thrill of the Hunt"
	},
	TWITCH_BUFFS = {
		en = "Twitch Intervention Buffs"
	},
	BARKSKIN = {
		en = "Barkskin"
	},
	custom_dps_timed_buff = {
		en = "Custom DPS Temp Buff",
	},
	custom_dps_buff = {
		en = "Custom DPS Map Buff",
	},
	custom_dmg_taken_buff = {
		en = "Custom Dmg Taken Buff",
	},
	custom_temp_hp_buff = {
		en = "Custom White HP Buff",
	},
	custom_scavenger_buff = {
		en = "Custom Ammo Gain Buff",
	},
	custom_wounded_buff = {
		en = "Custom Death's Door Buff",
	},
	MERC_MORE_MERRIER = {
		en = "Merc: The More The Merrier!",
	},
	MERC_REIKLAND_REAPER = {
		en = "Merc: Reikland Reaper",
	},
	MERC_BLADE_BARRIER = {
		en = "Merc: Blade Barrier",
	},
	KNIGHT_BUILD_MOMENTUM = {
		en = "Knight: Build Momentum",
	},
	SLAYER_MOVING_TARGET = {
		en = "Slayer: Moving Target",
	},
	SLAYER_TROPHY_HUNTER = {
		en = "Slayer: Trophy Hunter",
	},
	IB_MINERS_RHYTHM = {
		en = "Ironbreaker: Miner's Rhythm",
	},
	ZEALOT_INVULNERABLE_ACTIVE = {
		en = "Zealot: Heart Of Iron Active",
	},
	ZEALOT_INVULNERABLE_ON_CD = {
		en = "Zealot: Heart Of Iron On CD",
	},
	ZEALOT_HOLY_CRUSADER = {
		en = "Zealot: Holy Crusader"
	},
	ZEALOT_FIERY_FAITH = {
		en = "Zealot: Fiery Faith"
	},
	ZEALOT_NO_SURRENDER = {
		en = "Zealot: No Surrender!"
	},
	BW_WORLD_AFLAME = {
		en = "BW: World Aflame(power per enemy)"
	},
	BW_BURNOUT = {
		en = "BW: Burnout(double ult)"
	},
	UNCHAINED_FEURBACHS_FURY = {
		en = "Unchained: Feurbach's Fury(charged hits stam regen)"
	},

})

return mod.localizations
