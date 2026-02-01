Config = {}

Config.Framework = 'auto' -- 'esx', 'qb', 'qbox' or 'auto'

Config.Migration = {
    Enabled = true,
    SourceTable = 'player_vehicles', -- 'owned_vehicles' for ESX usually, 'player_vehicles' for QB
    SourceColumn = 'plate',
    MileageColumn = 'drivingdistance' -- Column in source table that holds mileage
}

Config.UpdateInterval = 2000 -- How often to check distance (ms)
Config.SaveInterval = 60000 -- How often to save to DB (ms) - Autosave
Config.MinSpeed = 1.0 -- Minimum speed in m/s (~3.6 km/h) to count mileage (Lowered for testing)
Config.MaxDist = 500.0 -- Max distance allowed per check (anti-teleport)

-- Conversion: 1 meter = 0.000621371 miles
Config.MeterToMiles = 0.000621371
