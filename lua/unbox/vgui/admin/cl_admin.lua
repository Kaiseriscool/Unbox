local PANEL = {}
function PANEL:Init()
    self.height, self.margin = PIXEL.Scale(30), PIXEL.Scale(6)
    self.Sidebar = self:Add("PIXEL.Sidebar")
    self.Sidebar:Dock(LEFT)
    self.Sidebar:AddItem("Rarities", "Rarities", "1BbnIvQ", function() self:ChangeTab("LUnbox:Rarities") end)
    self.Sidebar:AddItem("Items", "Items", "WM4snIs", function() self:ChangeTab("LUnbox:Items") end)
--    self.Sidebar:AddItem("Keys", "Keys", "aXamXre", function() self:ChangeTab("LUnbox:Keys") end)
    self.Sidebar:AddItem("Crates", "Crates", "GpaOHJY", function() self:ChangeTab("LUnbox:Crates") end)
    self.Sidebar:SelectItem("Rarities")
end

function PANEL:ChangeTab(pnl)
    if IsValid(self.ContentPanel) then self.ContentPanel:Remove() end
    self.ContentPanel = self:Add(pnl)
    self.ContentPanel:Dock(FILL)
end

function PANEL:PerformLayout(w, h)
    self.Sidebar:SetWide(w*.2)
end
vgui.Register("LUnbox:Admin", PANEL, "EditablePanel")