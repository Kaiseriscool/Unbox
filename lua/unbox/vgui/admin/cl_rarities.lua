local function EditRarity(pnl, data, int)
    local frame = vgui.Create("PIXEL.Frame")
    frame:SetSize(400, 150)
    frame:SetTitle("Editing: "..data.name)
    frame:MakePopup()
    frame:Center()
    local oldthink = frame.Think
    frame.Think = function(s)
        oldthink(s)
        if not IsValid(pnl) then s:Remove() end
    end

    local color = frame:Add("PIXEL.ColorPicker")
    color:Dock(LEFT)
    color:SetWide(150)
    color:SetColor(data.col)
    color.value = data.col
    color.OnChange = function(s, col)
        s.value = col
    end

    local namebox = frame:Add("PIXEL.TextEntry")
    namebox:Dock(TOP)
    namebox:SetTall(35)
    namebox:SetValue(data.name)

    local save = frame:Add("PIXEL.TextButton")
    save:DockMargin(0, 5, 0, 0)
    save:Dock(TOP)
    save:SetTall(35)
    save:SetText("Save")
    save.DoClick = function(s)
        if color.value == data.color and namebox:GetValue() == data.name then return end
        frame:Remove()
        net.Start("LUnbox:EditRarity")
        net.WriteUInt(int, 32)
        net.WriteString(namebox:GetValue())
        net.WriteUInt(color.value.r, 8)
        net.WriteUInt(color.value.g, 8)
        net.WriteUInt(color.value.b, 8)
        net.SendToServer()
    end
end

local function CreateRarity(pnl)
    local frame = vgui.Create("PIXEL.Frame")
    frame:SetSize(400, 150)
    frame:SetTitle("Creating a rarity")
    frame:MakePopup()
    frame:Center()
    local oldthink = frame.Think
    frame.Think = function(s)
        oldthink(s)
        if not IsValid(pnl) then s:Remove() end
    end

    local color = frame:Add("PIXEL.ColorPicker")
    color:Dock(LEFT)
    color:SetWide(150)
    color:SetColor(color_white)
    color.value = color_white
    color.OnChange = function(s, col)
        s.value = col
    end

    local namebox = frame:Add("PIXEL.TextEntry")
    namebox:Dock(TOP)
    namebox:SetTall(35)
    namebox:SetValue("Rarity")

    local save = frame:Add("PIXEL.TextButton")
    save:DockMargin(0, 5, 0, 0)
    save:Dock(TOP)
    save:SetTall(35)
    save:SetText("Save")
    save.DoClick = function(s)
        net.Start("LUnbox:CreateRarity")
        net.WriteString(namebox:GetValue())
        net.WriteUInt(color.value.r, 8)
        net.WriteUInt(color.value.g, 8)
        net.WriteUInt(color.value.b, 8)
        net.SendToServer()
        frame:Remove()
    end
end

local PANEL = {}
function PANEL:Init()
    self.height, self.margin = PIXEL.Scale(30), PIXEL.Scale(6)
    self.CreateRarity = self:Add("PIXEL.TextButton")
    self.CreateRarity:DockMargin(self.margin, self.margin, self.margin, self.margin)
    self.CreateRarity:Dock(BOTTOM)
    self.CreateRarity:SetText("Create Rarity")
    self.CreateRarity.DoClick = function(s)
        CreateRarity(s)
    end

    self.ScrollPanel = self:Add("PIXEL.ScrollPanel")
    self.ScrollPanel:Dock(FILL)

    self.tbl = {}
    for k, v in ipairs(LUnbox.Config["Rarity"]) do
        self.tbl[k] = self:AddRarity(v, k)
    end

    hook.Add("LUnbox:RarityDeleted", "LUnbox:RarityDeleted", function()
        for k, v in pairs(self.tbl) do
            v:Remove()            
        end

        self.tbl = {}
        for k, v in ipairs(LUnbox.Config["Rarity"]) do
            self.tbl[k] = self:AddRarity(v, k)
        end
    end)

    hook.Add("LUnbox:RarityAdded", "LUnbox:AddRarity", function(int)
        self.tbl[int] = self:AddRarity(LUnbox.Config["Rarity"][int], int)
        timer.Simple(.1, function()
            self.ScrollPanel:Rebuild()
        end)
    end)

    hook.Add("LUnbox:RarityEdited", "LUnbox:RefreshRarity", function(int)
        if not self.tbl[int] then return end
        self.tbl[int].data = LUnbox.Config["Rarity"][int]
    end)
end

function PANEL:AddRarity(data, k)
    local rarity = self.ScrollPanel:Add("DPanel")
    rarity:DockMargin(self.margin, self.margin, self.margin, 0)
    rarity:Dock(TOP)
    rarity:SetTall(self.height)
    rarity.data = data
    rarity.Paint = function(s, w, h)
        PIXEL.DrawRoundedBox(self.margin, 0, 0, w, h, Color(32, 32, 37))

        surface.SetDrawColor(s.data.col)
        surface.DrawRect(5, 5, h-10, h-10)
        PIXEL.DrawSimpleText(s.data.name, "LUnbox:22", self.margin*2 + h-10, h/2, color_white, nil, TEXT_ALIGN_CENTER)
    end

    local editbutton = rarity:Add("PIXEL.ImgurButton", self)
    editbutton:DockMargin(0, 5, 0, 5)
    editbutton:Dock(RIGHT)
	editbutton:SetImgurID("hhnxDGH")
	editbutton:SetNormalColor(PIXEL.Colors.PrimaryText)
	editbutton:SetHoverColor(PIXEL.Colors.Negative)
	editbutton:SetClickColor(PIXEL.Colors.Negative)
	editbutton:SetDisabledColor(PIXEL.Colors.DisabledText)
	editbutton.DoClick = function(s)
        EditRarity(s, rarity.data, k)
    end

    local deletebutton = rarity:Add("PIXEL.ImgurButton", self)
    deletebutton:DockMargin(0, 5, 0, 5)
    deletebutton:Dock(RIGHT)
	deletebutton:SetImgurID("51ATKoY")
	deletebutton:SetNormalColor(PIXEL.Colors.PrimaryText)
	deletebutton:SetHoverColor(PIXEL.Colors.Negative)
	deletebutton:SetClickColor(PIXEL.Colors.Negative)
	deletebutton:SetDisabledColor(PIXEL.Colors.DisabledText)
	deletebutton.DoClick = function(s)
        net.Start("LUnbox:DeleteRarity")
        net.WriteUInt(k, 32)
        net.SendToServer()
    end
    return rarity
end
vgui.Register("LUnbox:Rarities", PANEL, "EditablePanel")