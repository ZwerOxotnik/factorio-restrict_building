---@class PE : module
local M = {}


--#region Constatns
local TEXT = {
	text = {"messages.warning_restricted_building"},
	create_at_cursor = true,
	time_to_live = 180
}
local DESTROY_TYPE = {raise_destroy = true}
local CHARACTER_TYPE = defines.controllers.character
local GOD_TYPE       = defines.controllers.god
--#endregion


--#region Utils

--#endregion


--#region Functions of events

local __find_param = {
	max_distance = settings.global["restrict_building_radius"].value,
	position = nil,
	force = nil
}
local function on_built_entity(event)
	local entity = event.entity
	-- if not entity.valid then return end

	local force = entity.force
	if force.index == 3 then return end -- neutral
	local player = game.get_player(event.player_index)
	local controller_type = player.controller_type
	if not (controller_type == CHARACTER_TYPE or controller_type == GOD_TYPE) then return end

	__find_param.position = entity.position
	__find_param.force    = force
	local near_entity = entity.surface.find_nearest_enemy_entity_with_owner(__find_param)
	if not near_entity then
		return
	end

	player.mine_entity(entity, true)
	player.create_local_flying_text(TEXT)
end

local function on_robot_built_entity(event)
	local entity = event.entity
	if not entity.valid then return end

	local force = entity.force
	if force.index == 3 then return end -- neutral

	__find_param.position = entity.position
	__find_param.force    = force
	local near_entity = entity.surface.find_nearest_enemy_entity_with_owner(__find_param)
	if not near_entity then
		return
	end

	entity.destroy(DESTROY_TYPE)
end

local function on_runtime_mod_setting_changed(event)
	-- if event.setting_type ~= "runtime-global" then return end
	if event.setting == "restrict_building_radius" then
		__find_param.max_distance = settings.global[event.setting].value
	end
end

--#endregion


--#region Pre-game stage

local function set_filters()
	local filters = {{filter = "type", type = "entity-ghost", invert = true}}
	script.set_event_filter(defines.events.on_built_entity, filters)
end

local function add_remote_interface()
	-- https://lua-api.factorio.com/latest/LuaRemote.html
	remote.remove_interface("restrict_building") -- For safety
	remote.add_interface("restrict_building", {})
end

M.on_init = set_filters
M.on_load = set_filters
M.on_mod_enabled  = set_filters
M.on_mod_disabled = set_filters
M.add_remote_interface = add_remote_interface

--#endregion


M.events = {
	[defines.events.on_runtime_mod_setting_changed] = on_runtime_mod_setting_changed,
	[defines.events.on_built_entity] = function(event)
		pcall(on_built_entity, event)
	end,
	[defines.events.on_robot_built_entity] = on_robot_built_entity,
}

M.events_when_off = {
	[defines.events.on_runtime_mod_setting_changed] = on_runtime_mod_setting_changed
}

return M
