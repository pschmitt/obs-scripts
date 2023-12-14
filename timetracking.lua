---@diagnostic disable-next-line undefined-global
local obs = obslua

local utils = require 'utils'
local cmdtxt = require 'cmd-to-text'

-- Define defaults
local DEFAULT_INTERVAL = 30
local DEFAULT_TIMEOUT = 5
local DEFAULT_SHELL = "zsh"
local DEFAULT_COMMAND = 'timewarrior::today-total --minutes'

cmdtxt.DEFAULT_INTERVAL = DEFAULT_INTERVAL
cmdtxt.DEFAULT_TIMEOUT = DEFAULT_TIMEOUT
cmdtxt.DEFAULT_SHELL = DEFAULT_SHELL
cmdtxt.DEFAULT_COMMAND = DEFAULT_COMMAND
cmdtxt.DEBUG = false

-- Function to execute a shell command and capture its output
local function update_text_source_with_cmd_output()
    local text = utils.exec_cmd(cmdtxt.COMMAND, cmdtxt.TIMEOUT, cmdtxt.SHELL, cmdtxt.DEBUG)

    if text == nil then
        print("ERROR: Command returned nil")
        return
    end

    local color = '#ffffff'
    local hours = utils.extract_first_digit(text)

    if hours ~= nil then
        print("Hours: " .. hours)

        if hours >= 8 then
            color = '#ff0000'
        elseif hours >= 7 then
            color = '#ff8000'
        end
    end

    text = string.format("⏱️ %s", text)
    utils.update_text_source(cmdtxt.TARGET_SOURCE, text, color)
end

-- override upstream func
cmdtxt.update_text_source_with_cmd_output = update_text_source_with_cmd_output

---@diagnostic disable-next-line lowercase-global
function script_load(settings)
    cmdtxt.work(settings)
end

---@diagnostic disable-next-line lowercase-global
function script_update(settings)
    cmdtxt.work(settings)
end

---@diagnostic disable-next-line lowercase-global
function script_defaults(settings)
    cmdtxt.script_defaults(settings)
end

---@diagnostic disable-next-line lowercase-global
function script_description()
    return "⏱️ Show timetracking info"
end

---@diagnostic disable-next-line lowercase-global
function script_properties()
    return cmdtxt.script_properties()
end

---@diagnostic disable-next-line lowercase-global
function script_unload()
    return cmdtxt.script_unload()
end

-- vim set ft=lua et ts=4 sw=4 :
