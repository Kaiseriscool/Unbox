local function ItemUsed(items, itemid)
    if not items or #items < 1 then return false end
    for k, v in ipairs(items) do
        if v.itemid == itemid then return true end
    end
    return false
end

local function AddItem(pnl, itemstbl)
    local frame = vgui.Create("PIXEL.Frame")
    frame:SetSize(400, 190)
    frame:SetTitle("Add Item")
    frame:MakePopup()
    frame:Center()
    local oldthink = frame.Think
    frame.Think = function(s)
        oldthink(s)
        if not IsValid(pnl) then s:Remove() end
    end

    local copy = table.Copy(itemstbl)
    local items = frame:Add("PIXEL.ComboBox")
    items:DockMargin(5, 5, 5, 0)
    items:Dock(TOP)
    items:SetTall(35)
    items:SetSizeToText(false)
    items:SetSortItems(false)
    for k, v in ipairs(LUnbox.Config["Items"]) do
        if ItemUsed(copy, k) then continue end
        items:AddChoice(v.name, k)
    end
    items:ChooseOptionID(1)

    local ChanceBox = frame:Add("PIXEL.TextEntry")
    ChanceBox:DockMargin(5, 5, 5, 0)
    ChanceBox:Dock(TOP)
    ChanceBox:SetTall(35)
    ChanceBox:SetPlaceholderText("Chance")
    ChanceBox:SetNumeric(true)
    ChanceBox:SetValue(100)

    local ChanceLabel = frame:Add("PIXEL.Label")
    ChanceLabel:DockMargin(5, 5, 5, 0)
    ChanceLabel:Dock(TOP)
    ChanceLabel:SetTall(35)
    ChanceLabel:SetText("")
    ChanceLabel:SetTextAlign(TEXT_ALIGN_CENTER)
    ChanceLabel:SetFont("LUnbox:22")
    ChanceLabel:SetAutoHeight(true)
    ChanceLabel.Think = function(s)
        local newtbl = table.Copy(itemstbl)
        local tbl = {
            chance = ChanceBox:GetValue() or 0,
        }
        table.Add(newtbl, {tbl})
        s:SetText(LUnbox:CalculateChance(tonumber(ChanceBox:GetValue()) or 0, newtbl).."%")
    end

    local add = frame:Add("PIXEL.TextButton")
    add:DockMargin(5, 5, 5, 0)
    add:Dock(TOP)
    add:SetText("Add")
    add.DoClick = function()
        frame:Remove()
        pnl.AddItemsData(items:GetOptionData(items:GetSelectedID()), tonumber(ChanceBox:GetValue()) or 0)
    end
end

