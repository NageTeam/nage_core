RegisterNetEvent("nage_notify:notify", function(data)
    SendNUIMessage({
        action = "notify",
        title = data.title or "Nage Core",
        description = data.description or "",
        type = data.type or "info",
        position = data.position or "top",
        duration = data.duration or 3500,
        icon = data.icon or "",
        iconColor = data.iconColor,
    })
end)
