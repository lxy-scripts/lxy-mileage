# lxy-mileage
A standalone, multi-framework vehicle mileage system for FiveM.

## Features
- **Multi-Framework Support**: Works with ESX, QBCore, and Qbox (Auto-detected).
- **Standalone Capable**: Can run without a framework if configured (requires minor tweaks for plate/ownership).
- **Performance Friendly**: Uses statebags for syncing and caches DB updates.
- **Mileage Tracking**: Tracks distance driven for every vehicle.
- **Migration**: Can migrate existing mileage from `player_vehicles` or `owned_vehicles`.

## Installation

1. Download and put into your `resources` folder.
2. Ensure you have `oxmysql` installed and started.
3. Add `ensure lxy-mileage` to your `server.cfg`.
4. The database table `vehicle_mileage` will be created automatically.

## Configuration

Edit `config.lua` to set your preferences.

```lua
Config.Framework = 'auto' -- 'esx', 'qb', 'qbox', or 'auto' behavior

Config.Migration = {
    Enabled = true, -- Enable auto-import from existing tables
    SourceTable = 'player_vehicles', -- 'owned_vehicles' for ESX, 'player_vehicles' for QBCore
    SourceColumn = 'plate',
    MileageColumn = 'drivingdistance' -- The column name in your old table
}
```

## Functions / Exports

### Internal Functions
- `SetStateMileage(veh, amount)`: Sets the statebag `drivingdistance` on the vehicle entity.

### Exports
Get mileage for a plate:
```lua
local miles = exports['lxy-mileage']:GetMileage(plate)
print(miles)
```

Set mileage for a plate:
```lua
exports['lxy-mileage']:SetMileage(plate, newAmount)
```

## Support
For support, please contact the developer or verify your framework configuration.
