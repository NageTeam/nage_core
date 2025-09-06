local localeLoader = LoadResourceFile(GetCurrentResourceName(), "utils/locales.lua")
local locales = load(localeLoader)()
local locale = locales.new(Config.Locale or "en")

NAGE = exports['nage']:getSharedCode()
NAGE.ServerCallbacks = {}

function NAGE.ServerCallback(name, cb)
    NAGE.ServerCallbacks[name] = cb
end

function NAGE.TriggerCallback(name, a, b, ...)
    local callback = NAGE.ServerCallbacks[name]
    if not callback then
        NagePrint("error", locale["callback_not_found"], name)
        return
    end

    if type(a) == "number" and type(b) == "function" then
        callback(a, b, ...)

    elseif type(a) == "function" then
        callback(0, a, ...)

    else
        NagePrint("error", "Invalid TriggerCallback usage → " .. tostring(name))
    end
end

RegisterNetEvent("nage:triggerCallback", function(name, callbackId, ...)
    local src = source
    local callback = NAGE.ServerCallbacks[name]

    if callback then
        callback(src, function(...)
            TriggerClientEvent("nage:callbackResult", src, callbackId, ...)
        end, ...)
    else
        NagePrint("error", locale["callback_not_found"], name)
    end
end)
