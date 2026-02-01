-- Initialize Database
CreateThread(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `vehicle_mileage` (
            `plate` varchar(50) NOT NULL,
            `mileage` double DEFAULT 0,
            PRIMARY KEY (`plate`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end)

-- Cache to avoid spamming DB
local MileageCache = {}

-- Load mileage when vehicle spawns or script starts
local function LoadMileage(plate)
    if MileageCache[plate] then return MileageCache[plate] end
    
    local result = MySQL.scalar.await('SELECT mileage FROM vehicle_mileage WHERE plate = ?', {plate})
    if result then
        MileageCache[plate] = result
        return result
    else
        -- Create entry
        MySQL.insert('INSERT IGNORE INTO vehicle_mileage (plate, mileage) VALUES (?, ?)', {plate, 0})
        MileageCache[plate] = 0
        return 0
    end
end

-- Save mileage
local function SaveMileage(plate, mileage)
    if not plate or not mileage then return end
    MileageCache[plate] = mileage
    MySQL.update('UPDATE vehicle_mileage SET mileage = ? WHERE plate = ?', {mileage, plate})
    
    -- Optional: Sync with player_vehicles for compatibility (if user wants)
    -- MySQL.update('UPDATE player_vehicles SET drivingdistance = ? WHERE plate = ?', {mileage, plate})
end

-- Callback to get mileage
Bridge.CreateCallback('lxy-mileage:server:GetMileage', function(source, cb, plate)
    local mileage = LoadMileage(plate)
    cb(mileage)
end)

-- Event to update mileage from client (Periodic sync)
RegisterNetEvent('lxy-mileage:server:UpdateMileage', function(plate, newDist)
    local src = source
    if not plate then return end
    
    -- Update Cache
    MileageCache[plate] = newDist
end)

-- Event to Force Save (e.g. from Garage)
RegisterNetEvent('lxy-mileage:server:ForceSave', function(plate, newDist)
    if not plate then return end
    
    MileageCache[plate] = newDist
    MySQL.update('UPDATE vehicle_mileage SET mileage = ? WHERE plate = ?', {newDist, plate})
    -- print('[lxy-mileage] Force Saved: ' .. plate .. ' | ' .. newDist)
end)

-- Periodic Save for Cache
CreateThread(function()
    -- Migration: Attempt to import existing mileage from source table
    if Config.Migration and Config.Migration.Enabled then
        local query = string.format("INSERT IGNORE INTO vehicle_mileage (plate, mileage) SELECT %s, %s FROM %s WHERE %s > 0", 
            Config.Migration.SourceColumn, Config.Migration.MileageColumn, 
            Config.Migration.SourceTable, Config.Migration.MileageColumn)
        
        -- Safely attempt migration (pcall isn't strictly needed for SQL but good practice if table doesn't exist)
        -- We just run the query, if it fails (e.g. table missing), it prints error but script continues.
        MySQL.query(query, {}, function(response)
            if response then
                -- print("[Mileage] Attempted migration from " .. Config.Migration.SourceTable)
            end
        end)
    end
    
    while true do
        Wait(Config.SaveInterval)
        for plate, mileage in pairs(MileageCache) do
            MySQL.update('UPDATE vehicle_mileage SET mileage = ? WHERE plate = ?', {mileage, plate})
        end
    end
end)

-- Exports
exports('GetMileage', function(plate)
    return LoadMileage(plate)
end)

exports('SetMileage', function(plate, amount)
    SaveMileage(plate, amount)
end)
