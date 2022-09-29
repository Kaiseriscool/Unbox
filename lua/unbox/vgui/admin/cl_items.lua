local function EditItem(k, data, pnl)
    local frame = vgui.Create("PIXEL.Frame")
    frame:SetSize(400, 238)
    frame:SetTitle("Editing: "..data.name)
    frame:MakePopup()
    frame:Center()
    local oldthink = frame.Think
    frame.Think = function(s)
        oldthink(s)
        if not IsValid(pnl) then s:Remove() end
    end

    local itemname = frame:Add("PIXEL.TextEntry")
    itemname:Dock(TOP)
    itemname:SetTall(35)
    itemname:SetValue(data.name)
    itemname:SetPlaceholderText("Item Name")

    local itemvalue = frame:Add("PIXEL.TextEntry")
    itemvalue:DockMargin(0, 5, 0, 0)
    itemvalue:Dock(TOP)
    itemvalue:SetTall(35)
    itemvalue:SetValue(data.value)
    itemvalue:SetPlaceholderText("Item Value (eg value or class")

    local rarity = frame:Add("PIXEL.ComboBox")
    rarity:DockMargin(0, 5, 0, 0)
    rarity:Dock(TOP)
    rarity:SetTall(35)
    rarity:SetValue(data.name)
    rarity:SetSizeToText(false)
    rarity:SetSortItems(false)
    if #LUnbox.Config["Rarity"] > 0 then
        for k, v in ipairs(LUnbox.Config["Rarity"]) do
            rarity:AddChoice(v.name, k)
            if k == data.rarity then
                rarity:ChooseOption(LUnbox.Config["Rarity"][data.rarity].name, k)
            end
        end
    end

    local itemtype = frame:Add("PIXEL.ComboBox")
    itemtype:DockMargin(0, 5, 0, 0)
    itemtype:Dock(TOP)
    itemtype:SetTall(35)
    itemtype:SetValue(data.name)
    itemtype:SetSizeToText(false)
    local int = 1
    for k, v in pairs(LUnbox.ItemTypes) do
        itemtype:AddChoice(k, k)
        if k == data.type then
            itemtype:ChooseOption(data.type, int)
        end
        int = int + 1
    end

    local save = frame:Add("PIXEL.TextButton")
    save:DockMargin(0, 5, 0, 0)
    save:Dock(TOP)
    save:SetTall(35)
    save:SetText("Save")
    save.DoClick = function(s)
        local text, data1 = rarity:GetSelected()
        local text, data2 = itemtype:GetSelected()
        net.Start("LUnbox:EditItem")
        net.WriteUInt(k, 32)
        net.WriteString(itemname:GetValue())
        net.WriteString(itemvalue:GetValue())
        net.WriteUInt(tonumber(data1), 32)
        net.WriteString(data2)
        net.SendToServer()

        frame:Remove()
    end
end

local function CreateItem(pnl)
    local frame = vgui.Create("PIXEL.Frame")
    frame:SetSize(400, 238)
    frame:SetTitle("Creating Item")
    frame:MakePopup()
    frame:Center()
    local oldthink = frame.Think
    frame.Think = function(s)
        oldthink(s)
        if not IsValid(pnl) then s:Remove() end
    end

    local itemname = frame:Add("PIXEL.TextEntry")
    itemname:Dock(TOP)
    itemname:SetTall(35)
    itemname:SetPlaceholderText("Item Name")

    local itemvalue = frame:Add("PIXEL.TextEntry")
    itemvalue:DockMargin(0, 5, 0, 0)
    itemvalue:Dock(TOP)
    itemvalue:SetTall(35)
    itemvalue:SetPlaceholderText("Item Value (eg value or class")

    local rarity = frame:Add("PIXEL.ComboBox")
    rarity:DockMargin(0, 5, 0, 0)
    rarity:Dock(TOP)
    rarity:SetTall(35)
    rarity:SetSizeToText(false)
    rarity:SetSortItems(false)
    for k, v in ipairs(LUnbox.Config["Rarity"]) do
        rarity:AddChoice(v.name, k)
    end
    rarity:ChooseOptionID(1)

    local itemtype = frame:Add("PIXEL.ComboBox")
    itemtype:DockMargin(0, 5, 0, 0)
    itemtype:Dock(TOP)
    itemtype:SetTall(35)
    itemtype:SetSizeToText(false)
    local int = 1
    for k, v in pairs(LUnbox.ItemTypes) do
        itemtype:AddChoice(k, k)
        if int == 1 then
            itemtype:ChooseOption(k, 1)
        end
        int = int + 1
    end

    local save = frame:Add("PIXEL.TextButton")
    save:DockMargin(0, 5, 0, 0)
    save:Dock(TOP)
    save:SetTall(35)
    save:SetText("Save")
    save.DoClick = function(s)
        local text, data1 = rarity:GetSelected()
        local text, data2 = itemtype:GetSelected()
        net.Start("LUnbox:CreateItem")
        net.WriteString(itemname:GetValue())
        net.WriteString(itemvalue:GetValue())
        net.WriteUInt(tonumber(data1), 32)
        net.WriteString(data2)
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
    self.CreateItem:SetText("Create Item")
    self.CreateItem.DoClick = function(s)
        CreateItem(s)
    end

    self.ScrollPanel = self:Add("PIXEL.ScrollPanel")
    self.ScrollPanel:Dock(FILL)

    self.tbl = {}
    for k, v in ipairs(LUnbox.Config["Items"]) do
        self.tbl[k] = self:AddItem(v, k)
    end

    hook.Add("LUnbox:ItemEdited", "LUnbox:ItemEdited", function(int)
        if not IsValid(self) then return end
        self.tbl[int].data = LUnbox.Config["Items"][int]
    end)

    hook.Add("LUnbox:ItemDeleted", "LUnbox:ItemDeleted", function(int)
        if not IsValid(self) then return end
        if self.tbl then
            for k, v in pairs(self.tbl) do
                v:Remove()
            end
        end

        self.tbl = {}
        for k, v in ipairs(LUnbox.Config["Items"]) do
            self.tbl[k] = self:AddItem(v, k)
        end
    end)

    hook.Add("LUnbox:ItemCreated", "LUnbox:ItemCreated", function(int)
        self.tbl[int] = self:AddItem(LUnbox.Config["Items"][int], int)
        timer.Simple(.1, function()
            self.ScrollPanel:Rebuild()
        end)
    end)
end

function PANEL:AddItem(data, k)
    local rarity = self.ScrollPanel:Add("DPanel")
    rarity:DockMargin(self.margin, self.margin, self.margin, 0)
    rarity:Dock(TOP)
    rarity:SetTall(self.height)
    rarity.data = data
    rarity.Paint = function(s, w, h)
        PIXEL.DrawRoundedBox(self.margin, 0, 0, w, h, Color(32, 32, 37))

        col = LUnbox.Config["Rarity"][s.data.rarity].col
        surface.SetDrawColor(col)
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
        EditItem(k, rarity.data, s)
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
        net.Start("LUnbox:DeleteItem")
        net.WriteUInt(k, 32)
        net.SendToServer()
    end
    return rarity
end
vgui.Register("LUnbox:Items", PANEL, "EditablePanel")