# Poggy's Utilities (poggy_util)

A comprehensive utility resource for RedM servers, providing framework abstraction, notifications, and various quality-of-life features. **Works with VORP Core, RSG Core, QBCore, RedemRP, or standalone!**

## Features

### 1. Framework Abstraction Layer
Universal framework bridge that allows your scripts to work with ANY RedM framework:
- **Multi-Framework Support**: VORP Core, RSG Core, QBCore, RedemRP, or standalone
- **Automatic Detection**: Detects running framework automatically
- **Unified API**: Same function calls work across all frameworks
- **Database Support**: Direct database queries via oxmysql
- **Exports Available**: Easy integration for any script

### 2. Native Notifications System
A standalone notification system using native RedM UI — no external dependencies required!
- **Native UI**: Uses built-in game notifications (no HTML/CSS/NUI overhead)
- **Multiple Styles**: Tip, Top, Left, Right, Center, Advanced with icons, and more
- **VORP Compatible**: Registers handlers for `vorp:` events for backwards compatibility
- **Exports Available**: Easy-to-use exports for any script
- **Framework Agnostic**: Works standalone without requiring any framework

### 3. Area of Play (AOP) System
Automatically tracks where players are congregating and displays the current "Area of Play" on screen. **Enabled by default.**
- **Automatic Detection**: Calculates the most populated zone based on player locations
- **UI Display**: Shows the current zone name and player count
- **Configurable**: Zones can be added or modified in `config.lua`
- **Command**: `/aop` — Toggles the AOP display on/off

### 4. Weapon Jamming
Adds a realistic weapon jamming mechanic based on weapon degradation condition. **Enabled by default.**
- **Degradation Based**: The lower the weapon condition, the higher the jam chance
- **Sound Effects**: Plays a "click" sound when a weapon jams (positional, heard by nearby players too)
- **Configurable**: Adjust thresholds, probability curve, and which weapons can jam
- **Visual Feedback**: Prevents firing while the weapon is jammed

### 5. Government Stipend (Unemployment)
Provides financial support for unemployed characters, rewarding long-term play. **Enabled by default.**
- **Tenure Based**: Pay increases based on how many days the character has been on the server
- **Retroactive**: Automatically calculates tenure for existing characters using a configurable legacy date
- **Configurable**: Set base pay, increase amounts, intervals, minimum tenure, and job name

### 6. Object Removal & Dead Entity Cleanup
Keeps the server clean by removing unwanted objects and optionally dead entities. **Object removal enabled by default. Dead entity cleanup is disabled by default** — enable `Config.ObjectRemoval.DeadEntityCleanup.Enabled` if you want automatic corpse/wagon cleanup.
- **Object Removal**: Periodically removes specific object models (e.g., glitched coach locks). Add models to `Config.ObjectRemoval.Objects`.
- **Dead Entity Cleanup** *(optional, off by default)*: Removes dead NPCs, horses, animals, and abandoned wagons to save resources
- **Admin Commands**:
  - `/removeobjects [modelName]` — Manually trigger object removal
  - `/cleandead` — Manually trigger dead entity cleanup

### 7. Armor Protection *(optional, disabled by default)*
Grants physical armor protection based on a clothing slot item. **Disabled by default** — set `Config.ArmorProtection.Enabled = true` to activate.
- **Clothing-Based**: Detects when a player has an item equipped in the native RDR3 armor clothing slot (compatible with vorp_character, jo_libs, kd systems)
- **Damage Blocking**: Fully absorbs shots to the torso/chest/abdomen zone
- **Durability System**: Armor has a configurable number of absorption charges (`MaxShots`) before it breaks
- **Repair Kit**: Players can repair broken armor using an inventory item (`RepairKitItem`, default `"armor_kit"`)
- **HUD Indicator**: On-screen shield icon showing remaining armor durability (position is CSS-configurable)
- **Repair Bar**: Progress bar display during the repair animation

### 8. Music Zones *(optional, disabled by default)*
Plays ambient audio in specific map locations using YouTube. **Disabled by default** — set `Config.MusicZones.Enabled = true` and configure your zones to activate.
- **3D Audio**: Simulates distance falloff and directional audio (quieter when looking away)
- **Timestamps**: Can start tracks at random timestamps for variety
- **Command**: `/togglemusic` — Toggles music zones on/off per player
- **Configurable**: Add zones with a YouTube ID, radius, volume, and one or more `locations` vectors

### 9. Help System
Fully customizable in-game help guide accessible to all players.
- **Searchable**: Players can search across all categories
- **Content**: Configured entirely in `config_help.lua` — edit categories, sections, and items freely
- **Command**: `/help`

### 10. Unstuck
Teleports a player to the nearest road node after a short countdown. **Enabled by default.**
- **Safety Delay**: Player must remain stationary during the countdown or it cancels
- **Configurable**: Set delay time, command name, and movement tolerance in `config.lua`
- **Command**: `/unstuck` (default, configurable via `Config.Unstuck.Command`)

