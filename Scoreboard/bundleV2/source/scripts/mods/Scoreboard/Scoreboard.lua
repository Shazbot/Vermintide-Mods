local mod = get_mod("Scoreboard") -- luacheck: ignore get_mod

-- luacheck: globals ScoreboardHelper StatisticsDefinitions AiUtils ScriptUnit Managers
-- luacheck: globals UIRenderer math UTF8Utils local_require Localize EndViewStateScore
-- luacheck: globals PlayerUnitHealthExtension Unit StatisticsUtil DamageDataIndex
-- luacheck: globals ItemMasterList

local pl = require'pl.import_into'()
local tablex = require'pl.tablex'

mod:pcall(function()
	local scoreboard_topic_ff = {
		name = "ff",
		stat_type = "ff",
		display_text = "scoreboard_topic_ff",
		sort_function = function (a, b)
			return a.score < b.score
		end
	}
	if not tablex.find_if(ScoreboardHelper.scoreboard_topic_stats, function(scoreboard_topic_stat)
		return scoreboard_topic_stat.name == "ff"
	end) then
		table.insert(ScoreboardHelper.scoreboard_topic_stats, scoreboard_topic_ff)
	end

	if not tablex.find_if(ScoreboardHelper.scoreboard_grouped_topic_stats[1].stats, function(stat)
		return stat == "ff"
	end) then
		table.insert(ScoreboardHelper.scoreboard_grouped_topic_stats[1].stats, "ff")
	end

	local new_stats = pl.List{ "ff", "hs_melee", "hs_ranged", "self_dmg", "boss_dmg" }
	new_stats:foreach(function(stat_key)
		if not StatisticsDefinitions.player[stat_key] then
			StatisticsDefinitions.player[stat_key] = {
				value = 0,
				name = stat_key
			}
		end
	end)
end)

mod:hook("Localize", function (func, id, ...)
	if id == "scoreboard_topic_ff" then
		return "Friendly Fire"
	end

	return func(id, ...)
end)

mod:hook(EndViewStateScore, "draw", function(func, self, ...)
	mod:pcall(function()
		local size_delta = 15

		for i = 1, 4 do
			self._hero_widgets[i].offset[2] = size_delta
			self._score_widgets[i].offset[1] = -0
			self._score_widgets[i].offset[2] = size_delta
			self._score_widgets[i].style.background_left_glow.offset[2] = -size_delta*2
			self._score_widgets[i].style.background_right_glow.offset[2] = -size_delta*2
			self._score_widgets[i].style.background.offset[2] = -size_delta*2
			self._score_widgets[i].style.background.size[2] = 580 + size_delta

			self._score_widgets[i].style.glass_top.offset[2] = 572 - size_delta
			self._score_widgets[i].style.glass_bottom.offset[2] = 5 - size_delta*2

			self._score_widgets[i].style.frame.offset[2] = -size_delta*2
			self._score_widgets[i].style.frame.size[2] = 580 + size_delta

			self._score_widgets[i].style.edge_fade.offset[2] = 5 - size_delta
			self._score_widgets[i].style.edge_fade.size[2] = 15
		end

		for i = 1, 3 do
			self._widgets[i].offset[2] = size_delta
		end
		self._widgets[2].style.background.offset[2] = -size_delta
		self._widgets[2].style.background.size[2] = 500 + size_delta

		self._widgets[2].style.frame.offset[2] = -size_delta
		self._widgets[2].style.frame.size[2] = 500 + size_delta

		self._widgets[2].style.edge_fade.offset[2] = 5 - size_delta
		self._widgets[2].style.edge_fade.size[2] = 15

		self._widgets[2].style.glass_top.offset[2] = 492
		self._widgets[2].style.glass_bottom.offset[2] = 5 - size_delta
	end)

	return func(self, ...)
end)

