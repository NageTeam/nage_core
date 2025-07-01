local Callbacks = {}
local callbackId = 0
NAGE = NAGE or {}

function NAGE.TriggerServerCallback(name, cb, ...)
    callbackId = callbackId + 1
    local id = callbackId

    Callbacks[id] = cb
    TriggerServerEvent("nage:triggerCallback", name, id, ...)
end

RegisterNetEvent("nage:callbackResult", function(id, ...)
    if Callbacks[id] then
        Callbacks[id](...)
        Callbacks[id] = nil
    end
end)
