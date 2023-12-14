---@diagnostic disable-next-line undefined-global
local obs = obslua

local utils = require 'utils'

-- Define defaults
local DEFAULT_INTERVAL = 30
local DEFAULT_TIMEOUT = 5
local DEFAULT_COMMAND = 'date'
local DEFAULT_SHELL = 'sh'

-- Internal vars (current settings)
local INTERVAL = DEFAULT_INTERVAL
local TIMEOUT = DEFAULT_TIMEOUT
local SHELL = DEFAULT_SHELL
local COMMAND = DEFAULT_COMMAND
local TARGET_SOURCE = ""
local DEBUG = false

-- Function to execute a shell command and capture its output
local function update_text_source_with_cmd_output()
    local text = utils.exec_cmd(COMMAND, TIMEOUT, SHELL, DEBUG)

    if text == nil then
        print("ERROR: Command returned nil")
        return
    end

    utils.update_text_source(TARGET_SOURCE, text)
end

-- Timer callback function
local function timer_callback()
    update_text_source_with_cmd_output()
end

-- Function to update the timer based on the interval setting
local function update_timer()
    -- Remove the existing timer
    obs.timer_remove(timer_callback)

    -- Register the timer with the new interval
    obs.timer_add(timer_callback, INTERVAL * 1000)
end

local function print_script_settings()
    print("Script settings:")
    print(string.format("Interval: %ds", INTERVAL))
    print(string.format("Command: %s", COMMAND))
    print(string.format("Shell: %s", SHELL))
    print(string.format("Timeout: %ds", TIMEOUT))
    print(string.format("Target Source: %s", TARGET_SOURCE))
end

local function work(settings)
    COMMAND = obs.obs_data_get_string(settings, 'command')
    INTERVAL = obs.obs_data_get_int(settings, 'interval')
    SHELL = obs.obs_data_get_string(settings, 'shell')
    TARGET_SOURCE = obs.obs_data_get_string(settings, 'target_source')
    TIMEOUT = obs.obs_data_get_int(settings, 'timeout')

    if INTERVAL == nil then
        INTERVAL = DEFAULT_INTERVAL
    end

    if TIMEOUT == nil then
        TIMEOUT = DEFAULT_TIMEOUT
    end

    print_script_settings()
    update_timer()
    -- Update text right away
    update_text_source_with_cmd_output()
end

---@diagnostic disable-next-line lowercase-global
function script_load(settings)
    work(settings)
end

---@diagnostic disable-next-line lowercase-global
function script_update(settings)
    work(settings)
end

---@diagnostic disable-next-line lowercase-global
function script_defaults(settings)
    obs.obs_data_set_default_int(settings, 'interval', DEFAULT_INTERVAL)
    obs.obs_data_set_default_int(settings, 'timeout', DEFAULT_TIMEOUT)
    obs.obs_data_set_default_string(settings, 'command', DEFAULT_COMMAND)
    obs.obs_data_set_default_string(settings, 'shell', DEFAULT_SHELL)
end

---@diagnostic disable-next-line lowercase-global
function script_description()
    return "🤖 Execute a command periodically and update a text source with the output."
end

---@diagnostic disable-next-line lowercase-global
function script_properties()
    return utils.cmd_script_properties()
end

-- Script Hook - Called when the script is unloaded
---@diagnostic disable-next-line lowercase-global
function script_unload()
    obs.timer_remove(timer_callback)
end

-- vim set ft=lua et ts=4 sw=4 :
