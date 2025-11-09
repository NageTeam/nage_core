local Config = {
    Colors = {
        core = "^5",
        info = "^4",
        warn = "^3",
        error = "^1",
        success = "^2",
        text = "^7",
        reset = "^9",
        clothing = "^6",
        debug = "^3",
        log = "^9",
    }
}

_G.NagePrint = function(type, text, ...)
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
