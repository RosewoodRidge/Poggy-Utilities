Config = Config or {}

Config.PoggyDebug = {
    Enabled = false,       -- Master toggle ENABLED for debugging
    LogToConsole = true,  -- Print debug messages to console

    Categories = {       -- Toggle specific debug categories
        CORE = false,
        WEAPON = false,
        WEAPON_JAM = false,
        WEAPON_JAM_FIRE = false, 
        PLAYER = false,
        UTILS = false,
        EXPORTS = false,
        OBJECT_REMOVAL = false,
        HORSE = false,
        MUSIC = false,
        ARMOR = false         -- Armor protection system debugging
    },

    Level = {            -- Toggle specific log levels
        TRACE = false,    -- Enable TRACE for detailed loop info
        INFO = false,
        WARNING = false,
        ERROR = false     
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

-- Government Stipend Configuration
Config.Stipend = {
    Enabled = true,
    IntervalMinutes = 60,              -- How often to check/pay (in minutes)
    BasePay = 5.00,                    -- Base payment amount
    IncreaseAmount = 0.25,             -- Amount to increase pay by
    IncreaseIntervalDays = 30,         -- Days required for each pay increase
    MinimumTenureDays = 30,            -- Minimum days on server to be eligible
    UnemployedJobName = "unemployed",  -- Job name to check for (case-insensitive)
    LegacyDate = "2025-11-01 00:00:00" -- Default creation date for existing characters (YYYY-MM-DD HH:MM:SS)
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
        Enabled = false,               -- Master toggle for dead entity cleanup
        IntervalMinutes = 60,         -- Check every X minutes for dead entities
        CleanPeds = true,             -- Remove dead NPCs (not players)
        CleanHorses = true,           -- Remove dead horses
        CleanAnimals = true,          -- Remove dead animals (deer, wolves, etc.)
        CleanWagons = true            -- Remove abandoned wagons
    }
}

-- Armor Protection configuration
-- When enabled, any shot that lands on the torso / chest / abdomen bone zone
-- while the player has a clothing component equipped in the native "armor" slot
-- is fully blocked (health is immediately restored to its pre-shot value).
-- The "armor" slot is the dedicated RDR3 body-armour clothing category used by
-- vorp_character, jo_libs, and the jo_clothingstore / kd systems.
Config.ArmorProtection = {
    Enabled = false,               -- Master toggle for the armor protection feature

    -- Minimum HP drop (before it's treated as a real shot rather than a
    -- health-tick fluctuation).  Keep this low (1–2) for all bullet types.
    MinDamageThreshold = 1,

    -- Player-facing notification when armor absorbs a hit
    NotifyPlayer     = false,
    NotifyMessage    = "Your armor absorbed the hit!",
    NotifyDuration   = 2500,       -- ms to display the notification (absorbed hit)
    NotifyCooldown   = 3000,       -- ms between notifications (prevents spam on rapid fire)

    -- ── Durability system ──────────────────────────────────────────────────
    -- The armor starts at MaxShots. Each absorbed chest/abdomen shot costs 1.
    -- When shots reach 0 the armor stops blocking damage entirely.
    -- To repair, the player uses RepairKitItem from their VORP inventory.
    MaxShots     = 10,             -- Total absorbed hits before armor breaks
    ShotsPerStage = 2,             -- Absorbed hits consumed per tank-image stage (10 stages total)
    RepairKitItem = "armor_kit",   -- VORP inventory item name for the repair kit
    RepairTime    = 8000,          -- ms for the repair animation + progress bar

    -- ── HUD – armor durability indicator ─────────────────────────────────
    -- Displays rpg_tank_1 … rpg_tank_10 (or empty_bg when broken) at a
    -- fixed corner of the screen.  All position values are CSS strings.
    HUD = {
        Enabled     = true,
        Bottom      = "80px",      -- distance from the bottom edge
        Left        = "30px",      -- distance from the left edge
        Right       = nil,         -- set this (and clear Left) to anchor to the right side
        ImageWidth  = "44px",      -- reduced circle size (was 80px)
        ImageHeight = "44px",
        ShieldSize  = "25px",      -- size of the armor.png shield icon in the center
    },

    -- ── Repair progress bar position ──────────────────────────────────────
    RepairBar = {
        Bottom = "90px",           -- distance from the bottom edge (centered horizontally)
        Width  = "300px",          -- width of the progress bar widget
    },
}

-- Music Zone configuration
Config.MusicZones = {
    Enabled = false,                    -- Master toggle for music zones
    UnloadDistance = 100.0,            -- Distance to unload the video completely (save resources)
    Quality = 'small',                 -- YouTube quality: 'small' (240p), 'medium' (360p), 'large' (480p), 'hd720', 'hd1080', 'highres'
    VolumeMultiplier = 0.5,            -- Global volume multiplier (0.0 - 1.0)
    Falloff = 2.0,                     -- Volume falloff exponent (2.0 = realistic inverse square law, 1.0 = linear)
    DirectionalAudio = true,           -- Simulate 3D audio by lowering volume when looking away
    Zones = {
        --[[{
            name = "Christmas Ambience",
            youtubeId = "6SlwnNKsidw",   -- YouTube video ID
            radius = 70.0,               -- Audible radius
            volume = 0.2,
            loop = true,
            -- List of timestamps (in seconds) to randomly start the video at
            timestamps = {
                0,    -- [00:00] Jingle Bells
                61,   -- [01:01] We Wish You a Merry Christmas
                132,  -- [02:12] Deck The Halls
                221,  -- [03:41] Adeste Fideles
                359,  -- [05:59] Silent Night
                522,  -- [08:42] Joy to the World
                615,  -- [10:15] It Came Upon the Midnight Clear
                705,  -- [11:45] Oh, Little Town of Bethlehem
                813,  -- [13:33] The First Noel
                916,  -- [15:16] O Christmas Tree
                1003, -- [16:43] Hark! The Herald Angels Sing
                1160, -- [19:20] Away in a Manger
                1246, -- [20:46] What Child Is This
                1358, -- [22:38] God Rest Ye, Merry Gentlemen
                1473, -- [24:33] Angels, We Have Heard On High
                1620, -- [27:00] Every Year Again
                1815, -- [30:15] Good King Wenceslas
                1866, -- [31:06] We Three Kings
                1935, -- [32:15] Up on the House Top
                2008, -- [33:28] Oh Come Little Children
                2150, -- [35:50] Jolly Old Saint Nicholas
                2191, -- [36:31] Lo, How a Rose E'er Blooming
                2436, -- [40:36] While Shepherds Watched Their Flocks By Night
                2543, -- [42:23] From Heaven Above to Earth I Come
                2717, -- [45:17] Maria Walks Amid the Thorns
                2879  -- [47:59] Ich Steh an Deiner Krippen Hier
            },
            -- Define multiple locations for the same music track
            locations = {
                vector3(-1813.49, -420.13, 159.25), -- Strawberry
                vector3(-799.62, -1299.16, 43.52),   -- Blackwater Main Road
                vector3(1337.78, -1376.93, 80.48) -- Rhodes Saloon
            }
        },
        {
            name = "Christmas Ambience 2",
            youtubeId = "qxR5ISPkhM0",   -- YouTube video ID
            radius = 70.0,               -- Audible radius
            volume = 0.2,
            loop = true,
            timestamps = {
                0,    -- 0:00:00 Angels We Have Heard on High
                153,  -- 0:02:33 Quanno Nascete Ninno
                295,  -- 0:04:55 Away in a Manger
                433,  -- 0:07:13 Away in a Manger
                557,  -- 0:09:17 The Carol of the Drum
                682,  -- 0:11:22 Joy to the World
                755,  -- 0:12:35 Ding Dong Merrily on High
                872,  -- 0:14:32 Deck the Halls
                965,  -- 0:16:05 We Wish You a Merry Christmas
                1135, -- 0:18:55 Bell Carol / In Dulci Jubilo
                1343, -- 0:22:23 Bring a Torch, Jeanette, Isabella
                1485, -- 0:24:45 Listen, Lordlings, Unto Me
                1560, -- 0:26:00 Verbum Caro Factum Est
                1628, -- 0:27:08 Carol of the Bells
                1737, -- 0:28:57 The Coventry Carol
                1876, -- 0:31:16 The Coventry Carol - Lully, Lullay
                2034, -- 0:33:54 God Rest You Merry Gentlemen
                2149, -- 0:35:49 O Come, O Come, Emmanuel
                2342, -- 0:39:02 Adeste Fideles (O Come All Ye Faithful)
                2478, -- 0:41:18 O Holy Night
                2722, -- 0:45:22 Silent Night
                2993, -- 0:49:53 Greensleeves (What Child Is This)
                3277, -- 0:54:37 The First Noel
                3417, -- 0:56:57 The Lord’s Prayer
                3588, -- 0:59:48 Amazing Grace
                3971, -- 1:06:11 Cantata BWV 147: Jesu, Joy of Man’s Desiring
                4228, -- 1:10:28 Hark! The Herald Angels Sing
                4371, -- 1:12:51 O Shepherds, Leave Your Sheep
                4455, -- 1:14:15 Lo, How a Rose E’er Blooming
                4663, -- 1:17:43 Sing We Now of Christmas
                4942, -- 1:22:22 Gaudete
                5009, -- 1:23:29 The Gloucestershire Wassail
                5085  -- 1:24:45 Here We Come A-Caroling
            },
            locations = {
                vector3(-182.09, 645.21, 113.58), -- Valentine Train Station 
                vector3(-308.68, 803.16, 118.98), -- Valentine Saloon
                vector3(1307.78, -1293.46, 75.91), -- Rhodes Square
                vector3(1423.28, 281.79, 89.55) -- Emerald Ranch
            }
        },
        {
            name = "Christmas Ambience 3",
            youtubeId = "OChjkM5V_DU",   -- YouTube video ID
            radius = 70.0,               -- Audible radius
            volume = 0.25,
            loop = true,
            timestamps = {
                0,    -- 0:00 O Holy Night
                284,  -- 4:44 Away in a Manger
                484,  -- 8:04 O Come, All Ye Faithful
                705,  -- 11:45 Joy to the World
                913,  -- 15:13 Hark the Herald Angels Sing
                1105, -- 18:25 We Three Kings
                1288, -- 21:28 Angels We Have Heard on High
                1471, -- 24:31 First Noel
                1719, -- 28:39 Silent Night
                1896  -- 31:36 What Child is This
            },
            locations = {
                vector3(467.87, 2242.27, 248.29), -- Wapiti 
                vector3(-3706.76, -2598.68, -10.29), -- Armadillo Saloon
                vector3(2630.8, -1230.89, 54.19)   -- St Denis Saloon   
            }
        },
        {
            name = "Christmas Ambience 4",
            youtubeId = "ncjuqj0WN6s",
            radius = 10.0,
            volume = 0.2,
            loop = true,
            timestamps = {
                0,    -- 0:00 - Peder B. Helland - O Holy Night
                205,  -- 3:25 - Peder B. Helland - Hark! The Herald Angels Sing
                314,  -- 5:14 - Peder B. Helland - Auld Lang Syne
                410,  -- 6:50 - Peder B. Helland - In The Bleak Midwinter
                579,  -- 9:39 - Peder B. Helland - O Little Town of Bethlehem
                694,  -- 11:34 - Peder B. Helland - O Come All Ye Faithful
                742,  -- 12:22 - Peder B. Helland - Silent Night
                871,  -- 14:31 - Peder B. Helland - The First Noel
                984,  -- 16:24 - Peder B. Helland - God Rest Ye Merry, Gentleman
                1061, -- 17:41 - Peder B. Helland - Angels We Have Heard On High
                1184, -- 19:44 - Peder B. Helland - Angels of the Realm of Glory
                1299, -- 21:39 - Peder B. Helland - O Christmas Tree
                1394, -- 23:14 - Peder B. Helland - Away in a Manger
                1483  -- 24:43 - Peder B. Helland - We Wish You a Merry Christmas
            },
            locations = {
                vector3(2537.84, -1278.45, 49.22) -- Saint Denis Theater
            }
        },]]
        {
            name = "Sousa Marches",
            youtubeId = "h8RnD9Qz1tI",
            radius = 25.0,
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
        }--[[,
        {
            name = "Christmas Choir",
            youtubeId = "W3O-JLbu7qo",
            radius = 40.0,
            volume = 0.25,
            loop = true,
            timestamps = { 0 },
            locations = {
                vector3(-232.15, 801.13, 125.02)
            }
        }]]
    }
}

-- Unstuck configuration
Config.Unstuck = {
    Enabled = true,                    -- Master toggle for unstuck feature
    Command = "unstuck",               -- Command name to trigger unstuck
    DelaySeconds = 10,                 -- Seconds to wait before teleporting (player must stay still)
    MoveTolerance = 2.0                -- Distance (meters) player can drift before cancelling
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
