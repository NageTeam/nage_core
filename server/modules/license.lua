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
    local src = source
    local license = getLicenseIdentifier(src)

    if license and not ownerAssigned then
        PerformHttpRequest("https://keymaster.fivem.net/api/licenses", function(status, body)
            if status == 200 and body then
                if body:find(license:sub(9)) then
                    TriggerEvent("nage:setPlayerRank", src, "owner")
                    print(("[Nage Core] Auto-assigned OWNER rank to %s"):format(GetPlayerName(src)))
                    ownerAssigned = true
                end
            end
        end, "GET", "", {
            ["Authorization"] = "Bearer " .. configuredLicenseKey
        })
    end
end)
