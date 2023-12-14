---@diagnostic disable-next-line undefined-global
local obs = obslua

local M = {}

function M.exec_cmd(command, timeout, shell, debug)
    timeout = timeout or 30
    shell = shell or "sh"
    debug = debug or false

    command = string.format("timeout '%d' %s -c '%s'", timeout, shell, command)

    if debug then
        command = string.format('%s 2>&1', command)
    end

    local time = os.date("%H:%M:%S")
    print(string.format("[%s] Exec: %s", time, command))

    -- Execute command and capture output
    local handle = io.popen(command, "r")

    if handle == nil then
        print("ERROR: Unable to execute command")
        return
    end

    local command_output = handle:read("*a")
    local rc = handle:close()

    print(string.format("Return code: %s", rc))

    if command_output == nil then
        print("ERROR: Command output is nil")
        return
    end

    -- Remove trailing newline from the output
    command_output = string.gsub(command_output, "\n$", "")

    print(string.format("Output:\n%s", command_output))

    return command_output
end

function M.convertHexToOBSColor(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    local a = 255 -- Default opacity

    -- Include alpha if it's part of the hex string
    if #hex == 8 then
        a = tonumber(hex:sub(7, 8), 16)
    end

    local color = a * 256 ^ 3 + b * 256 ^ 2 + g * 256 + r
    return color
end

function M.convertOBSColorToHex(color)
    local r = color % 256
    local g = math.floor((color / 256) % 256)
    local b = math.floor((color / 256 ^ 2) % 256)
    local a = math.floor(color / 256 ^ 3)

    return string.format("#%02X%02X%02X%02X", r, g, b, a)
end

function M.extract_first_digit(str)
    local first_part = string.match(str, "^(%d+):")
    return tonumber(first_part)
end

local OBS_TXT_SOURCE_PTHREAD = "obs_text_pthread_source_v2"
local OBS_TXT_SOURCE_FREETYPE2 = "text_ft2_source_v2"

function M.is_text_source(source_id)
    local allowed_source_types = {
        OBS_TXT_SOURCE_PTHREAD,
        OBS_TXT_SOURCE_FREETYPE2
    }
    for _, allowed_id in ipairs(allowed_source_types) do
        if source_id == allowed_id then
            return true
        end
    end
    return false
end

function M.get_text_sources()
    local sources = {}
    local source_list = obs.obs_enum_sources()
    if source_list then
        for _, source in ipairs(source_list) do
            local source_id = obs.obs_source_get_id(source)
            if M.is_text_source(source_id) then
                local name = obs.obs_source_get_name(source)
                table.insert(sources, name)
            end
        end
        obs.source_list_release(source_list)
    end
    return sources
end

function M.update_text_source(source_name, text, color_hex)
    color_hex = color_hex or nil

    print(string.format(
        "Updating text source: '%s' with text: '%s' (color: %s)",
        source_name, text, color_hex)
    )

    local source = obs.obs_get_source_by_name(source_name)
    if source == nil then
        print("Target source not found.")
        return
    end

    local source_settings = obs.obs_source_get_settings(source)
    local previous_text = obs.obs_data_get_string(source_settings, "text")

    if text ~= previous_text then
        print(string.format("Text content: %s -> %s", previous_text, text))
        obs.obs_data_set_string(source_settings, "text", text)
    end

    if color_hex ~= nil then
        local color_int = M.convertHexToOBSColor(color_hex)
        if color_int ~= nil then
            local previous_color = obs.obs_data_get_int(source_settings, "color")
            local previous_color_hex = M.convertOBSColorToHex(previous_color)

            if color_int ~= previous_color then
                print(string.format("Color: %s -> %s", previous_color_hex, color_hex))
                obs.obs_data_set_int(source_settings, "color", color_int)
            end
        end
    end

    obs.obs_source_update(source, source_settings)

    -- Release the source to avoid memory leaks
    obs.obs_source_release(source)
    obs.obs_data_release(source_settings)
end

function M.cmd_script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_int(
        props,
        "interval",
        "Interval (s)",
        1,
        7200,
        1
    )
    obs.obs_properties_add_text(
        props,
        "command",
        "Command",
        obs.OBS_TEXT_DEFAULT
    )

    obs.obs_properties_add_text(
        props,
        "shell",
        "Shell",
        obs.OBS_TEXT_DEFAULT
    )

    obs.obs_properties_add_int(
        props,
        "timeout",
        "Timeout (s)",
        1,
        3600,
        1
    )

    local sources = obs.obs_properties_add_list(
        props, 'target_source', 'Source:',
        obs.OBS_COMBO_TYPE_EDITABLE,
        obs.OBS_COMBO_FORMAT_STRING)

    local txt_sources = M.get_text_sources()
    for _, name in ipairs(txt_sources) do
        obs.obs_property_list_add_string(sources, name, name)
    end

    return props
end

return M
