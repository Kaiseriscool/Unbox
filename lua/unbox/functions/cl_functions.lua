function LUnbox:OpenMenu()
    if IsValid(LUnbox.Menu) then LUnbox.Menu:Remove() end
    LUnbox.Menu = vgui.Create("LUnbox:Frame")
    LUnbox.Menu:SetTitle(LUnbox.MenuText)
    LUnbox.Menu:SetSize(1000, 800)
    LUnbox.Menu:Center()
    LUnbox.Menu:MakePopup()

    local panel = LUnbox.Menu:Add("LUnbox:UnboxMenu")
    panel:Dock(FILL)
end

function LUnbox:CalculateChance(curchance, Items)
	local chanceSum = 0
	for k, v in ipairs(Items) do
		chanceSum = chanceSum + v.chance
	end

	chanceSum = chanceSum
	local percentage = math.Round((100 / chanceSum) * curchance)
	return percentage
end

LUnbox.Config = LUnbox.Config or {}
LUnbox.Config["Rarity"] = LUnbox.Config["Rarity"] or {}
LUnbox.Config["Items"] = LUnbox.Config["Items"] or {}
LUnbox.Config["Keys"] = LUnbox.Config["Keys"] or {}
LUnbox.Config["Crates"] = LUnbox.Config["Crates"] or {}
LUnbox.Inventory = LUnbox.Inventory or {}
net.Receive("LUnbox:NetworkConfig", function()
    local rarityint = net.ReadUInt(32)
    if rarityint > 0 then
        for i = 1, rarityint do
            local tbl = {
                name = net.ReadString(),
                col = Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8)),
            }
            table.Add(LUnbox.Config["Rarity"], {tbl})
        end
    end

    local itemsint = net.ReadUInt(32)
    if itemsint > 0 then
        for i = 1, itemsint do
            local tbl = {
                rarity = net.ReadUInt(32),
                img = net.ReadString(),
                model = net.ReadString(),
                name = net.ReadString(),
                type = net.ReadString(),
                value = net.ReadString(),
            }
            table.Add(LUnbox.Config["Items"], {tbl})
        end
    end

    local keysint = net.ReadUInt(32)
    if keysint > 0 then
        for i = 1, keysint do
            local tbl = {
                name = net.ReadString(),
                price = net.ReadUInt(32),
                col = Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8)),
            }
            table.Add(LUnbox.Config["Keys"], {tbl})
        end
    end

    local cratesint = net.ReadUInt(32)
    if cratesint > 0 then
        for i = 1, cratesint do
            local tbl = {
                name = net.ReadString(),
                type = net.ReadString(),
                price = net.ReadUInt(32),
                rarity = net.ReadUInt(32),
                imgur = net.ReadString(),
                items = {},
            }

            local itemsint = net.ReadUInt(32)
            if itemsint > 0 then
                for i = 1, itemsint do
                    local data = {
                        item = net.ReadString(),
                        chance = net.ReadUInt(32),
                    }
                    table.Add(tbl.items, {data})
                end
            end
            table.Add(LUnbox.Config["Crates"], {tbl})
        end
    end

    local inventoryint = net.ReadUInt(32)
    if inventoryint > 0 then
        for i = 1, inventoryint do
            LUnbox.Inventory[net.ReadUInt(32)] = net.ReadUInt(32)
        end
    end
end)

net.Receive("LUnbox:RarityEditted", function()
    local int = net.ReadUInt(4)
    if int == 1 then
        -- Rarity Changed
        local int, name, r, g, b = net.ReadUInt(32), net.ReadString(), net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8)
        LUnbox.Config["Rarity"][int] = {
            name = name,
            col = Color(r, g, b)
        }
        hook.Run("LUnbox:RarityEdited", int)
    elseif int == 2 then
        -- Rarity Deleted
        local int = net.ReadUInt(32)
        table.remove(LUnbox.Config["Rarity"], int)
        hook.Run("LUnbox:RarityDeleted", int)

        for k, v in ipairs(LUnbox.Config["Items"])  do
            if v.rarity > int then
                LUnbox.Config["Items"][k].rarity = v.rarity-1
                hook.Run("LUnbox:ItemEdited", int)
            end
        end

        for k, v in ipairs(LUnbox.Config["Crates"])  do
            if v.rarity > int then
                LUnbox.Config["Crates"][k].rarity = v.rarity-1
                hook.Run("LUnbox:CreateEditted", k)
            end
        end
    elseif int == 3 then
        local tbl = {
            name = net.ReadString(),
            col = Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8)),
        }
        table.Add(LUnbox.Config["Rarity"], {tbl})
        hook.Run("LUnbox:RarityAdded", #LUnbox.Config["Rarity"])
    elseif int == 4 then
        local int = net.ReadUInt(32)
        table.remove(LUnbox.Config["Items"], int)
        hook.Run("LUnbox:ItemDeleted", int)
    elseif int == 5 then
        local int = net.ReadUInt(32)
        table.remove(LUnbox.Config["Crates"], int)
        hook.Run("LUnbox:CrateDeleted", int)
    end
end)

