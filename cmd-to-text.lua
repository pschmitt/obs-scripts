---@diagnostic disable-next-line undefined-global
local obs = obslua

local utils = require("utils")

local M = {}

local DESCRIPTION = "🤖 Execute a command <b>periodically</b> and update a text source with the output."

-- Define defaults
M.DEFAULT_INTERVAL = 30
M.DEFAULT_TIMEOUT = 5
M.DEFAULT_COMMAND = "date"
M.DEFAULT_SHELL = "sh"
M.DEFAULT_DEBUG = false

-- Internal vars (current settings)
M.INTERVAL = M.DEFAULT_INTERVAL
M.TIMEOUT = M.DEFAULT_TIMEOUT
M.SHELL = M.DEFAULT_SHELL
M.COMMAND = M.DEFAULT_COMMAND
M.TARGET_SOURCE = ""
M.DEBUG = M.DEFAULT_DEBUG

function M.update_text_source_with_cmd_output()
	local text = utils.exec_cmd(M.COMMAND, M.TIMEOUT, M.SHELL, M.DEBUG)

	if text == nil then
		print("ERROR: Command returned nil")
		return
	end

	utils.update_text_source(M.TARGET_SOURCE, text)
end

-- Timer callback function
function M.timer_callback()
	M.update_text_source_with_cmd_output()
end

-- Function to update the timer based on the interval setting
function M.update_timer()
	-- Remove the existing timer
	obs.timer_remove(M.timer_callback)

	-- Register the timer with the new interval
	obs.timer_add(M.timer_callback, M.INTERVAL * 1000)
end

function M.print_script_settings()
	print("Script settings:")
	print(string.format("Interval: %ds", M.INTERVAL))
	print(string.format("Command: %s", M.COMMAND))
	print(string.format("Shell: %s", M.SHELL))
	print(string.format("Timeout: %ds", M.TIMEOUT))
	print(string.format("Target Source: %s", M.TARGET_SOURCE))
end

function M.work(settings)
	M.COMMAND = obs.obs_data_get_string(settings, "command")
	M.INTERVAL = obs.obs_data_get_int(settings, "interval")
	M.SHELL = obs.obs_data_get_string(settings, "shell")
	M.TARGET_SOURCE = obs.obs_data_get_string(settings, "target_source")
	M.TIMEOUT = obs.obs_data_get_int(settings, "timeout")
	M.DEBUG = obs.obs_data_get_bool(settings, "debug")

	if M.INTERVAL == nil then
		M.INTERVAL = M.DEFAULT_INTERVAL
	end

	if M.TIMEOUT == nil then
		M.TIMEOUT = M.DEFAULT_TIMEOUT
	end

	M.print_script_settings()

	if M.TARGET_SOURCE == "" or M.TARGET_SOURCE == nil then
		print("ERROR: No target source set")
		obs.timer_remove(M.timer_callback)
		return
	end

	M.update_timer()
	-- Update text right away
	M.update_text_source_with_cmd_output()
end

---@diagnostic disable-next-line lowercase-global
function script_load(settings)
	M.work(settings)
end

---@diagnostic disable-next-line lowercase-global
function script_update(settings)
	M.work(settings)
end

function M.script_defaults(settings)
	obs.obs_data_set_default_int(settings, "interval", M.DEFAULT_INTERVAL)
	obs.obs_data_set_default_int(settings, "timeout", M.DEFAULT_TIMEOUT)
	obs.obs_data_set_default_string(settings, "command", M.DEFAULT_COMMAND)
	obs.obs_data_set_default_string(settings, "shell", M.DEFAULT_SHELL)
	obs.obs_data_set_default_bool(settings, "debug", M.DEFAULT_DEBUG)
end

---@diagnostic disable-next-line lowercase-global
function script_defaults(settings)
	M.script_defaults(settings)
end

---@diagnostic disable-next-line lowercase-global
function script_description()
	return DESCRIPTION
end

function M.script_properties()
	local props = obs.obs_properties_create()
	obs.obs_properties_add_int(props, "interval", "Interval (s)", 1, 7200, 1)
	obs.obs_properties_add_text(props, "command", "Command", obs.OBS_TEXT_DEFAULT)

	obs.obs_properties_add_text(props, "shell", "Shell", obs.OBS_TEXT_DEFAULT)

	obs.obs_properties_add_int(props, "timeout", "Timeout (s)", 1, 3600, 1)

	local sources = obs.obs_properties_add_list(
		props,
		"target_source",
		"Source:",
		obs.OBS_COMBO_TYPE_EDITABLE,
		obs.OBS_COMBO_FORMAT_STRING
	)

	local txt_sources = utils.get_text_sources()
	for _, name in ipairs(txt_sources) do
		obs.obs_property_list_add_string(sources, name, name)
	end

	obs.obs_properties_add_bool(props, "debug", "Debug")

	return props
end

---@diagnostic disable-next-line lowercase-global
function script_properties()
	return M.script_properties()
end

function M.script_unload()
	obs.timer_remove(M.timer_callback)
end

---@diagnostic disable-next-line lowercase-global
function script_unload()
	M.script_unload()
end

return M

-- vim set ft=lua et ts=4 sw=4 :
