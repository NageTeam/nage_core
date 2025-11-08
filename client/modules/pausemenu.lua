local function AddTextEntry(k, v)
    Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), k, v)
end

local function replacePlaceholders(text)
    local playerId = GetPlayerServerId(PlayerId())
    local playerName = GetPlayerName(PlayerId())
    local playersOnline = #GetActivePlayers()

    text = text:gsub("{player_id}", tostring(playerId))
    text = text:gsub("{player_name}", tostring(playerName))
    text = text:gsub("{online_players}", tostring(playersOnline))

    return text
end

local function fallback(tbl, key, default)
    if tbl and tbl[key] ~= nil and tbl[key] ~= '' then
        return replacePlaceholders(tbl[key])
    end
    return default
end

Citizen.CreateThread(function()
    while true do
        local fivem_title = fallback(Config.PauseMenu, "Title", "FiveM")
        local map_category = fallback(Config.PauseMenu, "Map", "MAP")
        local settings_category = fallback(Config.PauseMenu, "Settings", "SETTINGS")
        local fivem_key_config_submenu = fallback(Config.PauseMenu, "Keybinds", "FiveM")

        AddTextEntry('FE_THDR_GTAO', fivem_title)
        AddTextEntry('PM_SCR_MAP', map_category)
        AddTextEntry('PM_SCR_SET', settings_category)
        AddTextEntry('PM_PANE_CFX', fivem_key_config_submenu)

        Citizen.Wait(10000)
    end
end)