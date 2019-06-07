local mod = get_mod("ModdedProgression")

local pl = require'pl.import_into'()

mod.modprog_achievements = pl.List{
	"modprog_ts_champ",
	"modprog_ts_legend",
	"modprog_dwons_champ",
	"modprog_dwons_legend",
	"modprog_dw_champ",
	"modprog_dw_legend",
	"modprog_ons_champ",
	"modprog_ons_legend",
}

mod.localize_lookup = {
	modprog_ts_champ = "True Solo Champion",
	modprog_ts_champ_desc = "Complete a True Solo on Champion.",
	modprog_ts_legend = "True Solo Legend",
	modprog_ts_legend_desc = "Complete a True Solo on Legend.",

	modprog_dwons_champ = "DwOns Champion",
	modprog_dwons_champ_desc = "Complete a Deathwish and Onslaught map on Champion.",
	modprog_dwons_legend = "DwOns Legend",
	modprog_dwons_legend_desc = "Complete a Deathwish and Onslaught map on Legend.",

	modprog_dw_champ = "Deathwish Champion",
	modprog_dw_champ_desc = "Complete a Deathwish map on Champion.",
	modprog_dw_legend = "Deathwish Legend",
	modprog_dw_legend_desc = "Complete a Deathwish map on Legend.",

	modprog_ons_champ = "Onslaught Champion",
	modprog_ons_champ_desc = "Complete an Onslaught map on Champion.",
	modprog_ons_legend = "Onslaught Legend",
	modprog_ons_legend_desc = "Complete an Onslaught map on Legend.",

	modprog_category_title = "Modded Progression",
}

mod:hook(_G, "Localize", function(func, id, ...)
	if mod.localize_lookup[id] then
		return mod.localize_lookup[id]
	end

	return func(id, ...)
end)
mod:hook_disable(_G, "Localize")

mod.enable_localize_hook = function(func, self, ...)
	mod:hook_enable(_G, "Localize")
	func(self, ...)
	mod:hook_disable(_G, "Localize")
end

mod:hook(HeroViewStateAchievements, "_setup_tab_widget",
mod.enable_localize_hook)

mod:hook(HeroViewStateAchievements, "_set_summary_achievement_categories_progress",
mod.enable_localize_hook)

mod:hook(AchievementManager, "_setup_achievement_data",
function(func, self, ...)
	mod.enable_localize_hook(func, self, ...)

	pcall(function()
		local claimed_achievements = mod:get("CLAIMED_ACHIEVEMENTS") or {}
		for _, achievement_name in ipairs( mod.modprog_achievements ) do
			self._achievement_data[achievement_name].reward = {
				reward_type = "item",
				item_name = "frame_0000",
			}
			self._achievement_data[achievement_name].claimed = claimed_achievements[achievement_name]
		end
	end)
end)

mod:hook(HeroViewStateAchievements, "_claim_reward", function(func, self, widget)
	local achievement_name = widget.content.id

	if not mod.modprog_achievements:contains(achievement_name) then
		return func(self, widget)
	end

	widget.content.claimed = true
	local claimed_achievements = mod:get("CLAIMED_ACHIEVEMENTS") or {}
	claimed_achievements[achievement_name] = true
	pcall(function()
		Managers.state.achievement._achievement_data[achievement_name].claimed = true
	end)
	mod:set("CLAIMED_ACHIEVEMENTS", claimed_achievements)
	get_mod("VMF").save_unsaved_settings_to_file()
end)

mod:pcall(function()
	local def = require("scripts/managers/achievements/achievements_outline")

	def.categories[7] = {
		type = "achievements",
		name = "modprog_category_title",
		entries = mod.modprog_achievements
	}

	local definitions = local_require("scripts/ui/views/hero_view/states/definitions/hero_view_state_achievements_definitions")
	definitions.summary_widgets.summary_achievement_bar_7 = table.clone(definitions.summary_widgets.summary_achievement_bar_6)
end)
