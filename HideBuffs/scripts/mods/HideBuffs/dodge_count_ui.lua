local mod = get_mod("HideBuffs")
mod.dcui_always_on = mod:get("dcui_always_on")
mod.dcui_enabled = mod:get(mod.SETTING_NAMES.DODGE_COUNT)

local SCREEN_WIDTH = 1920
local SCREEN_HEIGHT = 1080

local function get_x()
  local x =  mod:get("dcui_offset_x")
  local x_limit = SCREEN_WIDTH / 2
  local max_x = math.min(mod:get("dcui_offset_x"), x_limit)
  local min_x = math.max(mod:get("dcui_offset_x"), -x_limit)
  if x == 0 then
	return 0
  end
  local clamped_x =  x > 0 and max_x or min_x
  return clamped_x
end

local function get_y()
  local y =  mod:get("dcui_offset_y")
  local y_limit = SCREEN_HEIGHT / 2
  local max_y = math.min(mod:get("dcui_offset_y"), y_limit)
  local min_y = math.max(mod:get("dcui_offset_y"), -y_limit)
  if y == 0 then
	return 0
  end
  local clamped_y = -(y > 0 and max_y or min_y)
  return clamped_y
end

local fake_input_service = {
  get = function ()
	return
  end,
  has = function ()
	return
  end
}

local scenegraph_definition = {
  root = {
	scale = "fit",
	size = {
	  1920,
	  1080
	},
	position = {
	  0,
	  0,
	  UILayer.hud
	}
  }
}

local dodge_ui_definition = {
  scenegraph_id = "root",
  element = {
	passes = {
	  {
		style_id = "dodge_text",
		pass_type = "text",
		text_id = "dodge_text",
		retained_mode = false,
		fade_out_duration = 5,
		content_check_function = function(content)
			if not mod.dcui_enabled then
				return false
			end
		  return mod.dcui_always_on or content.has_dodged
		end
	  },
	  {
		style_id = "cooldown_text",
		pass_type = "text",
		text_id = "cooldown_text",
		retained_mode = false,
		content_check_function = function(content)
		  return content.display_cooldown and content.has_cooldown
		end
	  }
	}
  },
  content = {
	dodge_text = "",
	cooldown_text = "",
	has_dodged = false,
	has_cooldown = false,
	display_cooldown = mod:get("dcui_display_cooldown"),
  },
  style = {
	dodge_text = {
	  font_type = "hell_shark",
	  font_size = mod:get("dcui_font_size"),
	  vertical_alignment = "center",
	  horizontal_alignment = "center",
	  text_color = Colors.get_table("white"),
	  offset = {
		get_x(),
		get_y(),
		0
	  }
	},
	cooldown_text = {
	  font_type = "hell_shark",
	  font_size = mod:get("dcui_cd_font_size"),
	  vertical_alignment = "center",
	  horizontal_alignment = "center",
	  text_color = Colors.get_table("white"),
	  offset = {
		get_x(),
		get_y() - mod:get("dcui_font_size"),
		0
	  }
	},
  },
  offset = {
	0,
	0,
	0
  },
}

function mod:dcui_init()
  if mod.ui_widget then
		return
  end

  local world = Managers.world:world("top_ingame_view")
  mod.ui_renderer = UIRenderer.create(world, "material", "materials/fonts/gw_fonts")
  mod.ui_scenegraph = UISceneGraph.init_scenegraph(scenegraph_definition)
  mod.ui_widget = UIWidget.init(dodge_ui_definition)
end

mod:hook_safe(IngameHud, "update", function(self, dt)
  -- If the EquipmentUI isn't visible or the player is dead
  -- then let's not show the Dodge Count UI
  if not self._currently_visible_components.EquipmentUI or self:is_own_player_dead() then
		return
  end

  local t = Managers.time:time("game")
  local player_unit = Managers.player:local_player().player_unit
  local status_system = ScriptUnit.has_extension(player_unit, "status_system")

  if not status_system or not player_unit then
		return
  end

  if not mod.ui_widget then
		mod.dcui_init()
  end

  if not status_system.is_dodging then
		status_system:get_dodge_item_data()
  end

  local current_dodge_count = status_system.dodge_cooldown
  local efficient_dodge_count = status_system.dodge_count
  local cooldown = status_system.dodge_cooldown_delay or 0

  local widget = mod.ui_widget
  local ui_renderer = mod.ui_renderer
  local ui_scenegraph = mod.ui_scenegraph

  widget.content.dodge_text = string.format("%i/%u", math.max(-3, efficient_dodge_count - current_dodge_count), efficient_dodge_count)
  widget.content.cooldown_text = string.format("%.1fs", cooldown - t)
  widget.content.has_dodged = current_dodge_count > 0
  widget.content.has_cooldown = (cooldown - t) > 0
  widget.content.display_cooldown = mod:get("dcui_display_cooldown")

  UIRenderer.begin_pass(ui_renderer, ui_scenegraph, fake_input_service, dt)
  UIRenderer.draw_widget(ui_renderer, widget)
  UIRenderer.end_pass(ui_renderer)
end)
