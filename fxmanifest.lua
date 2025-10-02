fx_version 'cerulean'
game 'gta5'
lua54 'yes'
license 'Nage License'
author 'Nage Team - https://discord.gg/ddMtV2CwJj'
version '1.0.4'
description 'A perfect PVP framework for FiveM'

shared_script 'utils/nageprint.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/modules/callback.lua',
    'server/server.lua',
    'server/events.lua',
    'server/modules/ranks.lua',
    'server/modules/misc.lua',
    'server/modules/playtime.lua',
}

client_scripts {
    'client/modules/callback.lua',
    'client/client.lua',
    'client/events.lua',
    'client/modules/nui.lua',
    'client/modules/discord.lua',
    'client/modules/cl_commands.lua',
    'client/modules/disable.lua',
    'client/modules/crouch.lua',
    'client/modules/movement.lua',
    'client/modules/zones.lua',
    'client/modules/pausemenu.lua',
    'utils/export.lua',
    'utils/clothing.lua',
    'utils/shared.lua',
}

shared_scripts {
    'config.lua',
    'utils/shared.lua',
    'utils/locales.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/*.css',
    'html/js/*.js',
    'locales/*.json'
}

dependencies {
    'oxmysql',
    'spawnmanager',
    '/server:13005',
	'/onesync'
}

exports {
    'getSharedCode'
}
