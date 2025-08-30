NAGE = exports['nage']:getSharedCode()

local pvpEnabled = false

AddEventHandler('playerDeath', function(nPlayer, killerId)
    TriggerEvent('nage:playerDeath', nPlayer, killerId)
end)

RegisterNetEvent('nage:TogglePVP')
AddEventHandler('nage:TogglePVP', function()
    pvpEnabled = not pvpEnabled

    NetworkSetFriendlyFireOption(pvpEnabled)
    SetCanAttackFriendly(NAGE.PlayerPedID(), pvpEnabled, true)

    local status = pvpEnabled and "^2enabled^7" or "^1disabled^7"
    NagePrint("info", "PVP is now %s", status)
end)
