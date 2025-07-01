nage = nage or {}
or {}

---@param data table
---@field title string
---@field description string
---@field type string
---@field position string
---@field duration number
---@field icon string
---@field iconcolor string

function nage.notify(data)
    TriggerEvent("nage_notify:notify", data)
end

