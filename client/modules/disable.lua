NAGE = exports['nage']:getSharedCode()

Citizen.CreateThread(function()
    local nPlayer = NAGE.PlayerID()
    while true do
        Citizen.Wait(1000)
        if Config.Disable.Wanted then
            SetPlayerWantedLevel(nPlayer, 0, false)
            SetPlayerWantedLevelNow(nPlayer, false)
            SetPoliceIgnorePlayer(nPlayer, true)
            SetPoliceRadarBlips(false)
            SetMaxWantedLevel(0)
        end

        if Config.Disable.HealthRegeneration then
            SetPlayerHealthRechargeMultiplier(nPlayer, 0.0)
        end
    end
end)

if Config.Disable.InfStamina then
    Citizen.CreateThread(function()
        local player = PlayerId()
        SetPlayerMaxStamina(player, 1.0)
    
        while true do
            Citizen.Wait(100)
            local stamina = GetPlayerStamina(player)
    
            if stamina < 0.2 then
                ResetPlayerStamina(player)
                if Config.Debug then
                    NagePrint("debug", "Stamina was low - Restored to 100%")
                end
            end
        end
    end)
end

if Config.Disable.AmmoDisplay then
    Citizen.CreateThread(function()
        local lastWeapon = nil
    
        while true do
            local ped = NAGE.PlayerPedID()
            local currentWeapon = GetSelectedPedWeapon(ped)
    
            if currentWeapon ~= `WEAPON_UNARMED` and not IsPedMeleeWeapon(currentWeapon) then
                lastWeapon = currentWeapon
                DisplayAmmoThisFrame(false)
                Citizen.Wait(0)
            else
                lastWeapon = currentWeapon
                Citizen.Wait(500)
            end
        end
    end)
end

function IsPedMeleeWeapon(weaponHash)
    local meleeWeapons = {
        `WEAPON_KNIFE`,
        `WEAPON_NIGHTSTICK`,
        `WEAPON_HAMMER`,
        `WEAPON_BAT`,
        `WEAPON_CROWBAR`,
        `WEAPON_BOTTLE`,
        `WEAPON_GOLFCLUB`,
        `WEAPON_FLASHLIGHT`,
        `WEAPON_MACHETE`,
        `WEAPON_BALL`,
        `WEAPON_STONE_HATCHET`
    }

    for _, melee in ipairs(meleeWeapons) do
        if weaponHash == melee then
            return true
        end
    end
    return false
end

if Config.Disable.AimAssist then
    SetPlayerTargetingMode(3)
end

-- Thanks to RodaScripts for Anti GhostPeak (https://github.com/RodericAguilar/Roda_BlockX)
if Config.Disable.GhostPeak then
    local degToRad = math.pi / 180
    local tolerance = 0.30

    local function RotationToDirection(rot)
        local xRad, yRad, zRad = rot.x * degToRad, rot.y * degToRad, rot.z * degToRad
        local cosX = math.abs(math.cos(xRad))
        return vector3(
            -math.sin(zRad) * cosX,
            math.cos(zRad) * cosX,
            math.sin(xRad)
        )
    end

    local function RayCast(startCoord, distance, flag)
        local camRot = GetGameplayCamRot()
        local dir = RotationToDirection(camRot)
        local dest = startCoord + (dir * distance)
        flag = flag or 1
        local _, hit, hitCoords, _, entity = GetShapeTestResult(
            StartShapeTestRay(startCoord.x, startCoord.y, startCoord.z, dest.x, dest.y, dest.z, flag, -1, 1)
        )
        return hit, hitCoords, entity
    end

    Citizen.CreateThread(function()
        while true do
            local playerId = PlayerId()
            local ped = PlayerPedId()

            if IsPlayerFreeAiming(playerId) then
                local weapon = GetCurrentPedWeaponEntityIndex(ped)
                if weapon > 0 then
                    Citizen.Wait(0)

                    local startWeapon = GetEntityCoords(weapon) - vector3(0, 0, 0.05)
                    local camCoord = GetGameplayCamCoord()

                    local hitW, coordsW, entityW = RayCast(startWeapon, 15.0)
                    local hitC, coordsC = RayCast(camCoord, 1000.0)

                    if hitW > 0 and entityW > 0 then
                        local dist = #(coordsW - coordsC)
                        if dist > tolerance then
                            DisablePlayerFiring(playerId, true)
                            DisableControlAction(0, 106, true)
                            if Config.Debug then
                                NagePrint("debug", "Ghost Peaking prevented")
                            end
                        end
                    end
                else
                    Citizen.Wait(500)
                end
            else
                Citizen.Wait(1500)
            end
        end
    end)
end

if Config.Disable.Minimap then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(500)
            local nPlayerPed = NAGE.PlayerPedID()
            if IsPedOnFoot(nPlayerPed) or IsPedInAnyVehicle(nPlayerPed, true) then
                DisplayRadar(false)
            end
        end
    end)
