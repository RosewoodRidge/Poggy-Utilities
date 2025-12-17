Config = Config or {}

Config.PoggyDebug = {
    Enabled = true,       -- Master toggle ENABLED for debugging
    LogToConsole = true,  -- Print debug messages to console

    Categories = {       -- Toggle specific debug categories
        CORE = false,
        WEAPON = false,
        WEAPON_JAM = true,
        WEAPON_JAM_FIRE = true, 
        PLAYER = false,
        UTILS = false,
        EXPORTS = false,
        OBJECT_REMOVAL = false,
        MUSIC = false
    },

    Level = {            -- Toggle specific log levels
        TRACE = true,    -- Enable TRACE for detailed loop info
        INFO = true,
        WARNING = true,
        ERROR = true     
    }
}

Config.WeaponJam = {
    Enabled = true, -- Master switch for the weapon jamming feature
    JamCheckInterval = 250, -- Milliseconds between jam checks when player is shooting
    JamStartThreshold = 0.2, -- Degradation value (0.0 to 1.0) at which jamming can start. Default: 0.1
    JamChanceExponent = 1.5, -- Controls how steeply the jam chance increases with degradation. Higher values = steeper curve.
    MaxJamProbability = 0.25, -- Maximum probability of a jam occurring (0.0 to 1.0). Default: 0.5 (50%)
    CleanlinessCheckInterval = 5000, -- Milliseconds between checking if jammed weapons are now clean
    UnjamThreshold = 0.05, -- If weapon degradation is below this value, a jammed weapon will be automatically unjammed
    
    -- Jam Sound Configuration
    JamSound = {
        Enabled = true, -- Play sound when weapon jams
        Gain = 0.3, -- Volume/gain of the jam sound (0.0 to 1.0)
        MaxDistance = 50.0, -- Maximum distance (in meters) at which the jam sound can be heard
        Falloff = 2.0, -- Volume falloff exponent (2.0 = realistic inverse square law, 1.0 = linear)
        Sounds = { -- List of sound files to randomly play on jam (relative to ui/sfx/weaponjam/)
            "gun_empty1.wav",
            "gun_empty2.wav",
            "gun_empty3.wav"
        }
    },
    
    GunsToJam = {
        "WEAPON_PISTOL_SEMIAUTO", "WEAPON_PISTOL_MAUSER", "WEAPON_PISTOL_VOLCANIC",
        "WEAPON_PISTOL_M1899", "WEAPON_REVOLVER_SCHOFIELD", "WEAPON_REVOLVER_NAVY",
        "WEAPON_REVOLVER_NAVY_CROSSOVER", "WEAPON_REVOLVER_LEMAT", "WEAPON_REVOLVER_DOUBLEACTION",
        "WEAPON_REVOLVER_CATTLEMAN", "WEAPON_REVOLVER_CATTLEMAN_MEXICAN", "WEAPON_RIFLE_VARMINT",
        "WEAPON_REPEATER_WINCHESTER", "WEAPON_REPEATER_HENRY", "WEAPON_REPEATER_EVANS",
        "WEAPON_REPEATER_CARBINE", "WEAPON_SNIPERRIFLE_ROLLINGBLOCK", "WEAPON_SNIPERRIFLE_CARCANO",
        "WEAPON_RIFLE_SPRINGFIELD", "WEAPON_RIFLE_ELEPHANT", "WEAPON_RIFLE_BOLTACTION",
        "WEAPON_SHOTGUN_SEMIAUTO", "WEAPON_SHOTGUN_SAWEDOFF", "WEAPON_SHOTGUN_REPEATING",
        "WEAPON_SHOTGUN_DOUBLEBARREL_EXOTIC", "WEAPON_SHOTGUN_PUMP", "WEAPON_SHOTGUN_DOUBLEBARREL"
    }
}

