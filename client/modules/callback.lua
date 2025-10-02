NAGE = exports['nage']:getSharedCode()

local callbackId = 0
local pendingCallbacks = {}

function NAGE.TriggerServerCallback(name, cb, ...)
    callbackId += 1
    pendingCallbacks[callbackId] = cb
    TriggerServerEvent("nage:triggerCallback", name, callbackId, ...)
end

RegisterNetEvent("nage:callbackResult", function(cbId, ...)
    local cb = pendingCallbacks[cbId]
    if cb then
        pendingCallbacks[cbId] = nil
        cb(...)
    end
end)
