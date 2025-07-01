local json = require("json")

local localeCache = {}

local function loadLocaleFile(localeName)
    local filePath = ("locales/%s.json"):format(localeName)
    local content = LoadResourceFile(GetCurrentResourceName(), filePath)

    if not content then
        print(("^1[Locale]^7 Missing locale file: %s"):format(filePath))
        return {}
    end

    local success, data = pcall(function()
        return json.decode(content)
    end)

    if not success then
        print(("^1[Locale]^7 Failed to parse locale file: %s"):format(filePath))
        return {}
    end

    return data
end

local locales = {}

function locales.new(localeName)
    if not localeCache[localeName] then
        localeCache[localeName] = loadLocaleFile(localeName)
    end

    local tbl = localeCache[localeName] or {}

    return setmetatable({}, {
        __index = function(_, key)
            local value = tbl[key]
            if not value then
                return "[Missing locale key: " .. tostring(key) .. "]"
            end
            return value
        end
    })
end

return locales