end

if Config.Disable.Minimap then
    Citizen.CreateThread(function()
        local radarHidden = false
        while true do
            Citizen.Wait(1000)
            local nPlayerPed = NAGE.PlayerPedID()
            if IsPedOnFoot(nPlayerPed) or IsPedInAnyVehicle(nPlayerPed, true) then
                if not radarHidden then
                    DisplayRadar(false)
                    radarHidden = true
                end
            else
                if radarHidden then
                    DisplayRadar(true)
                    radarHidden = false
                end
            end
        end
    end)
end

if Config.Disable.GTACrosshair then
    CreateThread(function()
        while true do
            Citizen.Wait(100)
            HideHudComponentThisFrame(14)
        end
    end)
end

if Config.Disable.NPC then
    DisableVehicleDistantlights(true)
    SetPedPopulationBudget(0)
    SetVehiclePopulationBudget(0)
    SetRandomEventFlag(false)

    local scenarios = {
        'WORLD_VEHICLE_ATTRACTOR',
        'WORLD_VEHICLE_AMBULANCE',
        'WORLD_VEHICLE_BICYCLE_BMX',
        'WORLD_VEHICLE_BICYCLE_BMX_BALLAS',
        'WORLD_VEHICLE_BICYCLE_BMX_FAMILY',
        'WORLD_VEHICLE_BICYCLE_BMX_HARMONY',
        'WORLD_VEHICLE_BICYCLE_BMX_VAGOS',
        'WORLD_VEHICLE_BICYCLE_MOUNTAIN',
        'WORLD_VEHICLE_BICYCLE_ROAD',
        'WORLD_VEHICLE_BIKE_OFF_ROAD_RACE',
        'WORLD_VEHICLE_BIKER',
        'WORLD_VEHICLE_BOAT_IDLE',
        'WORLD_VEHICLE_BOAT_IDLE_ALAMO',
        'WORLD_VEHICLE_BOAT_IDLE_MARQUIS',
        'WORLD_VEHICLE_BROKEN_DOWN',
        'WORLD_VEHICLE_BUSINESSMEN',
        'WORLD_VEHICLE_HELI_LIFEGUARD',
        'WORLD_VEHICLE_CLUCKIN_BELL_TRAILER',
        'WORLD_VEHICLE_CONSTRUCTION_SOLO',
        'WORLD_VEHICLE_CONSTRUCTION_PASSENGERS',
        'WORLD_VEHICLE_DRIVE_PASSENGERS',
        'WORLD_VEHICLE_DRIVE_PASSENGERS_LIMITED',
        'WORLD_VEHICLE_DRIVE_SOLO',
        'WORLD_VEHICLE_FIRE_TRUCK',
        'WORLD_VEHICLE_EMPTY',
        'WORLD_VEHICLE_MARIACHI',
        'WORLD_VEHICLE_MECHANIC',
        'WORLD_VEHICLE_MILITARY_PLANES_BIG',
        'WORLD_VEHICLE_MILITARY_PLANES_SMALL',
        'WORLD_VEHICLE_PARK_PARALLEL',
        'WORLD_VEHICLE_PARK_PERPENDICULAR_NOSE_IN',
        'WORLD_VEHICLE_PASSENGER_EXIT',
        'WORLD_VEHICLE_POLICE_BIKE',
        'WORLD_VEHICLE_POLICE_CAR',
        'WORLD_VEHICLE_POLICE',
        'WORLD_VEHICLE_POLICE_NEXT_TO_CAR',
        'WORLD_VEHICLE_QUARRY',
        'WORLD_VEHICLE_SALTON',
        'WORLD_VEHICLE_SALTON_DIRT_BIKE',
        'WORLD_VEHICLE_SECURITY_CAR',
        'WORLD_VEHICLE_STREETRACE',
        'WORLD_VEHICLE_TOURBUS',
        'WORLD_VEHICLE_TOURIST',
        'WORLD_VEHICLE_TANDL',
        'WORLD_VEHICLE_TRACTOR',
        'WORLD_VEHICLE_TRACTOR_BEACH',
        'WORLD_VEHICLE_TRUCK_LOGS',
        'WORLD_VEHICLE_TRUCKS_TRAILERS',
        'WORLD_VEHICLE_DISTANT_EMPTY_GROUND'
    }

    for _, scenario in ipairs(scenarios) do
        SetScenarioTypeEnabled(scenario, false)
    end
