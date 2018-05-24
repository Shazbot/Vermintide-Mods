local mod = get_mod("Scoreboard") -- luacheck: ignore get_mod

-- luacheck: globals ScoreboardHelper StatisticsDefinitions AiUtils ScriptUnit Managers
-- luacheck: globals UIRenderer math UTF8Utils local_require Localize

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

	if not StatisticsDefinitions.player.ff then
		StatisticsDefinitions.player.ff = {
			value = 0,
			name = "ff"
		}
	end
end)

mod:hook("Localize", function (func, id, ...)
	if id == "scoreboard_topic_ff" then
		return "Friendly Fire"
	end

	return func(id, ...)
end)

mod:hook("EndViewStateScore.draw", function(func, self, ...)
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

mod:hook("PlayerUnitHealthExtension.add_damage", function(func, self, attacker_unit, damage_amount, hit_zone_name, damage_type, ...)
	mod:pcall(function()
		local player_manager = Managers.player
		local player = player_manager:owner(self.unit)

		local statistics_db = Managers.player:statistics_db()

		if player and ScriptUnit.has_extension(self.unit, "health_system") and ScriptUnit.has_extension(self.unit, "buff_system") then
			local ff_damage = damage_amount

			local actual_attacker_unit = AiUtils.get_actual_attacker_unit(attacker_unit)
			local player_attacker = player_manager:owner(actual_attacker_unit)

			if player_attacker and damage_type ~= "wounded_dot" and damage_type ~= "knockdown_bleed" and damage_type ~= "kinetic" then
				local stats_id = player_attacker:stats_id()
				if actual_attacker_unit ~= self.unit then
					statistics_db:modify_stat_by_amount(stats_id, "ff", ff_damage)
				end
			end
		end
	end)

	return func(self, attacker_unit, damage_amount, hit_zone_name, damage_type, ...)
end)

local PLAYER_NAME_MAX_LENGTH = 16
local definitions = local_require("scripts/ui/views/level_end/states/definitions/end_view_state_score_definitions")
local player_score_size = definitions.player_score_size

-- luacheck: no unused, no redefined
mod:hook("EndViewStateScore._setup_score_panel", function(func, self, score_panel_scores, player_names)
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
				local name = (PLAYER_NAME_MAX_LENGTH < UTF8Utils.string_length(player_name) and UIRenderer.crop_text_width(self.ui_renderer, player_name, player_score_size[1] - 40, style[score_text_name])) or player_name
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
					local min_score = tablex.reduce(math.min, player_scores)
					has_highscore = min_score == player_score
				end
				local has_horizontal_divider = false
				local line_suffix = "_" .. total_row_index
				local score_text_name = "score_text" .. line_suffix
				local row_name = "row_bg" .. line_suffix
				local row_content = content[row_name]
				row_content[score_text_name] = player_score
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