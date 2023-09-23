---@deprecated file will be deleted in a future version

---@enum Position
local positions = {
    left = 'left-center',
    right = 'right-center',
    top = 'top-center'
}

local function ExportHandler(name, cb)
    AddEventHandler(string.format('__cfx_export_qb-core_%s', name), function(setCB)
        setCB(cb)
    end)
end

---@deprecated use ox_lib showTextUI calls directly
local function hideText()
    lib.hideTextUI()
end

---@deprecated use ox_lib showTextUI calls directly
---@param text string
---@param position Position
local function drawText(text, position)
    position = positions[position] or position
    lib.showTextUI(text, {
        position = position
    })
end

---@deprecated use ox_lib showTextUI calls directly
---@param text string
---@param position Position
local function changeText(text, position)
    position = positions[position] or position
    lib.hideTextUI()
    lib.showTextUI(text, {
        position = position
    })
end

---@deprecated use ox_lib showTextUI calls directly
local function keyPressed()
    CreateThread(function() -- Not sure if a thread is needed but why not eh?
        Wait(500)
        lib.hideTextUI()
    end)
end

---@deprecated use ox_lib showTextUI calls directly
RegisterNetEvent('qb-core:client:DrawText', function(text, position)
    drawText(text, position)
end)

---@deprecated use ox_lib showTextUI calls directly
RegisterNetEvent('qb-core:client:ChangeText', function(text, position)
    changeText(text, position)
end)

---@deprecated use ox_lib showTextUI calls directly
RegisterNetEvent('qb-core:client:HideText', function()
    lib.hideTextUI()
end)

---@deprecated use ox_lib showTextUI calls directly
RegisterNetEvent('qb-core:client:KeyPressed', function()
    keyPressed()
end)

---@deprecated use ox_lib showTextUI calls directly
RegisterNetEvent('qbx-core:client:DrawText', function(text, position)
    drawText(text, position)
end)

---@deprecated use ox_lib showTextUI calls directly
RegisterNetEvent('qbx-core:client:ChangeText', function(text, position)
    changeText(text, position)
end)

---@deprecated use ox_lib showTextUI calls directly
RegisterNetEvent('qbx-core:client:HideText', function()
    lib.hideTextUI()
end)

---@deprecated use ox_lib showTextUI calls directly
RegisterNetEvent('qbx-core:client:KeyPressed', function()
    keyPressed()
end)

---@deprecated use ox_lib showTextUI calls directly
exports('DrawText', drawText)
---@deprecated use ox_lib showTextUI calls directly
exports('ChangeText', changeText)
---@deprecated use ox_lib showTextUI calls directly
exports('HideText', hideText)
---@deprecated use ox_lib showTextUI calls directly
exports('KeyPressed', keyPressed)

---@deprecated use ox_lib showTextUI calls directly
ExportHandler('DrawText', drawText)
---@deprecated use ox_lib showTextUI calls directly
ExportHandler('ChangeText', changeText)
---@deprecated use ox_lib showTextUI calls directly
ExportHandler('HideText', hideText)
---@deprecated use ox_lib showTextUI calls directly
ExportHandler('KeyPressed', keyPressed)
