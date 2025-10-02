local localeLoader = LoadResourceFile(GetCurrentResourceName(), "utils/locales.lua")
local locales = load(localeLoader)()
local locale = locales.new(Config.Locale or "en")

NAGE = exports['nage']:getSharedCode()
NAGE.ServerCallbacks = {}

function NAGE.RegisterServerCallback(name, cb)
    NAGE.ServerCallbacks[name] = cb
end

function NAGE.TriggerCallback(name, source, cb, ...)
    local callback = NAGE.ServerCallbacks[name]
    if not callback then
        NagePrint("error", locale["callback_not_found"], name)
        cb(nil)
        return
    end
    callback(source, cb, ...)
end

RegisterNetEvent("nage:triggerCallback", function(name, cbId, ...)
    local src = source
    local callback = NAGE.ServerCallbacks[name]

    if not callback then
        NagePrint("error", locale["callback_not_found"], name)
        TriggerClientEvent("nage:callbackResult", src, cbId, nil)
        return
    end

    callback(src, function(...)
        TriggerClientEvent("nage:callbackResult", src, cbId, ...)
    end, ...)
end)

NAGE.RegisterServerCallback("nage:checkAdminAccess", function(source, cb)
    if not source or source == 0 then
        cb(false)
        return
    end

    local license
    for _, id in pairs(GetPlayerIdentifiers(source)) do
        if id:find("license:") then
            license = id:sub(9)
            break
        end
    end

    if not license then
        cb(false)
        return
    end

    exports.oxmysql:query("SELECT `rank` FROM users WHERE license = ?", { license }, function(result)
        if not result or not result[1] then
            cb(false)
            return
        end

        local userGroup = result[1].rank
        local isAdmin = false

        for _, rank in pairs(Config.Ranks.Admins) do
            if rank:lower() == userGroup:lower() then
                isAdmin = true
                break
            end
        end

        cb(isAdmin)
    end)
end)
