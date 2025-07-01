local localeLoader = LoadResourceFile(GetCurrentResourceName(), "utils/locales.lua")
local locales = load(localeLoader)()
local locale = locales.new(Config.Locale or "en")

RegisterNetEvent('nage:starterClothing')
AddEventHandler('nage:starterClothing', function()
    local function isResourceRunning(name)
        return GetResourceState(name) == 'started'
    end

    if isResourceRunning('pure-clothing') or isResourceRunning('pure_clothing') then
        if Config.Debug then
            print("^4[Nage Core]^7 ^6[CLOTHING]^7: Detected Pure Clothing")
        end
        Wait(100)
        exports['pure-clothing']:initiateApperance()
        return
    end

    print("^4[Nage Core]^7 ^6[CLOTHING]^7: " .. locale["no_clothing_system"])
end)
