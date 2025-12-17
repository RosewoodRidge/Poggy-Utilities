fx_version 'cerulean'
games { 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'
author 'Poggy'
description 'Various utilities for RedM servers'
version '1.0.0'

shared_scripts {
    'config.lua',
    'exports.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/music.css',
    'ui/sounds.js',
    'ui/*',
    'ui/sfx/**/*'
}

escrow_ignore {
    'config.lua',
    'exports.lua'
}