-- Object removal configuration
Config.ObjectRemoval = {
    Enabled = true,                   -- Master toggle for object removal feature
    IntervalMinutes = 1,              -- Check every X minutes for objects to remove
    Objects = {
        "s_coachlock02x"              -- Default object model to remove
    },
    AdminGroups = {"admin", "superadmin", "moderator"}, -- Groups that can use the removeobjects command
    
    -- Dead entity cleanup settings
    DeadEntityCleanup = {
        Enabled = true,               -- Master toggle for dead entity cleanup
        IntervalMinutes = 60,         -- Check every X minutes for dead entities
        CleanPeds = true,             -- Remove dead NPCs (not players)
        CleanHorses = true,           -- Remove dead horses
        CleanAnimals = true,          -- Remove dead animals (deer, wolves, etc.)
        CleanWagons = true            -- Remove abandoned wagons
    }
}

-- Music Zone configuration
Config.MusicZones = {
    Enabled = true,                    -- Master toggle for music zones
    UnloadDistance = 100.0,            -- Distance to unload the video completely (save resources)
    Quality = 'small',                 -- YouTube quality: 'small' (240p), 'medium' (360p), 'large' (480p), 'hd720', 'hd1080', 'highres'
    VolumeMultiplier = 0.5,            -- Global volume multiplier (0.0 - 1.0)
    Falloff = 2.0,                     -- Volume falloff exponent (2.0 = realistic inverse square law, 1.0 = linear)
    DirectionalAudio = true,           -- Simulate 3D audio by lowering volume when looking away
    Zones = {
        {
            name = "Sousa Marches",
            youtubeId = "h8RnD9Qz1tI",
            radius = 50.0,
            volume = 0.25,
            loop = true,
            timestamps = {
                0,    -- 0:00 - Semper Fidelis (1888)
                164,  -- 2:44 - The Thunderer (1889)
                328,  -- 5:28 - The Washington Post (1889)
                481,  -- 8:01 - The High School Cadets (1890)
                635,  -- 10:35 - The Liberty Bell (1893)
                848,  -- 14:08 - Manhattan Beach (1893)
                981,  -- 16:21 - El Capitan (1896)
                1118, -- 18:38 - The Stars and Stripes Forever (1896)
                1331, -- 22:11 - Hands Across the Sea (1899)
                1497  -- 24:57 - The Invincible Eagle (1901)
            },
            locations = {
                vector3(2401.08, -1115.61, 46.52)
            }
        }
    }
}

-- Area of Play (AOP) configuration
Config.AOP = {
    Enabled = true,                    -- Master toggle for AOP display
    UpdateInterval = 20,               -- Seconds between automatic zone updates (changed from 120 to 20)
    SearchRadius = 1000.0,              -- Meters to search for nearest zone node
    Zones = {
        {
            name = "Valentine Zone",
            coords = vector3(-300.32, 790.24, 118.16)
        },
        {
            name = "Strawberry Zone",
            coords = vector3(-1790.0, -390.0, 160.0)
        },
        {
            name = "Rhodes Zone",
            coords = vector3(1360.0, -1300.0, 77.0)
        },
        {
            name = "Blackwater Zone",
            coords = vector3(-813.0, -1324.0, 44.0)
        },
        {
            name = "Saint Denis Zone",
            coords = vector3(2439.69, -1185.52, 46.66)
        },
        {
            name = "Armadillo Zone",
            coords = vector3(-3685.0, -2623.0, -13.0)
        },
        {
            name = "Tumbleweed Zone",
            coords = vector3(-5512.0, -2950.0, -2.0)
        },
        {
            name = "Emerald Ranch Zone",
            coords = vector3(1426.88, 328.73, 88.44)
        },
        {
            name = "Van Horn Zone",
            coords = vector3(2974.0, 570.0, 44.0)
        },
        {
            name = "Annesburg Zone",
            coords = vector3(2930.0, 1290.0, 44.0)
        }
    }
}

