local PANEL = {}
function PANEL:Init()
    self.padding, self.margin = PIXEL.Scale(12), PIXEL.Scale(6)
    self:DockPadding(self.padding, self.padding, self.padding, self.padding)

/*
    self.Header = self:Add("DPanel")
    self.Header:DockPadding(self.margin, self.margin, self.margin, self.margin)
    self.Header:DockMargin(0, 0, 0, self.padding)
    self.Header:Dock(TOP)
    self.Header.Paint = function(s, w, h)
        PIXEL.DrawRoundedBox(6, 0, 0, w, h, Color(35, 35, 40))
    end
    self.Header.PerformLayout = function(s, w, h)
        s.Search:SetWide(200)
        s.Combo:SetWide(150)
    end

    self.Header.Search = self.Header:Add("PIXEL.TextEntry")
    self.Header.Search:Dock(LEFT)
    self.Header.Search:SetPlaceholderText("Yo")

    self.Header.Combo = self.Header:Add("PIXEL.ComboBox")
    self.Header.Combo:DockMargin(self.margin, 0, 0, 0)
    self.Header.Combo:Dock(LEFT)
    self.Header.Combo:SetSizeToText(false)
    self.Header.Combo:ChooseOption("All")
    self.Header.Combo:AddChoice("Crates")
    self.Header.Combo:AddChoice("Items")
    self.Header.Combo:AddChoice("Keys")
    self.Header.Combo:AddChoice("All")
*/
    self.ScrollPanel = self:Add("PIXEL.ScrollPanel")
    self.ScrollPanel:Dock(FILL)

    self.Crates = {}
    self.Grid = self.ScrollPanel:Add("DIconLayout")
    self.Grid:Dock(FILL)
    self.Grid:SetSpaceX(self.margin)
    self.Grid:SetSpaceY(self.margin)
    self:Setup("")

    hook.Add("LUnbox:CrateDeleted", "LUnbox:RefreshShop", function()
        if IsValid(self) then
            LUnbox:OpenMenu()
        end
    end)

    hook.Add("LUnbox:CrateCreated", "LUnbox:CrateCreatedShop", function()
        if IsValid(self) then
            LUnbox:OpenMenu()
        end
    end)

    hook.Add("LUnbox:CreateEditted", "LUnbox:CreateEdittedShop", function(int)
        if not IsValid(self) then return end
        self:Setup("")
    end)
end

function PANEL:Clear()
    for k, v in ipairs(self.Crates) do
        v:Remove()
    end
end

function PANEL:Setup(search)
    self:Clear()
    for k, v in ipairs(LUnbox.Config["Crates"]) do
        self:AddCrate(k, v)
    end

    self.Grid:SizeToContents()
    self:InvalidateLayout()
end

function PANEL:AddCrate(k, data)
    local crate = self.Grid:Add("DPanel")
    crate:DockPadding(self.margin, self.margin, self.margin, self.margin)
    crate.Paint = function(s, w, h)
        PIXEL.DrawRoundedBox(self.margin, 0, 0, w, h, Color(35, 35, 40))
        PIXEL.DrawImgur(w * .25, h * .1, w * .5, w * .5, data.imgur, color_white)
        PIXEL.DrawSimpleText(data.name, "LUnbox:22", w/2, h*.63, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        PIXEL.DrawSimpleText(LUnbox.Config["Rarity"][data.rarity].name, "LUnbox:22", w/2, h*.70, LUnbox.Config["Rarity"][data.rarity].col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    crate.PerformLayout = function(s, w, h)
        if IsValid(crate.Preview) then
            local size = PIXEL.Scale(20)

            s.Preview:SetSize(size, size)
            s.Preview:SetPos(w - self.margin - size, self.margin)
        end
    end

    crate.Preview = crate:Add("PIXEL.ImgurButton")
    crate.Preview:SetImgurID("HNnJjiF")
    crate.Preview.DoClick = function(s)
        local itemview = vgui.Create("LUnbox:Frame")
        itemview:SetSize(700, 600)
        itemview:SetTitle(data.name)
        itemview:Center()
        itemview:MakePopup()
        itemview.Think = function(se)
            if not IsValid(s) then se:Remove() end
        end

        local panel = itemview:Add("LUnbox:ViewItem")
        panel:Dock(FILL)
        panel:SetData(data)
    end

    local Buttons = crate:Add("DPanel")
    Buttons:Dock(BOTTOM)
    Buttons:SetTall(PIXEL.Scale(40))
    Buttons.Paint = nil
    Buttons.PerformLayout = function(s, w, h)
        w = (w - self.margin) / 2
        if IsValid(s.Money) then s.Money:SetWide(w) end
        if IsValid(s.Tokens) then s.Tokens:SetWide(w) end
    end

    Buttons.Money = Buttons:Add("PIXEL.TextButton")
    Buttons.Money:Dock(LEFT)
    Buttons.Money:SetText(DarkRP.formatMoney(data.price))
    Buttons.Money.DoClick = function()
        net.Start("LUnbox:PurchaseCrate")
        net.WriteUInt(1, 2)
        net.WriteUInt(k, 32)
        net.SendToServer()
    end

    Buttons.Tokens = Buttons:Add("PIXEL.TextButton")
    Buttons.Tokens:Dock(RIGHT)
    Buttons.Tokens:SetText(string.Comma(data.price/LUnbox.PricePerToken).." Tokens")
    Buttons.Tokens.DoClick = function()
        net.Start("LUnbox:PurchaseCrate")
        net.WriteUInt(2, 2)
        net.WriteUInt(k, 32)
        net.SendToServer()
    end
    table.insert(self.Crates, crate)
end

function PANEL:PerformLayout(w, h)
    --self.Header:SetTall(PIXEL.Scale(50))

    local perRow = 4
    local pnlW, pnlH = (self.Grid:GetWide() - ((perRow - 1) * self.margin)) / perRow, PIXEL.Scale(275)

    for k, v in ipairs(self.Crates) do
        v:SetSize(pnlW, pnlH)
    end
end
vgui.Register("LUnbox:Shop", PANEL, "EditablePanel")