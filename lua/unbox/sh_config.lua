--[[
Copyright (c) 2023 Argon Devloment Team(Freal and Kaiser)

Permission is granted to use and modify this addon with permission from Argon Devloment Team(Freal and Kaiser), subject to the following conditions:


- By using this software, you agree to abide by these conditions if applicable.
- The copyright notice and this permission notice must be included in all copies or substantial portions of the software.
- You may not sell or distribute any portion of this software for any gain unless very clear credit is given to Argon Devloment Team(Freal and Kaiser) and permission is obtained from Argon Devloment Team(Freal and Kaiser).
- You may not distribute this software.
- You may not remove any credit or the provided license.
- You may not claim ownership or development of any part of this software.
- Permission to use and modify this software may be revoked at any time by Argon Devloment Team(Freal and Kaiser). If permission is revoked, you must stop using and modifying the software and may not sell or distribute it.
- You are responsible for any actions taken by any third party that you give access to this software.
- If any of these conditions are violated, you lose any permission to use or modify this software, and may not sell or distribute it.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

]]--
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
