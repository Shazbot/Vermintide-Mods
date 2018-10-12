local mod = get_mod("Gib")

local pl = require'pl.import_into'()

fassert(pl, "Gib must be lower than Penlight Lua Libraries in your launcher's load order.")

UnitGibSettings_b = UnitGibSettings_b or table.clone(UnitGibSettings)

mod:hook(GenericHitReactionExtension, "_execute_effect", function(func, self, unit, effect_template, biggest_hit, parameters, t, dt)
	if mod:get(mod.SETTING_NAMES.ALWAYS_DISMEMBER) then
		effect_template = table.clone(effect_template)
		effect_template.do_dismember = true
	end
	if mod:get(mod.SETTING_NAMES.FORCE_DISMEMBER) then
		parameters = table.clone(parameters)
		parameters.force_dismember = true
	end
	if mod:get(mod.SETTING_NAMES.ALWAYS_RAGDOLL) then
		self.force_ragdoll_on_death = true
	end

	return func(self, unit, effect_template, biggest_hit, parameters, t, dt)
end)

mod:hook(GenericHitReactionExtension, "_do_push", function(func, self, unit, dt)
	local breed = Unit.get_data(unit, "breed")
	breed.scale_death_push = mod:get(mod.SETTING_NAMES.DEATH_PUSH_MULTIPLIER)
	return func(self, unit, dt)
end)

mod:hook(DamageUtils, "calculate_stagger_player", function(func, stagger_table, target_unit, attacker_unit, hit_zone_name, original_power_level, boost_curve_multiplier, is_critical_strike, damage_profile, target_index, blocked, damage_source)
	local stagger_type, stagger_duration, stagger_distance, stagger_value, stagger_strength
		= func(stagger_table, target_unit, attacker_unit, hit_zone_name, original_power_level, boost_curve_multiplier, is_critical_strike, damage_profile, target_index, blocked, damage_source)
	mod:pcall(function()
		stagger_distance = stagger_distance * mod:get(mod.SETTING_NAMES.STAGGER_MULTIPLIER)/100
	end)
	return stagger_type, stagger_duration, stagger_distance, stagger_value, stagger_strength
end)

mod.on_setting_changed = function(setting_name)
	if setting_name == mod.SETTING_NAMES.GIB_PUSH_FORCE then
		mod.apply_gib_push_force()
	end
end

mod.apply_gib_push_force = function()
	for _, breed_gib_data in pairs( UnitGibSettings ) do
		for _, part in pairs( breed_gib_data.parts ) do
			part.gib_push_force = mod:get(mod.SETTING_NAMES.GIB_PUSH_FORCE)
		end
	end
end

mod.on_enabled = function()
	mod.apply_gib_push_force()
end

mod.on_disabled = function()
	UnitGibSettings = table.clone(UnitGibSettings_b)
end
