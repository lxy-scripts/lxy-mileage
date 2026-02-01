Bridge = {}
local QBCore = nil
local ESX = nil

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
             if exports["es_extended"]:getSharedObject() then
                ESX = exports["es_extended"]:getSharedObject()
            else
                TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
            end
        end
        return ESX
    end
end

function Bridge.CreateCallback(name, handler)
    if Config.Framework == 'qbox' or Config.Framework == 'qb' then
        if not QBCore then QBCore = exports['qb-core']:GetCoreObject() end
        QBCore.Functions.CreateCallback(name, handler)
    elseif Config.Framework == 'esx' then
        if not ESX then Bridge.GetCore() end
        ESX.RegisterServerCallback(name, handler)
    end
end

function Bridge.GetPlayer(source)
    if Config.Framework == 'qbox' or Config.Framework == 'qb' then
        if not QBCore then QBCore = exports['qb-core']:GetCoreObject() end
        return QBCore.Functions.GetPlayer(source)
    elseif Config.Framework == 'esx' then
        if not ESX then Bridge.GetCore() end
        return ESX.GetPlayerFromId(source)
    end
end

-- Initialize on start
CreateThread(function()
    Bridge.GetCore()
    print("[Mileage] Server Bridge Initialized as: " .. (Config.Framework or 'Unknown'))
end)
