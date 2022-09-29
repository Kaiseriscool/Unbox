ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName		= "Crate"
ENT.Author			= "VoidCases"
ENT.Category = "VoidCases"
ENT.Spawnable = true

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "CaseInt")
    self:NetworkVar("Int", 1, "ItemInt")
    self:NetworkVar("Bool", 0, "ShowText")
end