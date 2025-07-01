local localeLoader = LoadResourceFile(GetCurrentResourceName(), "utils/locales.lua")
local locales = load(localeLoader)()
local locale = locales.new(Config.Locale or "en")

NAGE = exports['nage']:getSharedCode()
NAGE.ServerCallbacks = {}

function NAGE.ServerCallback(name, cb)
    NAGE.ServerCallbacks[name] = cb
end

function NAGE.TriggerCallback(name, source, cb, ...)
    local callback = NAGE.ServerCallbacks[name]
    if callback then
        callback(source, cb, ...)
    else
        print(string.format("^4[Nage Core]^7 ^1[CALLBACK]^7: %s", locale["callback_not_found"]:format(name)))
    end
end

RegisterNetEvent("nage:triggerCallback", function(name, callbackId, ...)
    local nPlayer = NAGE.PlayerID(source)
    local args = { ... }

    local callback = NAGE.ServerCallbacks[name]
    if callback then
        callback(nPlayer, function(...)
            TriggerClientEvent("nage:callbackResult", nPlayer, callbackId, ...)
        end, table.unpack(args))
    else
        print(string.format("^4[Nage Core]^7 ^1[CALLBACK]^7: %s", locale["callback_not_found"]:format(name)))
    end
end)
