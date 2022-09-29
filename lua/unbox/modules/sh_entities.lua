local DATA = {}
DATA.Name = "Entities"

DATA.OnGive = function(ply, value)
    local ent = ents.Create(value)
    ent:SetPos(ply:GetPos() + (ply:GetForward() * 3) + Vector(0, 0, 5))
    ent:Spawn()
    --ent:SetOwner(ply)
end

--ply:AddInventoryItem(ent)
--ent:Remove()
--DarkRP.notify(ply, 1, 3, "The item has gone into your inventory!")
LUnbox.ItemTypes[DATA.Name] = DATA.OnGive