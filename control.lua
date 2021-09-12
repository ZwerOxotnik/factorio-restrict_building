if script.active_mods["zk-lib"] then
	require("__zk-lib__/event_handler_vSM").add_lib(require("models/restrict_building"))
else
	require("event_handler").add_lib(require("models/restrict_building"))
end
