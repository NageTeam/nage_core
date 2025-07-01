Citizen.CreateThread(function()
    local hashKeys = {
        GetHashKey("mp0_shooting_ability"),
        GetHashKey("mp1_shooting_ability"),
        GetHashKey("mp2_shooting_ability"),
        GetHashKey("mp3_shooting_ability"),
        GetHashKey("sp0_shooting_ability"),
        GetHashKey("sp1_shooting_ability"),
        GetHashKey("sp2_shooting_ability"),
        GetHashKey("sp3_shooting_ability")
    }

    for _, hashKey in ipairs(hashKeys) do
        StatSetInt(hashKey, 100, true)
    end
end)
