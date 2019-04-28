local mod = get_mod("TrueSoloQoL")

mod:hook(EnemyRecycler, "update", function(func, self, t, dt, player_positions, threat_population, player_areas, use_player_areas)
	mod:pcall(function()
		if mod:get(mod.SETTING_NAMES.SHOW_BOSS_PATH_PROGRESS) then
			local current_path = string.format("%.2f", self.current_main_path_event_activation_dist)
			local ahead_path = string.format("%.2f", self.main_path_info.ahead_travel_dist)

			local streaming_info = get_mod("StreamingInfo")
			if streaming_info then
				streaming_info.set_info_lines(
					"Next:       "..current_path..";"
					.."Current:  "..ahead_path..";"
					.."Delta:      "..(current_path-ahead_path)
				)
			end
		end

		if mod:get(mod.SETTING_NAMES.DRAW_BOSS_EVENTS) then
			local world = Managers.world:world("level_world")

			if not mod.line_object then
				mod.line_object = World.create_line_object(world, false)
			end

			LineObject.reset(mod.line_object)

			for _, main_path_event in ipairs( self.main_path_events ) do
				local position = main_path_event[2]:unbox()
				local color = Color(255, 0, 0)
				LineObject.add_sphere(mod.line_object, color, position, 45, 160, 16)
			end

			LineObject.dispatch(world, mod.line_object)
		end
	end)
	return func(self, t, dt, player_positions, threat_population, player_areas, use_player_areas)
end)