net.Receive("LUnbox:ItemEditted", function()
    local int = net.ReadUInt(4)
    if int == 1 then
        -- editted
        local int, name, value, rarity, itemtype = net.ReadUInt(32), net.ReadString(), net.ReadString(), net.ReadUInt(32), net.ReadString()
        LUnbox.Config["Items"][int] = {
            rarity = rarity,
            img = "",
            model = "",
            name = name,
            type = itemtype,
            value = value,
        }
        hook.Run("LUnbox:ItemEdited", int)
    elseif int == 2 then
        -- delted
        local int = net.ReadUInt(32)
        table.remove(LUnbox.Config["Items"], int)
        hook.Run("LUnbox:ItemDeleted", int)
    elseif int == 3 then
        -- created
        local name, value, rarity, itemtype = net.ReadString(), net.ReadString(), net.ReadUInt(32), net.ReadString()
        local tbl = {
            rarity = rarity,
            img = "",
            model = "",
            name = name,
            type = itemtype,
            value = value,
        }
        table.Add(LUnbox.Config["Items"], {tbl})
        hook.Run("LUnbox:ItemCreated", #LUnbox.Config["Items"])
    elseif int == 4 then
        -- Crate edited
        local int, int1 = net.ReadUInt(32), net.ReadUInt(32)
        table.remove(LUnbox.Config["Crates"][int].items, int1)
        hook.Run("LUnbox:CreateEditted", int)
    end
end)

net.Receive("LUnbox:KeyEddited", function()
    local int = net.ReadUInt(4)
    if int == 1 then
        -- key deleted
        local int = net.ReadUInt(32)
        table.remove(LUnbox.Config["Keys"], int)
        hook.Run("LUnbox:KeyDeleted", int)
    elseif int == 2 then
        -- key created
        local name, price, r, g, b = net.ReadString(), net.ReadUInt(32), net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8)
        local tbl = {
            name = name,
            price = price,
            col = Color(r, g, b),
        }
        table.Add(LUnbox.Config["Keys"], {tbl})
        hook.Run("LUnbox:KeyCreated", #LUnbox.Config["Keys"])
    elseif int == 3 then
        -- key edited
        local int, name, price, r, g, b = net.ReadUInt(32), net.ReadString(), net.ReadUInt(32), net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8)
        LUnbox.Config["Keys"][int] = {
            name = name,
            price = price,
            col = Color(r, g, b),
        }
        hook.Run("LUnbox:KeyEditted", int)
    end
end)

net.Receive("LUnbox:CrateEditted", function()
    local int = net.ReadUInt(4)
    if int == 1 then
        -- Crate deleted
        local int = net.ReadUInt(32)
        table.remove(LUnbox.Config["Crates"], int)
        hook.Run("LUnbox:CrateDeleted", int)
    elseif int == 2 then
        -- crate create
        local name, itemtype, price, imgurid, rarity, itemint, items = net.ReadString(), net.ReadString(), net.ReadUInt(32), net.ReadString(), net.ReadUInt(32), net.ReadUInt(32), {}
        for i = 1, itemint do
            local tbl = {
                item = net.ReadUInt(32),
                chance = net.ReadUInt(32),
            }
            table.Add(items, {tbl})
        end

        local tbl = {
            name = name,
            type = itemtype,
            price = price,
            rarity = rarity,
            imgur = imgurid,
            items = items,
        }
        table.Add(LUnbox.Config["Crates"], {tbl})
        hook.Run("LUnbox:CrateCreated", #LUnbox.Config["Crates"])
    elseif int == 3 then
        local int, name, itemtype, price, imgurid, rarity, itemint, items = net.ReadUInt(32), net.ReadString(), net.ReadString(), net.ReadUInt(32), net.ReadString(), net.ReadUInt(32), net.ReadUInt(32), {}
        for i = 1, itemint do
            local tbl = {
                item = net.ReadUInt(32),
                chance = net.ReadUInt(32),
            }
            table.Add(items, {tbl})
        end

        local tbl = {
            name = name,
            type = itemtype,
            price = price,
            rarity = rarity,
            imgur = imgurid,
            items = items,
        }
        LUnbox.Config["Crates"][int] = tbl
        hook.Run("LUnbox:CreateEditted", int)
    end
end)

net.Receive("LUnbox:Inventory", function()
    local int = net.ReadUInt(2)
    if int == 1 then
        -- add item
        local crateid = net.ReadUInt(32)
        if LUnbox.Inventory[crateid] then
            LUnbox.Inventory[crateid] = LUnbox.Inventory[crateid] + 1
        else
            LUnbox.Inventory[crateid] = 1
        end
        hook.Run("LUnbox:InventoryAdd", crateid)
    elseif int == 2 then
        -- remove item
        local crateid = net.ReadUInt(32)
        LUnbox.Inventory[crateid] = LUnbox.Inventory[crateid] - 1
        hook.Run("LUnbox:InventoryRemove", crateid)
    end
end)

concommand.Add("unbox", function()
    LUnbox:OpenMenu()
end)