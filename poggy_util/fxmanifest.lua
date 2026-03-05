fx_version 'cerulean'
games { 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'
author 'Poggy'
description 'Various utilities for RedM servers'
version '1.2.0'

shared_scripts {
    'config.lua',
    'config_help.lua',
    'exports.lua',
    'shared/*.lua'  -- Framework detection (must load before client/server)
}

client_scripts {
    'client/cl_framework.lua',  -- Framework bridge (load first)
    'client/cl_notifications.lua',  -- Notifications (load second)
    'client/*.lua'  -- Other client scripts
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',  -- Database (optional, for standalone mode)
    'server/sv_framework.lua',  -- Framework bridge (load first)
    'server/*.lua'  -- Other server scripts
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/music.css',
    'ui/finder.css',
    'ui/finder.js',
    'ui/sell.css',
    'ui/sell.js',
    'ui/sounds.js',
    'ui/*',
    'ui/img/**/*',
    'ui/sfx/**/*'
}

escrow_ignore {
    'config.lua',
    'exports.lua'
}