### 11. Debug System
Configurable server-side and client-side logging for developers.
- **Granular Control**: Toggle specific categories (`CORE`, `WEAPON`, `WEAPON_JAM`, `ARMOR`, `MUSIC`, etc.) and log levels (`INFO`, `TRACE`, `WARNING`, `ERROR`) independently in `config.lua`
- **Disabled by default**: Set `Config.PoggyDebug.Enabled = true` along with the specific categories/levels you want

---

## Default On / Default Off Quick Reference

| Feature | Default |
| :--- | :--- |
| Framework Bridge | ✅ Always active |
| Notifications | ✅ Always active |
| Area of Play (AOP) | ✅ On |
| Weapon Jamming | ✅ On |
| Government Stipend | ✅ On |
| Object Removal | ✅ On |
| Unstuck (`/unstuck`) | ✅ On |
| Help Guide (`/help`) | ✅ On |
| Dead Entity Cleanup | ⬜ Off — enable in `Config.ObjectRemoval.DeadEntityCleanup` |
| Armor Protection | ⬜ Off — enable in `Config.ArmorProtection` |
| Music Zones | ⬜ Off — enable in `Config.MusicZones` and add zones |
| Debug Logging | ⬜ Off — enable in `Config.PoggyDebug` |

---

## Installation

1. Place the `poggy_util` folder into your server's `resources` directory.
2. Add `ensure poggy_util` to your `server.cfg` **before** any scripts that depend on it.
3. Optional dependencies:
   - `oxmysql` — Required for the Government Stipend, Location Finder player-shop query, and all database exports
   - A supported framework (`vorp_core`, `rsg-core`, `qb-core`) — Required for player/character data exports

## Configuration

All primary settings live in `config.lua`. Help guide content is in `config_help.lua`.

- Every feature has an `Enabled` toggle — set it to `false` to fully disable that system
- Features that are **off by default** (Armor Protection, Music Zones, Dead Entity Cleanup) will not run any code until explicitly enabled
- **Weapon Jam**: Tune `JamStartThreshold`, `JamChanceExponent`, and `MaxJamProbability` for your preferred difficulty
- **Music Zones**: Add entries to `Config.MusicZones.Zones` — each zone needs a `youtubeId`, `radius`, `volume`, and a `locations` table of `vector3` values
- **Armor**: Set `RepairKitItem` to match whatever item name your inventory system uses for armor repair kits
- **Stipend**: Set `LegacyDate` to your server's approximate launch date so existing characters get correct tenure

## Commands

| Command | Side | Description |
| :--- | :--- | :--- |
| `/aop` | Player | Toggles the Area of Play UI on/off |
| `/unstuck` | Player | Teleports to nearest road after a countdown (stays still required) |
| `/help` | Player | Opens the in-game help guide |
| `/togglemusic` | Player | Toggles ambient music zones on/off *(requires Music Zones enabled)* |
| `/removeobjects [model]` | Admin | Removes configured objects, or a specific model if provided |
| `/cleandead` | Admin | Manually removes dead entities (peds, horses, animals, wagons) |

Admin commands require a group listed in `Config.ObjectRemoval.AdminGroups` (default: `admin`, `superadmin`, `moderator`).

---

## Exports

### Framework Detection & Player Data

#### Client-Side
```lua
-- Get framework type ('vorp', 'rsg', 'qbcore', 'redemrp', 'standalone')
local fwType = exports['poggy_util']:GetFrameworkType()

-- Check if framework is ready
local ready = exports['poggy_util']:IsFrameworkReady()

-- Get local character info (normalized format)
local charInfo = exports['poggy_util']:GetLocalCharacterInfo()
-- Returns: { charId, identifier, firstname, lastname, job, jobLabel, jobGrade, jobGradeName, onDuty }

-- Get local player's job
local job = exports['poggy_util']:GetLocalJob()

-- Get local player's job grade
local grade = exports['poggy_util']:GetLocalJobGrade()

-- Check if local player is on duty
local onDuty = exports['poggy_util']:IsLocalOnDuty()

-- Check if player has specific job(s)
local isCop = exports['poggy_util']:HasJob("police")
local isLaw = exports['poggy_util']:HasJob({"police", "sheriff", "marshal"})

-- Check if player is law enforcement (any law job)
local isLaw = exports['poggy_util']:IsLawEnforcement()

-- Get local player's full name
local name = exports['poggy_util']:GetLocalFullName()
```

