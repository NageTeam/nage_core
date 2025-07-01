local queueNummer = 0

RegisterNetEvent('connectqueue:playerJoinQueue')
AddEventHandler('connectqueue:playerJoinQueue', function(count)
    queueNummer = count
end)

RegisterNetEvent('connectqueue:playerLeaveQueue')
AddEventHandler('connectqueue:playerLeaveQueue', function(count)
    queueNummer = count
end)

Citizen.CreateThread(function()
    while true do
        local playerID = GetPlayerServerId(PlayerId())
        local playerName = GetPlayerName(PlayerId())
        local onlinePlayers = #GetActivePlayers()

        local presence = Config.DiscordActivity.presence
            :gsub("{player_id}", playerID)
            :gsub("{player_name}", playerName)
            :gsub("{online_players}", tostring(onlinePlayers))
            :gsub("{queue_number}", tostring(queueNummer))

        SetDiscordAppId(Config.DiscordActivity.appId)
        SetDiscordRichPresenceAsset(Config.DiscordActivity.assetName)
        SetDiscordRichPresenceAssetSmallText(Config.DiscordActivity.assetText)
        SetRichPresence(presence)

        for i, button in ipairs(Config.DiscordActivity.buttons) do
            SetDiscordRichPresenceAction(i - 1, button.label, button.url)
        end

        Citizen.Wait(Config.DiscordActivity.refresh)
    end
end)