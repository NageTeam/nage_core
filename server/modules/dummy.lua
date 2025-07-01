--[[
    NAGE Core: Cheater Event
    This is a fake event designed to catch cheaters who try to trigger 
    unauthorized admin commands. It pretends to perform a ban, but instead:
    - Announces the failed attempt in chat.
    - Kicks the cheater who triggered it.
    - Does NOT ban or affect the intended "target".

    Use with caution and enjoy the confusion on the cheaters end.
--]]

NAGE = exports['nage']:getSharedCode()

RegisterNetEvent("nage:banPlayer")
AddEventHandler("nage:banPlayer", function(targetPlayerId, reason)
    local nPlayer = NAGE.PlayerID(source)
    local name = GetPlayerName(nPlayer)
    local targetId = tonumber(targetPlayerId) or 0
    local targetName = GetPlayerName(targetId) or ("ID " .. tostring(targetId))

    TriggerClientEvent('chat:addMessage', -1, {
        args = {
            "[System]",
            name .. " tried to ban " .. targetName .. " but failed miserably. Nice try. 😂"
        }
    })

    print("\n")
    print("████████████████████████████████████████████████████████████████████████")
    print("❌ EXPLOIT ATTEMPT DETECTED ❌")
    print("Player: " .. name .. " (ID: " .. nPlayer .. ")")
    print("Tried to trigger: nage:banPlayer")
    print("Target: " .. targetName .. " (ID: " .. targetId .. ")")
    print("Reason: " .. (reason or "No reason provided"))
    print("This event is a trap. They have been kicked.")
    print("████████████████████████████████████████████████████████████████████████")
    print("\n")

    DropPlayer(nPlayer, "Bro, at least try to hide it, this event was logged 😂 💀")
end)

RegisterNetEvent("nage:addMoney")
AddEventHandler("nage:addMoney", function(amount)
    local nPlayer = NAGE.PlayerID(source)
    local name = GetPlayerName(nPlayer)

    TriggerClientEvent('chat:addMessage', -1, {
        args = {
            "[System]",
            name .. " tried to add $" .. tostring(amount) .. " to their account... didn't work. 😂"
        }
    })

    print("\n")
    print("████████████████████████████████████████████████████████████████████████")
    print("❌ EXPLOIT ATTEMPT DETECTED ❌")
    print("Player: " .. name .. " (ID: " .. nPlayer .. ")")
    print("Tried to trigger: nage:addMoney with amount: $" .. tostring(amount))
    print("This event is a fake trap and they have been kicked.")
    print("████████████████████████████████████████████████████████████████████████")
    print("\n")

    DropPlayer(nPlayer, "Why cheat?, legit get a job. This event was logged 😂 💀")
end)