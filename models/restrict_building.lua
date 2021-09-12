---@class PE : module
local M = {}


--#region Constatns
local TEXT = {
	text = {"messages.warning_restricted_building"},
	create_at_cursor = true,
	time_to_live = 180
}
--#endregion


--#region Settings
local restrict_building_radius = settings.global["restrict_building_radius"].value
--#endregion


--#region Utils

local function find_near_enemy(created_entity)
	local near_entity = created_entity.surface.find_nearest_enemy_entity_with_owner({
		position = created_entity.position,
		max_distance = restrict_building_radius,
		force = created_entity.force
	})
	if near_entity then
		return near_entity
	else
		return false
	end
end

--#endregion


--#region Functions of events

local function on_built_entity(event)
	local created_entity = event.created_entity
	if created_entity.force.name == "neutral" then return end
	local player_index = event.player_index
	local player = game.get_player(player_index)
	if not (player.controller_type == defines.controllers.character or player.controller_type == defines.controllers.god) then return end

	if not find_near_enemy(created_entity) then return end
	player.mine_entity(created_entity, true)
	player.create_local_flying_text(TEXT)
end

local DESTROY_TYPE = {raise_destroy = true}
local function on_robot_built_entity(event)
	local created_entity = event.created_entity
	local force = created_entity.force
	if force.name == "neutral" then return end

	if not find_near_enemy(created_entity) then return end
	created_entity.destroy(DESTROY_TYPE)
end

local function on_runtime_mod_setting_changed(event)
	if event.setting_type ~= "runtime-global" then return end

	if event.setting == "restrict_building_radius" then
		restrict_building_radius = settings.global[event.setting].value
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
M.on_mod_enabled = set_filters
M.on_mod_disabled = set_filters
M.add_remote_interface = add_remote_interface

--#endregion


M.events = {
	[defines.events.on_runtime_mod_setting_changed] = on_runtime_mod_setting_changed,
	[defines.events.on_built_entity] = function(event)
		pcall(on_built_entity, event)
	end,
	[defines.events.on_robot_built_entity] = function(event)
		pcall(on_robot_built_entity, event)
	end
}

M.events_when_off = {
	[defines.events.on_runtime_mod_setting_changed] = on_runtime_mod_setting_changed
}

return M
