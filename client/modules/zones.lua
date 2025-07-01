local currentZone = nil
local debugColor = { r = 0, g = 255, b = 0, a = 80 }
local shootingBlockThread = nil
local ghostCollisionThread = nil
local localeLoader = LoadResourceFile(GetCurrentResourceName(), "utils/locales.lua")
local locales = load(localeLoader)()
local locale = locales.new(Config.Locale or "en")

local function DrawZone(zone)
    if not zone.points or #zone.points < 3 then return end

    local z = GetEntityCoords(NAGE.PlayerPedID()).z
    for i = 1, #zone.points do
        local p1 = zone.points[i]
        local p2 = zone.points[i + 1] or zone.points[1]
        DrawLine(p1.x, p1.y, z, p2.x, p2.y, z, debugColor.r, debugColor.g, debugColor.b, debugColor.a)
    end
end

local function StartShootingBlock()
    if shootingBlockThread then return end

    shootingBlockThread = CreateThread(function()
        while currentZone do
            local zone = Config.Zones[currentZone]
            if not zone or (zone.options and zone.options.Shooting == false) then
                DisablePlayerFiring(PlayerId(), true)
                SetCanAttackFriendly(NAGE.PlayerPedID(), false, false)
                NetworkSetFriendlyFireOption(false)
                Wait(0)
            else
                break
            end
        end

        DisablePlayerFiring(PlayerId(), false)
        SetCanAttackFriendly(NAGE.PlayerPedID(), true, true)
        NetworkSetFriendlyFireOption(true)
        shootingBlockThread = nil
    end)
end

local function StartGhostCollision()
    if ghostCollisionThread then return end

    ghostCollisionThread = CreateThread(function()
        while currentZone do
            local playerPed = NAGE.PlayerPedID()
            for _, player in ipairs(GetActivePlayers()) do
                local otherPed = GetPlayerPed(player)
                if otherPed ~= playerPed and DoesEntityExist(otherPed) then
                    SetEntityNoCollisionEntity(playerPed, otherPed, true)
                end
            end
            Wait(100)
        end
        ghostCollisionThread = nil
    end)
end

local function StopGhostCollision()
    ghostCollisionThread = nil
end

local function ApplyOptions(options)
    local ped = NAGE.PlayerPedID()

    SetEntityInvincible(ped, options.GodMode or false)
    SetPlayerHealthRechargeMultiplier(PlayerId(), options.HealthRegeneration == false and 0.0 or 1.0)

    if options.Collision then
        StartGhostCollision()
    else
        StopGhostCollision()
    end

    if options.Shooting == false then
        StartShootingBlock()
    else
        if shootingBlockThread then
            shootingBlockThread = nil
            DisablePlayerFiring(PlayerId(), false)
            SetCanAttackFriendly(ped, true, true)
            NetworkSetFriendlyFireOption(true)
        end
    end
end

local function ResetOptions()
    local ped = NAGE.PlayerPedID()

    SetEntityInvincible(ped, false)
    SetPlayerHealthRechargeMultiplier(PlayerId(), 1.0)

    DisablePlayerFiring(PlayerId(), false)
    NetworkSetFriendlyFireOption(true)
    SetCanAttackFriendly(ped, true, true)
    SetEntityCanBeDamaged(ped, true)

    StopGhostCollision()

    if shootingBlockThread then
        shootingBlockThread = nil
        DisablePlayerFiring(PlayerId(), false)
        SetCanAttackFriendly(ped, true, true)
        NetworkSetFriendlyFireOption(true)
    end
end

function IsPointInPoly(point, poly)
    local inside = false
    local j = #poly

    for i = 1, #poly do
        local xi, yi = poly[i].x, poly[i].y
        local xj, yj = poly[j].x, poly[j].y

        if ((yi > point.y) ~= (yj > point.y)) and
            (point.x < (xj - xi) * (point.y - yi) / (yj - yi + 0.00001) + xi) then
            inside = not inside
        end
        j = i
    end

    return inside
end

function IsPlayerInZone(zone, playerPos)
    local pos2D = vector2(playerPos.x, playerPos.y)
    if not IsPointInPoly(pos2D, zone.points) then return false end
    return playerPos.z >= zone.minZ and playerPos.z <= zone.maxZ
end

CreateThread(function()
    while true do
        local sleep = 500
        local ped = NAGE.PlayerPedID()
        local pos = GetEntityCoords(ped)
        local foundZone = nil

        for zoneName, zone in pairs(Config.Zones) do
            if IsPlayerInZone(zone, pos) then
                foundZone = zoneName
                sleep = 0

                if currentZone ~= zoneName then
                    if currentZone then
                        local oldZone = Config.Zones[currentZone]
                        if oldZone.onExit then
                            oldZone.onExit()
                        end
                        ResetOptions()
                        if oldZone.debug then
                            print("🔴 " .. string.format(locale["debug_zone_exited"], currentZone))
                        end
                        if Config.Debug then
                            print("^4[Nage Core]^7 ^5[ZONE]^7: " .. string.format(locale["debug_zone_exited"], currentZone))
                        end
                    end

                    currentZone = zoneName
                    if zone.onEnter then
                        zone.onEnter()
                    end
                    ApplyOptions(zone.options or {})
                    if zone.debug then
                        print("🟢 " .. string.format(locale["debug_zone_entered"], zoneName))
                    end
                    if Config.Debug then
                        print("^4[Nage Core]^7 ^1[ZONE]^7: " .. string.format(locale["debug_zone_entered"], zoneName))
                    end
                end
                break
            end
        end

        if not foundZone and currentZone then
            local oldZone = Config.Zones[currentZone]
            if oldZone.onExit then
                oldZone.onExit()
            end
            if oldZone.debug then
                print("🔴 " .. string.format(locale["debug_zone_exited"], currentZone))
            end
            if Config.Debug then
                print("^4[Nage Core]^7 ^5[ZONE]^7: " .. string.format(locale["debug_zone_exited"], currentZone))
            end
            ResetOptions()
            currentZone = nil
        end

        Wait(sleep)
    end
end)

CreateThread(function()
    local anyDebugZones = false
    for _, zone in pairs(Config.Zones) do
        if zone.debug then
            anyDebugZones = true
            break
        end
    end

    if not anyDebugZones then return end

    while true do
        for _, zone in pairs(Config.Zones) do
            if zone.debug then DrawZone(zone) end
        end
        Wait(100)
    end
end)
