fx_version 'cerulean'
game 'gta5'

description 'ESX Emergency System mit ox_lib, Notrufannahme, Discord Logs, GPS Auswahl, Blips, Rückruf'
author 'Edin'

shared_script '@es_extended/imports.lua'
shared_script 'config.lua'

client_scripts {
    '@ox_lib/init.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}
