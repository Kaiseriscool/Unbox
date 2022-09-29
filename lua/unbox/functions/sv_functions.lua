function LUnbox:IsAdmin(ply)
    return LUnbox.Admins[ply:GetUserGroup()]
end

function LUnbox:Error(ply, int)
    if int == 1 then
        DarkRP.notify(ply, 1, 3, "You are the wrong rank ):")
    elseif int == 2 then
        DarkRP.notify(ply, 1, 3, "This dosnt exist ):")
    elseif int == 3 then
        DarkRP.notify(ply, 1, 3, "You cannot afford this ):")
    elseif int == 4 then
        DarkRP.notify(ply, 1, 3, "Purchased")       
    end
end

util.AddNetworkString("LUnbox:RarityEditted")
util.AddNetworkString("LUnbox:EditRarity")
net.Receive("LUnbox:EditRarity", function(len, ply)
    local int, name, r, g, b = net.ReadUInt(32), net.ReadString(), net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8)
    if not LUnbox.Config["Rarities"][int] then LUnbox:Error(ply, 2) return end
    if not LUnbox:IsAdmin(ply) then LUnbox:Error(ply, 1) return end
    DarkRP.notify(ply, 1, 3, "Successfully editted!")

    LUnbox.Config["Rarities"][int][1] = name
    LUnbox.Config["Rarities"][int][2] = Color(r, g, b, 255)
    LUnbox:SaveConfig()

    net.Start("LUnbox:RarityEditted")
    net.WriteUInt(1, 4)
    net.WriteUInt(int, 32)
    net.WriteString(name)
    net.WriteUInt(r, 8)
    net.WriteUInt(g, 8)
    net.WriteUInt(b, 8)
    net.Broadcast()
end)

util.AddNetworkString("LUnbox:DeleteRarity")
net.Receive("LUnbox:DeleteRarity", function(len, ply)
    local int = net.ReadUInt(32)
    if not LUnbox.Config["Rarities"][int] then LUnbox:Error(ply, 2) return end
    if not LUnbox:IsAdmin(ply) then LUnbox:Error(ply, 1) return end
    DarkRP.notify(ply, 1, 3, "Successfully deleted!")

    for k, v in ipairs(LUnbox.Config["Items"])  do
        if v.rarity == int then
            net.Start("LUnbox:RarityEditted")
            net.WriteUInt(4, 4)
            net.WriteUInt(k, 32)
            net.Broadcast()
            table.remove(LUnbox.Config["Items"], k)
        end

        if v.rarity > int then
            LUnbox.Config["Items"][k].rarity = v.rarity-1
        end
    end

    for k, v in ipairs(LUnbox.Config["Crates"])  do
        if v.rarity == int then
            net.Start("LUnbox:RarityEditted")
            net.WriteUInt(5, 4)
            net.WriteUInt(k, 32)
            net.Broadcast()
            table.remove(LUnbox.Config["Crates"], k)
        end

        if v.rarity > int then
            LUnbox.Config["Crates"][k].rarity = v.rarity-1
        end
    end

    table.remove(LUnbox.Config["Rarities"], int)
    LUnbox:SaveConfig()

    net.Start("LUnbox:RarityEditted")
    net.WriteUInt(2, 4)
    net.WriteUInt(int, 32)
    net.Broadcast()
end)

util.AddNetworkString("LUnbox:CreateRarity")
net.Receive("LUnbox:CreateRarity", function(len, ply)
    local name, r, g, b = net.ReadString(), net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8)
    if not LUnbox:IsAdmin(ply) then LUnbox:Error(ply, 1) return end
    DarkRP.notify(ply, 1, 3, "Successfully created!")

    local tbl = {
        name,
        Color(r, g, b, 255),
    }
    table.Add(LUnbox.Config["Rarities"], {tbl})
    LUnbox:SaveConfig()

    net.Start("LUnbox:RarityEditted")
    net.WriteUInt(3, 4)
    net.WriteString(name)
    net.WriteUInt(r, 8)
    net.WriteUInt(g, 8)
    net.WriteUInt(b, 8)
    net.Broadcast()
