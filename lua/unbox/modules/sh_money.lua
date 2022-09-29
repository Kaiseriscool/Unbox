local DATA = {}
DATA.Name = "Money"
DATA.OnGive = function(ply, value)
    ply:addMoney(tonumber(value))
    DarkRP.notify(ply, 1, 3, "You have got $"..value.."!")
end
LUnbox.ItemTypes[DATA.Name] = DATA.OnGive