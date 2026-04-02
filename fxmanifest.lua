fx_version 'cerulean'
game      'gta5'
lua54     'yes'

name        'pr_menu'
author      'PR'
version     '1.0.0'
description 'Sistema de gerenciamento de veículo e jogador via ox_target'

shared_scripts {
    '@ox_lib/init.lua',
    'config/config.lua',
}

client_scripts {
    'client/target.lua',
}

server_scripts {
    'server/target.lua',
}

dependency 'ox_lib'
dependency 'ox_target'