else
    Citizen.CreateThread(function()
        DisableVehicleDistantlights(false)
        SetPedPopulationBudget(1)
        SetVehiclePopulationBudget(1)
        SetRandomEventFlag(true)

        local scenarios = {
            'WORLD_VEHICLE_ATTRACTOR',
            'WORLD_VEHICLE_AMBULANCE',
            'WORLD_VEHICLE_BICYCLE_BMX',
            'WORLD_VEHICLE_BICYCLE_BMX_BALLAS',
            'WORLD_VEHICLE_BICYCLE_BMX_FAMILY',
            'WORLD_VEHICLE_BICYCLE_BMX_HARMONY',
            'WORLD_VEHICLE_BICYCLE_BMX_VAGOS',
            'WORLD_VEHICLE_BICYCLE_MOUNTAIN',
            'WORLD_VEHICLE_BICYCLE_ROAD',
            'WORLD_VEHICLE_BIKE_OFF_ROAD_RACE',
            'WORLD_VEHICLE_BIKER',
            'WORLD_VEHICLE_BOAT_IDLE',
            'WORLD_VEHICLE_BOAT_IDLE_ALAMO',
            'WORLD_VEHICLE_BOAT_IDLE_MARQUIS',
            'WORLD_VEHICLE_BROKEN_DOWN',
            'WORLD_VEHICLE_BUSINESSMEN',
            'WORLD_VEHICLE_HELI_LIFEGUARD',
            'WORLD_VEHICLE_CLUCKIN_BELL_TRAILER',
            'WORLD_VEHICLE_CONSTRUCTION_SOLO',
            'WORLD_VEHICLE_CONSTRUCTION_PASSENGERS',
            'WORLD_VEHICLE_DRIVE_PASSENGERS',
            'WORLD_VEHICLE_DRIVE_PASSENGERS_LIMITED',
            'WORLD_VEHICLE_DRIVE_SOLO',
            'WORLD_VEHICLE_FIRE_TRUCK',
            'WORLD_VEHICLE_EMPTY',
            'WORLD_VEHICLE_MARIACHI',
            'WORLD_VEHICLE_MECHANIC',
            'WORLD_VEHICLE_MILITARY_PLANES_BIG',
            'WORLD_VEHICLE_MILITARY_PLANES_SMALL',
            'WORLD_VEHICLE_PARK_PARALLEL',
            'WORLD_VEHICLE_PARK_PERPENDICULAR_NOSE_IN',
            'WORLD_VEHICLE_PASSENGER_EXIT',
            'WORLD_VEHICLE_POLICE_BIKE',
            'WORLD_VEHICLE_POLICE_CAR',
            'WORLD_VEHICLE_POLICE',
            'WORLD_VEHICLE_POLICE_NEXT_TO_CAR',
            'WORLD_VEHICLE_QUARRY',
            'WORLD_VEHICLE_SALTON',
            'WORLD_VEHICLE_SALTON_DIRT_BIKE',
            'WORLD_VEHICLE_SECURITY_CAR',
            'WORLD_VEHICLE_STREETRACE',
            'WORLD_VEHICLE_TOURBUS',
            'WORLD_VEHICLE_TOURIST',
            'WORLD_VEHICLE_TANDL',
            'WORLD_VEHICLE_TRACTOR',
            'WORLD_VEHICLE_TRACTOR_BEACH',
            'WORLD_VEHICLE_TRUCK_LOGS',
            'WORLD_VEHICLE_TRUCKS_TRAILERS',
            'WORLD_VEHICLE_DISTANT_EMPTY_GROUND'
        }

        for _, scenario in ipairs(scenarios) do
            SetScenarioTypeEnabled(scenario, true)
        end
    end)
end