end)

util.AddNetworkString("LUnbox:ItemEditted")
util.AddNetworkString("LUnbox:EditItem")
net.Receive("LUnbox:EditItem", function(len, ply)
    local int, name, value, rarity, itemtype = net.ReadUInt(32), net.ReadString(), net.ReadString(), net.ReadUInt(32), net.ReadString()
    if not LUnbox.Config["Items"][int] then LUnbox:Error(ply, 2) return end
    if not LUnbox:IsAdmin(ply) then LUnbox:Error(ply, 1) return end

    DarkRP.notify(ply, 1, 3, "Successfully editted!")
    LUnbox.Config["Items"][int] = {
        rarity = rarity,
        img = "",
        model = "",
        name = name,
        type = itemtype,
        value = value,
    }
    LUnbox:SaveConfig()

    net.Start("LUnbox:ItemEditted")
    net.WriteUInt(1, 4)
    net.WriteUInt(int, 32)
    net.WriteString(name)
    net.WriteString(value)
    net.WriteUInt(rarity, 32)
    net.WriteString(itemtype)
    net.Broadcast()
end)

util.AddNetworkString("LUnbox:CreateItem")
net.Receive("LUnbox:CreateItem", function(len, ply)
    local name, value, rarity, itemtype = net.ReadString(), net.ReadString(), net.ReadUInt(32), net.ReadString()
    if not LUnbox:IsAdmin(ply) then LUnbox:Error(ply, 1) return end

    DarkRP.notify(ply, 1, 3, "Successfully created!")
    local tbl = {
        rarity = rarity,
        img = "",
        model = "",
        name = name,
        type = itemtype,
        value = value,
    }
    table.Add(LUnbox.Config["Items"], {tbl})
    LUnbox:SaveConfig()

    net.Start("LUnbox:ItemEditted")
    net.WriteUInt(3, 4)
    net.WriteString(name)
    net.WriteString(value)
    net.WriteUInt(rarity, 32)
    net.WriteString(itemtype)
    net.Broadcast()
end)

util.AddNetworkString("LUnbox:DeleteItem")
net.Receive("LUnbox:DeleteItem", function(len, ply)
    local int = net.ReadUInt(32)
    if not LUnbox.Config["Items"][int] then LUnbox:Error(ply, 2) return end
    if not LUnbox:IsAdmin(ply) then LUnbox:Error(ply, 1) return end

    DarkRP.notify(ply, 1, 3, "Successfully deleted!")

    for key, val in ipairs(LUnbox.Config["Crates"]) do
        for k, v in ipairs(val.items) do
            if v.item == int then
                table.remove(LUnbox.Config["Crates"][key].items, k)
                net.Start("LUnbox:ItemEditted")
                net.WriteUInt(4, 4)
                net.WriteUInt(key, 32)
                net.WriteUInt(k, 32)
                net.Broadcast()
            end
        end
    end

    table.remove(LUnbox.Config["Items"], int)

    LUnbox:SaveConfig()

    net.Start("LUnbox:ItemEditted")
    net.WriteUInt(2, 4)
    net.WriteUInt(int, 32)
    net.Broadcast()
end)

util.AddNetworkString("LUnbox:KeyEddited")
util.AddNetworkString("LUnbox:DeleteKey")
net.Receive("LUnbox:DeleteKey", function(len, ply)
    local int = net.ReadUInt(32)
    if not LUnbox.Config["Keys"][int] then LUnbox:Error(ply, 2) return end
    if not LUnbox:IsAdmin(ply) then LUnbox:Error(ply, 1) return end

    DarkRP.notify(ply, 1, 3, "Successfully deleted!")
    table.remove(LUnbox.Config["Keys"], int)

    LUnbox:SaveConfig()

    net.Start("LUnbox:KeyEddited")
    net.WriteUInt(1, 4)
    net.WriteUInt(int, 32)
    net.Broadcast()
end)

