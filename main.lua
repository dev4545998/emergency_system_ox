local activeBlips = {}
local currentCallId = nil

RegisterCommand('emergency', function()
    local coords = lib.inputDialog('📍 Ort wählen', {
        {
            type = 'input',
            label = 'Was ist passiert?',
            description = 'Beschreibe den Notfall',
            required = true,
            icon = 'comment'
        },
        {
            type = 'input',
            label = 'Markiere den Ort auf der Karte und gib dann X,Y ein (z.B. 215.3,-810.2)',
            description = 'Ort auf der Map',
            required = true,
            icon = 'map'
        }
    })

    if not coords then return end

    local message = coords[1]
    local xy = coords[2]

    local x, y = xy:match("([^,]+),([^,]+)")
    if not x or not y then
        lib.notify({title = 'Fehler', description = 'Ungültige Koordinaten!', type = 'error'})
        return
    end

    TriggerServerEvent('esx_emergency:sendAlert', message, vector3(tonumber(x), tonumber(y), 0.0))
end)

RegisterNetEvent('esx_emergency:receiveAlert', function(data)
    local job = ESX.GetPlayerData().job.name
    if not Config.EmergencyJobs[job] then return end

    local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
    SetBlipSprite(blip, 161)
    SetBlipScale(blip, 1.2)
    SetBlipColour(blip, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("📞 Notruf von " .. data.sender)
    EndTextCommandSetBlipName(blip)
    activeBlips[data.id] = blip

    lib.registerContext({
        id = 'emergency_alert_' .. data.id,
        title = '🚨 Neuer Notruf',
        description = data.message,
        options = {
            {
                title = '📍 Zum Ort navigieren',
                icon = 'location-dot',
                onSelect = function()
                    SetNewWaypoint(data.coords.x, data.coords.y)
                end
            },
            {
                title = '✅ Notruf annehmen',
                icon = 'check',
                onSelect = function()
                    TriggerServerEvent('esx_emergency:acceptCall', data.id)
                end
            },
            {
                title = '📞 Rückruf starten',
                icon = 'phone',
                onSelect = function()
                    TriggerServerEvent('esx_emergency:callbackPlayer', data.id)
                end
            }
        }
    })

    lib.showContext('emergency_alert_' .. data.id)
end)

RegisterNetEvent('esx_emergency:callTaken', function(callData)
    local job = ESX.GetPlayerData().job.name
    if not Config.EmergencyJobs[job] then return end

    lib.notify({
        title = '🚨 Notruf angenommen',
        description = 'Ein anderer Mitarbeiter hat den Notruf übernommen: ' .. callData.by,
        type = 'inform'
    })
end)

RegisterNetEvent('esx_emergency:callClosed', function(callId)
    lib.notify({
        title = '✅ Notruf abgeschlossen',
        description = 'Der Notruf wurde erfolgreich bearbeitet.',
        type = 'success'
    })

    if activeBlips[callId] then
        RemoveBlip(activeBlips[callId])
        activeBlips[callId] = nil
    end
end)
