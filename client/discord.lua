local config = require 'config.client'.discord
if not config.enabled then return end

local maxPlayers = GlobalState.MaxPlayers

-- Update player count and show player's name in Rich Presence
AddStateBagChangeHandler('PlayerCount', nil, function(bagName, _, value)
	if bagName ~= 'global' or not value then return end

	local playerName = GetPlayerName(PlayerId())
	SetRichPresence(('%s | %s/%s'):format(playerName, value, maxPlayers))
end)

SetDiscordAppId(config.appId)
SetDiscordRichPresenceAsset(config.largeIcon.icon)
SetDiscordRichPresenceAssetText(config.largeIcon.text)

if config.smallIcon?.icon and config.smallIcon.icon:len() > 0 then
	SetDiscordRichPresenceAssetSmall(config.smallIcon.icon)
	SetDiscordRichPresenceAssetSmallText(config.smallIcon.text)
end

SetDiscordRichPresenceAction(0, config.buttons[1].text, config.buttons[1].url)
SetDiscordRichPresenceAction(1, config.buttons[2].text, config.buttons[2].url)
