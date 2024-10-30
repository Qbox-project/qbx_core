local positionConfig = require 'config.shared'.notifyPosition

---Text box popup for player which dissappears after a set time.
---@param text table|string text of the notification
---@param notifyType? NotificationType informs default styling. Defaults to 'inform'
---@param duration? integer milliseconds notification will remain on screen. Defaults to 5000
---@param notifyIcon? string Font Awesome 6 icon name
---@param notifyIconColor? string Custom color for the icon chosen before
---@param notifyAnimation? string Custom color for the icon chosen before
---@param notifyStyle? table Custom styling. Please refer too https://overext ended.dev/ox_lib/Modules/Interface/Client/notify#libnotify
---@param notifyPosition? NotificationPosition
function Notify(text, notifyType, duration, notifyIcon, notifyIconColor, notifyAnimation, notifyStyle, notifyPosition)
    local title, description
    if type(text) == 'table' then
        title = text.text or 'Missing text!'
        description = text.title or nil
    else
        description = text
    end
    local position = notifyPosition or positionConfig

    --type set & duration
    local type = notifyType or 'inform'
    if type == 'primary' then type = 'inform' end
    duration = duration or 5000

    --icon color
    local defaultIconColor = {
        info = '#1c75d2',
        police = '#1c75d2',
        ambulance = '#bf1d1d',
        warn = '#ee8a08',
        success = '#20bb44',
        error = '#bf1d1d'
    }

    local iconColor = notifyIconColor or defaultIconColor[notifyType] or '#1c75d2' -- Use custom icon color if provided, else use predefined icon color, default to blue

    --icon animations
    local iconAnimations = {
        info = 'beatFade',
        police = 'pulse',
        ambulance = 'pulse',
        warn = 'bounce',
        success = 'beat',
        error = 'shake'
    }

    local iconAnimation = notifyAnimation or iconAnimations[notifyType] or 'beatFade' -- Use custom icon animation if provided, else use predefined icon animation, default to beatFade

    --default styling
    local style = {
        borderRadius = '4px 4px 0 0',
        borderBottom = '2px solid ' .. iconColor, -- Use selected color for the border
        backgroundColor = '#2b2b2bE0',
        color = 'white'
    }

    lib.notify({
        id = title,
        title = title,
        description = description,
        duration = duration,
        type = type,
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

---@param filter string | string[] | table<string, number>
---@return boolean
function HasPrimaryGroup(filter)
    return HasPlayerGotGroup(filter, QBX.PlayerData, true)
end

exports('HasPrimaryGroup', HasPrimaryGroup)

---@param filter string | string[] | table<string, number>
---@return boolean
function HasGroup(filter)
    return HasPlayerGotGroup(filter, QBX.PlayerData)
end

exports('HasGroup', HasGroup)

---@return table<string, integer>
function GetGroups()
    local playerData = QBX.PlayerData
    return GetPlayerGroups(playerData)
end

exports('GetGroups', GetGroups)