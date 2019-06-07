local mod = get_mod("ModdedProgression")

AchievementTemplates.achievements.modprog_ts_champ = {
	name = "modprog_ts_champ",
	icon = "achievement_trophy_deeds_8",
	desc = "modprog_ts_champ_desc",
	completed = function()
		local completed = false
		for _, difficutly_name in pairs( mod:get("TS_DIFFICULTY") ) do
			if difficutly_name == "harder"
			or difficutly_name == "hardest"
			then
				completed = true
				break
			end
		end

		return completed
	end,
}
AchievementTemplates.achievements.modprog_ts_legend = {
	name = "modprog_ts_legend",
	icon = "achievement_trophy_deeds_8",
	desc = "modprog_ts_legend_desc",
	completed = function()
		local completed = false
		for _, difficutly_name in pairs( mod:get("TS_DIFFICULTY") ) do
			if difficutly_name == "hardest"
			then
				completed = true
				break
			end
		end

		return completed
	end,
}

AchievementTemplates.achievements.modprog_dwons_champ = {
	name = "modprog_dwons_champ",
	icon = "achievement_trophy_deeds_8",
	desc = "modprog_dwons_champ_desc",
	completed = function()
		local completed = false
		for _, difficutly_name in pairs( mod:get("DWONS_DIFFICULTY") ) do
			if difficutly_name == "harder"
			or difficutly_name == "hardest"
			then
				completed = true
				break
			end
		end

		return completed
	end,
}
AchievementTemplates.achievements.modprog_dwons_legend = {
	name = "modprog_dwons_legend",
	icon = "achievement_trophy_deeds_8",
	desc = "modprog_dwons_legend_desc",
	completed = function()
		local completed = false
		for _, difficutly_name in pairs( mod:get("DWONS_DIFFICULTY") ) do
			if difficutly_name == "hardest"
			then
				completed = true
				break
			end
		end

		return completed
	end,
}

AchievementTemplates.achievements.modprog_dw_champ = {
	name = "modprog_dw_champ",
	icon = "achievement_trophy_deeds_8",
	desc = "modprog_dw_champ_desc",
	completed = function()
		local completed = false
		for _, difficutly_name in pairs( mod:get("DW_DIFFICULTY") ) do
			if difficutly_name == "harder"
			or difficutly_name == "hardest"
			then
				completed = true
				break
			end
		end

		return completed
	end,
}
AchievementTemplates.achievements.modprog_dw_legend = {
	name = "modprog_dw_legend",
	icon = "achievement_trophy_deeds_8",
	desc = "modprog_dw_legend_desc",
	completed = function()
		local completed = false
		for _, difficutly_name in pairs( mod:get("DW_DIFFICULTY") ) do
			if difficutly_name == "hardest"
			then
				completed = true
				break
			end
		end

		return completed
	end,
}

AchievementTemplates.achievements.modprog_ons_champ = {
	name = "modprog_ons_champ",
	icon = "achievement_trophy_deeds_8",
	desc = "modprog_ons_champ_desc",
	completed = function()
		local completed = false
		for _, difficutly_name in pairs( mod:get("ONS_DIFFICULTY") ) do
			if difficutly_name == "harder"
			or difficutly_name == "hardest"
			then
				completed = true
				break
			end
		end

		return completed
	end,
}
AchievementTemplates.achievements.modprog_ons_legend = {
	name = "modprog_ons_legend",
	icon = "achievement_trophy_deeds_8",
	desc = "modprog_ons_legend_desc",
	completed = function()
		local completed = false
		for _, difficutly_name in pairs( mod:get("ONS_DIFFICULTY") ) do
			if difficutly_name == "hardest"
			then
				completed = true
				break
			end
		end

		return completed
	end,
}
