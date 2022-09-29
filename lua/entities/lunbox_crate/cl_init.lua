include("shared.lua")
function ENT:Draw()
    self:DrawModel()

    local data = LUnbox.Config["Crates"][self:GetCaseInt()]
    local rardat = LUnbox.Config["Rarity"][data.rarity]
    self:SetColor(rardat.col)

    if not self:GetShowText() then return end
    if not self:GetItemInt() then return end

    local item = LUnbox.Config["Items"][self:GetItemInt()]
    local plyAngles = LocalPlayer():EyeAngles()
    local angles = self:GetAngles()
    angles:RotateAroundAxis(self:GetRight(), 270)
    angles:RotateAroundAxis(self:GetForward(), 90)
    
    angles = Angle(angles.x, plyAngles.y - 90, angles.z)

    cam.Start3D2D( self:GetPos() + (self:GetUp()*40), angles, 0.2 )
        draw.SimpleText(item.name, "DermaLarge", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

function ENT:Think()
    self:NextThink(CurTime())
    return true
end