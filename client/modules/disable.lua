NAGE = exports['nage']:getSharedCode()

local nPlayer = NAGE.PlayerID()
local nPlayerPed = NAGE.PlayerPedID()

Citizen.CreateThread(function()
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
        while true do
            Citizen.Wait(1000)
            RestorePlayerStamina(nPlayer, 1.0)
        end
    end)
end

if Config.Disable.AmmoDisplay then
    CreateThread(function()
        while true do
            Wait(50)
            DisplayAmmoThisFrame(false)
            HideHudComponentThisFrame(19)
        end
    end)
end

if Config.Disable.AimAssist then
    SetPlayerTargetingMode(3)
end

if Config.Disable.GhostPeak then
    local DEG_TO_RAD = math.pi / 180

    local function RotationToDirection(rotation)
        local xRad = rotation.x * DEG_TO_RAD
        local yRad = rotation.y * DEG_TO_RAD
        local zRad = rotation.z * DEG_TO_RAD
        return {
            x = -math.sin(zRad) * math.abs(math.cos(xRad)),
            y = math.cos(zRad) * math.abs(math.cos(xRad)),
            z = math.sin(xRad)
        }
    end

    local function RayCastGamePlayWeapon(weapon, distance, flag)
        local cameraRotation = GetGameplayCamRot()
        local weapCoord = GetEntityCoords(weapon)
        local cameraCoord = GetGameplayCamCoord()
        local direction = RotationToDirection(cameraRotation)
        local destination = vector3(cameraCoord.x + direction.x * distance, cameraCoord.y + direction.y * distance,
            cameraCoord.z + direction.z * distance)
        if not flag then flag = 1 end
        local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(weapCoord.x, weapCoord.y, weapCoord.z, destination.x,
            destination.y, destination.z, flag, -1, 1))
        return b, c, e, destination
    end

    local function RayCastGamePlayCamera(weapon, distance, flag)
        local cameraRotation = GetGameplayCamRot()
        local weapCoord = GetEntityCoords(weapon)
        local cameraCoord = GetGameplayCamCoord()
        local direction = RotationToDirection(cameraRotation)
        local destination = vector3(cameraCoord.x + direction.x * distance, cameraCoord.y + direction.y * distance,
            cameraCoord.z + direction.z * distance)
        if not flag then flag = 1 end
        local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z,
            destination.x, destination.y, destination.z, flag, -1, 1))
        return b, c, e, destination
    end

    Citizen.CreateThread(function()
        local ped, weapon, nPlayer, sleep
        while true do
            sleep = 500
            nPlayer = NAGE.PlayerID()
            ped = NAGE.PlayerPedID()
            weapon = GetWeaponObjectFromPed(ped, false)

            if weapon > 0 and IsPlayerFreeAiming(nPlayer) then
                local hitW, coordsW, entityW = RayCastGamePlayWeapon(weapon, 15.0, 1)
                local hitC, coordsC, entityC = RayCastGamePlayCamera(weapon, 1000.0, 1)
                if hitW > 0 and entityW > 0 and math.abs(#coordsW - #coordsC) > 1 then
                    sleep = 0
                    Draw3DText(coordsW.x, coordsW.y, coordsW.z, '❌')
                    DisablePlayerFiring(ped, true)
                    DisableControlAction(0, 106, true)
                end
            else
                Citizen.Wait(500)
            end
            Citizen.Wait(sleep)
        end
    end)

    function Draw3DText(x, y, z, text)
        local onScreen, _x, _y = World3dToScreen2d(x, y, z)
        if onScreen then
            SetTextScale(0.3, 0.3)
            SetTextFont(0)
            SetTextColour(255, 255, 255, 255)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextDropShadow()
            SetTextOutline()
            SetTextEntry("STRING")
            SetTextCentre(1)
            AddTextComponentString(text)
            DrawText(_x, _y)
        end
    end
end

if Config.Disable.Minimap then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(500)
            local playerPed = GetPlayerPed(-1)
            if IsPedOnFoot(playerPed) or IsPedInAnyVehicle(playerPed, true) then
                DisplayRadar(false)
            end
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