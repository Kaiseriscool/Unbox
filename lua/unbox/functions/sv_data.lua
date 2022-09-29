function LUnbox:CreateConfig()
    if not file.Exists("lords_unbox.txt", "DATA") then
        local tbl = {
            ["Rarities"] = {
                {"Common", Color(84, 84, 84, 255)},
                {"Uncommon", Color(42, 251, 0, 255)},
                {"Rare", Color(0, 161, 255, 255)},
                {"Epic", Color(255, 0, 255, 255)},
                {"Legendary", Color(255, 246, 0, 255)},
                {"Celestial", Color(255, 0, 0, 255)},
                {"God", Color(255, 102, 0, 255)},
                {"Glitched", Color(119, 0, 255, 255)},
            },
            ["Items"] = {
            {rarity = 1, img = "", model = "models/weapons/w_pistol.mdl", name = "Pistol", type = "Weapon", value = "weapon_pistol"},
            {rarity = 2, img = "", model = "models/weapons/v_irifle.mdl", name = "Rifle", type = "Weapon", value = "weapon_ar2"},
            },
            ["Keys"] = {
                {name = "Expensive Boy", price = 500, color = Color(255, 0, 0)},
                {name = "Cheap", price = 120, color = Color(0, 255, 234)},
            },
            ["Crates"] = {
                --[[
                    items = {
                        {
                            item = 123,
                            chance = 100,
                            id = 1,
                        }
                    }
                ]]--

            {name = "Case 1 ", imgur = "", price = 250, rarity = 5, type = "Crate", items = {}},
            }
        }
        file.Write("lords_unbox.txt", util.TableToJSON(tbl))
    end
    LUnbox.Config = util.JSONToTable(file.Read("lords_unbox.txt", "DATA"))
end

function LUnbox:SaveConfig()
    file.Write("lords_unbox.txt", util.TableToJSON(LUnbox.Config, true))
end

function LUnbox:CreateSQL()
    sql.Query("CREATE TABLE IF NOT EXISTS LUnboxInventories (steamid TEXT, crateid INTEGER, crateamount INTEGER)")
end

util.AddNetworkString("LUnbox:Inventory")
function LUnbox:AddItem(steamid, crateid)
	local data = sql.Query("SELECT * FROM LUnboxInventories WHERE steamid = "..sql.SQLStr(steamid).." AND crateid = "..crateid..";")
	if data then
        local int = tonumber(data[1].crateamount)
		sql.Query("UPDATE LUnboxInventories SET crateamount = "..(int+1).." WHERE steamid = "..sql.SQLStr(steamid).." AND crateid = "..crateid..";")
	else
		sql.Query("INSERT INTO LUnboxInventories (steamid, crateid, crateamount) VALUES("..sql.SQLStr(steamid)..", "..crateid..", 1)")
	end

    local ply = player.GetBySteamID(steamid)
    if not IsValid(ply) then return end

    net.Start("LUnbox:Inventory")
    net.WriteUInt(1, 2)
    net.WriteUInt(crateid, 32)
    net.Send(ply)
end

function LUnbox:RemoveItem(steamid, crateid)
    local data = sql.Query("SELECT * FROM LUnboxInventories WHERE steamid = "..sql.SQLStr(steamid).." AND crateid = "..crateid..";")
	if data then
        local int = tonumber(data[1].crateamount)
		sql.Query("UPDATE LUnboxInventories SET crateamount = "..(int-1).." WHERE steamid = "..sql.SQLStr(steamid).." AND crateid = "..crateid..";")
	end
    
    local ply = player.GetBySteamID(steamid)
    if not IsValid(ply) then return end

    net.Start("LUnbox:Inventory")
    net.WriteUInt(2, 2)
    net.WriteUInt(crateid, 32)
    net.Send(ply)
end

function LUnbox:HasCrate(steamid, crateint)
    local data = sql.Query("SELECT * FROM LUnboxInventories WHERE steamid = "..sql.SQLStr(steamid).." AND crateid = "..crateint..";")
    if not data then return false end
    if tonumber(data[1].crateamount) < 1 then return false end
    if tonumber(data[1].crateamount) > 0 then return true end    

    return false
end

util.AddNetworkString("LUnbox:NetworkConfig")
hook.Add("PlayerInitialSpawn", "LUnbox:NetworkConfig", function(ply)
    LUnbox:CreateConfig()
    LUnbox:CreateSQL()

    net.Start("LUnbox:NetworkConfig")
    net.WriteUInt(#LUnbox.Config["Rarities"], 32)
    if #LUnbox.Config["Rarities"] > 0 then
        for k, v in ipairs(LUnbox.Config["Rarities"]) do
            net.WriteString(v[1])
            net.WriteUInt(v[2].r, 8)
            net.WriteUInt(v[2].g, 8)
            net.WriteUInt(v[2].b, 8)
        end
    end

    net.WriteUInt(#LUnbox.Config["Items"], 32)
    if #LUnbox.Config["Items"] > 0 then
        for k, v in ipairs(LUnbox.Config["Items"]) do
            net.WriteUInt(v.rarity, 32)
            net.WriteString(v.img)
            net.WriteString(v.model)
            net.WriteString(v.name)
            net.WriteString(v.type)
            net.WriteString(v.value)
        end
    end

    net.WriteUInt(#LUnbox.Config["Keys"], 32)
    if #LUnbox.Config["Keys"] > 0 then
        for k, v in ipairs(LUnbox.Config["Keys"]) do
            net.WriteString(v.name)
            net.WriteUInt(v.price, 32)
            net.WriteUInt(v.color.r, 8)
            net.WriteUInt(v.color.g, 8)
            net.WriteUInt(v.color.b, 8)
        end
    end

    net.WriteUInt(#LUnbox.Config["Crates"], 32)
    if #LUnbox.Config["Crates"] > 0 then
        for k, v in ipairs(LUnbox.Config["Crates"]) do
            net.WriteString(v.name)
            net.WriteString(v.type)
            net.WriteUInt(v.price, 32)
            net.WriteUInt(v.rarity, 32)
            net.WriteString(v.imgur)
            net.WriteUInt(#v.items, 32)
            if #v.items > 0 then
                for k2, v2 in ipairs(v.items) do
                    net.WriteString(v2.item)
                    net.WriteUInt(v2.chance, 32)
                end
            end
        end
    end

    local data = sql.Query("SELECT * FROM LUnboxInventories WHERE steamid = "..sql.SQLStr(ply:SteamID())..";")
    net.WriteUInt(data and #data or 0, 32)
    if data and #data > 0 then
        for k, v in ipairs(data) do
            net.WriteUInt(v.crateid, 32)
            net.WriteUInt(v.crateamount, 32)
        end
    end
    net.Send(ply)
end)