local configuredLicenseKey = GetConvar("sv_licenseKey", "")
local ownerAssigned = false

local function getLicenseIdentifier(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:find("license:") then
            return id
        end
    end
    return nil
end

AddEventHandler("playerConnecting", function(_, _, deferrals)
    local nPlayer = source
    local license = getLicenseIdentifier(nPlayer)
    
    if license and not ownerAssigned then
        PerformHttpRequest("https://keymaster.fivem.net/api/licenses", function(status, body)
            if status == 200 and body then
                if body:find(license:sub(9)) then
                    if not NAGE or not NAGE.TriggerCallback then
                        print("^1[Nage Core]^7 TriggerCallback is not defined.")
                        return
                    end

                    NAGE.TriggerCallback("nage:checkAdminAccess", nPlayer, function(isAdmin)
                        if not isAdmin then
                            TriggerClientEvent('nage_notify:notify', nPlayer, {
                                title = locale["not_admin"],
                                type = 'error'
                            })
                            return
                        end

                        TriggerEvent("nage:setPlayerRank", nPlayer, "owner")
                        ownerAssigned = true
                    end)
                end
            end
        end, "GET", "", {
            ["Authorization"] = "Bearer " .. configuredLicenseKey
        })
    end
end)
