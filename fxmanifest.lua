fx_version 'cerulean'
game 'gta5'

description 'QBX_Core'
repository 'https://github.com/Qbox-project/qbx_core'
version '1.3.2'

shared_scripts {
    '@ox_lib/init.lua',
    'modules/utils.lua',
    'shared/locale.lua',
    'locale/en.lua',
    'locale/*.lua',
}

client_scripts {
    'modules/utils.lua',
    'client/main.lua',
    'client/functions.lua',
    'client/loops.lua',
    'client/events.lua',
    'client/character.lua',
    'client/discord.lua',
    'bridge/qb/client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/functions.lua',
    'server/player.lua',
    'server/events.lua',
    'server/commands.lua',
    'server/loops.lua',
    'server/storage.lua',
    'server/character.lua',
    'bridge/qb/server/main.lua',
}

files {
    'modules/*.lua',
    'shared/gangs.lua',
    'shared/items.lua',
    'shared/jobs.lua',
    'shared/locations.lua',
    'shared/main.lua',
    'shared/vehicles.lua',
    'shared/weapons.lua',
    'bridge/qb/client/functions.lua',
    'bridge/qb/client/drawtext.lua',
    'bridge/qb/client/events.lua',
    'bridge/qb/shared/main.lua',
    'bridge/qb/shared/export-function.lua',
    'config/client.lua',
    'config/shared.lua'
}

dependencies {
    'ox_lib',
    'oxmysql',
}

provide 'qb-core'
lua54 'yes'
use_experimental_fxv2_oal 'yes'
