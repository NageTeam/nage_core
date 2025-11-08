# Nage Core - Perfect for PvP

Welcome to **Nage Core**, a lightweight framework designed for fast, reliable PVP servers.

---

## License
This project is licensed under the **Nage Core License**.  
Refer to the license file before using or distributing this resource.

---

## Clothing Integration

### Pure-Clothing Setup

> Follow these steps to enable Pure-Clothing in standalone mode.

1. Open **`config.lua`** and set:
   ```lua
   Config.Framework = "standalone"
   ```
2. Nagivate to server/framework/standalone/sv_functions.lua and replace the `getPlayerUniqueId(source)` with:
   ```
   NAGE = exports['nage']:getSharedCode()
   
   function getPlayerUniqueId(source)
       if not source then return false end

       local identifiers = NAGE.GetIdentifier(source)
       for _, id in ipairs(identifiers) do
           if string.sub(id, 1, string.len("license:")) == "license:" then
               return id
           end
       end

       return false
   end
   ```
2. Restart the server or script

---

# Links
- [Documentation](https://nage-core.gitbook.io/nage-core/) 
- [txAdmin recipe](https://github.com/NageTeam/txAdminRecipe)
- [Discord](discord.gg/ddMtV2CwJj)

