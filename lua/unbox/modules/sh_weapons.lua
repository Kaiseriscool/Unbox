local DATA = {}
DATA.Name = "Weapon"

DATA.OnGive = function(ply, value)
    if ply:HasWeapon(value) and LUnbox.Inventory ~= "Xenin" then return end

    if LUnbox.Inventory == "Xenin" then
        ply:XeninInventory():AddV2(value, DarkRP and "spawned_weapon" or wep, 1, {})
    else
        ply:Give(value)
        ply:SelectWeapon(value)
    end
end

-- local wep = ply:GetActiveWeapon()
--if not IsValid(wep) or not wep.GetItemData then print("NAN") return end
LUnbox.ItemTypes[DATA.Name] = DATA.OnGive -- Put your Lua here