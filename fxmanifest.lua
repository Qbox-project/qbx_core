fx_version 'cerulean'
game 'gta5'

description 'QBX-Core'
version '1.0.0'

shared_scripts {
    'config.lua',
    'shared/*.lua',
    'locale/en.lua',
    'locale/*.lua',
    '@ox_lib/init.lua',
    'import.lua'
}

client_scripts {
    'client/main.lua',
    'client/functions.lua',
    'client/loops.lua',
    'client/events.lua',
    'client/drawtext.lua',
    'client/character.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/functions.lua',
    'server/player.lua',
    'server/events.lua',
    'server/commands.lua',
    'server/exports.lua',
    'server/debug.lua',
    'server/loops.lua',
    'server/storage.lua',
    'server/character.lua'
}

modules {
    'utils'
}

files {
    'modules/*.lua'
}

dependency 'oxmysql'
provide 'qb-core'
lua54 'yes'
use_experimental_fxv2_oal 'yes'
