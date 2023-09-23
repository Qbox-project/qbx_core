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
    'client/*',
    'bridge/qb/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*',
    'bridge/qb/server.lua'
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
