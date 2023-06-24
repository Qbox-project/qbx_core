--[[ 
    example config:
    for a god called BigDaddy with the fivem identifier "69420"
    in server.cfg it would look like this:
    add_principal identifier.fivem:69420 qbox.god

    We'll use this:
        ["BigDaddy"] = {
            permission = "god",
            identifiers = {
                -- type = identifier
                fivem = "69420",
            }
        } 

    identifier types are:
        license
        license2
        fivem
        discord
        steam
    ]]
local Staff = {
    [""] = {
        permission = "",
        identifiers = {
        }
    }
}

AddEventHandler('playerJoining', function()
    local identifiers = {}
    for _, idtype in pairs({"license", "license2", "fivem", "discord", "steam"}) do
        identifiers[idtype] = QBCore.Functions.GetIdentifier(source, idtype)
    end
    
    local done = false
    for _, member in pairs(Staff) do
        for idtype, identifier in pairs(member.identifiers) do
            if identifier and identifiers[idtype] == string.format("%s:%s", idtype, identifier) then
                lib.addAce("player." .. source, string.format("group.%s", member.permission))
                lib.addAce("player." .. source, string.format("qbox.%s", member.permission)) -- remove once we moved to group.permission
                done = true
                break
            end
        end
        if done then break end
    end
end)