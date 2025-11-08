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
            NagePrint("debug", locale["debug_spawn_coords"], Config.Spawn.x, Config.Spawn.y, Config.Spawn.z)
        end

        exports.spawnmanager:setAutoSpawn(true)
        exports.spawnmanager:forceRespawn()

        exports.spawnmanager:spawnPlayer({
            x = Config.Spawn.x,
            y = Config.Spawn.y,
            z = Config.Spawn.z,
            heading = Config.Spawn.w,
            model = "mp_m_freemode_01",
            skipFade = true
        })

        TriggerEvent('nage:starterClothing')

        if firstSpawn then
            firstSpawn = false
            TriggerServerEvent('nage:checkFirstJoin')
        end
    else
        NagePrint("error", locale["error_spawn_config_missing"])
    end
end)

AddEventHandler("playerSpawned", function()
	SetCanAttackFriendly(GetPlayerPed(-1), true, false)
	NetworkSetFriendlyFireOption(true)
end)

local headBones = {
    [31086] = true, -- SKEL_Head
    [39317] = true, -- SKEL_Neck_1
    [12844] = true, -- IK_Head
    [25260] = true, -- FB_L_Eye_000
    [27474] = true, -- FB_R_Eye_000
    [46240] = true, -- FB_Jaw_000
}

local ignoreWeapons = {
    [GetHashKey("WEAPON_DAGGER")] = true,
    [GetHashKey("WEAPON_BAT")] = true,
    [GetHashKey("WEAPON_BOTTLE")] = true,
    [GetHashKey("WEAPON_CROWBAR")] = true,
    [GetHashKey("WEAPON_UNARMED")] = true,
    [GetHashKey("WEAPON_FLASHLIGHT")] = true,
    [GetHashKey("WEAPON_GOLFCLUB")] = true,
    [GetHashKey("WEAPON_HAMMER")] = true,
    [GetHashKey("WEAPON_HATCHET")] = true,
    [GetHashKey("WEAPON_KNUCKLE")] = true,
    [GetHashKey("WEAPON_KNIFE")] = true,
    [GetHashKey("WEAPON_MACHETE")] = true,
    [GetHashKey("WEAPON_SWITCHBLADE")] = true,
    [GetHashKey("WEAPON_NIGHTSTICK")] = true,
    [GetHashKey("WEAPON_WRENCH")] = true,
    [GetHashKey("WEAPON_BATTLEAXE")] = true,
    [GetHashKey("WEAPON_POOLCUE")] = true,
    [GetHashKey("WEAPON_STONE_HATCHET")] = true,
}

AddEventHandler('gameEventTriggered', function(name, args)
    if name ~= 'CEventNetworkEntityDamage' then return end

    local victim = tonumber(args[1])
    local attacker = tonumber(args[2])

    if not DoesEntityExist(victim) or not DoesEntityExist(attacker) then 
        return 
    end
    if not IsPedAPlayer(victim) or not IsPedAPlayer(attacker) then 
        return 
    end

    local bulletHit, boneHit = GetPedLastDamageBone(victim)
    if not bulletHit then 
        return 
    end

    local weaponHash = GetSelectedPedWeapon(attacker)
    if ignoreWeapons[weaponHash] then 
        return 
    end

    if boneHit and headBones[boneHit] then
        SetPedArmour(victim, 0)
        SetEntityHealth(victim, 0)
        
        if not IsEntityDead(victim) then
            SetPedArmour(victim, 0)
            SetEntityHealth(victim, 0)
        end
    end
end)
