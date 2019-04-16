local mod = get_mod("HideBuffs")

mod.item_type_to_breakpoints = {
	bw_1h_crowbill = "",
	bw_1h_dagger = "",
	bw_1h_sword = "",
	bw_flame_sword = "",
	bw_morningstar = "",
	bw_staff_beam = "",
	bw_staff_firball = "",
	bw_staff_flamethrower = "",
	bw_staff_geiser = "",
	bw_staff_spear = "",
	dr_1h_axe_shield = "10% Chaos & Stamina to oneshot bodyshot Fanatics with Light attacks and 2 Shot bodyshot Marauders with Light attacks.",
	dr_1h_axes = "10% Chaos + Attack speed to oneshot bodyshot Fanatics with Light attacks and to 2 shot Marauders with every attack. (Add 10% Chaos on the charm to oneshot headshot Marauders with Light attacks with 3 Stacks of Trophy Hunter on Slayer).",
	dr_1h_hammer = "10% Chaos + attack speed to 2 shot bodyshot Fanatics with Light 1-3 and 1 shot with Light 4. (attack speed + crit chance with Trophy Hunter).",
	dr_1h_hammer_shield = "10% Chaos + stamina to 2 shot bodyshot Fanatics with Light attacks and 1 shot bodyshot with Push attacks.",
	dr_2h_axes = "Attack speed + crit chance. Doesn't hit relevant breakpoints with properties.",
	dr_2h_hammer = "10% Chaos + Attack speed to 4 shot headshot Chaos Warriors with Light attacks.",
	dr_2h_picks = "10% chaos + attack speed to 2 shot bodyshot Chaos Warriors with fully charged heavies.",
	dr_crossbow = "10% Skaven + crit chance to oneshot bodyshot assassins and to oneshot headshot Stormvermin after damage falloff.",
	dr_drakefire_pistols = "20% Chaos/Infantry to oneshot bodyshot Fanatics.",
	dr_drakegun = "20% Skaven/Armored to increase DPS versus Stormvermin since horde dps doesn't require futher increase.",
	dr_dual_axes = "10% Chaos + Attack speed to oneshot bodyshot Fanatics with Light attacks with 3 Stacks of Trophy Hunter.",
	dr_dual_wield_hammers = "10% Chaos + attack speed to 2 shot bodyshot Fanatics with Light attacks (attack speed + crit chance with Trophy Hunter).",
	dr_grudgeraker = "10% Skaven + Crit chance to oneshot bodyshot Stormvermin with all pellets.",
	dr_handgun = "20% Chaos/Infantry to oneshot bodyshot Blightstormers and Leeches before damage falloff. 20% Chaos/Infantry on the charm to oneshot bodyshot Gasrats before damage falloff and to oneshot bodyshot Blightstormers / Leeches with damage falloff.",
	es_1h_mace = "Attack speed & Crit chance on the weapon and 10% Infantry on the charm to oneshot headshot Clanrats with Light attacks and to 2 shot bodyshot / 1 shot headshot Fanatics with Light 1-3 and to oneshot bodyshot fanatics with Light 4 (Can be exchanged with Reikland reaper or 2 stacks of The More the Merrier on Mercenary).",
	es_1h_mace_shield = "Stamina & Attack speed and 10% Infantry on the charm to oneshot headshot Clanrats with Light attacks and to 2 shot bodyshot Fanatics with Light attacks and to oneshot bodyshot Fanatics with Push attacks (Can be exchanged with Reikland reaper or 2 stacks of The More the Merrier on Mercenary).",
	es_1h_sword = "Attack speed + stamina on the weapon and 20% Skaven/Infantry on the charm to oneshot bodyshot Clanrats with push attacks and to oneshot headshot them with Light attacks. And to oneshot bodyshot Fanatics with Light 3 and Heavy attacks. (One property of the charm can be exchanged with Reikland reaper or 4 stacks of The More the Merrier on Mercenary).",
	es_1h_sword_shield = "10% Chaos + Stamina to oneshot bodyshot Fanatics with Light 3 and Heavy 2 (The stab) (Can be exchanged with Reikland reaper or 4 stacks on The More the Merrier on Mercenary).",
	es_2h_halberd = "10% Skaven + Stamina to oneshot bodyshot Clanrats with Light attacks. (Can be exchanged with Reikland reaper or 2 stacks of The More the Merrier on Mercenary).",
	es_2h_sword = "10% Chaos + Attack speed to oneshot headshot Fanatics with Light attacks and to oneshot headshot Marauders with Heavy attacks (Can be exchanged with Reikland reaper or 4 stacks of The More the Merrier on Mercenary).",
	es_2h_sword_executioner = "10% Skaven + Attack speed to oneshot Headshot Stormvermin with heavies. (Can be exchanged with Reikland reaper or 2 stacks of The More the Merrier on Mercenary).",
	es_2h_war_hammer = "10% Chaos + Attack speed to 4 shot headshot Chaos Warriors with Light attacks. (Can be exchanged with Reikland reaper or 1 stack of The More the Merrier on Mercenary).",
	es_blunderbuss = "10% Skaven + Crit chance to oneshot bodyshot Packmasters with all pellets hitting.",
	es_dual_wield_hammer_sword = "doesn't reach relevant breakpoints, just go attack speed + stamina.",
	es_flail = "10% infantry to allow lights 1/2 to headshot fanatics, lights 3/4 & heavies to bodyshot fanatics. If WHC with deathknell: 10% infantry allows light 1/pushstabs to headshot assassins.",
	es_handgun = "20% Chaos/Infantry to oneshot bodyshot Blightstormers and Leeches before damage falloff. 20% Chaos/Infantry on the charm to oneshot bodyshot Gasrats before damage falloff and to oneshot bodyshot Blightstormers / Leeches with damage falloff.",
	es_repeating_handgun = "10% Skaven/Infantry + crit chance to oneshot bodyshot assassins .",
	we_1h_axe = "10% Infantry (Charm) to oneshot bodyshot Fanatics with Light attacks and to 2 shot bodyshot Assassins with Light attacks.",
	we_2h_spear = "10% Skaven to oneshot bodyshot Clanrats with Light Attacks.",
	wh_1h_axes = "10% Infantry to oneshot bodyshot Fanatics with Light attacks and to 2 shot Marauders with every attack, and 2-shot body assassins. If WHC with Deathknell, you also are able to 1-shot headshot assassins with lights. Add another 10% chaos/inf to 1-shot headshot marauders with lights.",
	wh_1h_falchions = "10% chaos to allow light 3 to bodyshot a fanatic, 2-shot bodyshot a marauder, & brings the Heavy > light > light headshow CW BP from 5->4 (8->7 if all bodies).",
	wh_2h_sword = "10% Chaos + 10% armour to oneshot headshot Fanatics with Light attacks, oneshot headshot Marauders with Heavy attacks, to pushstab headshot CWs in 5 headshots, and heavy SV in 3 headhots. 10% armour can be exchanged for another 10% chaos on charm, forgoing the SV BP.",
	wh_brace_of_pisols = "10% Skaven to bodyshot assasins (and hooks with ping bonus or a headshot).",
	wh_crossbow = "Full Skaven/armour (all 4 properties, 43.2%) to bodyshot a SV. Also allows you to bodyshot an assasin (5.8%), and 2-shot bodyshot hookrats/sackrats (10.2%). If WHC: Only need 2 properties (19.4%) to reach SV BP with ping.",
	wh_dual_wield_axe_falchion = "10% chaos to bodyshot fanatics with axe light attacks, and bring heavy headshots on CWs down to 5. If WHC with Deathknell, this also lets your headshot heavies kill maulers in 3 shots, which is the same as body BP.",
	wh_fencing_sword = "10% infantry to bring fanatic bodyshots to 3 hits, full-charge headshot pokes on globes/stormers/leaches to 1-shots, and pistol > half-charge body pokes on maulers to 2-combos (matching the same BP the pistol > full charge poke has). If WHC with deathknell: 10% skaven/armoured to 1-shot a SV with a full-charge headshot poke (without ping). Now headshots globes/stormers/leaches with full-charge pokes at 0%.",
	wh_repeating_crossbow = "WH: 2 skaven/armoured properties to let you (as BH with Crippling Strike) singleshot 2-tap bodyshot gunners/warpfires & hooks with your passive crit up, or 1-shot headshot gunner/warpfires with crit single shot.\nELF: 10% Infantry to oneshot headshot marauders with single arrows.",
	wh_repeating_pistol = "As BH with Crippling strikes & with Hunter: 20% Chaos & 20% Armoured OR 40% crit power & 10% Chaos to full-burst (right click) a CW with the crit passive up.",
	ww_1h_sword = "No relevant breakpoints. (Crit Chance & Attack Speed)",
	ww_2h_axe = "10% Skaven to oneshot bodyshot Clanrats with Light Attacks.",
	ww_2h_sword = "20% Skaven without Power Talents to oneshot headshot SV with Heavy 1. 0 Properties with either Power talent.",
	ww_dual_daggers = "20% Skaven with Arcane Bodkins to oneshot headshot SV with Heavy 1. 30% with Eldrazor's Precision and Hekarti's Bounty.",
	ww_dual_swords = "10% Chaos to oneshot bodyshot Fanatics with Heavy attacks. Oneshot headshot Fanatics with Light attacks and 2 shot SV with Heavy attacks with either power talent.",
	ww_hagbane = "20% Infantry & 20% Skaven to 2 shot Warpfires, Ratlings, Blightstormers & Assassins. Also oneshot Packmasters. (All Charged arrows)",
	ww_longbow = "SOLDIER: 20% Skaven/Armored on the weapon and 10% Skaven/Armored and 10% Chaos/Infantry on the charm to oneshot bodyshot Stormvermin, Warpfires & Ratlings with a fully charged arrow and to 2 shot bodyshot Leeches/Blightstormers with partially charged arrows.\nELF: 30% Skaven/Infantry to oneshot bodyshot Assassins with Charged Arrows.",
	ww_shortbow = "10% Skaven to oneshot bodyshot Clanrats on close range and Slaverats on long range with Quick Arrows.",
	ww_sword_and_dagger = "20% Skaven with Arcane Bodkins to oneshot headshot SV with Heavy 2. 30% with Eldrazor's Precision and Hekarti's Bounty.",
}

