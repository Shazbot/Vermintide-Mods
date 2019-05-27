local mod = get_mod("ModdedProgression")

mod:hook_safe(CutsceneSystem, "flow_cb_activate_cutscene_camera", function()
	mod.map_start_time = Managers.time:time("game")
end)