#### Server-Side
```lua
-- Get player object by source (raw framework object)
local player = exports['poggy_util']:GetPlayer(source)

-- Get character data (raw framework format)
local character = exports['poggy_util']:GetCharacter(source)

-- Get normalized character info (works on ALL frameworks!)
local charInfo = exports['poggy_util']:GetCharacterInfo(source)
-- Returns: { charId, identifier, firstname, lastname, job, jobLabel, jobGrade, jobGradeName, onDuty }

-- Get player's license identifier
local identifier = exports['poggy_util']:GetPlayerIdentifier(source)

-- Get player's job
local job = exports['poggy_util']:GetPlayerJob(source)

-- Get player's job grade
local grade = exports['poggy_util']:GetPlayerJobGrade(source)

-- Check if player is on duty
local onDuty = exports['poggy_util']:IsPlayerOnDuty(source)

-- Get all online players
local players = exports['poggy_util']:GetPlayers()

-- Get player's weapons (async with callback)
exports['poggy_util']:GetPlayerWeapons(source, function(weapons)
    for _, weapon in ipairs(weapons) do
        print(weapon.name)
    end
end)
```

### Notifications

#### Client-Side Exports
```lua
-- Simple tip notification (center-bottom)
exports["poggy_util"]:NotifyTip("Your message here", 5000)

-- Right-side tip notification
exports["poggy_util"]:NotifyRightTip("Message", 4000)

-- Top notification with title and subtitle
exports["poggy_util"]:NotifySimpleTop("Title", "Subtitle message", 5000)

-- Left notification with icon
exports["poggy_util"]:NotifyLeft("Title", "Subtitle", "generic_textures", "tick", 5000, "COLOR_WHITE")

-- Advanced notification with icon
exports["poggy_util"]:NotifyAdvanced("Message", "generic_textures", "tick", "COLOR_WHITE", 5000)

-- Center screen notification
exports["poggy_util"]:NotifyCenter("Message", 5000, "COLOR_PURE_WHITE")

-- Bottom right notification
exports["poggy_util"]:NotifyBottomRight("Message", 5000)

-- Top location notification
exports["poggy_util"]:NotifyTop("Message", "location_name", 5000)

-- Objective/mission style notification (bottom)
exports["poggy_util"]:NotifyObjective("Objective text", 5000)
```

#### Server-Side Notifications
```lua
-- Send notification to a specific player
TriggerClientEvent("poggy:TipRight", targetSource, "Message", 5000)
TriggerClientEvent("poggy:ShowTopNotification", targetSource, "Title", "Subtitle", 5000)
```

#### Events (VORP-Compatible)
```lua
-- Client-side events - both prefixes work identically:
TriggerEvent("poggy:TipBottom", "Message", 5000)
TriggerEvent("vorp:TipBottom", "Message", 5000)

TriggerEvent("poggy:ShowTopNotification", "Title", "Subtitle", 5000)
TriggerEvent("vorp:ShowTopNotification", "Title", "Subtitle", 5000)
```

### Client — Weapons
```lua
exports["poggy_util"]:GetCurrentWeaponHash()    -- Returns current weapon hash
exports["poggy_util"]:GetCurrentWeaponEntity()  -- Returns current weapon entity ID
```

### Server — Database Utilities
```lua
-- Raw SQL query
exports["poggy_util"]:ExecuteQuery("SELECT * FROM characters WHERE job = ?", {"police"}, function(results) end)

-- Search with conditions
exports["poggy_util"]:SearchRecords("characters", {job = "doctor"}, {limit = 10}, function(results) end)

-- Find a character by various criteria (source, charid, identifier, firstname/lastname, fullname)
exports["poggy_util"]:FindCharacter({source = playerId}, function(charInfo) end)
exports["poggy_util"]:FindCharacter({fullname = "John Doe"}, function(charInfo) end)

-- Insert / Update / Delete
exports["poggy_util"]:InsertRecord("my_table", {col = "value"}, function(insertId) end)
exports["poggy_util"]:UpdateRecord("characters", {money = 500}, {charIdentifier = "abc"}, function(rows) end)
exports["poggy_util"]:DeleteRecord("old_logs", {created_at = {operator = "<", value = "2024-01-01"}}, function(rows) end)
```

## Using poggy_util in Your Scripts

### Add Dependency
In your script's `fxmanifest.lua`:
```lua
dependencies {
    'poggy_util'
}
```

### Quick Start Example

#### Server Script
```lua
RegisterServerEvent('myScript:doSomething')
AddEventHandler('myScript:doSomething', function()
    local source = source
    
    -- Get player info (works on ANY framework!)
    local charInfo = exports['poggy_util']:GetCharacterInfo(source)
    if not charInfo then return end
    
    print(string.format("Player %s %s (job: %s) did something!", 
        charInfo.firstname, charInfo.lastname, charInfo.job))
    
    -- Send notification
    TriggerClientEvent("poggy:TipRight", source, "Action completed!", 5000)
end)
```

#### Client Script  
```lua
-- Check if player is law enforcement
if exports['poggy_util']:IsLawEnforcement() then
    exports['poggy_util']:NotifyTip("Law enforcement features enabled", 5000)
end

-- Get player's job
local job = exports['poggy_util']:GetLocalJob()
print("Current job: " .. (job or "none"))
```

## Credits
- Author: Poggy
