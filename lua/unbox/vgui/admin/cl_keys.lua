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

    local price = frame:Add("PIXEL.TextEntry")
    price:DockMargin(0, 5, 0, 0)
    price:Dock(TOP)
    price:SetTall(35)
    price:SetPlaceholderText("Price")
    price:SetValue(data.price)
    price:SetNumeric(true)

    local save = frame:Add("PIXEL.TextButton")
    save:DockMargin(0, 5, 0, 0)
    save:Dock(TOP)
    save:SetTall(35)
    save:SetText("Save")
    save.DoClick = function(s)
        net.Start("LUnbox:EditKey")
        net.WriteUInt(int, 32)
        net.WriteString(namebox:GetValue())
        net.WriteUInt(tonumber(price:GetValue()), 32)
        net.WriteUInt(color.value.r, 8)
        net.WriteUInt(color.value.g, 8)
        net.WriteUInt(color.value.b, 8)
        net.SendToServer()
        frame:Remove()
    end
end

local function CreateItem(pnl)
    local frame = vgui.Create("PIXEL.Frame")
    frame:SetSize(400, 157)
    frame:SetTitle("Creating a key")
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
    namebox:SetPlaceholderText("Key Name")

    local price = frame:Add("PIXEL.TextEntry")
    price:DockMargin(0, 5, 0, 0)
    price:Dock(TOP)
    price:SetTall(35)
    price:SetPlaceholderText("Price")
    price:SetValue(0)
    price:SetNumeric(true)

    local save = frame:Add("PIXEL.TextButton")
    save:DockMargin(0, 5, 0, 0)
    save:Dock(TOP)
    save:SetTall(35)
    save:SetText("Save")
    save.DoClick = function(s)
        net.Start("LUnbox:CreateKey")
        net.WriteString(namebox:GetValue())
        net.WriteUInt(tonumber(price:GetValue()), 32)
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
    self.CreateItem = self:Add("PIXEL.TextButton")
    self.CreateItem:DockMargin(self.margin, self.margin, self.margin, self.margin)
    self.CreateItem:Dock(BOTTOM)
    self.CreateItem:SetText("Create Keys")
    self.CreateItem.DoClick = function(s)
        CreateItem(s)
    end

    self.ScrollPanel = self:Add("PIXEL.ScrollPanel")
    self.ScrollPanel:Dock(FILL)

    self.tbl = {}
    for k, v in ipairs(LUnbox.Config["Keys"]) do
        self.tbl[k] = self:AddKey(v, k)
    end

    hook.Add("LUnbox:KeyDeleted", "LUnbox:KeyDeleted", function(int)
        for k, v in pairs(self.tbl) do
            v:Remove()
        end

        for k, v in ipairs(LUnbox.Config["Keys"]) do
            self.tbl[k] = self:AddKey(v, k)
        end
    end)

    hook.Add("LUnbox:KeyCreated", "LUnbox:KeyCreated", function(int)
        self.tbl[int] = self:AddKey(LUnbox.Config["Keys"][int], int)
        timer.Simple(.1, function()
            self.ScrollPanel:Rebuild()
        end)
    end)

    hook.Add("LUnbox:KeyEditted", "LUnbox:KeyEditted", function(int)
        if not self.tbl[int] then return end
        self.tbl[int].data = LUnbox.Config["Keys"][int]
    end)
end

function PANEL:AddKey(data, k)
    local key = self.ScrollPanel:Add("DPanel")
    key:DockMargin(self.margin, self.margin, self.margin, 0)
    key:Dock(TOP)
    key:SetTall(self.height)
    key.data = data
    key.Paint = function(s, w, h)
        PIXEL.DrawRoundedBox(self.margin, 0, 0, w, h, Color(32, 32, 37))

        col = s.data.col
        surface.SetDrawColor(col)
        surface.DrawRect(5, 5, h-10, h-10)
        PIXEL.DrawSimpleText(s.data.name, "LUnbox:22", self.margin*2 + h-10, h/2, color_white, nil, TEXT_ALIGN_CENTER)
    end

    local editbutton = key:Add("PIXEL.ImgurButton", self)
    editbutton:DockMargin(0, 5, 0, 5)
    editbutton:Dock(RIGHT)
	editbutton:SetImgurID("hhnxDGH")
	editbutton:SetNormalColor(PIXEL.Colors.PrimaryText)
	editbutton:SetHoverColor(PIXEL.Colors.Negative)
	editbutton:SetClickColor(PIXEL.Colors.Negative)
	editbutton:SetDisabledColor(PIXEL.Colors.DisabledText)
	editbutton.DoClick = function(s)
        EditRarity(s, key.data, k)
    end

    local deletebutton = key:Add("PIXEL.ImgurButton", self)
    deletebutton:DockMargin(0, 5, 0, 5)
    deletebutton:Dock(RIGHT)
	deletebutton:SetImgurID("51ATKoY")
	deletebutton:SetNormalColor(PIXEL.Colors.PrimaryText)
	deletebutton:SetHoverColor(PIXEL.Colors.Negative)
	deletebutton:SetClickColor(PIXEL.Colors.Negative)
	deletebutton:SetDisabledColor(PIXEL.Colors.DisabledText)
	deletebutton.DoClick = function(s)
        net.Start("LUnbox:DeleteKey")
        net.WriteUInt(k, 32)
        net.SendToServer()
    end
    return key
end
vgui.Register("LUnbox:Keys", PANEL, "EditablePanel")