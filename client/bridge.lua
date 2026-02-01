Bridge = {}
local QBCore = nil
local ESX = nil

local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function Bridge.GetCore()
    if Config.Framework == 'auto' then
        if GetResourceState('qbx_core') == 'started' then
            Config.Framework = 'qbox'
        elseif GetResourceState('qb-core') == 'started' then
            Config.Framework = 'qb'
        elseif GetResourceState('es_extended') == 'started' then
            Config.Framework = 'esx'
        end
    end

    if Config.Framework == 'qbox' then
        return exports['qbx_core']:GetCoreObject()
    elseif Config.Framework == 'qb' then
        if not QBCore then QBCore = exports['qb-core']:GetCoreObject() end
        return QBCore
    elseif Config.Framework == 'esx' then
        if not ESX then 
             -- Legacy ESX support
             if exports["es_extended"]:getSharedObject() then
                ESX = exports["es_extended"]:getSharedObject()
            else
                TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
            end
        end
        return ESX
    end
end

function Bridge.GetPlate(vehicle)
    if not vehicle or vehicle == 0 then return nil end
    local plate = GetVehicleNumberPlateText(vehicle)
    if not plate then return nil end
    return trim(plate)
end

function Bridge.TriggerCallback(name, cb, ...)
    if Config.Framework == 'qbox' or Config.Framework == 'qb' then
        if Config.Framework == 'qbox' and exports.qbx_core then
             -- QBox might use lib.callback in future but QBCore callbacks are supported via bridge usually.
             -- But standard QB approach:
             if not QBCore then QBCore = exports['qb-core']:GetCoreObject() end
             QBCore.Functions.TriggerCallback(name, cb, ...)
        else
             if not QBCore then QBCore = exports['qb-core']:GetCoreObject() end
             QBCore.Functions.TriggerCallback(name, cb, ...)
        end
    elseif Config.Framework == 'esx' then
        if not ESX then Bridge.GetCore() end
        ESX.TriggerServerCallback(name, cb, ...)
    else
        -- Standalone fallback or simple event? 
        -- For standalone, callbacks are tricky without a framework. 
        -- We might just rely on data syncing via events if needed, but for now we assume framework.
    end
end

-- Initialize on start
CreateThread(function()
    Bridge.GetCore()
    print("[Mileage] Client Bridge Initialized as: " .. (Config.Framework or 'Unknown'))
end)
