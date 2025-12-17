# Poggy's Utilities (poggy_util)

A comprehensive utility resource for RedM servers (VORP Core), providing various quality-of-life features, immersion enhancements, and server management tools.

## Features

### 1. Area of Play (AOP) System
Automatically tracks where players are congregating and displays the current "Area of Play" on the screen.
- **Automatic Detection**: Calculates the most populated zone based on player locations.
- **UI Display**: Shows the current zone name and player count in that zone.
- **Configurable**: Zones can be added or modified in `config.lua`.
- **Command**: `/aop` - Toggles the AOP display on/off for the player.

### 2. Weapon Jamming
Adds a realistic weapon jamming mechanic based on weapon condition.
- **Degradation Based**: The lower the weapon condition, the higher the chance of jamming.
- **Sound Effects**: Plays realistic "click" sounds when a weapon jams (heard only by the shooter).
- **Configurable**: Adjust jam thresholds, probabilities, and which weapons can jam.
- **Visual Feedback**: Prevents firing when jammed.

### 3. Government Stipend (Unemployment)
Provides financial support for unemployed characters, rewarding long-term play.
- **Tenure Based**: Pay increases based on how many days the character has existed on the server.
- **Retroactive**: Automatically calculates tenure for existing characters using a legacy date.
- **Configurable**: Set base pay, increase amounts, intervals, and eligibility requirements.

### 4. Object Removal & Entity Cleanup
Helps keep the server clean and performant by removing unwanted objects and dead entities.
- **Object Removal**: Periodically removes specific object models (e.g., glitched coach locks).
- **Dead Entity Cleanup**: Removes dead NPCs, horses, animals, and abandoned wagons to save resources.
- **Admin Commands**:
  - `/removeobjects [modelName]` - Manually trigger object removal (removes configured objects if no model specified).
  - `/cleandead` - Manually trigger dead entity cleanup.

### 5. Music Zones
Plays ambient music or audio in specific locations using YouTube audio.
- **3D Audio**: Simulates distance falloff and directional audio (quieter when looking away).
- **Timestamps**: Can start tracks at random timestamps for variety.
- **Command**: `/togglemusic` - Toggles music zones on/off for the player.
- **Configurable**: Add custom zones with YouTube IDs, radius, and volume.

### 6. Debug System
Extensive debugging tools for server developers.
- **Configurable Logging**: Toggle specific debug categories (CORE, WEAPON, HORSE, etc.) and levels (INFO, TRACE, ERROR).
- **Command**: `/mountdebug` - Prints detailed information about nearby mounts and animals to the client console (F8).

## Installation

1. Ensure you have the required dependencies:
   - `vorp_core`
   - `vorp_inventory`
   - `oxmysql`
2. Place the `poggy_util` folder into your server's `resources` directory.
3. Add `ensure poggy_util` to your `server.cfg`.

## Configuration

All settings can be adjusted in `config.lua`.

- **Toggles**: Each feature has an `Enabled` toggle to turn it on or off globally.
- **Stipend**: Adjust `BasePay`, `IncreaseAmount`, and `LegacyDate`.
- **Weapon Jam**: Adjust `JamStartThreshold` and `MaxJamProbability`.
- **Music**: Add new zones in `Config.MusicZones.Zones`.

## Commands

| Command | Permission | Description |
| :--- | :--- | :--- |
| `/aop` | Everyone | Toggles the Area of Play UI display. |
| `/togglemusic` | Everyone | Toggles ambient music zones on/off. |
| `/mountdebug` | Everyone | Prints debug info about nearby mounts to F8 console. |
| `/removeobjects` | Admin | Removes configured objects or a specific model. |
| `/cleandead` | Admin | Removes dead entities (peds, horses, animals, wagons). |

## Exports

### Client
- `exports["poggy_util"]:GetCurrentWeaponHash()` - Returns the hash of the player's current weapon.
- `exports["poggy_util"]:GetCurrentWeaponEntity()` - Returns the entity ID of the player's current weapon object.

## Credits
- Author: Poggy