local function CreateCrate(pnl)
    local margin = PIXEL.Scale(6)
    local Items = {}
    local frame = vgui.Create("PIXEL.Frame")
    frame:SetSize(600, 600)
    frame:SetTitle("Creating a case")
    frame:MakePopup()
    frame:Center()
    local oldthink = frame.Think
    frame.Think = function(s)
        oldthink(s)
        if not IsValid(pnl) then s:Remove() end
    end

    local topbox = frame:Add("DPanel")
    topbox:DockMargin(margin, 0, margin, margin)
    topbox:Dock(TOP)
    topbox:SetTall(160)
    topbox.Paint = nil
    topbox.PerformLayout = function(s, w, h)
        if IsValid(topbox.imgurbox) then topbox.imgurbox:SetWide(h) end
    end

    topbox.imgurbox = topbox:Add("DPanel")
    topbox.imgurbox:Dock(LEFT)
    topbox.imgurbox.Paint = function(s, w, h)
        if not s.ImgurID then PIXEL.DrawProgressWheel(0, 0, w, h, PIXEL.Colors.Negative) return end
        PIXEL.DrawImgur(0, 0, w, h, s.ImgurID, color_white)
    end

    local namebox = topbox:Add("PIXEL.TextEntry")
    namebox:DockMargin(margin, 0, 0, 0)
    namebox:Dock(TOP)
    namebox:SetTall(35)
    namebox:SetPlaceholderText("Crate Name")

    local price = topbox:Add("PIXEL.TextEntry")
    price:DockMargin(margin, margin, 0, 0)
    price:Dock(TOP)
    price:SetTall(35)
    price:SetPlaceholderText("Crate Price")
    price:SetNumeric(true)

    local imgurid = topbox:Add("PIXEL.TextEntry")
    imgurid:DockMargin(margin, margin, 0, 0)
    imgurid:Dock(TOP)
    imgurid:SetTall(35)
    imgurid:SetPlaceholderText("Imgur ID (press enter to view)")
    imgurid.OnEnter = function(s, val)
        topbox.imgurbox.ImgurID = s:GetValue()
    end

    local rarity = topbox:Add("PIXEL.ComboBox")
    rarity:DockMargin(margin, margin, 0, 0)
    rarity:Dock(TOP)
    rarity:SetTall(35)
    rarity:SetSizeToText(false)
    rarity:SetSortItems(false)
    if #LUnbox.Config["Rarity"] > 0 then
        for k, v in ipairs(LUnbox.Config["Rarity"]) do
            rarity:AddChoice(v.name, k)
        end
    end
    rarity:ChooseOptionID(1)

    local saveButton = frame:Add("PIXEL.TextButton")
    saveButton:DockMargin(margin, margin, margin, margin)
    saveButton:Dock(BOTTOM)
    saveButton:SetTall(35)
    saveButton:SetText("Create case")
    saveButton.DoClick = function()
        net.Start("LUnbox:CreateCrate")
        net.WriteString(namebox:GetValue())
        net.WriteUInt(price:GetValue(), 32)
        net.WriteString(imgurid:GetValue())
        net.WriteUInt(rarity:GetOptionData(rarity:GetSelectedID()), 32)
        net.WriteUInt(#Items, 32)
        for k, v in ipairs(Items) do
            net.WriteUInt(v.itemid, 32)
            net.WriteUInt(v.chance, 32)
        end
        net.SendToServer()
        frame:Remove()
    end

    local scrollpanel = frame:Add("PIXEL.ScrollPanel")
    scrollpanel:Dock(FILL)

    local additembutton = scrollpanel:Add("PIXEL.TextButton")
    additembutton:DockMargin(margin, 0, margin, 0)
    additembutton:Dock(TOP)
    additembutton:SetTall(35)
    additembutton:SetText("Add Item")
    additembutton.AddItemsData = function(itemint, chance)
        local tbl = {
            itemid = itemint,
            chance = chance,
        }
        table.Add(Items, {tbl})
        local int = #Items

        local panel = scrollpanel:Add("DPanel")
        panel:DockMargin(margin, margin, margin, 0)
        panel:Dock(TOP)
        panel:SetTall(30)
        panel.Paint = function(s, w, h)
            PIXEL.DrawRoundedBox(PIXEL.Scale(6), 0, 0, w, h, Color(32, 32, 37))
            PIXEL.DrawSimpleText(LUnbox.Config["Items"][itemint].name.." "..(LUnbox:CalculateChance(chance, Items)).."%", "LUnbox:22", 0 + margin, h/2, color_white, nil, TEXT_ALIGN_CENTER)
        end

        local deletebutton = panel:Add("PIXEL.ImgurButton", self)
        deletebutton:DockMargin(0, 5, 0, 5)
        deletebutton:Dock(RIGHT)
        deletebutton:SetImgurID("51ATKoY")
        deletebutton:SetNormalColor(PIXEL.Colors.PrimaryText)
        deletebutton:SetHoverColor(PIXEL.Colors.Negative)
        deletebutton:SetClickColor(PIXEL.Colors.Negative)
        deletebutton:SetDisabledColor(PIXEL.Colors.DisabledText)
        deletebutton.DoClick = function(s)
            table.remove(Items, int)
            panel:Remove()
        end

        timer.Simple(.1, function()
            scrollpanel:Rebuild()
        end)
    end
    additembutton.DoClick = function(s)
        AddItem(s, Items)
    end
end

local function EditCrate(int, pnl, data)
    local margin = PIXEL.Scale(6)
    local Items = {}
    local frame = vgui.Create("PIXEL.Frame")
    frame:SetSize(600, 600)
    frame:SetTitle("Editing "..data.name)
    frame:MakePopup()
    frame:Center()
    local oldthink = frame.Think
    frame.Think = function(s)
        oldthink(s)
        if not IsValid(pnl) then s:Remove() end
    end

    local topbox = frame:Add("DPanel")
    topbox:DockMargin(margin, 0, margin, margin)
    topbox:Dock(TOP)
    topbox:SetTall(160)
    topbox.Paint = nil
    topbox.PerformLayout = function(s, w, h)
        if IsValid(topbox.imgurbox) then topbox.imgurbox:SetWide(h) end
    end

    topbox.imgurbox = topbox:Add("DPanel")
    topbox.imgurbox:Dock(LEFT)
    topbox.imgurbox.Paint = function(s, w, h)
        PIXEL.DrawImgur(0, 0, w, h, data.imgur, color_white)
    end

    local namebox = topbox:Add("PIXEL.TextEntry")
    namebox:DockMargin(margin, 0, 0, 0)
    namebox:Dock(TOP)
    namebox:SetTall(35)
    namebox:SetValue(data.name)

    local price = topbox:Add("PIXEL.TextEntry")
    price:DockMargin(margin, margin, 0, 0)
    price:Dock(TOP)
    price:SetTall(35)
    price:SetValue(data.price)
    price:SetNumeric(true)

    local imgurid = topbox:Add("PIXEL.TextEntry")
    imgurid:DockMargin(margin, margin, 0, 0)
    imgurid:Dock(TOP)
    imgurid:SetTall(35)
    imgurid:SetValue(data.imgur)
    imgurid.OnEnter = function(s, val)
        data.imgur = s:GetValue()
    end

    local rarity = topbox:Add("PIXEL.ComboBox")
    rarity:DockMargin(margin, margin, 0, 0)
    rarity:Dock(TOP)
    rarity:SetTall(35)
    rarity:SetSizeToText(false)
    rarity:SetSortItems(false)
    if #LUnbox.Config["Rarity"] > 0 then
        for k, v in ipairs(LUnbox.Config["Rarity"]) do
            rarity:AddChoice(v.name, k)
            if k == data.rarity then
                rarity:ChooseOptionID(k)
            end
        end
    end

    local saveButton = frame:Add("PIXEL.TextButton")
    saveButton:DockMargin(margin, margin, margin, margin)
    saveButton:Dock(BOTTOM)
    saveButton:SetTall(35)
    saveButton:SetText("Edit case")
    saveButton.DoClick = function()
        net.Start("LUnbox:EditCrate")
        net.WriteUInt(int, 32)
        net.WriteString(namebox:GetValue())
        net.WriteUInt(price:GetValue(), 32)
        net.WriteString(imgurid:GetValue())
        net.WriteUInt(rarity:GetOptionData(rarity:GetSelectedID()), 32)
        net.WriteUInt(#Items, 32)
        for k, v in ipairs(Items) do
            net.WriteUInt(v.itemid, 32)
            net.WriteUInt(v.chance, 32)
        end
        net.SendToServer()
        frame:Remove()
    end

    local scrollpanel = frame:Add("PIXEL.ScrollPanel")
    scrollpanel:Dock(FILL)

    local additembutton = scrollpanel:Add("PIXEL.TextButton")
    additembutton:DockMargin(margin, 0, margin, 0)
    additembutton:Dock(TOP)
    additembutton:SetTall(35)
    additembutton:SetText("Add Item")
    additembutton.AddItemsData = function(itemint, chance)
        local tbl = {
            itemid = itemint,
            chance = chance,
        }
        table.Add(Items, {tbl})
        local int = #Items

        local panel = scrollpanel:Add("DPanel")
        panel:DockMargin(margin, margin, margin, 0)
        panel:Dock(TOP)
        panel:SetTall(30)
        panel.Paint = function(s, w, h)
            PIXEL.DrawRoundedBox(PIXEL.Scale(6), 0, 0, w, h, Color(32, 32, 37))
            PIXEL.DrawSimpleText(LUnbox.Config["Items"][itemint].name.." "..(LUnbox:CalculateChance(chance, Items)).."%", "LUnbox:22", 0 + margin, h/2, color_white, nil, TEXT_ALIGN_CENTER)
        end

        local deletebutton = panel:Add("PIXEL.ImgurButton", self)
        deletebutton:DockMargin(0, 5, 0, 5)
        deletebutton:Dock(RIGHT)
        deletebutton:SetImgurID("51ATKoY")
        deletebutton:SetNormalColor(PIXEL.Colors.PrimaryText)
        deletebutton:SetHoverColor(PIXEL.Colors.Negative)
        deletebutton:SetClickColor(PIXEL.Colors.Negative)
        deletebutton:SetDisabledColor(PIXEL.Colors.DisabledText)
        deletebutton.DoClick = function(s)
            table.remove(Items, int)
            panel:Remove()
        end

        timer.Simple(.1, function()
            scrollpanel:Rebuild()
        end)
    end
    additembutton.DoClick = function(s)
        AddItem(s, Items)
    end

    for k, v in ipairs(data.items) do
        local tbl = {
            itemid = v.item,
            chance = v.chance,
        }
        table.Add(Items, {tbl})
        local int = #Items

        local panel = scrollpanel:Add("DPanel")
        panel:DockMargin(margin, margin, margin, 0)
        panel:Dock(TOP)
        panel:SetTall(30)
        panel.Paint = function(s, w, h)
            PIXEL.DrawRoundedBox(PIXEL.Scale(6), 0, 0, w, h, Color(32, 32, 37))
            PIXEL.DrawSimpleText(LUnbox.Config["Items"][tonumber(v.item)].name.." "..(LUnbox:CalculateChance(v.chance, Items)).."%", "LUnbox:22", 0 + margin, h/2, color_white, nil, TEXT_ALIGN_CENTER)
        end

        local deletebutton = panel:Add("PIXEL.ImgurButton", self)
        deletebutton:DockMargin(0, 5, 0, 5)
        deletebutton:Dock(RIGHT)
        deletebutton:SetImgurID("51ATKoY")
        deletebutton:SetNormalColor(PIXEL.Colors.PrimaryText)
        deletebutton:SetHoverColor(PIXEL.Colors.Negative)
        deletebutton:SetClickColor(PIXEL.Colors.Negative)
        deletebutton:SetDisabledColor(PIXEL.Colors.DisabledText)
        deletebutton.DoClick = function(s)
            table.remove(Items, int)
            panel:Remove()
        end

        timer.Simple(.1, function()
            scrollpanel:Rebuild()
        end)
    end
end

local PANEL = {}
function PANEL:Init()
    self.height, self.margin = PIXEL.Scale(30), PIXEL.Scale(6)
    self.CreateCrate = self:Add("PIXEL.TextButton")
    self.CreateCrate:DockMargin(self.margin, self.margin, self.margin, self.margin)
    self.CreateCrate:Dock(BOTTOM)
    self.CreateCrate:SetText("Create Crate")
    self.CreateCrate.DoClick = function(s)
        CreateCrate(s)
    end

    self.ScrollPanel = self:Add("PIXEL.ScrollPanel")
    self.ScrollPanel:Dock(FILL)

    self.tbl = {}
    for k, v in ipairs(LUnbox.Config["Crates"]) do
        self.tbl[k] = self:AddCrate(v, k)
    end

    hook.Add("LUnbox:CrateDeleted", "LUnbox:Crates", function(int)
        if not IsValid(self) then return end
        for k, v in pairs(self.tbl) do
            v:Remove()
        end

        for k, v in ipairs(LUnbox.Config["Crates"]) do
            self.tbl[k] = self:AddCrate(v, k)
        end
    end)

    hook.Add("LUnbox:CrateCreated", "LUnbox:Created", function(int)
        self.tbl[int] = self:AddCrate(LUnbox.Config["Crates"][int], int)
        timer.Simple(.1, function()
            self.ScrollPanel:Rebuild()
        end)
    end)

    hook.Add("LUnbox:CreateEditted", "LUnbox:Editted", function(int)
        if not IsValid(self) then return end
        if not self.tbl[int] then return end
        self.tbl[int].data = LUnbox.Config["Crates"][int]
    end)
end

function PANEL:AddCrate(data, k)
    if not LUnbox.Config["Rarity"][data.rarity] then return end
    local crate = self.ScrollPanel:Add("DPanel")
    crate:DockMargin(self.margin, self.margin, self.margin, 0)
    crate:Dock(TOP)
    crate:SetTall(self.height)
    crate.data = data
    crate.Paint = function(s, w, h)
        PIXEL.DrawRoundedBox(self.margin, 0, 0, w, h, Color(32, 32, 37))
       
        local col = LUnbox.Config["Rarity"][s.data.rarity].col
        surface.SetDrawColor(col)
        surface.DrawRect(5, 5, h-10, h-10)
        PIXEL.DrawSimpleText(s.data.name, "LUnbox:22", self.margin*2 + h-10, h/2, color_white, nil, TEXT_ALIGN_CENTER)
    end

    local editbutton = crate:Add("PIXEL.ImgurButton", self)
    editbutton:DockMargin(0, 5, 0, 5)
    editbutton:Dock(RIGHT)
	editbutton:SetImgurID("hhnxDGH")
	editbutton:SetNormalColor(PIXEL.Colors.PrimaryText)
	editbutton:SetHoverColor(PIXEL.Colors.Negative)
	editbutton:SetClickColor(PIXEL.Colors.Negative)
	editbutton:SetDisabledColor(PIXEL.Colors.DisabledText)
	editbutton.DoClick = function(s)
        EditCrate(k, s, crate.data)
    end

    local deletebutton = crate:Add("PIXEL.ImgurButton", self)
    deletebutton:DockMargin(0, 5, 0, 5)
    deletebutton:Dock(RIGHT)
	deletebutton:SetImgurID("51ATKoY")
	deletebutton:SetNormalColor(PIXEL.Colors.PrimaryText)
	deletebutton:SetHoverColor(PIXEL.Colors.Negative)
	deletebutton:SetClickColor(PIXEL.Colors.Negative)
	deletebutton:SetDisabledColor(PIXEL.Colors.DisabledText)
	deletebutton.DoClick = function(s)
        net.Start("LUnbox:DeleteCrate")
        net.WriteUInt(k, 32)
        net.SendToServer()
    end
    return crate
end
vgui.Register("LUnbox:Crates", PANEL, "EditablePanel")