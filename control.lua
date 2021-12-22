if script.active_mods["switchable_mods"] then
	require("__switchable_mods__/event_handler_vSM").add_lib(require("models/restrict_building"))
else
	local event_handler
	if script.active_mods["zk-lib"] then
		event_handler = require("__zk-lib__/static-libs/lualibs/event_handler_vZO.lua")
	else
		event_handler = require("event_handler")
	end
	event_handler.add_lib(require("models/restrict_building"))
end
