local PANEL = {}
function PANEL:Init()
    self.padding, self.margin = PIXEL.Scale(12), PIXEL.Scale(6)
    self.Box = self:Add("DPanel")
    self.Box:DockMargin(self.padding, self.padding, self.padding, self.padding)
    self.Box:Dock(TOP)
    self.Box.Paint = function(s, w, h)
        if not self.data then return end
        PIXEL.DrawImgur((w/2)-(h/2), 0, h, h, self.data.imgur, color_white)
    end

    self.ScrollPanel = self:Add("PIXEL.ScrollPanel")
    self.ScrollPanel:Dock(FILL)
    self.ScrollPanel:DockMargin(self.padding, self.padding, self.padding, self.padding)

    self.Panels = {}
    self.Items = self.ScrollPanel:Add("DIconLayout")
    self.Items:Dock(FILL)
    self.Items:SetSpaceX(self.margin)
    self.Items:SetSpaceY(self.margin)
end

function PANEL:SetData(data)
    self.data = data

    for k, v in ipairs(data.items) do
        local item = LUnbox.Config["Items"][tonumber(v.item)]

        local panel = self.Items:Add("DPanel")
        panel.Paint = function(s, w, h)
            local rardat = LUnbox.Config["Rarity"][tonumber(item.rarity)]
            col = rardat.col
            surface.SetDrawColor(col)
            surface.DrawRect(0, 0, w, 3)
            surface.DrawRect(0, 0, 3, h)
            surface.DrawRect(0, h-3, w, 3)
            surface.DrawRect(w-3, 0, 3, h)

            PIXEL.DrawSimpleText(item.name or "N/A", "LUnbox:22", w/2, h*.3, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            PIXEL.DrawSimpleText(rardat.name or "N/A", "LUnbox:22", w/2, h*.45, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            PIXEL.DrawSimpleText((v.chance or "N/A").."%", "LUnbox:22", w/2, h*.7, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        table.insert(self.Panels, panel)
    end
end

function PANEL:PerformLayout(w, h)
    if IsValid(self.Box) then self.Box:SetTall(h*.4) end

    local perRow = 5
    w = (w - ((perRow) * self.margin)) / perRow
    for k, v in ipairs(self.Panels) do
        v:SetSize(w, w)
    end
end
vgui.Register("LUnbox:ViewItem", PANEL, "EditablePanel")