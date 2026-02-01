fx_version 'cerulean'
game 'gta5'

author 'Lxy'
description 'Standalone Vehicle Mileage System'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua', -- Optional: If we want to use ox_lib features later, otherwise bridge handles it
    'config.lua'
}

client_scripts {
    'client/bridge.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/bridge.lua',
    'server/main.lua'
}

dependencies {
    'oxmysql'
}
