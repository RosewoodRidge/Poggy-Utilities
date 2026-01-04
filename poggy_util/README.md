# Poggy's Utilities (poggy_util)

A comprehensive utility resource for RedM servers, providing framework abstraction, notifications, and various quality-of-life features. **Works with VORP Core, RSG Core, QBCore, RedemRP, or standalone!**

## Features

### 1. Framework Abstraction Layer (NEW!)
Universal framework bridge that allows your scripts to work with ANY RedM framework:
- **Multi-Framework Support**: VORP Core, RSG Core, QBCore, RedemRP, or standalone
- **Automatic Detection**: Detects running framework automatically
- **Unified API**: Same function calls work across all frameworks
- **Database Support**: Direct database queries for standalone mode
- **Exports Available**: Easy integration for any script

### 2. Native Notifications System
A standalone notification system using native RedM UI - no external dependencies required!
- **Native UI**: Uses built-in game notifications (no HTML/CSS/NUI overhead)
- **Multiple Styles**: Tip, Top, Left, Right, Center, Advanced with icons, and more
- **VORP Compatible**: Registers handlers for `vorp:` events for backwards compatibility
- **Exports Available**: Easy-to-use exports for any script
- **Framework Agnostic**: Works standalone without requiring any framework

### 2. Area of Play (AOP) System
Automatically tracks where players are congregating and displays the current "Area of Play" on the screen.
- **Automatic Detection**: Calculates the most populated zone based on player locations.
- **UI Display**: Shows the current zone name and player count in that zone.
- **Configurable**: Zones can be added or modified in `config.lua`.
- **Command**: `/aop` - Toggles the AOP display on/off for the player.

### 3. Weapon Jamming
Adds a realistic weapon jamming mechanic based on weapon condition.
- **Degradation Based**: The lower the weapon condition, the higher the chance of jamming.
- **Sound Effects**: Plays realistic "click" sounds when a weapon jams (heard only by the shooter).
- **Configurable**: Adjust jam thresholds, probabilities, and which weapons can jam.
- **Visual Feedback**: Prevents firing when jammed.

### 4. Government Stipend (Unemployment)
Provides financial support for unemployed characters, rewarding long-term play.
- **Tenure Based**: Pay increases based on how many days the character has existed on the server.
- **Retroactive**: Automatically calculates tenure for existing characters using a legacy date.
- **Configurable**: Set base pay, increase amounts, intervals, and eligibility requirements.

### 5. Object Removal & Entity Cleanup
Helps keep the server clean and performant by removing unwanted objects and dead entities.
- **Object Removal**: Periodically removes specific object models (e.g., glitched coach locks).
- **Dead Entity Cleanup**: Removes dead NPCs, horses, animals, and abandoned wagons to save resources.
- **Admin Commands**:
  - `/removeobjects [modelName]` - Manually trigger object removal (removes configured objects if no model specified).
  - `/cleandead` - Manually trigger dead entity cleanup.

### 6. Music Zones
Plays ambient music or audio in specific locations using YouTube audio.
- **3D Audio**: Simulates distance falloff and directional audio (quieter when looking away).
- **Timestamps**: Can start tracks at random timestamps for variety.
- **Command**: `/togglemusic` - Toggles music zones on/off for the player.
- **Configurable**: Add custom zones with YouTube IDs, radius, and volume.

### 7. Debug System
Extensive debugging tools for server developers.
- **Configurable Logging**: Toggle specific debug categories (CORE, WEAPON, HORSE, etc.) and levels (INFO, TRACE, ERROR).
- **Command**: `/mountdebug` - Prints detailed information about nearby mounts and animals to the client console (F8).

## Installation

1. Place the `poggy_util` folder into your server's `resources` directory.
2. Add `ensure poggy_util` to your `server.cfg` (before any scripts that use it).
3. Optional dependencies (for enhanced features):
   - `oxmysql` - For database queries in standalone mode
   - A framework (vorp_core, rsg-core, qb-core) - For full player data

## Configuration

All settings can be adjusted in `config.lua`.

- **Toggles**: Each feature has an `Enabled` toggle to turn it on or off globally.
- **Weapon Jam**: Adjust `JamStartThreshold` and `MaxJamProbability`.
- **Music**: Add new zones in `Config.MusicZones.Zones`.

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

## Commands

| Command | Permission | Description |
| :--- | :--- | :--- |
| `/aop` | Everyone | Toggles the Area of Play UI display. |
| `/togglemusic` | Everyone | Toggles ambient music zones on/off. |
| `/mountdebug` | Everyone | Prints debug info about nearby mounts to F8 console. |
| `/removeobjects` | Admin | Removes configured objects or a specific model. |
| `/cleandead` | Admin | Removes dead entities (peds, horses, animals, wagons). |

### Client - Weapons
```lua
exports["poggy_util"]:GetCurrentWeaponHash()    -- Returns weapon hash
exports["poggy_util"]:GetCurrentWeaponEntity()  -- Returns weapon entity ID
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
