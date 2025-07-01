NAGE = exports['nage']:getSharedCode()

AddEventHandler('playerConnecting', function(playerName, nPlayer, deferrals)
    TriggerEvent('nage:playerConnecting', playerName, nPlayer, deferrals)
end)

AddEventHandler('playerJoining', function(playerName, nPlayer)
    TriggerEvent('nage:playerJoined', playerName, nPlayer)
end)

AddEventHandler('playerSpawned', function()
    TriggerEvent('nage:playerSpawned')
end)

AddEventHandler('playerDropped', function(nPlayer, reason)
    TriggerEvent('nage:playerDropped', nPlayer, reason)
end)