local latest_item_type = nil
mod:hook(_G, "Localize", function(func, id, ...)
	local breakpoints
	if latest_item_type then
		breakpoints = mod.item_type_to_breakpoints[latest_item_type]
	end

	local localized = func(id, ...)

	if breakpoints
	and breakpoints ~= ""
	then
		return localized.."\n\n"..breakpoints
	end

	return localized
end)
mod:hook_disable(_G, "Localize")

mod:hook(UITooltipPasses.item_description, "draw", function(func, draw, ui_renderer, pass_data, ui_scenegraph, pass_definition, ui_style, ui_content, position, size, input_service, dt, ui_style_global, item, data, ...)
	if not mod:get(mod.SETTING_NAMES.SHOW_ITEM_BREAKPOINTS) then
		return func(draw, ui_renderer, pass_data, ui_scenegraph, pass_definition, ui_style, ui_content, position, size, input_service, dt, ui_style_global, item, data, ...)
	end

	mod:hook_enable(_G, "Localize")

	latest_item_type = item.data.item_type
	data.style.text.font_size = 16
	local pass_height = func(draw, ui_renderer, pass_data, ui_scenegraph, pass_definition, ui_style, ui_content, position, size, input_service, dt, ui_style_global, item, data, ...)

	mod:hook_disable(_G, "Localize")

	return pass_height
end)
