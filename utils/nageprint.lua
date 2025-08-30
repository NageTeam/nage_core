local Config = {
    DebugMode = true,
    Colors = {
        core = "^5",
        info = "^4",
        warn = "^3",
        error = "^1",
        success = "^2",
        text = "^7",
        reset = "^9",
        clothing = "^6",
        debug = "^3"
    }
}

_G.NagePrint = function(type, text, ...)
    if not Config.DebugMode then return end
    local t = (type or "info"):lower()
    local typeColor = Config.Colors[t] or Config.Colors.info
    local coreColor = Config.Colors.core
    local textColor = Config.Colors.text

    local message = text
    if select("#", ...) > 0 then
        message = string.format(text, ...)
    end

    print(string.format("%s[Nage Core]%s %s[%s]%s%s: %s%s",
        coreColor, Config.Colors.reset,
        typeColor, t:upper(), Config.Colors.reset,
        textColor,
        message, Config.Colors.reset
    ))
end

_G.NagePrintSection = function(title)
    local coreColor = Config.Colors.core
    local textColor = Config.Colors.text
    print(string.format("%s[Nage Core]%s %s================ %s ================%s",
        coreColor, Config.Colors.reset,
        textColor, title, Config.Colors.reset
    ))
end
