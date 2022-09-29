LUnbox.ItemTypes = {} -- no touchy
LUnbox.PricePerToken = 5000
LUnbox.MenuText = "Unbox"
LUnbox.Inventory = "Xenin" -- only supports xenin inv , if your dont use it leave blank ""
LUnbox.Credits = "Mtokens" -- do we use mtokens :hmmm:? id we dont then leave blank

LUnbox.Admins = {
    -- Ranks who can change all the config
    ["superadmin"] = true,
}

LUnbox.ChatCommands = {
    ["!unbox"] = true,
    ["/unbox"] = true,
}

LUnbox.CanAffordTokens = function(ply, amt)
    if LUnbox.Credits == "Mtokens" then
        local sid = ply:SteamID64()
        if mTokens.PlyData[sid].tokens >= amt then 
        return true end
    else
        return false
    end
end

LUnbox.RemoveTokens = function(ply, amt)
    if LUnbox.Credits == "Mtokens" then
        local sid = ply:SteamID64()
        mTokens.PlyData[sid].tokens = mTokens.PlyData[sid].tokens - amt

        if player.GetBySteamID64(sid) then
            mTokens.SendPlyTokens(player.GetBySteamID64(sid))
        end

        mTokens.SQL.UpdateValue(sid, "tokens", mTokens.PlyData[sid].tokens)
        mTokens.Print("SteamID " .. sid .. " received " .. tokens .. " " .. mTokens.Config.TokenName .. ".")
    end
end