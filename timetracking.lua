---@diagnostic disable-next-line undefined-global
local obs = obslua

local cmdtxt = require 'cmd-to-text'
local utils = require 'utils'

local DESCRIPTION = "⏱️ Show timetracking info"
local DEFAULT_VALUE= "N/A"

-- Update default values
cmdtxt.DEFAULT_SHELL = "zsh"
cmdtxt.DEFAULT_COMMAND = string.format(
    "timewarrior::today-total --minutes || echo '%s'",
    DEFAULT_VALUE
)

local function update_text_source_with_cmd_output()
    local text = utils.exec_cmd(
        cmdtxt.COMMAND,
        cmdtxt.TIMEOUT,
        cmdtxt.SHELL,
        cmdtxt.DEBUG
    )

    if text == nil or text == "" then
        print(string.format(
            "ERROR: Command returned no output. Defaulting to %s",
            DEFAULT_VALUE)
        )
        text = DEFAULT_VALUE
    end

    local color = '#ffffff'
    local hours = utils.extract_first_digit(text)

    local valid = (hours ~= nil)

    if valid then
        print(string.format("Hours: %d", hours))

        if hours >= 8 then
            color = '#ff0000'
        elseif hours >= 7 then
            color = '#ff8000'
        elseif hours >= 6 then
            color = '#fff000'
        end
    end

    -- prepend emoji
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
    return DESCRIPTION
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