util.AddNetworkString("LUnbox:CreateKey")
net.Receive("LUnbox:CreateKey", function(len, ply)
    local name, price, r, g, b = net.ReadString(), net.ReadUInt(32), net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8)
    if not LUnbox:IsAdmin(ply) then LUnbox:Error(ply, 1) return end

    DarkRP.notify(ply, 1, 3, "Successfully created!")
    local tbl = {
        name = name,
        price = price,
        color = Color(r, g, b),
    }
    table.Add(LUnbox.Config["Keys"], {tbl})
    LUnbox:SaveConfig()

    net.Start("LUnbox:KeyEddited")
    net.WriteUInt(2, 4)
    net.WriteString(name)
    net.WriteUInt(price, 32)
    net.WriteUInt(r, 8)
    net.WriteUInt(g, 8)
    net.WriteUInt(b, 8)
    net.Broadcast()
end)

util.AddNetworkString("LUnbox:EditKey")
net.Receive("LUnbox:EditKey", function(len, ply)
    local int, name, price, r, g, b = net.ReadUInt(32), net.ReadString(), net.ReadUInt(32), net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8)
    if not LUnbox.Config["Keys"][int] then LUnbox:Error(ply, 2) return end
    if not LUnbox:IsAdmin(ply) then LUnbox:Error(ply, 1) return end

    DarkRP.notify(ply, 1, 3, "Successfully editted!")
    local tbl = {
        name = name,
        price = price,
        color = Color(r, g, b),
    }
    LUnbox.Config["Keys"][int] = tbl
    LUnbox:SaveConfig()

    net.Start("LUnbox:KeyEddited")
    net.WriteUInt(3, 4)
    net.WriteUInt(int, 32)
    net.WriteString(name)
    net.WriteUInt(price, 32)
    net.WriteUInt(r, 8)
    net.WriteUInt(g, 8)
    net.WriteUInt(b, 8)
    net.Broadcast()
end)

util.AddNetworkString("LUnbox:CrateEditted")
util.AddNetworkString("LUnbox:DeleteCrate")
net.Receive("LUnbox:DeleteCrate", function(len, ply)
    local int = net.ReadUInt(32)
    if not LUnbox.Config["Crates"][int] then LUnbox:Error(ply, 2) return end
    if not LUnbox:IsAdmin(ply) then LUnbox:Error(ply, 1) return end

    DarkRP.notify(ply, 1, 3, "Successfully deleted!")
    table.remove(LUnbox.Config["Crates"], int)

    LUnbox:SaveConfig()

    net.Start("LUnbox:CrateEditted")
    net.WriteUInt(1, 4)
    net.WriteUInt(int, 32)
    net.Broadcast()
end)

util.AddNetworkString("LUnbox:CreateCrate")
net.Receive("LUnbox:CreateCrate", function(len, ply)
    local name, price, imgurid, rarity, itemint, items = net.ReadString(), net.ReadUInt(32), net.ReadString(), net.ReadUInt(32), net.ReadUInt(32), {}
    if not LUnbox:IsAdmin(ply) then LUnbox:Error(ply, 1) return end
    for i = 1, itemint do
        local tbl = {
            item = net.ReadUInt(32),
            chance = net.ReadUInt(32),
        }
        table.Add(items, {tbl})
    end

    local tbl = {
        name = name,
        imgur = imgurid,
        price = price,
        rarity = rarity,
        type = "Crate",
        items = items,
    }
    table.Add(LUnbox.Config["Crates"], {tbl})
    LUnbox:SaveConfig()

    net.Start("LUnbox:CrateEditted")
    net.WriteUInt(2, 4)
    net.WriteString(name)
    net.WriteString("Crate")
    net.WriteUInt(price, 32)
    net.WriteString(imgurid)
    net.WriteUInt(rarity, 32)
    net.WriteUInt(itemint, 32)
    for k, v in ipairs(items) do
        net.WriteUInt(v.item, 32)
        net.WriteUInt(v.chance, 32)
    end
    net.Send(ply)
end)

