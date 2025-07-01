Config = {}

Config.Debug = false                       -- Use this for debugging the core
Config.Locale = "en"                       -- Set locale/language (en/da)
Config.Money = 2500                        -- The starting money you get when joining for the first time
Config.Spawn = {                           -- Where you will spawn when you join
    x = -413.1252,
    y = 1168.0978,
    z = 325.8542,
    w = 344.3802
}

Config.Disable = {
    Wanted = true,                        -- Disable Wanted Level
    NPC = true,                           -- Removes all NPCs
    InfStamina = true,                    -- Infinite stamina
    AmmoDisplay = false,                  -- Disable top-right ammo display (takes a bit performance)
    AimAssist = true,                     -- Disable controller AimAssist
    HealthRegeneration = true,            -- No auto-healing
    Minimap = true,                       -- Disable minimap
    GhostPeak = true,                     -- Prevent shooting through walls
    MagicBullet = false                   -- Make players not able to shoot though walls (WORK IN PROGRESS)  
}

Config.Ranks = {
    Admins = { 'owner', 'admin' },
    Ranks = { 'owner', 'admin', 'mod', 'user' }
}

Config.Zones = {
    ["spawn"] = {
        debug = false,
        points = {
            vector2(-430.0104, 1183.6840),
            vector2(-445.2907, 1127.0479),
            vector2(-406.8774, 1116.3931),
            vector2(-390.9230, 1172.6416)
        },
        options = {
            Shooting = false,            -- Enable Shooting inside the zone
            GodMode = true,              -- Enable Godmode inside the zone
            HealthRegeneration = false,  -- Enable auto-healing inside the zone
            Collision = true             -- Enable Collisions (For players)
        },
        minZ = 0.0,
        maxZ = 800.0,
        onEnter = function()
            print("Entered Spawn, super crazy overrated enter")
            nage.notify({
                title = 'Nage Zones',
                description = 'You entered the safezone',
                type = 'success'
            })
        end,
        onExit = function()
            print("Exited Spawn, super crazy overrated exit")
            nage.notify({
                title = 'Nage Zones',
                description = 'You left the safezone',
                type = 'error'
            })
        end
    }
    -- Add / Remove zones
}

Config.DiscordActivity = {
    appId = YOUR_BOT_CLIENT_ID,         -- Discord Bot Client ID
    assetName = "LargeIcon",
    assetText = "Nage Core",
    buttons = {
        { 
            label = "Join Server", 
            url = "fivem://connect/67mxv7" 
        },
        { 
            label = "Discord", 
            url = "https://discord.gg/8gj6tHPj8F" 
        }
    },
    presence = "[{player_id}] Nage Core | {online_players}/5 | In queue: {queue_number}",
    refresh = 1 * 60 * 1000
}
