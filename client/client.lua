local firstSpawn = true
local localeLoader = LoadResourceFile(GetCurrentResourceName(), "utils/locales.lua")
if not localeLoader then
    error("^4[Nage Core]^7 ^1[ERROR]^7: 'utils/locales.lua' could not be loaded in resource: " .. GetCurrentResourceName())
end
local locales = load(localeLoader)()
local locale = locales.new(Config.Locale or "en")

NAGE = exports['nage']:getSharedCode()

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    if Config.Spawn then
        if Config.Debug then
            print(string.format("^4[Nage Core]^7 ^2[SUCCESS]^7: " .. locale["debug_spawn_coords"], Config.Spawn.x, Config.Spawn.y, Config.Spawn.z))
        end

        exports.spawnmanager:setAutoSpawn(true)
        exports.spawnmanager:forceRespawn()

        exports.spawnmanager:spawnPlayer({
            x = Config.Spawn.x,
            y = Config.Spawn.y,
            z = Config.Spawn.z,
            heading = Config.Spawn.w,
            model = "a_m_y_skater_01", -- mp_m_freemode_01
            skipFade = false
        })
        if firstSpawn then
            firstSpawn = false
            TriggerServerEvent('nage:checkFirstJoin')
            TriggerEvent('nage:starterClothing')
        end
    else
        print("^4[Nage Core]^7 ^1[ERROR]^7: " .. locale["error_spawn_config_missing"])
    end
end)

AddEventHandler("playerSpawned", function()
	SetCanAttackFriendly(GetPlayerPed(-1), true, false)
	NetworkSetFriendlyFireOption(true)
end)

local criticalBones = {
    [31086] = true, [39317] = true, [39318] = true,
    [27474] = true, [24817] = true, [24816] = true,
    [27473] = true, [24810] = true, [10706] = true,
    [23553] = true, [58866] = true
}

local meleeWeapons = {
    [GetHashKey("WEAPON_UNARMED")] = true,
    [GetHashKey("WEAPON_BAT")] = true,
    [GetHashKey("WEAPON_KNIFE")] = true,
    [GetHashKey("WEAPON_CROWBAR")] = true,
    [GetHashKey("WEAPON_DAGGER")] = true,
    [GetHashKey("WEAPON_FLASHLIGHT")] = true,
    [GetHashKey("WEAPON_GOLFCLUB")] = true,
    [GetHashKey("WEAPON_HAMMER")] = true,
    [GetHashKey("WEAPON_HATCHET")] = true,
    [GetHashKey("WEAPON_KNUCKLE")] = true,
    [GetHashKey("WEAPON_MACHETE")] = true,
    [GetHashKey("WEAPON_SWITCHBLADE")] = true,
    [GetHashKey("WEAPON_WRENCH")] = true,
    [GetHashKey("WEAPON_POOLCUE")] = true,
    [GetHashKey("WEAPON_STONE_HATCHET")] = true,
    [GetHashKey("WEAPON_NIGHTSTICK")] = true
}

AddEventHandler("gameEventTriggered", function(name, args)
    if name ~= "CEventNetworkEntityDamage" then return end

    local victimNetId = args[1]
    local attackerNetId = args[2]
    local victimPed = NetToPed(victimNetId)
    local attackerPed = NetToPed(attackerNetId)

    if attackerPed ~= NAGE.PlayerPedID() then return end
    if not DoesEntityExist(victimPed) then return end

    local success, bone = GetPedLastDamageBone(victimPed)
    if not success then return end

    if criticalBones[bone] then
        local weapon = GetPedCauseOfDeath(victimPed)
        if not meleeWeapons[weapon] then
            local victimPlayer = NetworkGetPlayerIndexFromPed(victimPed)
            if victimPlayer ~= -1 then
                local victimServerId = GetPlayerServerId(victimPlayer)
                TriggerServerEvent("nage:criticalKill:requestKill", victimServerId)
            end
        end
    end
end)

RegisterNetEvent("nage:criticalKill:forceKill", function()
    local ped = NAGE.PlayerPedID()
    if DoesEntityExist(ped) and not IsEntityDead(ped) then
        ApplyDamageToPed(ped, 9999, true)
        SetPedArmour(ped, 0)
    end
end)