util.AddNetworkString("LUnbox:EditCrate")
net.Receive("LUnbox:EditCrate", function(len, ply)
    local int, name, price, imgurid, rarity, itemint, items = net.ReadUInt(32), net.ReadString(), net.ReadUInt(32), net.ReadString(), net.ReadUInt(32), net.ReadUInt(32), {}
    if not LUnbox:IsAdmin(ply) then LUnbox:Error(ply, 1) return end
    for i = 1, itemint do
        local tbl = {
            item = net.ReadUInt(32),
            chance = net.ReadUInt(32),
        }
        table.Add(items, {tbl})
    end

    local tbl = {
        name = name,
        imgur = imgurid,
        price = price,
        rarity = rarity,
        type = "Crate",
        items = items,
    }
    LUnbox.Config["Crates"][int] = tbl
    LUnbox:SaveConfig()

    net.Start("LUnbox:CrateEditted")
    net.WriteUInt(3, 4)
    net.WriteUInt(int, 32)
    net.WriteString(name)
    net.WriteString("Crate")
    net.WriteUInt(price, 32)
    net.WriteString(imgurid)
    net.WriteUInt(rarity, 32)
    net.WriteUInt(itemint, 32)
    for k, v in ipairs(items) do
        net.WriteUInt(v.item, 32)
        net.WriteUInt(v.chance, 32)
    end
    net.Send(ply)
end)

util.AddNetworkString("LUnbox:PurchaseCrate")
net.Receive("LUnbox:PurchaseCrate", function(len, ply)
    local int, crateid = net.ReadUInt(2), net.ReadUInt(32)
    local data = LUnbox.Config["Crates"][crateid]
    if not data then LUnbox:Error(ply, 2) return end
 
    if int == 1 then
        if not ply:canAfford(data.price) then LUnbox:Error(ply, 3) return end
        ply:addMoney(-data.price)
        LUnbox:Error(ply, 4)

        LUnbox:AddItem(ply:SteamID(), crateid)
    else
        local price = math.floor(data.price/LUnbox.PricePerToken)
        if not LUnbox.CanAffordTokens(ply, price) then LUnbox:Error(ply, 3) return end
        LUnbox.RemoveTokens(ply, price)
        LUnbox:Error(ply, 4)

        LUnbox:AddItem(ply:SteamID(), crateid)
    end
end)

function LUnbox:CalculateChance(curchance, Items)
	local chanceSum = 0
	for k, v in ipairs(Items) do
		chanceSum = chanceSum + v.chance
	end

	chanceSum = chanceSum
	local percentage = math.Round((100 / chanceSum) * curchance)
	return percentage
end

util.AddNetworkString("LUnbox:OpenCrate")
net.Receive("LUnbox:OpenCrate", function(len, ply)
    local crateint = net.ReadUInt(32)
    if not LUnbox:HasCrate(ply:SteamID(), crateint) then LUnbox:Error(ply, 2) return end

    LUnbox:RemoveItem(ply:SteamID(), crateint)

    local trace = {}
    trace.start = ply:EyePos()
    trace.endpos = trace.start + ply:GetAimVector() * 85
    trace.filter = ply
    local tr = util.TraceLine(trace)

    local data = LUnbox.Config["Crates"][crateint]
    local rardat = LUnbox.Config["Rarities"][data.rarity]
    local crate = ents.Create("lunbox_crate")
    crate:SetPos(tr.HitPos)
    crate:SetCaseInt(crateint)
    crate:Spawn()
    crate:OpenBox()

    local num, int, itempicked = math.random(1, 100), 0, 1
    for k, v in ipairs(data.items) do
        local ch = LUnbox:CalculateChance(v.chance, data.items)
        int = int + ch
        if num < int then
            itempicked = v.item
            break
        end
    end
    crate:SetItemInt(itempicked)
    timer.Simple(2, function()
        local data = LUnbox.Config["Items"][itempicked]
        LUnbox.ItemTypes[data.type](ply, data.value)
    end)
end)

hook.Add("PlayerSay", "LUnbox:ChatCommand", function(ply, text)
    if LUnbox.ChatCommands[string.lower(text)] then
        ply:ConCommand("unbox")
    end
end)