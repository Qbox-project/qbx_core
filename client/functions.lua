local positionConfig = require 'config.shared'.notifyPosition

---Text box popup for player which dissappears after a set time.
---@param text table|string text of the notification
---@param notifyType? NotificationType informs default styling. Defaults to 'inform'
---@param duration? integer milliseconds notification will remain on screen. Defaults to 5000
---@param subTitle? string extra text under the title
---@param notifyPosition? NotificationPosition
---@param notifyStyle? table Custom styling. Please refer too https://overextended.dev/ox_lib/Modules/Interface/Client/notify#libnotify
---@param notifyIcon? string Font Awesome 6 icon name
---@param notifyIconColor? string Custom color for the icon chosen before
function Notify(text, notifyType, duration, subTitle, notifyPosition, notifyStyle, notifyIcon, notifyIconColor)
    local title, description
    if type(text) == 'table' then
        title = text.text or 'Placeholder'
        description = text.caption or nil
    elseif subTitle then
        title = text
        description = subTitle
    else
        description = text
    end
    local position = notifyPosition or positionConfig

    lib.notify({
        id = title,
        title = title,
        description = description,
        duration = duration,
        type = notifyType,
        position = position,
        style = notifyStyle,
        icon = notifyIcon,
        iconColor = notifyIconColor
    })
end

exports('Notify', Notify)

---@return PlayerData? playerData
function GetPlayerData()
    return QBX.PlayerData
end

exports('GetPlayerData', GetPlayerData)

--- HasPlayerGotGroup function borrowed from ox_target: https://github.com/overextended/ox_target/blob/aefc464d01da9b7aa3565e79161dd0a489945b90/client/framework/qb.lua#L41

-- MIT License

-- Copyright (c) 2022 Overextended

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

---@param filter string | string[] | table<string, number>
---@return boolean
function HasGroup(filter)
    if not filter then return false end
    local _type = type(filter)

    if _type == 'string' then
        local job = QBX.PlayerData.job.name == filter
        local gang = QBX.PlayerData.gang.name == filter
        local citizenId = QBX.PlayerData.citizenid == filter

        if job or gang or citizenId then
            return true
        end
    elseif _type == 'table' then
        local tabletype = table.type(filter)

        if tabletype == 'hash' then
            for name, grade in pairs(filter) do
                local job = QBX.PlayerData.job.name == name
                local gang = QBX.PlayerData.gang.name == name
                local citizenId = QBX.PlayerData.citizenid == name

                if job and grade <= QBX.PlayerData.job.grade.level or gang and grade <= QBX.PlayerData.gang.grade.level or citizenId then
                    return true
                end
            end
        elseif tabletype == 'array' then
            for i = 1, #filter do
                local name = filter[i]
                local job = QBX.PlayerData.job.name == name
                local gang = QBX.PlayerData.gang.name == name
                local citizenId = QBX.PlayerData.citizenid == name

                if job or gang or citizenId then
                    return true
                end
            end
        end
    end
    return false
end

exports('HasGroup', HasGroup)