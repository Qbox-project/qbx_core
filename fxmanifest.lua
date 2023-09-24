fx_version 'cerulean'
game 'gta5'

description 'QBX-Core'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/locale.lua',
    'locale/en.lua',
    'locale/*.lua',
    'shared/main.lua',
    'import.lua'
}

client_scripts {
    'client/main.lua',
    'client/loops.lua',
    'client/events.lua',
    'client/drawtext.lua',
    'client/character.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/events.lua',
    'server/commands.lua',
    'server/debug.lua',
    'server/loops.lua',
    'server/storage.lua',
    'server/character.lua'
}

modules {
    'utils'
}

files {
    'modules/*.lua',
    'config.lua',
    'shared/gangs.lua',
    'shared/items.lua',
    'shared/jobs.lua',
    'shared/locations.lua',
    'shared/vehicles.lua',
    'shared/weapons.lua',
    'server/functions.lua',
    'server/player.lua',
    'client/functions.lua',
}

dependency 'oxmysql'
provide 'qb-core'
lua54 'yes'
use_experimental_fxv2_oal 'yes'
