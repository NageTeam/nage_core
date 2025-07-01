# Welcome to Nage Core, perfect to PVP

## License
This project is licensed under the Nage Core License.

## Clothing
----------------------------------------------------------------------

## Pure-Clothing

1. Open `config.lua` and set:
   Config.Framework = "standalone"

2. Go to `server/framework/standalone/sv_functions.lua`
   Find the function `getPlayerUniqueId(source)` and replace it with:

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

3. Restart the pure-clothing resource or your server.

## Links
----------------------------------------------------------------------
- [Documentation](https://nage-core.gitbook.io/nage-core/)
  - For installation, setup, and everything else.
- [txAdmin recipe](https://github.com/NageTeam/txAdminRecipe)
  - Install and configure Nage Core
- [Discord](discord.gg/ddMtV2CwJj)
  - For quick support and talking with our community