mod:hook(PlayerUnitHealthExtension, "add_damage", function(func, self, attacker_unit, damage_amount, hit_zone_name, damage_type, ...)
	mod:pcall(function()
		local player_manager = Managers.player
		local player = player_manager:owner(self.unit)

		local statistics_db = Managers.player:statistics_db()

		if player and ScriptUnit.has_extension(self.unit, "health_system") and ScriptUnit.has_extension(self.unit, "buff_system") then
			local ff_damage = damage_amount

			local actual_attacker_unit = AiUtils.get_actual_attacker_unit(attacker_unit)
			local player_attacker = player_manager:owner(actual_attacker_unit)

			if player_attacker
			and damage_type ~= "wounded_dot"
			and damage_type ~= "knockdown_bleed"
			and damage_type ~= "temporary_health_degen"
			and damage_type ~= "kinetic"
			then
				local stats_id = player_attacker:stats_id()
				if actual_attacker_unit ~= self.unit then
					statistics_db:modify_stat_by_amount(stats_id, "ff", ff_damage)
				else
					statistics_db:modify_stat_by_amount(stats_id, "self_dmg", ff_damage)
					-- mod:echo(damage_type)
					-- mod:echo(statistics_db:get_stat(stats_id, "self_dmg"))
				end
			end
		end
	end)

	return func(self, attacker_unit, damage_amount, hit_zone_name, damage_type, ...)
end)

mod:hook(EndViewStateScore, "_setup_player_scores", function(func, self, players_session_scores)
	mod.stats_by_index = {}
	local index = 1
	for _, player_data in pairs(players_session_scores) do
		mod.stats_by_index[index] = mod.stats_by_index[index] or {}
		mod.stats_by_index[index].self_dmg = player_data.self_dmg
		mod.stats_by_index[index].hs_melee = player_data.hs_melee
		mod.stats_by_index[index].hs_ranged = player_data.hs_ranged
		mod.stats_by_index[index].boss_dmg = player_data.boss_dmg
		index = index + 1
	end
	return func(self, players_session_scores)
end)

mod.bosses = pl.List{
	"skaven_stormfiend",
	"skaven_rat_ogre",
	"chaos_troll",
	"chaos_spawn"
}

local Unit_get_data = Unit.get_data
local Unit_alive = Unit.alive
mod:hook_safe(StatisticsUtil, "register_damage", function(victim_unit, damage_data, statistics_db)
	local attacker_unit = damage_data[DamageDataIndex.ATTACKER]
	attacker_unit = AiUtils.get_actual_attacker_unit(attacker_unit)
	local player_manager = Managers.player
	local attacker_player = player_manager:owner(attacker_unit)

	if attacker_player then
		local breed = Unit_alive(victim_unit) and Unit_get_data(victim_unit, "breed")

		if breed then
			-- is it a boss? ignore mini-bosses
			if breed.boss and not mod.bosses:contains(breed.name) then
				local stats_id = attacker_player:stats_id()
				local damage_amount = damage_data[DamageDataIndex.DAMAGE_AMOUNT]
				statistics_db:modify_stat_by_amount(stats_id, "boss_dmg", damage_amount)
			end
		end
	end
end)

mod:hook_safe(StatisticsUtil, "register_kill", function(victim_unit, damage_data, statistics_db, is_server) -- luacheck: no unused
	local attacker_unit = AiUtils.get_actual_attacker_unit(damage_data[DamageDataIndex.ATTACKER])
	local player_manager = Managers.player
	local attacker_player = player_manager:owner(attacker_unit)
	local breed = Unit_get_data(victim_unit, "breed")

	if attacker_player then
		local stats_id = attacker_player:stats_id()

		if breed ~= nil then
			local hit_zone = damage_data[DamageDataIndex.HIT_ZONE]
			if hit_zone == "head" then
				local damage_source = damage_data[DamageDataIndex.DAMAGE_SOURCE_NAME]
				local master_list_item = rawget(ItemMasterList, damage_source)

				if master_list_item then
					local slot_type = master_list_item.slot_type

					if slot_type == "melee" then
						statistics_db:increment_stat(stats_id, "hs_melee")
					elseif slot_type == "ranged" then
						statistics_db:increment_stat(stats_id, "hs_ranged")
					end
				end
			end
		end
	end
end)

mod:hook(ScoreboardHelper, "get_grouped_topic_statistics", function(func, statistics_db, profile_synchronizer)
	local player_list = func(statistics_db, profile_synchronizer)
	mod:pcall(function()
		for stats_id, player_data in pairs(player_list) do
			player_data.self_dmg = statistics_db:get_stat(stats_id, "self_dmg")
			player_data.hs_melee = statistics_db:get_stat(stats_id, "hs_melee")
			player_data.hs_ranged = statistics_db:get_stat(stats_id, "hs_ranged")
			player_data.boss_dmg = statistics_db:get_stat(stats_id, "boss_dmg")
		end
	end)
	return player_list
end)

