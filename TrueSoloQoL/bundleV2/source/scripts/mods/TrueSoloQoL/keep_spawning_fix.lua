-- luacheck: globals get_mod ConflictDirector Managers BreedFreezer

local mod = get_mod("TrueSoloQoL")

mod:hook_safe(ConflictDirector, "update", function(self)
	local game_mode_key = Managers.state.game_mode:game_mode_key()

	if not self.breed_freezer
	and game_mode_key == "inn"
	then
		self.breed_freezer = BreedFreezer:new(self._world, Managers.state.entity, self._network_event_delegate)
	end
end)

mod:hook(BreedFreezer, "commit_freezes", function(func, self)
	local game_mode_key = Managers.state.game_mode:game_mode_key()

	if game_mode_key == "inn" then
		self.units_to_freeze = {}
	end

	return func(self)
end)

mod:hook(BreedFreezer, "try_mark_unit_for_freeze", function(func, self, breed, unit)
	local game_mode_key = Managers.state.game_mode:game_mode_key()

	if game_mode_key == "inn" then
		return false
	end

	return func(self, breed, unit)
end)

mod:hook(BreedFreezer, "_setup_freeze_box", function(func, self)
	local game_mode_key = Managers.state.game_mode:game_mode_key()

	if game_mode_key == "inn" then
		return
	end

	return func(self)
end)
