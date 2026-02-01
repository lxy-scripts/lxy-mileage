local lastCoords = nil
local lastVeh = nil
local enteredTime = 0
local currentMileage = 0
local pendingSave = 0

-- Function to set mileage state for other scripts (HUDs etc)
local function SetStateMileage(veh, amount)
    if not DoesEntityExist(veh) then return end
    
    Entity(veh).state:set('drivingdistance', amount, true)
    -- Entity(veh).state:set('odometer', amount, true) -- Disabled to prevent conflict with vehiclefailure scripts
end

-- Initialize Vehicle Mileage
local function InitVehicle(veh)
    local plate = Bridge.GetPlate(veh)
    if not plate then return end
    
    Bridge.TriggerCallback('lxy-mileage:server:GetMileage', function(mileage)
        if mileage then
            currentMileage = mileage
            SetStateMileage(veh, mileage)
        end
    end, plate)
end

CreateThread(function()
    while true do
        Wait(Config.UpdateInterval)
        
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            
            -- Only Driver tracks mileage
            if GetPedInVehicleSeat(veh, -1) == ped then
                local currentCoords = GetEntityCoords(veh)
                
                -- Vehicle Switch / Init
                if lastVeh ~= veh then
                    lastVeh = veh
                    lastCoords = currentCoords
                    enteredTime = GetGameTimer()
                    InitVehicle(veh)
                end
                
                -- Tracking Logic
                if lastCoords and (GetGameTimer() - enteredTime > 5000) then
                    local dist = #(currentCoords - lastCoords)
                    local speed = GetEntitySpeed(veh)
                    
                    -- Debug Print
                    -- print(string.format("[Mileage] Speed: %.2f | Dist: %.2f | Current: %.2f", speed, dist, currentMileage))

                    -- Validation (Speed & Anti-Teleport)
                    if speed >= Config.MinSpeed and dist < Config.MaxDist then
                        -- Add distance to current session
                        currentMileage = currentMileage + dist
                        pendingSave = pendingSave + dist
                        
                        -- Update Statebag immediately for HUDs
                        SetStateMileage(veh, currentMileage)
                        
                        -- Sync to Server if pending amount is significant (e.g. > 100 meters)
                        if pendingSave > 100.0 then
                            local plate = Bridge.GetPlate(veh)
                            if plate then
                                TriggerServerEvent('lxy-mileage:server:UpdateMileage', plate, currentMileage)
                                pendingSave = 0
                                -- print("[Mileage] Synced to Server: " .. currentMileage)
                            end
                        end
                    end
                end
                
                lastCoords = currentCoords
            else
                -- Passenger or Switch
                lastVeh = nil
                lastCoords = nil
            end
        else
            -- On Foot
            lastVeh = nil
            lastCoords = nil
        end
    end
end)

-- Force save on exit
AddEventHandler('baseevents:leftVehicle', function(veh, seat, name, netId)
    if seat == -1 and pendingSave > 0 then
        local plate = Bridge.GetPlate(veh)
        if plate then
            TriggerServerEvent('lxy-mileage:server:UpdateMileage', plate, currentMileage)
            pendingSave = 0
        end
    end
end)