local PLAYER_NAME_MAX_LENGTH = 16
local definitions = local_require("scripts/ui/views/level_end/states/definitions/end_view_state_score_definitions")
local player_score_size = definitions.player_score_size

-- luacheck: no unused, no redefined
mod:hook_origin(EndViewStateScore, "_setup_score_panel", function(self, score_panel_scores, player_names)
	local category_title_size = 30
	local text_size = 22
	local total_row_index = 1
	local score_index = 1
	local score_widgets = self._score_widgets

	for group_name, group_data in pairs(score_panel_scores) do
		local title_text = "title_text_" .. tostring(total_row_index)
		local horizontal_divider = "horizontal_divider_" .. tostring(total_row_index)

		if total_row_index == 1 then
			for player_index, player_name in ipairs(player_names) do
				local score_text = "score_player_" .. tostring(player_index) .. "_" .. tostring(total_row_index)
				local widget = score_widgets[player_index]
				local content = widget.content
				local style = widget.style
				local line_suffix = "_" .. total_row_index
				local score_text_name = "score_text" .. line_suffix
				local row_name = "row_bg" .. line_suffix
				local row_content = content[row_name]
				local name = (PLAYER_NAME_MAX_LENGTH < UTF8Utils.string_length(player_name)
					and UIRenderer.crop_text_width(self.ui_renderer, player_name, player_score_size[1] - 40, style[score_text_name]))
					or player_name
				row_content[score_text_name] = name
			end

			total_row_index = total_row_index + 1
		end

		for group_row_index, score_data in ipairs(group_data) do
			local highscore = math.round(score_data.highscore)
			local player_scores = score_data.player_scores

			for player_index, player_score in ipairs(player_scores) do
				local widget = score_widgets[player_index]
				local content = widget.content
				local style = widget.style
				player_score = math.round(player_score)
				local title_text = "title_text_" .. tostring(total_row_index)
				local score_text = "score_player_" .. tostring(player_index) .. "_" .. tostring(total_row_index)
				local high_score_marker = "high_score_marker_" .. tostring(player_index) .. "_" .. tostring(total_row_index)
				local horizontal_divider = "horizontal_divider_" .. tostring(total_row_index)
				local row_bg = "row_bg_" .. tostring(total_row_index)
				local has_highscore = highscore <= player_score and highscore > 0
				if score_data.stat_name == "ff" or score_data.stat_name == "damage_taken" then
					local min_score = tablex.reduce(math.min, tablex.map(math.round, player_scores))
					has_highscore = min_score == player_score
				end
				local has_horizontal_divider = false
				local line_suffix = "_" .. total_row_index
				local score_text_name = "score_text" .. line_suffix
				local row_name = "row_bg" .. line_suffix
				local row_content = content[row_name]
				row_content[score_text_name] = player_score
				if score_data.stat_name == "damage_taken" then
					if mod.stats_by_index[player_index] and mod.stats_by_index[player_index].self_dmg then
						local player_score_mutable = player_score
						local self_dmg = math.round(mod.stats_by_index[player_index].self_dmg)
						if mod:get(mod.SETTING_NAMES.EXCLUDE_SELF_DMG_FROM_DMG_TAKEN) then
							player_score_mutable = player_score - self_dmg
						end
						row_content[score_text_name] = player_score_mutable
						.. " / "
						.. self_dmg
					end
				elseif score_data.stat_name == "headshots" then
					if mod.stats_by_index[player_index] and mod.stats_by_index[player_index].hs_melee then
						row_content[score_text_name] =
							player_score
							.. " / "
							.. mod.stats_by_index[player_index].hs_melee
							.. " / "
							.. mod.stats_by_index[player_index].hs_ranged
					end
				elseif score_data.stat_name == "damage_dealt_bosses" then
					if mod.stats_by_index[player_index] and mod.stats_by_index[player_index].boss_dmg then
						row_content[score_text_name] =
							player_score
							.. " / "
							.. math.round(mod.stats_by_index[player_index].boss_dmg)
					end
				end
				row_content.has_background = total_row_index % 2 == 0
				row_content.has_highscore = has_highscore
				row_content.has_score = true

				self:_set_score_topic_by_row(total_row_index, Localize(score_data.display_text))
			end

			total_row_index = total_row_index + 1
		end

		score_index = score_index + 1
	end
end)
-- luacheck: unused, redefined