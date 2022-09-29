AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua") 
include("shared.lua")

local casesUnlockSounds = ""
local raritySounds = ""

function ENT:Initialize()
	self:SetModel("models/voidcases/plastic_crate.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
 
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

    self:SetRenderMode(RENDERMODE_TRANSALPHA)
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
end


function ENT:Think()
    self:NextThink(CurTime())
    return true
end

function ENT:SetAttachmentItem(modelName, isIcon, isSkin, skin_)
    local attachment = self:LookupAttachment("attachment")
    local pos = self:GetAttachment(attachment)

    local model = ents.Create("prop_physics")
    model:SetModel( (!isIcon and modelName) or "models/hunter/blocks/cube025x025x025.mdl" )
    model:SetMoveType(MOVETYPE_NONE)
    model:SetCollisionGroup(COLLISION_GROUP_VEHICLE_CLIP)
    model:SetPos(self:GetPos() + self:GetUp() * 12)
    model:SetRenderMode(RENDERMODE_TRANSALPHA)
    model:SetColor(Color(0,0,0,0))
    model:SetParent(self, attachment)
    model:Spawn()

    self.itemModel = model
end

function ENT:OpenBox()
    self:PerformAnimation(0, 0, 0, 0, 1)
end

function ENT:PerformAnimation(model, isIcon, isSkin, skin_, rarity)
    if not IsValid(self) then return end

    self:ResetSequenceInfo()

    timer.Simple(0.28, function()
        if not IsValid(self) then return end
        self:EmitSound("voidcases/case_drop.wav")
    end)

    self:SetBodygroup(1, 1)
    self:ResetSequence("drop")

    local seqDuration = self:SequenceDuration()
    timer.Simple(seqDuration + 0.1, function()
        if not IsValid(self) then return end

        local unlockSound = casesUnlockSounds[self:GetModel()]
        self:EmitSound(unlockSound or "")
        self:SetAttachmentItem(model, isIcon, isSkin, skin_)

        self:SetBodygroup(2, 1)
        self:ResetSequence("open")

        seqDuration = self:SequenceDuration()
        timer.Simple(seqDuration, function ()
            if not IsValid(self) then return end
            self:SetBodygroup(2, 0)
            self:SetBodygroup(1, 0)

            self:ResetSequence("popout")
            self:SetPlaybackRate(0.5)
            self:SetShowText(true)

            local raritySound = raritySounds[rarity]
            self:EmitSound(raritySound or "")
            seqDuration = self:SequenceDuration()

            timer.Simple(seqDuration - 0.1, function()
                if not IsValid(self) then return end

                if (IsValid(self.itemModel) and self.itemModel:GetModelScale() != 1) then
                    self.itemModel:SetModelScale(1, 0.4)
                end

                self:ResetSequence("hover")
                self:SetPlaybackRate(1)
                timer.Simple(1, function()
                    if IsValid(self) then self:Remove() end
                end)
            end)
        end)
    end)
end
